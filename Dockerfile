ARG R_VERSION=4.3.2
FROM rocker/verse:${R_VERSION}

# Parameters
# This could be overridden when building 
ARG GRB_VERSION=10.0.0
ARG GRB_SHORT_VERSION=10.0
ARG PYTHON_VERSION=3.11 

ENV MOSEKLM_LICENSE_FILE=/opt/mosek/mosek.lic
ARG MOSEK_VERSION=10.1.28
ARG MOSEK_SHORT_VERSION=10.1
ENV RMOSEKDIR=/opt/mosek/${MOSEK_SHORT_VERSION}/tools/platform/linux64x86/rmosek


LABEL name="Reproducibility stack for AER-2023-0700" maintainer="dataeditor@aeapubs.org"
LABEL description="Docker image for the reproducibility stack for AER-2023-0700"
LABEL doi="10.1257/aer.20230700"


# ================== Install gurobi =====================

# based on https://github.com/Gurobi/docker-optimizer/blob/master/9.1.2/Dockerfile
WORKDIR /opt

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binfmt-support \
        ca-certificates \
        bzip2 \
        libpython${PYTHON_VERSION}-stdlib \
        python${PYTHON_VERSION} \
        python3-pip \
        python${PYTHON_VERSION}-minimal \
        python${PYTHON_VERSION}-venv  \
        python${PYTHON_VERSION}-dev \
        wget \
    && update-ca-certificates \
    && wget -v https://packages.gurobi.com/${GRB_SHORT_VERSION}/gurobi${GRB_VERSION}_linux64.tar.gz \
    && tar -xvf gurobi${GRB_VERSION}_linux64.tar.gz  \
    && rm -f gurobi${GRB_VERSION}_linux64.tar.gz \
    && mv -f gurobi* gurobi \
    && rm -rf gurobi/linux64/docs

# Install Python packages
# Python3.11 does not have pip in the Ubuntu repos, so we bootstrap it

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11
COPY requirements.txt .
RUN pip${PYTHON_VERSION}  install -r /opt/requirements.txt

#run the setup

WORKDIR /opt/gurobi/linux64
# RUN python${PYTHON_VERSION} setup.py install
# For versions later than 10.0.0, this should work faster:
RUN pip${PYTHON_VERSION}  install gurobipy==${GRB_VERSION}

# Add the license key
# Visit https://license.gurobi.com/manager/doc/overview for more information.
# You will need to provide your own.
# by passing it in during runtime: -v gurobi.lic:/opt/gurobi/gurobi.lic
# 
# If building a private image, uncomment this line
# COPY gurobi.lic /opt/gurobi/gurobi.lic

# now install the R package

ENV GUROBI_HOME /opt/gurobi/linux64
ENV PATH "$PATH:$GUROBI_HOME/bin"
ENV LD_LIBRARY_PATH $GUROBI_HOME/lib 

# For this particular image, we don't need the R packages, as Gurobi is only used in Python
#RUN Rscript -e 'install.packages("/opt/gurobi/linux64/R/gurobi_${GRB_SHORT_VERSION}_R_$R_VERSION.tar.gz",repos = NULL)'

## ===================== Install MOSEK =====================

WORKDIR /opt
RUN wget -v https://download.mosek.com/stable/${MOSEK_VERSION}/mosektoolslinux64x86.tar.bz2 \
    && tar -xvf mosektoolslinux64x86.tar.bz2 \
    && rm -f mosektoolslinux64x86.tar.bz2 \
    && rm -rf /opt/mosek/docs

# Users should copy their license file into the Docker container
# by passing it in during runtime: -v mosek.lic:/opt/mosek/mosek.lic
# Testing:
# /opt/mosek/10.1/tools/platform/linux64x86/bin/msktestlic
# should end with
# 
# ************************************
# A license was checked out correctly.
# ************************************

# If building a private image, uncomment this line
# COPY mosek.lic /opt/mosek/mosek.lic


## ================= Complete setup by installing R packages =====================

WORKDIR /opt
COPY setup.R .
RUN R CMD BATCH setup.R 

WORKDIR /code
