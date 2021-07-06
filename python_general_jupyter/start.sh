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
# docker run --rm -it -p 8887:8888  -e USER=$USER -v /data/mthuggin/tmp:/work -v /data/mthuggin/eddy2:/data  py_general_docker:latest bash
#
# Now in the container:
# jupyter notebook password
# jupyter lab --no-browser --port 8888
#
# There will be a url like:
# http://127.0.0.1:8888/lab?token=64a10a3319e79ea2980352eb9f07b806c8dc418156b913fb
# near the bottome of output.  Get the token from there.
#
# then in new terminal
# ssh -NL localhost:1234:localhost:8887  mthuggin@elcapitan.csc.calpoly.edu
# 
# it will ook like it has hung, but it is working.
# go to localhost:1234 in browser, use the token from above to log in.




# TENSORFLOW JUPYTER NOTEBOOK --------------------------------------------------------------------------
# ssh mthuggin@elcapitan.csc.calpoly.edu
#
# Now on the server,
# docker run -it --rm --runtime=nvidia -u $(id -u):$(id -g) -v /data/mthuggin/eddy:/data -v $(realpath /data/mthuggin/notebooks):/tf/notebooks -p 8885:8888 tensorflow/tensorflow:2.5.0-gpu-jupyter
#
# then in new terminal
# ssh -NL localhost:1234:localhost:8885  mthuggin@elcapitan.csc.calpoly.edu
# 
# it will look like it has hung, but it is working.
# go to localhost:1234 in browser, use the token from above to log in.

#  