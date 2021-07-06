FROM andrejreznik/python-gdal:py3.8.2-gdal3.0.4

LABEL maintainer="michaelhuggins@protonmail.com"

RUN pip install h5py==3.2.1 dask==2021.6.0 scikit-learn==0.24.2 matplotlib
#numpy==1.20.3 gdal

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]