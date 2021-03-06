from logging import raiseExceptions
import numpy as np
import matplotlib.pyplot as plt
from shapely.geometry import Polygon, MultiPoint
from shapely.ops import unary_union

class polygon():
    """
    A set of ponds typically are fit into a polygon shape, so we generate a convex polygon shape
    """
    def __init__(self, num_vrtx, xlims, ylims):
        self.num_vrtx = num_vrtx
        self.xlims = xlims
        self.ylims = ylims
        self.x = np.random.uniform(self.xlims[0], self.xlims[1], self.num_vrtx)
        self.y = np.random.uniform(self.ylims[0], self.ylims[1], self.num_vrtx)
        self.polygon = Polygon(zip(self.x, self.y)).convex_hull

    def create_polygons(self, num_polygons):
        """
        Create multiple polygons and merge them into one
        """
        polygons = []
        for i in range(num_polygons):
            p = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
            polygons.append(p.polygon)

        merged_polygon = unary_union(polygons)
        try:
            vertices = list(merged_polygon.exterior.coords)
        except: #if there is a polygon which is disconnected
            merged_polygon = merged_polygon.convex_hull
            vertices = list(merged_polygon.exterior.coords)
        return merged_polygon, vertices

def plot_poly(poly): #todo: make as class method
    """
    Plot the polygon
    """
    xs, ys = poly.exterior.xy
    fig, axs = plt.subplots()
    axs.fill(xs, ys, alpha=1, fc='r', ec='none')
    plt.draw()
    plt.show(block=False)

class ponds(polygon):
    """
    Use the merged polygon to outline the shape of the ponds, then take a grid of points within the polygon to simulate a fish farm layout.
    """
    def __init__(self, num_pts, polygon, vertices):
        self.num_pts = num_pts
        self.xlims = [polygon.bounds[0], polygon.bounds[2]]
        self.ylims = [polygon.bounds[1], polygon.bounds[3]]
        self.polygon = polygon
        self.depot_loc = self.depot_loc()
        self.loc = self.pond_loc()
        self.distance_matrix = self.distance_matrix()
        self.spacing = .8/(np.sqrt(self.num_pts/self.polygon.area))
        self.vertices = vertices
        

    def depot_loc(self):
        """
        Set the depot location
        """
        x=np.random.random(1)[0]*(self.xlims[1]-self.xlims[0])+self.xlims[0]
        y=np.random.random(1)[0]*(self.ylims[1]-self.ylims[0])+self.ylims[0]
        return [x,y]

    def pond_loc(self):
        """
        Gives the pond locations based on the polygon and the density.
        """
        area = self.polygon.area
        pts = self.num_pts
        n = np.sqrt(pts/area) #density of points in 1 dimension
        
        xmin, xmax = self.xlims[0], self.xlims[1]
        ymin, ymax = self.ylims[0], self.ylims[1]
        
        x = np.arange(np.floor(xmin), np.ceil(xmax), .8/(n))  # .8 to make sure spacing is tighter so at least num_pts included
        y = np.arange(np.floor(ymin), np.ceil(ymax), .8/(n))
        points = MultiPoint(np.transpose([np.tile(x, len(y)), np.repeat(y, len(x))]))
        MP = points.intersection(self.polygon)

        loc = [(pt.x, pt.y) for pt in MP]

        while len(loc) > pts:
            loc.pop(np.random.randint(0, len(loc)))
            
        x=[]
        y=[]
        for i in loc:
            x.append(i[0])
            y.append(i[1])
        
        pond_loc_array = np.array([x,y]).T.tolist()
        return pond_loc_array

    def distance_matrix(self):
        """
        Creates the distance matrix based on the pond locations.

        """
        distance_matrix = np.zeros((self.num_pts, self.num_pts))
        loc = np.array(self.loc)

        for i in range(self.num_pts):
            for j in range(self.num_pts):
                distance_matrix[i,j] = np.sqrt((loc[i,0]-loc[j,0])**2 + (loc[i,1]-loc[j,1])**2)
        return distance_matrix.tolist()
 
    def plot_pts(self):
        """
        Plot the pond locations based off of the MultiPoint object
        """

        plt.figure()
        loc = np.array(self.loc)
        plt.plot(loc[:,0], loc[:,1], '.')
        plt.show(block=False)

def dist_matrix(loc):
    """
    Creates the distance matrix based on the pond locations.

    """
    size = loc.shape[0]
    distance_matrix = np.zeros((size, size))
    loc = np.array(loc)

    for i in range(size):
        for j in range(size):
            distance_matrix[i,j] = np.sqrt((loc[i,0]-loc[j,0])**2 + (loc[i,1]-loc[j,1])**2)
    return distance_matrix.tolist()

