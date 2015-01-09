[Klee](http://klee.github.io/) is a symbolic virtual machine built on top of llvm compiler infrastructure.

Docker container is built on Ubuntu 14.04 image, uses experimental version of Klee for llvm version 3.4.

`docker build --rm -t klee .`

Klee is built in `/home` directory. Once the docker image is built you can start a container running Klee using 

`docker run -i -t klee /bin/bash`

It will open a bash terminal to the running container. If you want to exist any directory on your host system you can use `-v` flag to specify the path and where to mount on the container.

`docker run -i -t -v /path/in/host:/path/in/container klee /bin/bash`

For getting help on containers, see docker documentation. 
