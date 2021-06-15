#!/bin/sh

H5FILE=$1
LOCATIONS=$2
TYPE=$3


python extract_pixel.py --datapath=/datapath --outpath=/outpath --hyperspectral=$H5FILE --locations=$LOCATIONS --type=$TYPE