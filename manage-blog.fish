#!/usr/local/bin/fish

function showHelp
    string trim '
This script manage the lorentzca/blog.lorentzca.me Docker image.
================================================================

h help: Show this help.
  arguments: <required> [option]

r run [tag]: Run blog http://localhost:2368/.
  e.g.:
    $ ./manage-blog r v0.0.9-202004182344
    $ ./manage-blog r
  default tag: latest

c commit <any message> [version]: Commit blog image. Create specified version-date tag and latest tag.
  e.g.:
    $ ./manage-blog c "any message" v0.0.9
  default version: running blog container image version.

p push <tag>: Push iamge. Push specified tag and latest tag.
  e.g.:
    $ ./manage-blog p v0.0.9-202004182344
    $ ./manage-blog p
  default: Show tags. No push is done.

t tags: Show blog tags.
  e.g.:
    $ ./manage-blog t
    '
end

function runBlogContainer -d "Run blog container"
    if not set -q $argv[1]
        set tag $argv[1]
    else if set -q $argv[1]
        set tag latest
    else
        showHelp
        return 1
    end
    
    command docker run \
        --name blog \
        --privileged \
        -d \
        -p 2368:2368 \
        -e url=http://localhost:2368/ \
        lorentzca/blog.lorentzca.me:$tag
end

function commitBlog -d "Commit blog"
    if not set -q $argv[1]
        set message $argv[1]
    else if set -q $argv[1]
        echo Message is required!
        echo 
        showHelp
        return 1
    else
        showHelp
        return 1
    end

    if not set -q $argv[2]
        set blogversion $argv[2]
    else if set -q $argv[2]
        set blogversion (docker ps \
            --filter name=blog \
            --format "{{.Image}}" \
            | cut -d':' -f2 \
            | cut -d '-' -f1)
    else
        showHelp
        return 1
    end

    # Commit specfy version tag.
    command docker commit \
        -m "\"$message\"" \
        (docker ps -q --filter "name=/blog\$") \
        lorentzca/blog.lorentzca.me:$blogversion-(date +%Y%m%d%H%M)

    # Commit latest tag.
    command docker commit \
        -m "\"$message\"" \
        (docker ps -q --filter "name=/blog\$") \
        lorentzca/blog.lorentzca.me:latest
end

function pushBlog -d "Push blog to Docker Hub"
    if not set -q $argv[1]
        set tag $argv[1]
        # Push specfy tag.
        command docker push lorentzca/blog.lorentzca.me:$tag
        # Push latest tag.
        command docker push lorentzca/blog.lorentzca.me:latest
    else
        # Show blog image tags.
        tags
    end
end

function tags -d "Show blog tags"
    command docker images lorentzca/blog.lorentzca.me --format {{.Tag}}
end

function manageBlog -d "Manage blog"
    switch $argv[1]
        case h help
            showHelp
            return
        case r run
            runBlogContainer $argv[2]
            return

        case c commit
            commitBlog $argv[2] $argv[3]
            return

        case p push
            pushBlog $argv[2]
            return

        case t tags
            tags
            return

        case '*'
            showHelp
            return
    end
end

manageBlog $argv
