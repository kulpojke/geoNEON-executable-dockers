#!/bin/sh

H5FILE=$1
LOCATIONS=$2
MODE=$3
TYPE=$4



python extract_pixel.py --datapath=/datapath --outpath=/outpath --hyperspectral=$H5FILE --locations=$LOCATIONS --type=$TYPE --mode=$MODE