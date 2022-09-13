import numpy as np
from haucs.utils.utils import coord2arr
from haucs.utils.load_data import load
from haucs.solvers.googleORsolver import solve
from haucs.save_routes import save

coords = np.loadtxt('/home/tony/github/HAUCS/haucs/pondsfull.txt')
norm, lat_range, long_range = coord2arr(coords)
load('GLOP', norm, '/home/tony/github/HAUCS/haucs/GLOP_dataset_IL.pkl')
solve('/home/tony/github/HAUCS/haucs/GLOP_dataset_IL.pkl', '/home/tony/github/HAUCS/haucs/GLOP_solution_IL.pkl')
save('GLOP', coords, '/home/tony/github/HAUCS/haucs/GLOP_solution_IL.pkl')