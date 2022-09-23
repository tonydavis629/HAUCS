import numpy as np
from haucs.utils.utils import coord2arr
from haucs.utils.load_data import load
from haucs.solvers.googleORsolver import solve
from haucs.utils.save_routes import save

#load the coordinates of the ponds
coords = np.loadtxt('/home/tony/github/HAUCS/haucs/pondsfull.txt')

#normalize the coordinates between 0 and 1
norm, lat_range, long_range = coord2arr(coords)

# save the dataset for the desired path planning method
load('GLOP', norm, '/home/tony/github/HAUCS/haucs/GLOP_dataset_IL.pkl')

#solve the routes
solve('/home/tony/github/HAUCS/haucs/GLOP_dataset_IL.pkl', '/home/tony/github/HAUCS/haucs/GLOP_solution_IL.pkl')

#save the routes
save('GLOP', coords, '/home/tony/github/HAUCS/haucs/GLOP_solution_IL.pkl')