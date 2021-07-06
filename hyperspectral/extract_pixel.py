import numpy as np
import h5py
import gdal, osr
import os
import argparse
import dask.array as da
from dask import delayed, compute
from dask.diagnostics import ProgressBar
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

pbar = ProgressBar()
pbar.register()

def listmake_dataset(name,node):
    '''When fed to h5py.File.vivititems, returns a list of
    the names of the datasets'''
    names = []
    if isinstance(node, h5py.Dataset):
        names.append(name)
    return(names)


def list_dataset(name,node):
    if isinstance(node, h5py.Dataset):
        print(name)

def get_data(h5_path):
    # open h5 file
    f = h5py.File(h5_path, 'r')

    # get data
    refl = f['TEAK']['Reflectance']
    refl_data = refl['Reflectance_Data']
    refl_shape = refl_data.shape
    chunks = refl_data.chunks
    data = da.from_array(refl_data, chunks=chunks)

    # metadata
    metadata = f['TEAK']['Reflectance']['Metadata']

    # wavelengths
    wavelengths = metadata['Spectral_Data']['Wavelength']

    # epsg and spatial info
    epsg = int(metadata['Coordinate_System']['EPSG Code'][()])
    mapinfo = str(metadata['Coordinate_System']['Map_Info'][()]).split(',')
    resolution = (float(mapinfo[5]), float(mapinfo[6]))
    xmin, ymax = float(mapinfo[3]), float(mapinfo[4])
    xmax = xmin + resolution[0] * refl_shape[1]
    ymin = ymax - resolution[1] * refl_shape[0] 

    badbands1 = refl.attrs['Band_Window_1_Nanometers']
    badbands2 = refl.attrs['Band_Window_2_Nanometers']    
    
    # find the indices of good bands
    badidx1 = [i for i, x in enumerate(wavelengths) if x > badbands1[0] and x < badbands1[1]]
    badidx2 = [i for i, x in enumerate(wavelengths) if x > badbands2[0] and x < badbands2[1]]
    badidx  = set(badidx1 + badidx2)
    idx = set(range(len(wavelengths)))
    idx = list(idx - badidx)
    
    # select the good bands only
    wavelengths = wavelengths[idx]
    data = data[:,:,idx]

    return(data, wavelengths, epsg, resolution, xmin, ymin, xmax, ymax)


def extract(h5_path, locations, ext_type):
    if type == 'points':
        points = [loc.lstrip(',( ') for loc in locations.split(')')[:-1]]
        points = [(float(i), float(j)) for i, j in [loc.split(',') for loc in points]]
    elif type == 'boxes':
        boxes = [loc.lstrip(',( ') for loc in locations.split(')')[:-1]]
        boxes = [(float(i), float(j), float(k), float(l)) for i, j, k, l in [loc.split(',') for loc in boxes]]
        points = None
    else:
        raise Exception('--type must be either \'points\' or \'boxes\'.')

    
    #open the file and do all the band corrections stuff
    data, wavelengths, epsg, resolution, xmin, ymin, xmax, ymax = get_data(h5_path)

    if points:
        for (x, y) in points:
            # calculate raster coords
            x_ = int(x - xmin)
            y_ = int(y - ymin)
            # extract pixel
            pixel = data[x_, y_, :]
            # save pixel
            # TODO: save pixel
    else:
        for (box_xmin, box_ymin, box_xmax, box_ymax) in boxes:
            # calculate raster coords
            xmin_ = int(box_xmin - xmin) 
            ymin_ = int(box_ymin - ymin) 
            xmax_ = int(box_xmax - xmin) 
            ymax_ = int(box_ymax - ymin) 
            # extract box
            box = data[xmin_:xmax_, ymin_:ymax_, :]
            # save box
            # TODO: save box

def kmeans_classify(inpath, outpath, n_clusters):

    #get data as array
    src, wavelengths, epsg, resolution, xmin, ymin, xmax, ymax = get_data(h5_path)

    # find dimendsions
    X, Y, nbands = src.shape

    # flatten each band
    data = src.reshape(X * Y, nbands)

    # classify
    print('classifying')
    km = KMeans(n_clusters=n_clusters) 
    km.fit(data) 
    km.predict(data)
        
    # specify driver
    driverTiff = gdal.GetDriverByName('GTiff') 
    
    # reshape and write to tiff
    print('writing')
    labels = km.labels_
    centers = km.cluster_centers_
    print(centers[labels].shape)
    plt.figure(figsize=(20, 20))
    plt.imsave(centers[labels], '/data/mthuggin/tmp/image.png')
    
    classed = driverTiff.Create(outpath, ras.RasterXSize, ras.RasterYSize, 1, gdal.GDT_Float32)
    classed.SetGeoTransform(ras.GetGeoTransform())
    classed.SetProjection(ras.GetProjection())
    classed.GetRasterBand(1).SetNoDataValue(-9999.0)
    classed.GetRasterBand(1).WriteArray(out_data)
    classed = None


    




if __name__ == '__main__':
    # determine which tile the point is in. Actually this will be external, this is givebn tile
    # maybe the container coordinator should do this in conjuntion with calling AOP downloader?
    # maybe we should even group the points by tile, so we only have to open a tile once


    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument('--datapath', type=str, required=True,
                        help='Directory from which paths to files will be given.')
    parser.add_argument('--hyperspectral', type=str, required=True,
                        help='Relative path to hyperspectral h5 from datapath.')
    parser.add_argument('--outpath', type=str, required=True,
                        help='Path in which to save output.')
    parser.add_argument('--locations', nargs='?', default=None,
                        help='''comma delimitted string of tuples of the coordinates
                        for the points or boxes to extract.
                        e.g. (x0, y0), (x1, y1),... in the case of points,
                        or (xmin0, ymin0, xmax0, ymax0), (xmin1, ymin1, xmax1, ymax1),... 
                        in the case of boxes.''')
    parser.add_argument('--mode', type=str, required=True,
                        help='\'extract\' or \'kmeans\'.')
    parser.add_argument('--type', type=str, required=False,
                        help='\'points\' or \'boxes\'.')
    args = parser.parse_args()

    h5_path = os.path.join(args.datapath, args.hyperspectral)
    tile = '_'.join(np.array(args.hyperspectral.split('/')[-1].split('_'))[[2,4,5]])
    write_path = os.path.join(args.outpath, tile + '_classes.tif')

    if args.mode == 'extract':
        extract(h5_path, args.locations, args.type)

    elif args.mode == 'kmeans':
        kmeans_classify(h5_path, write_path, 7)










