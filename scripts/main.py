from create_data import create_data
from haucs.mission_planner import planner

if __name__ == '__main__':

    ponds = create_data(num_polygons=3, density=3, xlims=[0, 1], ylims=[0, 1], depot_loc=[.5,.5], show=True)
    
    planner.ponds2waypoints(ponds, 10, 'ardu')


