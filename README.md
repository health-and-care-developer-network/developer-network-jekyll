A simple dockerised tool for generating Jekyll sites and applying the developer network styles for publication into the developer network.

First, build the container:

```
./buildCompiler.sh
```

Now, create a directory to hold your html content:

```
mkdir -p /docker-data/jekyll-generated-pages
chown -R 1000:1000 /docker-data/jekyll-generated-pages
```

Note: If you are using user namespacing in your docker daemon (recommended on live systems), then the user id above will differ.

Now, use your docker image to generate the pages into a target path which can be served up using nginx (or any other web server):

```
./compilePages.sh "" https://github.com/nhsconnect/gpconnect.git http://developer-test.nhs.uk/apis GPConnect apis/gpconnect
```

Note: The above steps assume we are not using a private registry, and that we are interacting with the local docker daemon. Additional parameters can be used for a private registry and remote docker daemons (via the ReST API).

Now, build an nginx container to serve up the pages
```
./deploy-nginx.sh
```

Now you should be able to open the pages in your browser: http://localhost:8081/apis/gpconnect/

