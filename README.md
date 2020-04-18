https://github.com/docker-library/ghost/tree/master/2/alpine

## Usage
Build image.

```
$ docker build . -t lorentzca/stateful-ghost-3.13.3
```

## Migrate from existing image to new image
Copy stateful contents from existing image.

```
$ docker run --privileged -d -p 2368:2368 -e url=http://localhost:2368/ lorentzca/blog.lorentzca.me:v0.0.8-202004181630
$ docker cp (docker ps -q):/var/lib/ghost/content/images /tmp/

# Access http://localhost:2368/ghost and export blog.

$ docker stop (docker ps -q)
```

Copy contents to new iamge.

```
$ docker run --privileged -d -p 2368:2368 -e url=http://localhost:2368/ lorentzca/stateful-ghost-3.13.3
$ docker cp /tmp/images/ (docker ps -q):/var/lib/ghost/content/
$ docker exec -i -t (docker ps -q) chown -R node:node /var/lib/ghost/content/images

# Access http://localhost:2368/ghost and import the exported blog.
```

Commit new version.

```
$ docker commit -m 'Update to Ghost version 3!' (docker ps -q) lorentzca/blog.lorentzca.me:v0.0.9

$ docker stop (docker ps -q)
```

Push new image.

```
$ docker push lorentzca/blog.lorentzca.me:v0.0.9
```
