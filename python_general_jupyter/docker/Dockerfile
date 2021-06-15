FROM jupyter/datascience-notebook:ubuntu-20.04

# lets add apackage with conda so that this image will take hundreds of years to build
RUN conda install --yes -c conda-forge -c anaconda pymc3==3.8 mkl-service arviz==0.11.0 gdal




# give them the password 'notroot' put them in the sudo group
#RUN useradd -d /home/notroot -m -s /bin/bash notroot && echo "notroot:notroot" | chpasswd && adduser notroot sudo

# start working in the "tester" home directory
##COPY ./src .

# Make the files owned by tester
#RUN chown -R tester:tester /home/tester

# Switch to your new user in the docker image
#USER notroot

#RUN python -m pip install h5py tables pandas scipy dask jupyterlab seaborn

#EXPOSE 8888/udp
#EXPOSE 8888/tcp
