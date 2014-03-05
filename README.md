# Manchester Art Gallery: A collection explorer

## Introduction

Welcome to the Github repo for Manchester Art Gallery's art collection explorer, a semi-official open data API created during [my](http://github.com/asacalow) time as a [European Code Fellow](http://codeforeurope.net), with [Manchester Art Gallery](http://manchestergalleries.org) and the [Manchester Digital Development Agency](http://manchesterdda.com).

You can at present find an instance of this application [here](http://ce.asacalow.me).

## Ingredients

You will need:

  * The code in this repo
  * Some data (A KE Emu XML dump of the gallery collection – however, it is easily customisable to work with any xml data dump, see below)
  * A computer running a recent version of Ruby (1.9.3+), Rubygem and Bundler.
  * A running local instance of [Elasticsearch](http://elasticsearch.org).
  * Some sticky tape

## Setting up an instance

    $ cd the/app/directory
    $ bundle
    $ cp config/tire.yml.example config/tire.yml
    $ cp all-data.min.xml all-data.xml // or copy your actual data dump file
    $ bundle exec rake data:import

… profit!

## Running an instance

The Collection Explorer is a Sinatra app and comes bundled with a Rackup file so you can run it using your preferred method of deploying Rack applications (for development, mine is [Pow](http://pow.cx)). If you would rather just get up and running, you can run the Sinatra service directly:

    $ ruby collection_explorer.rb

## Using the API

The app is a paper-thin layer on top of Elasticsearch which does nothing more than provide a (barely) customised search interface returning results as JSON e.g.

    $ curl localhost:4567/search?q=fullname:Goya
    {"total":92,"items":[{"accession_number":"1983.852","accession_summary":"","bibliography":"","collection_title":"","content_tags":[],"created_on":"1799","description":"A monkey is standing with a seated donkey and to other figures in the background. The monkey is seen in full frontal and while his face is in profile. He is looking up at the donkey and is holding a mandolin with its legs apart.  Facing the monkey is the seated donkey on its hind legs.  Behind the donkey on the right are the other two figures that seem to be laughing.","earliest_created_on":"1799","first_name":"Francisco","fullname":"Francisco Goya Y Lucientes","height":"32.0","inscription":"","irn":"103458","last_name":"Goya Y Lucientes","latest_created_on":"1799","media_irn":"5656","medium":"ink (black)","middle_name":"","object_name":"on paper, print","organisation":"","physical_type":"support","provenance":"","purchased":"","role":"Printmaker","series_title":"Los Caprichos","subject_tags":[],"suffix":"","support":"paper","tags":["fine art","on paper, print","foreign"],"title":"Brabisimo!","unit":"cm","width":"22.0"}, …

## Customising the collection explorer

This app is so basic that it could easily be re-used for any number of purposes. Got an XML dump full of things you want to make searchable? Go right ahead!

1. To change the field definitions, as stored in Elasticsearch, modify the CollectionItem model.
2. To change how your XML is imported, modify the field mappings and implementation of is_item_node? in collection_data.rb.

## License

This project is released under an MIT Licence. 