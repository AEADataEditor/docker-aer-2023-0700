ARG R_VERSION=4.3.2
FROM rocker/verse:${R_VERSION}

COPY setup.R .
RUN Rscript setup.R

# Install gurobi
# This could be overridden when building 
ARG GRB_VERSION=10.0.0
ARG GRB_SHORT_VERSION=10.0
ARG PYTHON_VERSION=3.11 

# based on https://github.com/Gurobi/docker-optimizer/blob/master/9.1.2/Dockerfile
WORKDIR /opt

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binfmt-support \
        ca-certificates \
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
COPY gurobi.lic /opt/gurobi/gurobi.lic

# now install the R package

ENV GUROBI_HOME /opt/gurobi/linux64
ENV PATH "$PATH:$GUROBI_HOME/bin"
ENV LD_LIBRARY_PATH $GUROBI_HOME/lib 

#RUN Rscript -e 'install.packages("/opt/gurobi/linux64/R/gurobi_${GRB_SHORT_VERSION}_R_$R_VERSION.tar.gz",repos = NULL)'

WORKDIR /code
