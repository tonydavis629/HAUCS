from haucs.utils.utils import coord2arr
import numpy as np

coords = np.loadtxt('./ponds.txt')
arr, lat_range, long_range = coord2arr(coords)
np.savetxt('ILnormcoords.txt',arr,delimiter=',',fmt='%f')

solved_routes = np.loadtxt('./solved_routes.txt')
final_routes = coords[solved_routes]
print(final_routes)