FROM pdal/alpine:2.0.1
LABEL maintainer="michaelhuggins@protonmail.com"
SHELL [ "/bin/bash", "--login", "-c" ]
WORKDIR /

RUN conda install rasterio==1.2.2  --channel conda-forge --channel anaconda

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]