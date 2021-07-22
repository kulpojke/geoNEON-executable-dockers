#!/bin/sh

docker build docker -t tfp_jupyter_docker && \
docker run -it --rm --runtime=nvidia -u $(id -u):$(id -g) -v /data/mthuggin/eddy2:/data -v $(realpath /data/mthuggin/notebooks):/tf/notebooks -p 8885:8888 tfp_jupyter_docker

#
#
# then in new terminal
# ssh -NL localhost:1234:localhost:8885  mthuggin@elcapitan.csc.calpoly.edu
# 
# it will look like it has hung, but it is working.
# go to localhost:1234 in browser, use the token from above to log in.


# 6f8f6dc44ae5b11967f3c1219183c1f0524dc001dd5de045

