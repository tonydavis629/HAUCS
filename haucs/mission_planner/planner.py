from logging import raiseExceptions
import os

def cord2ardu_wp(cord, alt):
    """
    Takes in a coordinate and outputs a waypoint for ArduPilot MissionPlanner
    """
    lat = cord[0]
    lon = cord[1]

    with open('mission.waypoints','a+') as m:
        m.write("""0 0 0 16 0 0 0 0 """)
        m.write(str(lat) + ' ')
        m.write(str(lon) + ' ')
        m.write(str(alt) + ' ')
        m.write('1\n')

def sethome(loc):
    """
    Initialize the waypoint file and set the home location for the drone
    """
    lat = loc[0]
    lon = loc[1]
    alt = 0
    with open('mission.waypoints','a+') as m:
        m.seek(0)
        if os.path.getsize('mission.waypoints') == 0: #check if file is empty
            m.write('QGC WPL 110\n') #add waypoints file header

            #write home location
            m.write("""0 1 0 16 0 0 0 0 """) #sets home waypoint
            m.write(str(lat) + ' ')
            m.write(str(lon) + ' ')
            m.write(str(alt) + ' ')
            m.write('1\n')

def ponds2waypoints(ponds, alt, drone_model):
    """
    Takes in pond locations and outputs sample and transition waypoints for ArduPilot MissionPlanner

    Parameters
    ----------
    ponds:list
        list of pond locations
    drone_model:str
        drone model to use for waypoint generation (ardu or splash)
    """

    if drone_model == 'ardu':
        for i, pond in enumerate(ponds):
            if i == 0:
                sethome(pond)
            else:
                cord2ardu_wp(pond, alt) #transition waypoint, at altitude
                cord2ardu_wp(pond, 0) #sample waypoint, at 0 altitude
                cord2ardu_wp(pond, alt) #transition waypoint, at altitude
        cord2ardu_wp(ponds[0], 0) #return home

    elif drone_model == 'splash':
        for pond in ponds:
            cord2splash_wp(pond, alt)
            cord2splash_wp(pond, 0)
            cord2splash_wp(pond, alt)

def cord2splash_wp(cord,alt):
    """
    Takes in a coordinate and outputs a waypoint for Splashdrone API
    """
    raiseExceptions('Splash not yet implemented')

#todo: load into sitl