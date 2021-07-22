#!/bin/sh

SITE=$1
SENSORPOS=$2
PERPLOT=$3
PARSIZE=$4
PLOTPATH=$5

python3 matric.py --sensor_positions=$SENSORPOS --spc_perplot=$PERPLOT --spc_particlesize=$PARSIZE --plot_path=$PLOTPATH