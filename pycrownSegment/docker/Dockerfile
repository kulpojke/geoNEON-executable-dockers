FROM ubuntu:20.04
LABEL maintainer="michaelhuggins@protonmail.com"
SHELL [ "/bin/bash", "--login", "-c" ]
WORKDIR /

# apt stuff
RUN apt-get update && apt install -y software-properties-common \
&& apt-get install -y apt-utils 

RUN add-apt-repository ppa:deadsnakes/ppa -y 
#&& add-apt-repository ppa:ubuntugis/ppa

RUN apt-get update && apt-get install -y git wget python3.8 \
python3-pip  gdal-bin libgdal-dev gfortran
#&& sudo apt-get install -y pdal \

RUN git clone https://github.com/manaakiwhenua/pycrown.git

RUN python3 -m pip install --upgrade pip && pip3 --version

RUN cd pycrown \
&& ls pycrown \ 
&& pip3 install -r requirements.txt \
&& python3 /pycrown/setup.py install --verbose

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]


# This Docker is for running:
# PyCrown - Fast raster-based individual tree segmentation for LiDAR data
# -----------------------------------------------------------------------
# Copyright: 2018, Jan Zörner
# Licence: GNU GPLv3
