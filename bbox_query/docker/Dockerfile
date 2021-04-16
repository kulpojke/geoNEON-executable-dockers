FROM continuumio/miniconda3:4.9.2
LABEL maintainer="michaelhuggins@protonmail.com"
SHELL [ "/bin/bash", "--login", "-c" ]
WORKDIR /

RUN conda install rasterio=1.2.2 python-pdal=2.3.7 --channel conda-forge --channel anaconda

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]