class PondsDataset(ponds):
    """
    Build PondsDataset which is used to simulate multiple farms. Each farm is made from a ponds object.
    """
    def __init__(self, farms, num_pts, xlims, ylims):
        self.farms = farms
        self.num_pts = num_pts
        self.num_vrtx = 3
        self.xlims = xlims
        self.ylims = ylims
        self.data = self.build_data()

    def build_data(self):
        dataset = []
        for _ in range(self.farms):
            shape = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
            multipoly,vertices  = shape.create_polygons(num_polygons=3)
            ponddata = ponds(num_pts=self.num_pts, polygon=multipoly, vertices=vertices)
            dataset.append(ponddata)
        return dataset
        

    # def build_dm_dataset(self):
    #     """
    #     Create the dataset
    #     """
    #     dataset = []
    #     for _ in range(self.farms):
    #         shape = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
    #         multipoly,_  = shape.create_polygons(num_polygons=3)
    #         ponddata = ponds(num_pts=self.num_pts, polygon=multipoly)
    #         dataset.append(ponddata.distance_matrix)
    #     return dataset

    # def build_loc_dataset(self):
    #     """
    #     Create the dataset
    #     """
    #     dataset = []
    #     for _ in range(self.farms):
    #         shape = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
    #         multipoly,_  = shape.create_polygons(num_polygons=3)
    #         ponddata = ponds(num_pts=self.num_pts, polygon=multipoly)
    #         dataset.append(ponddata.loc)
    #     return dataset

    # def build_shamos_dataset(self):
    #     """
    #     Create the dataset
    #     """
    #     vertices = []
    #     loc = []
    #     depot = []
    #     spacing = []
    #     for _ in range(self.farms):
    #         shape = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
    #         multipoly,vrtxset  = shape.create_polygons(num_polygons=3)
    #         ponddata = ponds(num_pts=self.num_pts, polygon=multipoly)
    #         spacing.append(ponddata.spacing)
    #         vertices.append(vrtxset)
    #         depot.append(ponddata.depot_loc)
    #         loc.append(ponddata.loc)
    #     return (vertices, depot, loc, spacing)

    def build_HPP_dataset(self):
        vertices = []
        loc = []
        depot = []
        spacing = []
        for farm in self.data:
            vertices.append(farm.vertices)
            depot.append(farm.depot_loc)
            loc.append(farm.loc)
            spacing.append(farm.spacing)
        return (vertices, depot, loc, spacing)

    # def build_ATSP_dataset(self):
    #     """
    #     Create the dataset
    #     """
    #     dataset = []
    #     for _ in range(self.farms):
    #         shape = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
    #         multipoly,_  = shape.create_polygons(num_polygons=3)
    #         ponddata = ponds(num_pts=self.num_pts, polygon=multipoly)
    #         depot = ponddata.depot_loc
    #         demand = np.ones(self.num_pts)
    #         capacity = (self.num_pts/5) + 1
    #         dataset.append((depot, ponddata.loc, demand, capacity))
    #     return dataset

    def build_ATSP_dataset_2(self):
        dataset = []
        for farm in self.data:
            depot = farm.depot_loc
            demand = np.ones(self.num_pts)
            capacity = (self.num_pts/5) + 1
            dataset.append((depot, farm.loc, demand, capacity))
        return dataset

    # def build_GLOP_dataset(self):
    #     """
    #     Create the dataset for google OR-tools
        
    #     Clean this up!
    #     """
    #     dataset = []
    #     for _ in range(self.farms):
    #         shape = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
    #         multipoly,_  = shape.create_polygons(num_polygons=3)
    #         ponddata = ponds(num_pts=self.num_pts, polygon=multipoly)
            
    #         nodes = np.array(ponddata.loc)
    #         depot = ponddata.depot_loc
    #         node_depot = np.insert(nodes, 0, depot, axis=0)
            
    #         scaled = node_depot*1000
    #         dm = dist_matrix(scaled)

    #         farm_dic = {'distance_matrix': dm, 'depot': 0, 'num_vehicles' : 5 }

    #         dataset.append(farm_dic)
    #     return dataset

    def build_GLOP_dataset_2(self):
        dataset = []
        for farm in self.data:
            nodes = np.array(farm.loc)
            depot = farm.depot_loc
            node_depot = np.insert(nodes, 0, depot, axis=0)
            
            scaled = node_depot*1000
            dm = dist_matrix(scaled)

            farm_dic = {'distance_matrix': dm, 'depot': 0, 'num_vehicles' : 5 }

            dataset.append(farm_dic)
        return dataset

def node_data(size, lims):
    poly = polygon(num_vrtx=4, xlims=[0, lims], ylims=[0, lims])
    multipoly,_=poly.create_polygons(3)
    pond = ponds(num_pts=size, polygon = multipoly)
    return pond.loc