FROM continuumio/miniconda3:4.9.2
LABEL maintainer="michaelhuggins@protonmail.com"

# This docker just downloads from the api, so it is probably not important to constrain the versions 
RUN conda install gdal=3.2.2 --channel anaconda --channel conda-forge

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]