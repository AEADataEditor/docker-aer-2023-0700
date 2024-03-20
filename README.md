# Docker image basic R image with Gurobi installation

## Purpose

Many R replication packages have dependencies, which sometimes include the specific version of R (in particular before/after release of v4). In addition, R might interact with external programs. These are sometimes tricky to install.

This Docker image is meant to isolate and stabilize that environment, and in addition install Gurobi, an optimizer, as well as the associated R package. 

## Requirements

- Docker
- Access to Docker Hub
- Gurobi (downloaded as part of the script)
- Gurobi license - see
and should be portable across
multiple operating system, as long as [Docker](https://docker.com) is available.

## Build

### Source

This is based on [https://github.com/Gurobi/docker-optimizer/blob/master/9.1.2/Dockerfile](https://github.com/Gurobi/docker-optimizer/blob/master/9.1.2/Dockerfile) and uses the [rocker](https://hub.docker.com/u/rocker). base version.

### Adjust the needed packages

See the [setup.R](setup.R) file, and update accordingly.

> WARNING: not all packages might build, depending on whether the R base image has the relevant libraries. You might want to change R base image, or switch to another image from [rocker](https://hub.docker.com/u/rocker).

### Setup info

Set the `TAG` and `IMAGEID` accordingly.

```
TAG=v$(date +%F)
MYIMG=aer-2019-0221
MYHUBID=aeadataeditor
```
### Build the image

```bash
DOCKER_BUILDKIT=1 docker build . -t $MYHUBID/$MYIMG:$TAG
```

```
[+] Building 96.2s (15/15) FINISHED                                             
 => [internal] load build definition from Dockerfile                       0.0s
 => => transferring dockerfile: 1.55kB                                     0.0s
 => [internal] load .dockerignore                                          0.0s
 => => transferring context: 2B                                            0.0s
 => [internal] load metadata for docker.io/rocker/r-ver:4.0.1              0.0s
 => [ 1/10] FROM docker.io/rocker/r-ver:4.0.1                              0.0s
 => [internal] load build context                                          0.0s
 => => transferring context: 59B                                           0.0s
 => CACHED [ 2/10] COPY setup.R .                                          0.0s
 => CACHED [ 3/10] RUN Rscript setup.R                                     0.0s
 => [ 4/10] WORKDIR /opt                                                   0.0s
 => [ 5/10] RUN apt-get update     && apt-get install -y --no-install-re  93.6s
 => [ 6/10] WORKDIR /opt/gurobi/linux64                                    0.1s
 => [ 7/10] RUN python3.8 setup.py install                                 0.6s 
 => [ 8/10] COPY gurobi.lic /opt/gurobi/gurobi.lic                         0.0s 
 => [ 9/10] RUN Rscript -e 'install.packages("/opt/gurobi/linux64/R/gurob  0.8s 
 => [10/10] WORKDIR /code                                                  0.0s 
 => exporting to image                                                     0.9s 
 => => exporting layers                                                    0.9s
 => => writing image sha256:8d08a5d055d9d24e51840d64e464b1b456511c4e23fb9  0.0s
```
## Publish the image

The resulting docker image can be uploaded to [Docker Hub](https://hub.docker.com/), if desired.

```bash
docker push $MYHUBID/${MYIMG}:$TAG
```

However, you should be careful here, since you have embedded the license (if using the default setup)!

## Using the image

If using a pre-built image on [Docker Hub](https://hub.docker.com/repository/docker/larsvilhuber/), or if you tagged the image as above, locally,


```
docker run -it --rm $MYHUBID/${MYIMG}:$TAG
```

Somewhat more sophisticated, if you are in a project directory (for instance, the replication package you just downloaded), you can access it directly within the image as follows:

```
docker run -it --rm \
  -v $(pwd)/subdir:/code \
  -w /code $MYHUBID/${MYIMG}:$TAG
```

## Alternate license management

If you want to share the image, then you want to NOT include the license file. In that case, comment out or **remove** the line in [Dockerfile](Dockerfile):

```
COPY gurobi.lic /opt/gurobi/gurobi.lic
```
and then, when running the image, map a given license file into the image:

```
docker run -it --rm \
  -v gurobi.lic:/opt/gurobi/gurobi.lic \
  -v $(pwd)/subdir:/code \
  -w /code $MYHUBID/${MYIMG}:$TAG
```

You can now start to run code.

