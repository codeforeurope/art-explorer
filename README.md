# Manchester Art Gallery: A collection explorer

## Introduction

Welcome to the Github repo for Manchester Art Gallery's art collection explorer, the official open data API for Manchester Art Gallery, created during [my](http://github.com/asacalow) time as a [European Code Fellow](http://codeforeurope.net), with [Manchester Art Gallery](http://manchestergalleries.org) and the [Manchester Digital Development Agency](http://manchesterdda.com).

## Ingredients

You will need:

  * The code in this repo
  * Some data (A KE Emu XML dump of the gallery collection – however, it is easily customisable to work with any data dump, see below)
  * A computer running a recent version of Ruby (1.9.3+), Rubygem and Bundler.
  * A running local instance of [Elasticsearch](http://elasticsearch.org).

## Setting up an instance

    $ cd the/app/directory
    $ bundle
    $ cp config/elasticsearch.yml.example config/elasticsearch.yml
    $ bundle exec rake data:import[./spec/support] # <-- or.. a folder containing a zip of images and a data.xml file in the appropriate format

… profit!

## Running an instance

The Collection Explorer is a Sinatra app and comes bundled with a Rackup file so you can run it using your preferred method of deploying Rack applications (for development, mine is [Pow](http://pow.cx)). If you would rather just get up and running, you can run the Sinatra service via unicorn:

    $ bundle exec unicorn

## Using the API

The app is a paper-thin layer on top of Elasticsearch which does nothing more than provide a (barely) customised search interface, returning results as JSON. For full, official API documentation check http://github.com/codeforeurope/art-explorer-docs.

## Customising the collection explorer

This app is so basic that it could easily be re-used for any number of purposes. Got an XML dump full of things you want to make searchable? Go right ahead!

1. To change the field definitions, as stored in Elasticsearch, modify the CollectionItem model.
2. To change how your XML is imported, modify the field mappings and implementation of is_item_node? in collection_data.rb.
3. Check the rakefile for how the importer is implemented, and modify/remove the image processor accordingly.

## License

This project is released under an MIT Licence (see LICENSE).
