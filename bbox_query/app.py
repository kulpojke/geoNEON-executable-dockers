import rasterio
from rasterio.windows import Window
from rasterio.vrt import WarpedVRT
import argparse
import os
import affine
import pdal
from string import Template
import json
import subprocess



def vrt_window_query(xmin, xmax, ymin, ymax, raster, outpath, tag=None):
    '''Reads the extent - given by xmin, xmax, ymin, ymax - from a vrt and writes a GEOtiff to outpath.
    The GEOtiff filename is constructed as f'{xmin}_{xmax}_{ymin}_{ymax}_{tag}.tif' where the tag (and
    preceding underscore) is optional, see tag arg below.
        -- xmin    - int or float - minimum x value of desired extent in the vrt crs values.
        -- xmax    - int or float - maximum x value of desired extent in the vrt crs values.     
        -- ymin    - int or float - minimum y value of desired extent in the vrt crs values.
        -- ymax    - int or float - maximum y value of desired extent in the vrt crs values.
        -- raster  - str - path to vrt file
        -- outpath - str - path where tiles will be written
        -- tag     - str - tag to be placed between the location tag and the file extension (optional)  '''

    # make a tag for the output file
    if tag:
        loc = f'{xmin}_{xmax}_{ymin}_{ymax}'
        f = f'{loc}_{tag}.tif'
    else:
        f = f'{xmin}_{xmax}_{ymin}_{ymax}.tif'

    # convert the bbox values from crs to pixel values for chm
    with rasterio.open(raster) as data:
        width = data.meta['width']
        height = data.meta['height']
        profile = data.profile
        vrt = WarpedVRT(data, crs=data.meta['crs'], transform=data.meta['transform'], width=width, height=height)

        chm_ymin, chm_xmin = data.index(xmin, ymin)
        chm_ymax, chm_xmax = data.index(xmax, ymax)

    # origin in upper left corner    
    col_off = chm_xmin
    row_off = chm_ymax
    width = abs(chm_xmax - chm_xmin)
    height = abs(chm_ymax - chm_ymin)

    # create window with pixel values
    window = Window(col_off, row_off, width, height)

    # read the window from the vrt
    tile =  vrt.read(1,window=window)

    # create new affine transform to write tile in the right place
    # TODO: xmin y min are global, better they be passed to this function explicitly?
    A = affine.Affine( profile['transform'][0],
                       profile['transform'][1],
                       xmin, 
                       profile['transform'][3],
                       profile['transform'][4],
                       ymax)
    
    # update the profile
    profile.update(width=width, height=height, driver='GTiff', transform=A)
    
    # make outfile name and make sure dir exists
    fname = os.path.join(outpath, f)
    os.makedirs(outpath, exist_ok=True)
    
    # write the window as a tiff 
    with rasterio.open(fname, 'w', **profile) as dst:
        dst.write(tile, 1)

    
    

def ept_window_query(xmin, xmax, ymin, ymax, ept, srs, outpath, tag=None):
    ''' '''

    # make a tag for the output file
    loc = f'{int(xmin)}_{int(xmax)}_{int(ymin)}_{int(ymax)}'
    if tag:
        f = f'{loc}_{tag}'
    else:
        f = f'{loc}'
    of = os.path.join(outpath, f + '.las')


    # make pipeline
    bbox = ([xmin, xmax], [ymin, ymax])
    pipeline = make_pipe(ept, bbox, outpath, srs)
    json_file = os.path.join(outpath, f'{f}.json')
    with open(json_file, 'w') as j:
        json.dump(pipeline, j)
    
    #make pdal comand
    cmd = f'pdal pipeline -i {json_file}'
    _ = subprocess.run(cmd, shell=True, capture_output=True)
    print(f'\n\n\n{_.stderr}') 

def make_pipe(ept, bbox, out_path, srs, threads=4, resolution=1):
    '''Creates, validates and then returns the pdal pipeline
    
    Arguments:
    ept        -- String -Path to ept file.
    bbox       -- Tuple  - Bounding box in srs coordintes,
                  in the form: ([xmin, xmax], [ymin, ymax]).
    out_path   -- String - Path where the CHM shall be saved. Must include .tif exstension.
    srs        -- String - EPSG identifier for srs  being used. Defaults to EPSG:3857
                  because that is what ept files tend to use.
    threads    -- Int    - Number os threads to be used by the reader.ept. Defaults to 4.
    resolution -- Int or Float - resolution (m) used by writers.gdal
    '''
    print(bbox)

    pipe = {
        "pipeline": [
            {
            "bounds": f'{bbox}',
            "filename": ept,
            "type": "readers.ept",
            "tag": "readdata",
            "spatialreference": srs,
            "threads": threads
            },
            {
            "type":"filters.outlier",
            "method":"radius",
            "radius":1.0,
            "min_k":4
            },
            {
            "type":"filters.range",
            "limits":"returnnumber[1:1]"
            },
            {
            "type": "writers.las",
            "filename": out_path,
            "a_srs": srs
            }
        ]}
    return(pipe) 
    

    #pipeline = pdal.Pipeline(pipe)
    #if pipeline.validate():
    #return(pipeline)
    #else:
    #    raise Exception('Bad pipeline (sorry to be so ambigous)!')



if __name__ == '__main__':
    '''Returns subsets of supplied files clipped to bbox supplied in command or multiple bboxs specified in file using --bbxf '''

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



    # make list off bboxes
    if args.bbox:
        bboxes = [args.bbox]
    elif args.bbxf:
        bboxes = []
        #try:
        with open(args.bbxf) as bxs:
            for line in bxs:
                bboxes.append(line)
    else:
        print('One must either specify --bbox or --bbxf')
    


    for bbox in bboxes:
        # unpack the bbox string
        xmin, xmax, ymin, ymax = bbox.strip('()').replace('[', '').replace(']','').split(',')
        xmin = float(xmin)
        xmax = float(xmax)
        ymin = float(ymin)
        ymax = float(ymax)

        # read and write the window for each raster
        vrt_window_query(xmin, xmax, ymin, ymax, args.chm, args.out, tag='chm')
        vrt_window_query(xmin, xmax, ymin, ymax, args.dsm, args.out, tag='dsm')
        vrt_window_query(xmin, xmax, ymin, ymax, args.dtm, args.out, tag='dtm')

        # TODO: make a laz for the window from ept.
        ept_window_query(xmin, xmax, ymin, ymax, args.ept, args.srs, args.out, tag=None)
        



    
    print('-------------------------------------------------------------------\nDone!')


    