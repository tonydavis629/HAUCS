from haucs.utils.utils import coord2arr
import numpy as np
import pickle

coords = np.loadtxt('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\ponds.txt') #first point is the depot

#run data/load_data.py to generate the data for each model

#run solvers/HPP/solve.m first
# # # # # # HPP # # # # # # # 
# depot is the first point of each route
# with open('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\HPProutes.pkl','rb') as routes:
#     all_routes = pickle.load(routes)
#     all_routes = all_routes.squeeze()

# ind = np.where(all_routes == 0)[0]
# solved_routes = np.split(all_routes,ind)[1:-1]

# tour = [] #used for plotting in atsp
# for i, route in enumerate(solved_routes):
#     tour.extend(list(route[1:]) + [0])
#     final_route = coords[route,:] 
#     np.savetxt('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\HPProutes'+str(i)+'.txt',final_route,delimiter=',',fmt='%f')
    
# tour = tour[:-1] # remove last zero
# with open('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\HPPtour.pkl','wb') as tourfile:
#     pickle.dump(tour,tourfile)
# print(tour)

# # run atsp/plot_vrp.ipynb
# # # # # # # # GM # # # # # # # # 
# # no depot in routes
# with open('GM_routes.pkl','rb') as routes:
#     all_routes = pickle.load(routes)
#     all_routes = all_routes[0]
    
# for i, route in enumerate(all_routes):
#     final_route = coords[route,:]
#     final_route = np.insert(final_route,0,coords[0],axis=0) #insert depot
#     np.savetxt('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\GMroutes'+str(i)+'.txt',final_route,delimiter=',',fmt='%f')
    
    
# # # # # # # # GLOP # # # # # # # # # 
# depot is the first point of each route
# with open('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\GLOP_routes_IL.pkl','rb') as routes:
#     all_routes = pickle.load(routes)
#     all_routes = all_routes[0]
    
# tour = []
# for i, route in enumerate(all_routes):
#     tour.extend(list(route[1:]) + [0])
#     final_route = coords[route,:]
#     np.savetxt('C:\\Users\\coral-computer\\Documents\\github\\HAUCS\\haucs\\GLOProutes'+str(i)+'.txt',final_route,delimiter=',',fmt='%f')

# tour = tour[:-1] # remove last zero
# print(tour)