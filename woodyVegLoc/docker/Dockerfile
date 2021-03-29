FROM rocker/geospatial:4.0.2

RUN R -e 'options(warn=2); install.packages(c("devtools", "neonUtilities","raster", "data.table", "rgdal" )); devtools::install_github("NEONScience/NEON-geolocation/geoNEON")'

COPY file.sh /
#COPY get_woody_veg_locs.R /
RUN  chmod 777 file.sh
ENTRYPOINT ["/file.sh"]


