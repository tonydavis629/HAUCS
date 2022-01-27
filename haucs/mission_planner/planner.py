#points in a field south of engineering west
# strt=[26.369769461284108, -80.1043028838524]
# point1= [26.369813757198585, -80.1044878865724]
# point2=[26.369738025463516, -80.10448948142343]

def cord2waypoint(cord, alt):
    """
    Takes in a coordinate and outputs a waypoint for ArduPilot MissionPlanner
    """
    lat = cord[0]
    lon = cord[1]
    with open('mission.waypoints','a') as m:
        m.write("""0 0 0 16 0 0 0 0 """)
        m.write(str(lat) + ' ')
        m.write(str(lon) + ' ')
        m.write(str(alt) + ' ')
        m.write('1\n')

#give points
#points are processed to sample waypoints and transition waypoints
#then load those into mission_planner
#then load into sitl