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
        Create multiple polygons and put them in a list
        """
        polygons = []
        for i in range(num_polygons):
            p = polygon(num_vrtx=self.num_vrtx, xlims=self.xlims, ylims=self.ylims)
            polygons.append(p.polygon)

        # merged_polygon = polygons[0] 
        # # for i,poly in enumerate(polygons):
        #     merged_polygon = merged_polygon.unary_union(poly)
        merged_polygon = unary_union(polygons)
        return merged_polygon

def plot_poly(poly):
    """
    Plot the polygon
    """
    xs, ys = poly.exterior.xy
    fig, axs = plt.subplots()
    axs.fill(xs, ys, alpha=1, fc='r', ec='none')
    plt.draw()
    plt.show(block = False)

class ponds(polygon):
    """
    Use the merged polygon to outline the shape of the ponds, then take a grid of points within the polygon to simulate a fish farm layout.
    """
    def __init__(self, density, polygon):
        self.density = density
        self.xlims = [polygon.bounds[0], polygon.bounds[2]]
        self.ylims = [polygon.bounds[1], polygon.bounds[3]]
        self.polygon = polygon
        self.pond_loc = self.pond_loc()

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

        w=[]
        z=[]
        for i in range(len(MP)):
            w.append(MP[i].x)
            z.append(MP[i].y)
        pond_loc_array = np.array([w,z])
        return pond_loc_array.T
        
def plot_pts(pond_loc_array):
    """
    Plot the pond locations based off of the MultiPoint object
    """

    plt.figure()
    plt.plot(pond_loc_array[:,0], pond_loc_array[:,1], '.')
    plt.show(block = False)

class PondsDataset(ponds):
    """
    Build Dataset object using the pond_loc_array. This is used to create the distance matrix.
    """
    def __init__(self, pond_loc_array, depot_loc):
        self.depot_loc = depot_loc
        self.pond_loc = pond_loc_array.insert(0, self.depot_loc, axis=0)
        self.distance_matrix = self.distance_matrix()
    def distance_matrix(self):
        """
        Creates the distance matrix based on the pond locations.
        """
        distance_matrix = np.zeros((len(self.pond_loc), len(self.pond_loc)))
        for i in range(len(self.pond_loc)):
            for j in range(len(self.pond_loc)):
                distance_matrix[i,j] = np.linalg.norm(self.pond_loc[i] - self.pond_loc[j])
        return distance_matrix
