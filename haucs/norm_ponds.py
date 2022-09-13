import numpy as np
from haucs.utils.utils import coord2arr

coords = np.loadtxt('/home/tony/github/HAUCS/haucs/pondsfull.txt')
arr, lat_range, long_range = coord2arr(coords)
np.savetxt('/home/tony/github/HAUCS/haucs/ILnormcoordsfull.txt',arr,delimiter=',',fmt='%f')
