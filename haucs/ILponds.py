from haucs.utils.utils import coord2arr
import numpy as np
import pickle

coords = np.loadtxt('./ponds.txt')
arr, lat_range, long_range = coord2arr(coords)
# np.savetxt('ILnormcoords.txt',arr,delimiter=',',fmt='%f')


# # HPP, depot is the first point
# with open('HPProutes.pkl','rb') as routes:
#     all_routes = pickle.load(routes)
#     all_routes = all_routes.squeeze()

# ind = np.where(all_routes == 0)[0]
# solved_routes = np.split(all_routes,ind)[1:-1]

# for i, route in enumerate(solved_routes):
#     final_route = coords[route,:] 
#     np.savetxt('./HPProutes'+str(i)+'.txt',final_route,delimiter=',',fmt='%f')

# #GM
# with open('GM_routes.pkl','rb') as routes:
#     all_routes = pickle.load(routes)
#     all_routes = all_routes[0]
    
# for i, route in enumerate(all_routes):
#     final_route = coords[route,:]
#     final_route = np.insert(final_route,0,coords[0],axis=0) #insert depot
#     np.savetxt('./GMroutes'+str(i)+'.txt',final_route,delimiter=',',fmt='%f')
    
    
    
with open('GLOP_routes_IL.pkl','rb') as routes:
    all_routes = pickle.load(routes)
    
for i, route in enumerate(all_routes):
    final_route = coords[route,:]
    np.savetxt('./GLOProutes'+str(i)+'.txt',final_route,delimiter=',',fmt='%f')
