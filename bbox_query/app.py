import rasterio
from rasterio.windows import Window
from rasterio.vrt import WarpedVRT
import argparse
import os







def srs_to_pixel_coords(x, y, r,  srs):
    '''Converts from supplied srs to pixel coords of the supplied tiff. 
        -- x   - int or float - x coord in srs
        -- y   - int or float - y coord in srs
        -- r   - str - path to raster of which to convert to pixel coords of (awkward phrase!)
        -- srs - str - Source srs, e.g. 'EPSG:26911'
    ''' 
    with rasterio.open(r) as data: 
        
        dx = data.bounds.right - data.bounds.left
        dx = data.bounds.top - data.bounds.bottom


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

    # un-string the bbox
    xmin, xmax, ymin, ymax = args.bbox.strip('()').replace('[', '').replace(']','').split(',')
    xmin = float(xmin)
    xmax = float(xmax)
    ymin = float(ymin)
    ymax = float(ymax)
    
    bbox = ([xmin, xmax], [ymin, ymax])
    tag = f'{xmin}_{xmax}_{ymin}_{ymax}'

    # convert the bbox to pixel values for chm
    with rasterio.open(args.chm) as data:

        chm_vrt = WarpedVRT(data, crs=data.meta['crs'], transform=data.meta['transform'], width=data.meta['width'], height=data.meta['height'])

        chm_ymin, chm_xmin = data.index(xmin, ymin)
        chm_ymax, chm_xmax = data.index(xmax, ymax)
    col_off = chm_xmin
    row_off = chm_ymin
    width = abs(chm_xmax - chm_xmin)
    height = abs(chm_ymax - chm_ymin)
    print(f'{width} v {chm_vrt.width}')

    #TODO: make this a list of windows, then loop through so we can use bbxf
    # create window with pixel values
    chm_window = Window(col_off, row_off, width, height)

    
    
    with chm_vrt.read(1,window=chm_window) as tile:
        fname = os.path.join(args.out, f'{tag}_chm.tif')
        os.makedirs(args.out, exist_ok=True)
        tile.write(fname)


    