import tensorflow as tf
import tensorflow_probability as tfp
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import requests
import seaborn as sns
import sys
from math import sin, cos
import argparse
from zipfile import ZipFile

tfd = tfp.distributions

# ----------------------functions from the paper------------------------------
# Saxton, K.E., Rawls, W., Romberger, J.S. and Papendick, R.I., 1986. 
# Estimating generalized soil-water characteristics from texture.

def A(clay, sand):
    '''Saxton et al.'s coeficient A (eq 5) for Rawl's eq'''
    return(100.0 * np.exp(-4.396 - 0.0715 * clay 
           - 4.880e-4 * sand**2 - 4.285e-5 *sand**2 * clay))


def B(clay, sand): 
    '''Saxton et al.'s coeficient B (eq 6) for Rawl's eq'''
    return(-3.140 - 0.00222 * clay**2 - 3.484e-5 * sand**2 * clay)


def Ψ0(Θ, clay, sand):
    '''calculates matric potential above 10kPa
    using Rawl's eq (eq2 in saxton)'''
    return(A(clay, sand) * Θ**B(clay, sand))


def Θs(clay, sand):
    '''calculates moisture content at saturation (saxton eq 7)'''
    return(0.332 - 7.251e-4 * sand + 0.1276 * np.log10(clay))


def Ψe(clay, sand):
    '''calculates air entry potential (saxton eq 8)'''
    return(100.0 * (-0.108 + 0.341 * Θs(clay, sand)))


def theta10kPa(clay, sand):
    '''inverse of Ψ0 (eq2)'''
    return((10 / A(clay, sand))**(1/B(clay, sand)))


def theta_e(clay, sand):
    '''finds theta at air entry potential'''
    A_ = lambda clay, sand : Ψe(clay, sand) / Θs(clay, sand)**B(clay, sand)
    return((Ψe(clay, sand) / A_(clay, sand))**(1/B(clay, sand)))


def Ψ1(Θ, clay, sand):
    '''calculates matric potential as linear function between
    10kPa and air entry'''
    Θ_10KpA = theta10kPa(clay, sand)
    Θ_Ψe    = theta_e(clay, sand)
    slope = (10 - Ψe(clay, sand)) / (Θ_10KpA - Θ_Ψe)
    intercept =   -slope * Θ_10KpA + 10
    return(slope * Θ + intercept)


def Ψ(Θ, clay, sand):
    '''calculates matric potential across full range'''
    Θ_10KpA = theta10kPa(clay, sand)
    Θ_Ψe    = theta_e(clay, sand)
    if Θ < Θ_10KpA:
        return(Ψ0(Θ, clay, sand))
    elif Θ_10KpA < Θ < Θ_Ψe :
        return(Ψ1(Θ, clay, sand))
    else:
        return(0)


def save_a_dang_verification_plot(plot_path):
    sand_clay = {'a': (20, 60),
                'b': (8, 45),
                'c': (10, 35),
                'd': (35, 35),
                'e': (20, 15),
                'f': (40, 18),
                'g': (60, 28),
                'h': (65, 10),
                'i': (82, 6),
                'j': (92, 5),} 

    swc = np.linspace(0.01, 0.6, 100)

    for key, val in sand_clay.items():
        sand, clay = val
        kPa = np.vectorize(Ψ)(swc, clay, sand)
        plt.plot(swc, kPa, label=key);

    plt.ylim((-0.01, 50));
    plt.legend();
    plt.title('Compare to figure 4 in Saxton et al.')
    plt.xlabel('Volumetric Soil Moisture (fraction)')
    plt.ylabel('$\Psi$ (kPA)')
    plt.savefig(os.path.join(plot_path, 'verification.png'))

# ---------------------Other functions----------------------------------------   
# from NEON_SPC_userGuide_vC.1.pdf

def ref_corner_E_N(ref_corn, cent_east, cent_north):
    '''Returns UTM easting and northing or reference corner
    based of centroid easting and northing and which corner
    is reference
    
    params:
    ref_corn  - Str    - description of refernce corner location from spc_perplot,
                         e.g. 'SW20'.
    cent_east  - float - easting of centroid in UTM coords. can be obtained from
                         converting lat, lon found in spc_perplot to appropriate
                         UTM, or from the NEON API
    cent_north - float - northing of centroid in UTM coords. see cent_east'''

    rc = [char for char in ref_corn]
    corn = ''.join(rc[:2])
    dist = int(''.join(rc[2:]))
    
    x = {'NW' : lambda e, n, dist : (e - dist /  2, n + dist / 2),
         'SW' : lambda e, n, dist : (e - dist /  2, n - dist / 2),
         'NE' : lambda e, n, dist : (e + dist /  2, n + dist / 2),
         'SE' : lambda e, n, dist : (e + dist /  2, n - dist / 2)}

    return(x[corn](cent_east, cent_north, dist))


