# Docker image: for aer-2023-0700 with Gurobi, Mosek, R, Python, and Stata installation

All files needed to build this image are available at [AEADataEditor/docker-aer-2023-0700](https://github.com/AEADataEditor/docker-aer-2023-0700).

## Purpose

This Docker image is meant to isolate and stabilize the primary environment used for the analysis in AER-2023-0700. It does not cover all software packages (MATLAB is missing), and it is not optimized for compute speed, only for portability.

## Requirements to run

- Docker
- Access to Docker Hub
- Gurobi license (see [https://license.gurobi.com/manager/doc/overview](https://license.gurobi.com/manager/doc/overview) for details on how to obtain a license)
- Mosek license
- Stata license


## Using the image

### Setup info

Set the `TAG` and `IMAGEID` accordingly.

```
TAG=2024-03-30
MYIMG=aer-2023-0700
MYHUBID=aeadataeditor
```

Default parameters are encoded in `config.sh`, which is called by all utility scripts.

### Running the image 

If using a pre-built image on [Docker Hub](https://hub.docker.com/repository/docker/aeadataeditor/), 

```
docker run -it --rm $MYHUBID/${MYIMG}:$TAG
```

will initialize the standard start-up script, which launches Rstudio server. That, however, will not be enough

### Running Rstudio

You will need all licenses available, and can then use `start_rstudio.sh` to use Rstudio interactively. By default, Rstudio will run at [https://localhost:8787](https://localhost:8787), without a password.

```
bash ./start_rstudio.sh
```

or optionally

```
bash ./start_rstudio.sh (TAG)
```

to run with a tag that is different from the default encoded one.

### Running scripts at the command line

You will need all licenses available, and can then use `run_docker.sh` to obtain a shell. 

```
bash ./run_docker.sh
```

or optionally

```
bash ./run_docker.sh (TAG)
```

to run with a tag that is different from the default encoded one.


```
bash ./run_docker.sh (TAG) (COMMAND)
```

is also possible.

## Build

### Source

See [`Dockerfile`](Dockerfile) for the image build instructions. At this time, the image uses

- [rocker](https://hub.docker.com/r/rocker/) images as base images
- [stata](https://hub.docker.com/r/dataeditors/) image for Stata provided the Social Science Data Editors
- [Gurobi](https://packages.gurobi.com/) tar files provided by Gurobi
- [Mosek](https://www.mosek.com/) tar files provided by Mosek
- Python installed from Ubuntu repositories

### Packages

- [`requirements.txt`](requirements.txt) lists Python packages to be installed
- [`setup.R`](setup.R) lists R packages to be installed
- No Stata packages are installed at build time.

### Build

To build the image, use

```
bash ./build.sh (TAG)
```

You will need to manually push the image after it is built. The appropriate command line is printed out at the end of the build process.

