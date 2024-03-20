#!/bin/bash

if [[ "$1" == "-h" ]]
then
cat << EOF
$0 (tag) (command)

will start interactive shell for tag  if command empty

or

will run with the command provided 
EOF
exit 0
fi

PWD=$(pwd)
. $(dirname $0)/config.sh
shift

# docker binary

if [[ "${HOSTNAME:0:4}" == "cbsu" ]]
then
  echo "Running on CBSU"
  DOCKER=docker1
else
  echo "Running on non-CBSU"
  DOCKER=docker
fi


case $USER in
  *vilhuber)
  WORKSPACE=$PWD
  ;;
  codespace)
  WORKSPACE=/workspaces
  ;;
esac
  
# try to pull the image

$DOCKER pull $space/$repo:$tag

# Licenses: this particular image wants two licenses:
# - gurobi.lic
# - mosek.lic
#
# These are expected to be in the current directory, and will be mounted into the container

GUROBILIC=$PWD/gurobi.lic
MOSEKLIC=$PWD/mosek.lic
STATALIC=$PWD/stata.lic

if [[ -f $GUROBILIC ]]
then
  echo "Found gurobi license"
  OPTIONS="-v $GUROBILIC:/opt/gurobi/gurobi.lic $OPTIONS"
else
  echo "No gurobi license found"
fi

if [[ -f $MOSEKLIC ]]
then
  echo "Found mosek license"
  OPTIONS="-v $MOSEKLIC:/opt/mosek/mosek.lic $OPTIONS"
else
  echo "No mosek license found"
fi

if [[ -f $STATALIC ]]
then
  echo "Found stata license"
  OPTIONS="-v $STATALIC:/usr/local/stata/stata.lic $OPTIONS"
else
  echo "No stata license found"
fi

OPTIONS="-it --rm --entrypoint /bin/bash -w /home/rstudio $OPTIONS"
# OPTIONS="-e DISABLE_AUTH=true  --rm -p 8787:8787"

$DOCKER run -v "$WORKSPACE":/home/rstudio $OPTIONS $space/$repo:$tag $@
