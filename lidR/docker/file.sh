#!/bin/sh

# make a tmp directory for the app to use
mkdir /data/tmp

# run the app
Rscript lidRapp.R  

# rm the tmp dir
rm -r /data/tmp