#!/bin/sh


WORKDIR=$1
DATAPATH=$2

docker build docker -t py_general_docker && \
docker run --rm -it  -v $WORKDIR:/work -v $DATAPATH:/data -e USER=$USER -e HOME=/work -w /work  py_general_docker

# basic intereractive
# ./start.sh /data/mthuggin/tmp /data/mthuggin/eddy


# for jupyter lab follow these steps, rather than running the start.sh
#
# ssh mthuggin@elcapitan.csc.calpoly.edu
#
# Now on the server, got the proper directory and: 
# docker run --rm -it -p 8887:8888 -v /data/mthuggin/tmp:/work -v /data/mthuggin/eddy:/data  --name py_data_science jupyter/datascience-notebook:ubuntu-20.04 bash
#
# Now in the container:
# jupyter lab --no-browser --port 8888
#
# There will be a url like:
# http://127.0.0.1:8888/lab?token=dc6f64d49c49b3a3aa72e2d8df9bb93ba2ec3a107baadd5b
# near the bottome of output.  Get the token from there.
#
# then in new terminal
# ssh -NL localhost:1234:localhost:8887  mthuggin@elcapitan.csc.calpoly.edu
# 
# it will ook like it has hung, but it is working.
# go to localhost:1234 in browser, use the token from above to log in.