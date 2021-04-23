FROM continuumio/miniconda3:4.8.2
LABEL maintainer="michaelhuggins@protonmail.com"
SHELL [ "/bin/bash", "--login", "-c" ]
WORKDIR /

RUN conda install rasterio python-pdal --channel conda-forge --channel anaconda

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]
