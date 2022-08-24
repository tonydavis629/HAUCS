from haucs.utils.utils import coord2arr
import numpy as np

coords = np.loadtxt('./hboi_ponds.txt', delimiter=',')
arr = coord2arr(coords)
np.savetxt('normcoords.txt',arr,delimiter=',',fmt='%f')