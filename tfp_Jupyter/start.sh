#!/bin/sh

echo " "
echo "----------------------------"
echo " "
echo "$PWD will be mounted as /tf/work"
echo " "
echo "----------------------------"
echo " "

docker build docker -t tfp_jupyter_docker && \


docker run --gpus all -u $(id -u):$(id -g) -it --rm -p 8888:8888 --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 $PWD:/tf/work nvcr.io/nvidia/tensorflow:22.01-tf2-py3
# ./start.sh
#
# then in new terminal
# ssh -NL localhost:1234:localhost:8885  mthuggin@elcapitan.csc.calpoly.edu
#
# it will look like it has hung, but it is working.
# go to localhost:1234 in browser, use the token from above to log in.


# 1712686dd827ebd1897be18c8da7a94b2df95c646f4fad0e
