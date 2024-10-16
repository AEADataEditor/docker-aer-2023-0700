# Docker image for aer-2023-0700 with Gurobi, Mosek, R, Python, and Stata installation

All files needed to build this image are available at [AEADataEditor/docker-aer-2023-0700](https://github.com/AEADataEditor/docker-aer-2023-0700).

## Purpose

This Docker image is meant to isolate and stabilize the primary environment used for the analysis in AER-2023-0700. It does not cover all software packages (MATLAB is missing), and it is not optimized for compute speed, only for portability.

## Requirements to run

- Docker
- Access to Docker Hub
- Gurobi license (see [https://license.gurobi.com/manager/doc/overview](https://license.gurobi.com/manager/doc/overview) for details on how to obtain a license)
  - We used a "Temporary Academic" license for container/machine deployment. The license is limited to 2 simultaneous sessions, but can expand up to 5 sessions for up to 5 minutes (this is a limitation for part of the analysis)
- Mosek license (see [https://www.mosek.com/products/academic-licenses/](https://www.mosek.com/products/academic-licenses/)). We requested a "personal academic license". 
- Stata license
  - If you already own a copy of Stata, you can use the `stata.lic` file from your installation.
- Some of the scripts in the replication package require a job scheduler to run up to 100 parallel jobs. The authors and we used SLURM. 

Copy all three license files into the current directory. The `run_docker.sh` script will look for the licenses in whatever directory it is called from.

```
> ls -l *.lic
-rw-r--r-- 1 user users  326 Apr 28 15:23 gurobi.lic
-rw-r--r-- 1 user users 1029 Mar 20 10:18 mosek.lic
-rw-r--r-- 1 user users  128 Apr 28 15:25 stata.lic
```


## Using the image

### Setup info

Set the `tag` and `repo` accordingly.

```
tag=2024-03-30
repo=aer-2023-0700
space=aeadataeditor
```

Default parameters are encoded in `config.sh`, which is called by all utility scripts.

```bash
source config.sh
```

### Obtaining the image

#### Docker Hub

If using a pre-built image on [Docker Hub](https://hub.docker.com/r/aeadataeditor/aer-2023-0700), 

```
docker pull ${space}/${repo}:${tag}
```

#### If using Zenodo 

The image was preserved on Zenodo at [10.5281/zenodo.11080918](https://doi.org/10.5281/zenodo.11080918), and can be obtained from there. 

```
wget https://zenodo.org/record/11080918/files/${repo}-save.${tag}.tar
docker load -i ${repo}-save.${tag}.tar
```


### Running the image 

Basic run of the image is possible with

```
docker run -it --rm ${space}/${repo}:${tag}
```

will run the base image (default entry point is to run Rstudio). However, it will not have access to the licensed software.


### Running scripts at the command line

You will need all licenses available, and can then use [`run_docker.sh`](run_docker.sh) to obtain a shell. 

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

## Specific details

The [replication package for AER-2023-0700](https://doi.org/10.3886/E198284V1) has 8 scripts that each runs a part of the replication analysis.

| Script | Run in Docker? | Number of jobs | Software used | Notes |
| --- | --- | --- | --- | --- |
| `execute-part1.sh` | Yes | 1 | Python, R, Mosek, Gurobi, Stata | We commented out modules and Python environment initialization, as all modules and Python packages are installed in the Docker image |
| `execute-part2.sh` | No | 1 | MATLAB, R | Base R is needed, but no additional packages. MATLAB uses parallel processing up to the number of physical cores, or the limits of the license, whichever is lower. |
| `execute-part3.sh` | Yes | 1 | R, Stata, Mosek |  |
| `execute-part4.sh` | Yes | 100 | Python, Gurobi | We ran Docker within SLURM, limiting the number of parallel jobs to 2 (due to Gurobi licensing) |
| `execute-part5.sh` | Yes | 1 | Python, Stata |  |

Parts 6-8 were not run as part of the reproducibility checks, as they are MCMC runs that require additional adaptations to work in a particular computing environment. The container provided here is not optimized for speed (primarily due to Gurobi licensing restrictions), and the MCMC would have taken too long to run.



### Running Rstudio

You can also run the Rstudio interface. You will need all licenses available, and can then use `start_rstudio.sh` to use Rstudio and/or terminal interactively. By default, Rstudio will run at [https://localhost:8787](https://localhost:8787), without a password.

```
bash ./start_rstudio.sh
```

or optionally

```
bash ./start_rstudio.sh (TAG)
```

to run with a Docker hub tag that is different from the default encoded one.

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

### Exporting image

To export the image, use

```
source config.sh
docker save -o ${repo}-save.${tag}.tar ${space}/${repo}:${tag}
```

## License

All binary components remain copyright by their respective owners (Mosek, Gurobi, Stata, R, Python). The Dockerfile and scripts are released under the BSD license.


