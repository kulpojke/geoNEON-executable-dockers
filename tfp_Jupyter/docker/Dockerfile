FROM tensorflow/tensorflow:2.5.0-gpu-jupyter



# RUN python -m pip install jupyterlab
RUN python -m pip install --upgrade tensorflow-probability==0.12.2 pandas==1.1.5 sklearn seaborn "dask[complete]"  vaex==4.3.0
# Avoid permissions issues
RUN mkdir /.vaex && chmod  777 /.vaex

#COPY file.sh /
#RUN  chmod 777 /file.sh
#ENTRYPOINT ["/file.sh"]