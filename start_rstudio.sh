#!/bin/bash

if [[ "$1" == "-h" ]]
then
cat << EOF
$0 (tag)

will start interactive environment for tag (TAG)
EOF
exit 0
fi

PWD=$(pwd)
. $(dirname $0)/config.sh
tag=${1:-$tag}

case $USER in
  *vilhuber|*herbert)
  WORKSPACE=$PWD
  ;;
  codespace)
  WORKSPACE=/workspaces
  ;;
esac
  

# try to pull the image

docker pull $space/$repo:$tag

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


docker run -e DISABLE_AUTH=true -v "$WORKSPACE":/home/rstudio $OPTIONS \
    --rm -p 8787:8787 \
    $space/$repo:$tag
