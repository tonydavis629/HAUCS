from scripts import create_data
from mission_planner import planner

if __name__ == '__main__':
    create_data.main(num_polygons=3, density=35, xlims=[0, 1], ylims=[0, 1], depot_loc=[.5,.5], show=True)
    
    # strt=[26.369769461284666, -80.1043028838666]
    # planner.cord2waypoint(strt, 10)