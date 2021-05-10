FROM rocker/r-base:4.1.0

RUN apt-get update && apt install -y software-properties-common \
&& apt-get install -y apt-utils 

RUN  apt-get update \
&& apt-get install -y libgdal-dev libgeos++-dev libudunits2-dev libproj-dev libx11-dev libgl1-mesa-dev libglu1-mesa-dev libfreetype6-dev libnode-dev libxt-dev libfftw3-dev

RUN R -e "install.packages('remotes'); install.packages('devtools'); devtools::install_version('lidR', '3.1.2')"

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]