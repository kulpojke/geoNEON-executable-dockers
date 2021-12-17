FROM tensorflow/tensorflow:2.7.0-gpu-jupyter

# RUN python -m pip install jupyterlab
RUN python -m pip install --upgrade tensorflow-probability==0.15.0 pandas==1.3.5 cupy==10.0.0 optuna==2.10.0 sklearn seaborn "dask[complete]"  


#COPY file.sh /
#RUN  chmod 777 /file.sh
#ENTRYPOINT ["/file.sh"]