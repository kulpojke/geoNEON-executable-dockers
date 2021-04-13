from datetime import datetime
from pycrown import PyCrown
from shapely.geometry import mapping, Point, Polygon
import geopandas
import numpy as np
import fiona
import argparse
from glob import glob

def export_tree_locations(PC, loc='top'):
    """ Convert tree top raster indices to georeferenced 3D point shapefile
    Parameters
    ----------
    loc :     str, optional
              tree seed position: `top` or `top_cor`
    """
    outfile = PC.outpath / f'tree_location_{loc}.shp'
    outfile.parent.mkdir(parents=True, exist_ok=True)

    if outfile.exists():
        outfile.unlink()

    schema = {
        'geometry': '3D Point',
        'properties': {'DN': 'int', 'TH': 'float'}
    }
    with fiona.collection(
        str(outfile), 'w', 'ESRI Shapefile', schema, crs=PC.srs #crs_wkt=PC.srs
    ) as output:
        for tidx in range(len(PC.trees)):
            feat = {}
            tree = PC.trees.iloc[tidx]
            feat['geometry'] = mapping(
                Point(tree[loc].x, tree[loc].y, tree[f'{loc}_elevation'])
            )
            feat['properties'] = {'DN': tidx,
                                  'TH': float(tree[f'{loc}_height'])}
            output.write(feat)

def filter_trees(PC, path, loc='top', exclude=False):
    points = [Point(l.x,l.y) for l,z in zip(PC.trees[loc],PC.trees[f'{loc}_elevation'])]
    gdf = geopandas.read_file(path)
    good = [gdf.contains(point).any() for point in points]
    if exclude:
        good = [not g for g in good]
    PC.trees = PC.trees[good]


    

def do_the_delineation(F_CHM, F_DTM, F_DSM, F_LAS, outpath=args.out, ws=3, ws_in_pixels=True)
    PC = PyCrown(F_CHM, F_DTM, F_DSM, F_LAS, outpath=outpath)

    # Smooth CHM with median filter
    print('running median filter')
    # ws is filter window (pixels)
    PC.filter_chm(ws, ws_in_pixels=ws_in_pixels)

    # Tree Detection with local maximum filter
    print('running tree detection')
    PC.tree_detection(PC.chm, ws=5, ws_in_pixels=ws_in_pixels, hmin=1.)

    # Clip trees from edges
    print('running edge clipping')
    PC.clip_trees_to_bbox(inbuf=11)  # inward buffer of 11 metre
    
    # remove trees outside of area
    print('filtering out by area')
    if args.area is not None:
        filter_trees(PC,args.area,exclude=False)
    if args.bldgs is not None:
        filter_trees(PC,args.bldgs,exclude=True)

    export_tree_locations(PC,loc='top')

    # Crown Delineation
    print('running crown delineation')
    PC.crown_delineation(algorithm='dalponteCIRC_numba', th_tree=1.,
                         th_seed=0.7, th_crown=0.55, max_crown=10.)

    # Correct tree tops on steep terrain
    print('correcting tree tops')
    PC.correct_tree_tops()

    # Calculate tree height and elevation
    print('getting tree height and elevation')
    PC.get_tree_height_elevation(loc='top')
    PC.get_tree_height_elevation(loc='top_cor')

    # Screen small trees
    #PC.screen_small_trees(hmin=20., loc='top')

    # Convert raster crowns to polygons
    print('converting to raster crowns')
    PC.crowns_to_polys_raster()
    #print('converting to smooth raster crowns')
    #PC.crowns_to_polys_smooth(store_las=True)

    # Check that all geometries are valid
    print('quality control')
    PC.quality_control()

    # Export results
    print('export')
    PC.export_raster(PC.chm, PC.outpath / 'chm.tif', 'CHM')
    PC.export_tree_locations(loc='top')
    PC.export_tree_locations(loc='top_cor')
    PC.export_tree_crowns(crowntype='crown_poly_raster')
    #PC.export_tree_crowns(crowntype='crown_poly_smooth')

    TEND = datetime.now()

    print(f"Number of trees detected: {len(PC.trees)}")
    print(f'Processing time: {TEND-TSTART} [HH:MM:SS]')



if __name__ == '__main__':
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--dir')
    parser.add_argument('--prfx')
    parser.add_argument('--dsm')
    parser.add_argument('--dtm')
    parser.add_argument('--chm')
    parser.add_argument('--points')
    parser.add_argument('--area')
    parser.add_argument('--bldgs')
    parser.add_argument('--out')
    args = parser.parse_args()

    TSTART = datetime.now()

    datapath = args.dir

    if datapath:
        chms = glob('*_CHM.tif')
        dsms = glob('*_DSM.tif')
        dtms = glob('*_DTM.tif')
        points = glob('*.laz')

        # match up the tiles using the args.prfx (which is a pattern)


    else:
        F_CHM = args.chm
        F_DTM = args.dtm
        F_DSM = args.dsm
        F_LAS = args.points

    print('Would run:')
    print(f'do_the_delineation({F_CHM}, {F_DTM}, {F_DSM}, {F_LAS}')