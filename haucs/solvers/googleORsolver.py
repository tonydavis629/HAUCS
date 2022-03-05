"""Simple Vehicles Routing Problem (VRP).

   This is a sample using the routing library python wrapper to solve a VRP
   problem.
   A description of the problem can be found here:
   http://en.wikipedia.org/wiki/Vehicle_routing_problem.

   Distances are in meters.
"""

from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp

import pickle
import numpy as np
import time

from haucs.data.dataset import PondsDataset


def load_data_model(vrp_size):
    "Load the data from HAUCS"
    filename = 'GLOP_dataset' + str(vrp_size) + '.pkl'
    data = pickle.load(open(filename, 'rb'))
    return data

def create_data_model(vrp_size):
    """Stores the data for the problem."""
    data = PondsDataset(1, vrp_size, [0,1000], [0,1000])
    dm = data.build_dm_dataset()
    first = dm[0]
    data = {}
    data['distance_matrix'] = first
    data['num_vehicles'] = 4
    data['depot'] = 0
    return data


def gen_results(data, manager, routing, solution):
    """Generate results."""
    # print(f'Objective: {solution.ObjectiveValue()}')
    max_route_distance = 0
    total_distance = 0
    routes = []
    for vehicle_id in range(data['num_vehicles']):
        index = routing.Start(vehicle_id)
        plan_output = 'Route for vehicle {}:\n'.format(vehicle_id)
        route_distance = 0
        while not routing.IsEnd(index):
            plan_output += ' {} -> '.format(manager.IndexToNode(index))
            previous_index = index
            index = solution.Value(routing.NextVar(index))
            route_distance += routing.GetArcCostForVehicle(
                previous_index, index, vehicle_id)
        plan_output += '{}\n'.format(manager.IndexToNode(index))
        plan_output += 'Distance of the route: {}m\n'.format(route_distance)
        # print(plan_output)
        routes.append(plan_output)
        max_route_distance = max(route_distance, max_route_distance)
        total_distance += route_distance
    # print('Maximum of the route distances: {}m'.format(max_route_distance))
    return max_route_distance, total_distance, routes

def gen_routes(data, manager, routing, solution):
    """Generate results."""
    # print(f'Objective: {solution.ObjectiveValue()}')
    max_route_distance = 0
    total_distance = 0
    routes = []
    plan_output = []
    for vehicle_id in range(data['num_vehicles']):
        index = routing.Start(vehicle_id)
        # plan_output = 'Route for vehicle {}:\n'.format(vehicle_id)
        route_distance = 0
        
        while not routing.IsEnd(index):
            plan_output.append(manager.IndexToNode(index))
            previous_index = index
            index = solution.Value(routing.NextVar(index))
            route_distance += routing.GetArcCostForVehicle(
                previous_index, index, vehicle_id)
        # plan_output += '{}\n'.format(manager.IndexToNode(index))
        # plan_output += 'Distance of the route: {}m\n'.format(route_distance)
        # print(plan_output)
        routes.append(plan_output)
        max_route_distance = max(route_distance, max_route_distance)
        total_distance += route_distance
    # print('Maximum of the route distances: {}m'.format(max_route_distance))
    return max_route_distance, total_distance, routes

def print_solution(data, manager, routing, solution):
    """Prints solution on console."""
    print(f'Objective: {solution.ObjectiveValue()}')
    max_route_distance = 0
    total_distance = 0
    for vehicle_id in range(data['num_vehicles']):
        index = routing.Start(vehicle_id)
        plan_output = 'Route for vehicle {}:\n'.format(vehicle_id)
        route_distance = 0
        while not routing.IsEnd(index):
            plan_output += ' {} -> '.format(manager.IndexToNode(index))
            previous_index = index
            index = solution.Value(routing.NextVar(index))
            route_distance += routing.GetArcCostForVehicle(
                previous_index, index, vehicle_id)
        plan_output += '{}\n'.format(manager.IndexToNode(index))
        plan_output += 'Distance of the route: {}m\n'.format(route_distance)
        print(plan_output)
        max_route_distance = max(route_distance, max_route_distance)
        total_distance += route_distance
    print('Maximum of the route distances: {}m'.format(max_route_distance))
    return max_route_distance, total_distance


def main(data):
    """Entry point of the program."""
    # Instantiate the data problem.

    # Create the routing index manager.
    manager = pywrapcp.RoutingIndexManager(len(data['distance_matrix']),
                                           data['num_vehicles'], data['depot'])

    # Create Routing Model.
    routing = pywrapcp.RoutingModel(manager)


    # Create and register a transit callback.
    def distance_callback(from_index, to_index):
        """Returns the distance between the two nodes."""
        # Convert from routing variable Index to distance matrix NodeIndex.
        from_node = manager.IndexToNode(from_index)
        to_node = manager.IndexToNode(to_index)
        return data['distance_matrix'][from_node][to_node]

    transit_callback_index = routing.RegisterTransitCallback(distance_callback)

    # Define cost of each arc.
    routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)

    # Add Distance constraint.
    dimension_name = 'Distance'
    routing.AddDimension(
        transit_callback_index,
        0,  # no slack
        3000,  # vehicle maximum travel distance
        True,  # start cumul to zero
        dimension_name)
    distance_dimension = routing.GetDimensionOrDie(dimension_name)
    distance_dimension.SetGlobalSpanCostCoefficient(100)

    # Setting first solution heuristic.
    search_parameters = pywrapcp.DefaultRoutingSearchParameters()
    search_parameters.first_solution_strategy = (
        routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC)

    # Solve the problem.
    solution = routing.SolveWithParameters(search_parameters)

    # Print solution on console.
    if solution:
        max_route_dist, total_distance, routes = gen_routes(data, manager, routing, solution)
        toc = time.perf_counter()
    else:
        print('No solution found !')
    return max_route_dist, total_distance, routes


if __name__ == '__main__':
    for vrp_size in [100]:
        print(f'Solving for vrp_size: {vrp_size}')
        tic = time.perf_counter()
        data = load_data_model(vrp_size)
        maxrtdist_results, totdist_results, routeslist = [],[],[]
        for sample in data:
            max_route_dist, total_distance, routes = main(sample)
            maxrtdist_results.append(max_route_dist)
            totdist_results.append(total_distance)
            routeslist.append(routes)
        toc = time.perf_counter()
        tottime = toc - tic
        print(f'Total time: {tottime}')
        maxrtdist_results = np.array(maxrtdist_results)
        totdist_results = np.array(totdist_results)
        avg_maxrt = np.mean(maxrtdist_results)
        avg_totdist = np.mean(totdist_results)
        print(f'Average max route distance: {avg_maxrt}')
        print(f'Average total distance: {avg_totdist}')

        with open('GLOP_routes'+str(vrp_size)+'.pkl', 'wb') as f:
            pickle.dump(routeslist, f, pickle.HIGHEST_PROTOCOL)