def pit_location(ref_corner_e, ref_corner_n, sampleDistance, sampleBearing):
    '''returns pit location from reference corner, distance and bearing'''
    if sampleBearing < 90:
        theta = 90 - sampleBearing
    else:
        theta = 450 - sampleBearing

    pit_easting  = ref_corner_n + sampleDistance * cos(theta)    
    pit_northing = ref_corner_n + sampleDistance * sin(theta)

    return(pit_easting, pit_northing)


@np.vectorize
def find_pit_location(plotID, referenceCorner, sampleDistance, sampleBearing):
    '''creates new columns for pit easting, pit northing, and UTM zone for
    df with columns corresponfing to arguments'''
    # query API
    url = f'https://data.neonscience.org/api/v0/locations/{plotID}.basePlot.all'
    response = requests.get(url)
    response.raise_for_status()

    # extract info
    data = response.json()['data']
    utmZ = data['locationUtmZone']
    centroid_northing = data['locationUtmNorthing']
    centroid_easting = data['locationUtmEasting']

    ref_corner_e, ref_corner_n = ref_corner_E_N(referenceCorner, centroid_easting, centroid_northing)
    pit_e, pit_n = pit_location(ref_corner_e, ref_corner_n, sampleDistance, sampleBearing)

    return(pit_e, pit_n, utmZ)

# ---------------------MAIN------------------------------------------------- -

print(f'''
        USING:
        tensorlfow: {tf.__version__}
        tenforflow Probability: {tfp.__version__}
        numpy: {np.__version__}
        pandas: {pd.__version__}
        
        ''')

print('''Using equations from (bibtex)

@article{saxton1986estimating,
title={Estimating generalized soil-water characteristics from texture},
author={Saxton, KE and Rawls, W\_J and Romberger, J Sv and Papendick, RI},
year={1986}
}''')

# parse args
parser = argparse.ArgumentParser()
parser.add_argument('--site', type=str, required=True, help='''NEON site name''')
parser.add_argument('--plot_path', type=str, required=False, help='''Path to location where plots will be saved, if none, no plots will be saved.''') 
args = parser.parse_args() 


# unzip and read the soil characterization files
zips = [f for f in os.listdir(f'/savepath/{site}_DP1.10047.001/filesTOStack10047') if str.endswith(.zip)]

for z in zips:
    with ZipFile(z, 'r') as zipthing:
        zipthing.extractall(path=f'/savepath/{site}_DP1.10047.001/filesTOStack10047')

spc_particlesize = [f for f in os.listdir(f'/savepath/{site}_DP1.10047.001/filesTOStack10047') if 'spc_particlesize' in f][0]
spc_perplot      = [f for f in os.listdir(f'/savepath/{site}_DP1.10047.001/filesTOStack10047') if 'spc_perplot' in f][0]

# unzip and read the sensor_positions
zips = [f for f in os.listdir(f'/savepath/{site}_DP1.10047.001/filesTOStack00094') if str.endswith(.zip)]

for z in zips:
    with ZipFile(z, 'r') as zipthing:
        contents = [f for f in zipthing.namelist() if 'sensor_positions' in f]
        if len(contents > 1):
            print(f'Warning: more than one sensor_positions file exists for {args.site}')
        for lump in contents:
        zipthing.extract(lump, f'/savepath/{site}_DP1.10047.001/filesTOStack00094/{site}sensor_positions.csv')

sensor_positions = f'/savepath/{site}_DP1.10047.001/filesTOStack00094/{site}sensor_positions.csv'

# save verification plot if need be
if args.plot_path:
    save_a_dang_verification_plot(args.plot_path)
    print(f'verification plot saved to:\n{args.plot_path} ')



# open the particle size csv
cols = ['plotID', 'horizonName', 'horizonID', 'sandTotal',
        'clayTotal', 'biogeoCenterDepth']

df1 = pd.read_csv(spc_particlesize, usecols=cols)

# open the site location csv
cols = ['plotID', 'plotType', 'nlcdClass', 'decimalLongitude',
        'decimalLatitude', 'coordinateUncertainty', 'elevation',
        'elevationUncertainty', 'referenceCorner', 'sampleDistance',
        'sampleBearing']

df2 = pd.read_csv(spc_perplot, usecols=cols)

# find the pit locations
e, n, utm = find_pit_location(df2.plotID,
                            df2.referenceCorner,
                            df2.sampleDistance,
                            df2.sampleBearing)

df2['pit_easting'] = e
df2['pit_northing'] = n
df2['UTM_Zone'] = utm

# merge dfs
df = pd.merge(df1, df2, on='plotID')

print(df.columns)

dirt_plot = sns.jointplot(y='clayTotal', x='sandTotal', data=df)
fig = dirt_plot.get_figure()
fig.savefig(os.path.join(plot_path, site + '_sand_clay_jointplot.png'))

sand_mean = df.sandTotal.mean()
sand_var  = df.sandTotal.var()

clay_mean = df.clayTotal.mean()
clay_var  = df.clayTotal.var()