FROM base_docker:latest

RUN R -e "install.packages('raster'); install.packages('rgdal')"

COPY file.sh /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]