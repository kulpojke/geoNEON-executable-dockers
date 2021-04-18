import rasterio
from rasterio.windows import Window
from rasterio.vrt import WarpedVRT
import argparse
import os
import affine


def vrt_window_query(vrt, profile, col_off, row_off, width, height, tag, outpath):

    # create window with pixel values
    window = Window(col_off, row_off, width, height)

    tile =  vrt.read(1,window=window)
    A = affine.Affine( profile['transform'][0],
                       profile['transform'][1],
                       xmin, 
                       profile['transform'][3],
                       profile['transform'][4],
                       ymax)
    height, width = tile.shape
    profile.update(width=width, height=height, driver='GTiff', transform=A)
    
    
    
    fname = os.path.join(outpath, f'{tag}_chm.tif')
    os.makedirs(outpath, exist_ok=True)
    
    with rasterio.open(fname, 'w', **profile) as dst:
        dst.write(tile, 1)





if __name__ == '__main__':
    '''Returns subsets of supplied files clipped to bbox supplied in command or multiple bboes specified in file using --bbxf '''

    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument('--bbox', type=str, required=False,
    help='''The extents of the resource to select in 2 dimensions, expressed as a string,
    in the format: '([xmin, xmax], [ymin, ymax])' ''')
    parser.add_argument('--bbxf', type=str, required=False, help='''path to file with a bbox on each line''')    
    parser.add_argument('--chm', type=str, required=True, help='path to chm')
    parser.add_argument('--dtm', type=str, required=True, help='path to dtm')
    parser.add_argument('--dsm', type=str, required=True, help='path to dsm')
    parser.add_argument('--ept', type=str, required=True, help='path to ept')
    parser.add_argument('--srs', type=str, required=True, help='EPSG code of srs of files, all files must be in the same coordinate system')
    parser.add_argument('--out', type=str, required=True, help='path to output directory')
    args = parser.parse_args()  

    # unpack the bbox string
    xmin, xmax, ymin, ymax = args.bbox.strip('()').replace('[', '').replace(']','').split(',')
    xmin = float(xmin)
    xmax = float(xmax)
    ymin = float(ymin)
    ymax = float(ymax)
    
    # make a tag for the output file
    tag = f'{xmin}_{xmax}_{ymin}_{ymax}'

    # convert the bbox values from crs to pixel values for chm
    with rasterio.open(args.chm) as data:
        profile = data.profile
        vrt = WarpedVRT(data, crs=data.meta['crs'], transform=data.meta['transform'], width=data.meta['width'], height=data.meta['height'])

        chm_ymin, chm_xmin = data.index(xmin, ymin)
        chm_ymax, chm_xmax = data.index(xmax, ymax)
    col_off = chm_xmin
    row_off = chm_ymin
    width = abs(chm_xmax - chm_xmin)
    height = abs(chm_ymax - chm_ymin)


    #TODO: make this a list of windows, then loop through so we can use bbxf
    vrt_window_query(vrt, profile, col_off, row_off, width, height, tag, args.out)



    
    print('-------------------------------------------------------------------\nDone!')


    