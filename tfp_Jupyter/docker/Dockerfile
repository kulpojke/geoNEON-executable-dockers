FROM nvcr.io/nvidia/tensorflow:22.01-tf2-py3

RUN python -m pip install --upgrade tensorflow-probability pandas matplotlib tables optuna sklearn seaborn "dask[complete]"

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0" "--no-browser"]

# docker run --gpus all -it --rm --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 -v /home/michael/Work/geoNeon-executable-dockers/notebooks:/notebooks nvcr.io/nvidia/tensorflow:22.01-tf2-py3

# HERE IS RAPIDS  DOCKER FOR LATER
# docker pull rapidsai/rapidsai-core:21.12-cuda11.4-runtime-ubuntu20.04-py3.8
# docker run --gpus all --rm -it -p 8888:8888 -p 8787:8787 -p 8786:8786 rapidsai/rapidsai-core:21.12-cuda11.4-runtime-ubuntu20.04-py3.8