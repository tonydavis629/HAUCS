from scripts import create_data
from mission_planner import planner

if __name__ == '__main__':
    
    ponds = create_data.main(num_polygons=3, density=35, xlims=[0, 1], ylims=[0, 1], depot_loc=[.5,.5], show=False)
    
    planner.ponds2waypoints(ponds, 10, 'ardu')
