[Klee](http://klee.github.io/) is a symbolic virtual machine built on top of llvm compiler infrastructure.

Docker image is built on Ubuntu 14.04 image, stable version ok Klee uses llvm version 2.9, experimental version of Klee uses llvm version 3.4. You need to be root to build images or running containers.
The following command creates a image named `klee`

`docker build --rm -t klee .`

Klee is built in `/home` directory of the image. Once the Docker image is built you can start a container running Klee using 

`docker run -i -t klee /bin/bash`

It will create a container from the `Klee` image and open a bash terminal to the running container. If you want to share any directory of your host system you can use `-v` flag to specify the path in the host and where to mount on the container.

`docker run -i -t -v /path/in/host:/path/in/container klee /bin/bash`

For getting help on Docker containers, see Docker documentation. 
