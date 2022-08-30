import numpy as np
from haucs.utils.utils import coord2arr

coords = np.loadtxt('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\ponds.txt')
arr, lat_range, long_range = coord2arr(coords)
np.savetxt('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\ILnormcoords.txt',arr,delimiter=',',fmt='%f')
