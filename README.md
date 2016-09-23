A simple dockerised tool for generating Jekyll sites and applying the developer network styles for publication into the developer network.

First, build the container:

```
docker build --no-cache -t nhsd/jekyllpublish generate/.
```

And use your docker image to generate the pages intoa target path (in this case ~/gpconnect):

```
rm -Rf /tmp/site
mkdir /tmp/site
chmod 777 /tmp/site
docker run --net=host -v /tmp/site:/output nhsd/jekyllpublish sh -c '/generate.sh https://github.com/nhsconnect/gpconnect.git http://localhost/apis/'
```

Now, build an nginx container to serve up the pages
```
mv /tmp/site nginx/site
docker build --no-cache -t nhsd/nginx-gpconnect nginx/.
```

And start it:
```
docker run --name nginx-gpconnect -d -p 8091:80 nhsd/nginx-gpconnect
```
