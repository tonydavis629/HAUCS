import numpy as np

def normalize(x):
    x = np.asarray(x)
    return (x - x.min()) / (np.ptp(x))

def coord2arr(coords):
    """
    Convert a set of lat,lon coordinates to a pond locations array between 0 and 1
    """
    min_lat = coords[:,0].min()
    max_lat = coords[:,0].max()
    min_long = coords[:,1].min()
    max_long = coords[:,1].max()
    lat_range = (min_lat, max_lat)
    long_range = (min_long, max_long)
    lats = normalize(coords[:,0])
    longs = normalize(coords[:,1])
    return np.array([lats,longs]).T, lat_range, long_range

def save_norm_coords(coords, filename):
    """
    Save normalized coordinates to a file
    """
    norm_arr = coord2arr(coords)
    np.savetxt(filename,norm_arr,delimiter=',',fmt='%f')

def arr2coord(ponds, coord_range):
    """
    Convert a pond locations array to a list of coordinates in the cord_range for testing

    FAU_cordrange = [(26.36850720418702, 26.36887424754121),(-80.10453338243877, -80.10397008981852)]
    pond_cord = arr2cord(pp.loc,FAU_cordrange) #first pond is home location
     
    """
    lat_range = coord_range[0]
    lon_range = coord_range[1]
    ponds_norm=normalize(ponds)

    lat_cord = ponds_norm[:,0] * (lat_range[1] - lat_range[0]) + lat_range[0]
    lon_cord = ponds_norm[:,1] * (lon_range[1] - lon_range[0]) + lon_range[0]

    cord = np.array([lat_cord, lon_cord]).T
    return cord

