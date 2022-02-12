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

def plot_poly(poly):
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
    def __init__(self, density, polygon, depot_loc):
        self.density = density
        self.xlims = [polygon.bounds[0], polygon.bounds[2]]
        self.ylims = [polygon.bounds[1], polygon.bounds[3]]
        self.polygon = polygon
        self.depot_loc = depot_loc
        self.loc = self.pond_loc()
        self.distance_matrix = self.distance_matrix()

    def pond_loc(self):
        """
        Gives the pond locations based on the polygon and the density.
        """
        n = self.density
        xmin, xmax = self.xlims[0], self.xlims[1]
        ymin, ymax = self.ylims[0], self.ylims[1]
        x = np.arange(np.floor(xmin * n) / n, np.ceil(xmax * n) / n, 1 / n)  
        y = np.arange(np.floor(ymin * n) / n, np.ceil(ymax * n) / n, 1 / n)  
        points = MultiPoint(np.transpose([np.tile(x, len(y)), np.repeat(y, len(x))]))
        MP = points.intersection(self.polygon)

        x=[]
        y=[]
        for i in range(len(MP)):
            x.append(MP[i].x)
            y.append(MP[i].y)
        pond_loc_array = np.array([x,y]).T
        ponds_depot=np.insert(pond_loc_array, 0, self.depot_loc, axis=0) #home location / depot location is set as first row in the array
        return ponds_depot

    def distance_matrix(self):
        """
        Creates the distance matrix based on the pond locations.
        """
        distance_matrix = np.zeros((len(self.loc), len(self.loc)))
        for i in range(len(self.loc)):
            for j in range(len(self.loc)):
                distance_matrix[i,j] = np.linalg.norm(self.loc[i] - self.loc[j])
        return distance_matrix.tolist()

        
def plot_pts(pond_loc_array):
    """
    Plot the pond locations based off of the MultiPoint object
    """

    plt.figure()
    plt.plot(pond_loc_array[:,0], pond_loc_array[:,1], '.')
    plt.show(block=False)

class PondsDataset(ponds):
    """
    Build PondsDataset which is used to simulate multiple farms. Each farm is made from a ponds object.
    """
    def __init__(self, farms, num_polygons, density, num_vrtx, xlims, ylims, depot_loc):
        self.farms = farms
        self.density = density
        self.num_vrtx = num_vrtx
        self.xlims = xlims
        self.ylims = ylims
        self.depot_loc = depot_loc
        self.num_polygons = num_polygons
        # self.dataset = self.build_dataset()

    def build_dm_dataset(self):
        """
        Create the dataset
        """
        dataset = []
        for _ in range(self.farms):
            shape = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
            multipoly,_  = shape.create_polygons(num_polygons=self.num_polygons)
            ponddata = ponds(density=self.density, polygon=multipoly, depot_loc=self.depot_loc)
            dataset.append(np.asarray(ponddata.distance_matrix))
        return dataset

    def build_loc_dataset(self):
        """
        Create the dataset
        """
        dataset = []
        for _ in range(self.farms):
            shape = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
            multipoly,_  = shape.create_polygons(num_polygons=self.num_polygons)
            ponddata = ponds(density=self.density, polygon=multipoly, depot_loc=self.depot_loc)
            dataset.append(np.asarray(ponddata.loc))
        return dataset