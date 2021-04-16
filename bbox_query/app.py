import rasterio
from rasterio.windows import Window
from rasterio.vrt import WarpedVRT
import argparse







def srs_to_pixel_coords(x, y, r,  srs):
    '''Converts from supplied srs to pixel coords of the supplied tiff. 
        -- x   - int or float - x coord in srs
        -- y   - int or float - y coord in srs
        -- r   - str - path to raster of which to convert to pixel coords of (awkward phrase!)
        -- srs - str - Source srs, e.g. 'EPSG:26911'
    ''' 
    data = rasterio.open(r) 
    print(data.bounds)



if __name__ == '__main__':
    ''' '''

    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument('--bbox', type=str, required=True,
    help='''The extents of the resource to select in 2 dimensions, expressed as a string,
    in the format: '([xmin, xmax], [ymin, ymax])' ''')
    parser.add_argument('--chm', type=str, required=True, help='path to chm')
    parser.add_argument('--chm', type=str, required=True, help='path to chm')
    parser.add_argument('--dtm', type=str, required=True, help='path to dtm')
    parser.add_argument('--dsm', type=str, required=True, help='path to dsm')
    parser.add_argument('--ept', type=str, required=True, help='path to ept')
    parser.add_argument('--srs', type=str, required=True, help='EPSG code of srs of files, all files must be in the same coordinate system')
    args = parser.parse_args()  

    # convert the bbox to pixel values for chm
    chm_xmin, chm_ymin = srs_to_pixel_coords(args.bbox[0][0], args.bbox[1][0], args.chm, srs=args.srs)
    chm_xmax, chm_ymax = srs_to_pixel_coords(args.bbox[0][1], args.bbox[1][1], args.chm, srs=args.srs) 
    chm_col_off = chm_xmin
    chm_row_off = chm_ymin
    chm_width = abs(chm_xmax - chm_xmin)
    chm_height = abs(chm_ymax - chm_ymin)

    # convert the bbox to pixel values for dtm
    dtm_xmin, dtm_ymin = srs_to_pixel_coords(args.bbox[0][0], args.bbox[1][0], args.dtm, srs=args.srs)
    dtm_xmax, dtm_ymax = srs_to_pixel_coords(args.bbox[0][1], args.bbox[1][1], args.dtm, srs=args.srs) 
    dtm_col_off = dtm_xmin
    dtm_row_off = dtm_ymin
    dtm_width = abs(dtm_xmax - dtm_xmin)
    dtm_height = abs(dtm_ymax - dtm_ymin)

    # convert the bbox to pixel values for dsm
    dsm_xmin, dsm_ymin = srs_to_pixel_coords(args.bbox[0][0], args.bbox[1][0], args.dsm, srs=args.srs)
    dsm_xmax, dsm_ymax = srs_to_pixel_coords(args.bbox[0][1], args.bbox[1][1], args.dsm, srs=args.srs) 
    dsm_col_off = dsm_xmin
    dsm_row_off = dsm_ymin
    dsm_width = abs(dsm_xmax - dsm_xmin)
    dsm_height = abs(dsm_ymax - dsm_ymin)