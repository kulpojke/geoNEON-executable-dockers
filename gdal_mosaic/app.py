import numpy as np
import os, subprocess
from glob import glob
from osgeo import gdal
import argparse




if __name__ == '__main__':

    print(f'\nUsing:\n    NumPy version: {np.__version__}\n    gdal version: {gdal.VersionInfo()}\n')

    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument('--datapath', type=str, required=True,
                        help='Path to files to be merged')
    parser.add_argument('--outpath', type=str, required=True, help='Path where mosaics will be written')
    args = parser.parse_args()  

    # glob the files
    CHMs = glob(os.path.join(args.datapath, '*_CHM.tif'))
    DSMs = glob(os.path.join(args.datapath, '*_DSM.tif'))
    DTMs = glob(os.path.join(args.datapath, '*_DTM.tif'))
    LAZs = glob(os.path.join(args.datapath, '*.laz'))

    for chm in CHMs:
        print(chm)

    print('done!')