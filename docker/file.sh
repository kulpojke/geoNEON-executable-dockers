#!/bin/bash
ls
R -e 'tz <- Sys.getenv("TZ"); print(tz)'
Rscript get_woody_veg_locs.R
