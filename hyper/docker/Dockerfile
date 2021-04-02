FROM continuumio/miniconda3:4.9.2

RUN conda install numpy=1.19.2 pandas=1.2.3 h5py=2.10.0 gdal=3.2.2 dask=0.15.2 --channel anaconda --channel conda-forge

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]