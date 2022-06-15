https://github.com/docker-library/ghost/tree/master/5/alpine

## Create stateful Ghost image

### Build image

```
$ docker build . -t lorentzca/stateful-ghost-5.2.3
```

### Migrate from existing image to new image

Copy contents and setting from existing image.

```
$ ./manage-blog.fish run
$ docker cp (docker ps -q):/var/lib/ghost/content/images /tmp/

# Access http://localhost:2368/ghost and export blog.

$ docker stop (docker ps -q)
```

Copy contents to new iamge.

```
$ docker run --privileged -d -p 2368:2368 -e url=http://localhost:2368/ lorentzca/stateful-ghost-5.2.3
$ docker cp /tmp/images/ (docker ps -q):/var/lib/ghost/content/
$ docker exec -i -t (docker ps -q) chown -R node:node /var/lib/ghost/content/images

# Access http://localhost:2368/ghost and import the exported blog.
# If existing user is locked, it will be solved if you suspend and release it.
# In that case, you will also need to reset your password.
```

Commit new version.

```
$ command docker commit \
-m "Update to Ghost version 5.2.3!" \
(docker ps -q) \
lorentzca/blog.lorentzca.me:v0.0.13-(date +%Y%m%d%H%M)

$ docker stop (docker ps -q)
```

Push new image.

```
$ ./manage-blog.fish tags
$ ./manage-blog.fish push v0.0.13-yyyymmddHHMM
```

## Usage of the manage blog image script

`./manage-blog.fish help`
