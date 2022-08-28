import numpy as np
from haucs.utils.utils import coord2arr

coords = np.loadtxt('./pondsmall.txt')
arr, lat_range, long_range = coord2arr(coords)
np.savetxt('ILnormcoordsmall.txt',arr,delimiter=',',fmt='%f')
