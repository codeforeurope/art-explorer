# Dockerisation

    $ docker run -d -p 9200:9200 --name elasticsearch orchardup/elasticsearch
    $ docker build -t=asacalow/mag-api .

# Import the data

    $ docker run -v /root/api/public/assets/images --name images busybox
    $ docker run --link elasticsearch:elasticsearch --volumes-from images -v /path/to/data/folder:/data asacalow/mag-api bundle exec rake data:import[/data]

# Now fire up the service

    $ docker run -d --link elasticsearch:elasticsearch  --volumes-from images -p 80:80 --name api asacalow/mag-api

(Run it on the box like this:)

sudo nohup docker run --link elasticsearch:elasticsearch --volumes-from images -v /home/emu:/data asacalow/mag-api bundle exec rake data:import[/data] &
