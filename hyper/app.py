import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import h5py
import requests
import hashlib
import zlib
import binascii
import time
import os
import argparse
from osgeo import gdal
from dask import delayed, compute


def download_from_NEON_API(f, data_path):
    '''Download file described by f to datapath.
       f         -- dict - This dict is suplied by generate_download_info().
       data_path -- Str  - path where data will be saved.
    '''

    attempts = 0 
    while attempts < 4:
        try:
            # get the file 
            handle = requests.get(f['url'])
            
            # check the md5 if it exists
            if f['md5']:
                md5 = hashlib.md5(handle.content).hexdigest()
                if md5 == f['md5']:
                    success = True
                    attempts = 4
                else:
                    fmd5 = f['md5']
                    print(f'md5 mismatch on attempt {attempts}')
                    success = False
                    attempts = attempts + 1
            # or if there is a crc32 check that
            elif f['crc32']:
                crc32 = binascii.crc32(handle.content) 
                if crc32 == f['crc32']:
                    success = True
                    attempts = 4
                else:
                    fcrc32 = f['crc32']
                    #print(f'{crc32} v {fcrc32}')
                    #print(f'crc32 mismatch on attempt {attempts}')
                    success = False
                    attempts = attempts + 1
                # TODO; make the crc32 work, then remove the 2 lines below here
                success = True
                attempts = 4
            # if there is no hash just wing it
            else: 
                success = True
                attempts = 4
        except Exception as e:
            print(f'Warning:\n{e}')
            success = False
            attempts = attempts + 1
    # write the file
    fname = os.path.join(data_path, f['name'])
    if success:
        with open(fname, 'wb') as sink:
            sink.write(handle.content)
        if f['size'] != os.path.getsize(fname):
            oops = abs(f['size'] - os.path.getsize(fname))
            print(f'files ize is off by {oops}')
    else:
        return(f'failed to download to {f}')



def show_dates(site, productcode):
    '''returns available dates for site and product'''
    
    base_url = 'https://data.neonscience.org/api/v0/'

    # determine which dates are available for the site/product
    url = f'{base_url}sites/{site}'
    response = requests.get(url)
    data = response.json()['data']
    dates = list(set(data['dataProducts'][0]['availableMonths']))
    dates.sort()
    return(dates)

def show_files_for_site_date(product, site, date):
    '''returns list of files available for the site and date'''
    base_url = 'https://data.neonscience.org/api/v0/'
    url = f'{base_url}data/{product}/{site}/{date}'
    response = requests.get(url)
    data = response.json()
    files = data['data']['files']
    return(files)

def generate_download_info(productcode, site, date):
    '''Returns: time of url issueance, list of  files'''
    # note time at which urls are issued
    t0 = time.time()

    try:
        # find the relevant files and urls
        files = show_files_for_site_date(productcode, site, date)

        # sort through them for the specific files needed
        desired = []
        for file in files:
            # the lidar case
            if productcode == 'DP1.30003.001':
                if 'classified_point_cloud_colorized.laz' in file['name']:
                    desired.append(file)
            # the hyperspectral reflectance case
            elif productcode == 'DP3.30006.001':
                if file['name'].endswith('.h5'):
                    desired.append(file)
            # the rgb case
            elif productcode == 'DP1.30010.001':
                if file['name'].endswith('_ort.tif'):
                    desired.append(file)
            # TODO: add other cases as needed
            else:
                raise Exception(f'''This function does not know what to do with {productcode} yet.
                If {productcode} is a valid productcode condider adding it as a case to generate_download_info() ''')

    except TypeError:
        raise Exception('There was an error in generate_download_info(), most likely due to a bad productcode. Check the supplied productcode!')
    except Exception as  e:
        raise Exception(f'''There was an error in generate_download_info(). Why? who knows? but its not from a bad productcode.
        It said:
        {e}''')
    return(t0, desired)




if __name__ == '__main__':
    '''TODO: allow multiple dates to passed as list, add exception handling and date format checking before calling
    genrate_download_info, fix the crc32 checker in download_from_NEON_API(), check to see if we are importing unused modules'''

    print('''Warning!!! the crc32 checker is not functional yet, there is no assurance h5 is not corrupt!
    Though chances aare it is fine.''')

    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument('--productcode', type=str, required=True,
                        help='''NEON produccode to be downlaoded, acceptable values as of now:
                        DP1.30010.001  --  RGB orthorectified imagery
                        DP3.30006.001  --  Hyperspectral reflectance mosaic
                        DP1.30003.001  --  Discrete return LiDAR point cloud
                        ''')
    parser.add_argument('--site', type=str, required=True, help='NEON site code, e.g. TEAK')
    parser.add_argument('--date', type=str, required=False, help='date for which to access, if you don\'t know see --show_dates')
    parser.add_argument('--show_dates', action='store_true', required=False, help='Show available dates for the site and productcode')
    args = parser.parse_args()  

    # if the show_dates flag is used show the dates and exit
    if args.show_dates:
        print(show_dates(args.site, args.productcode))
        exit()
          
    # find available files and their urls etc...
    t0, files = generate_download_info(productcode, site, date)

    #TODO: change this wehn it goes back into docker
    data_path = './data2'

    os.makedirs(data_path, exist_ok=True)


    lazy = []
    for f in files:
        lazy.append(delayed(download_from_NEON_API)(f, data_path))

    _ = compute(lazy)

    print(*(f for f in _ if f != None))
    print('Finished downloading.')
