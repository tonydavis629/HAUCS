from haucs.data.dataset import PondsDataset, polygon, ponds, plot_poly
import numpy as np
import pickle
import matplotlib.pyplot as plt

polygons = polygon(num_vrtx=4, xlims=[0,100], ylims=[0,100])
multipoly, vertices= polygons.create_polygons(5)
pp = ponds(num_pts=800,polygon=multipoly, depot_loc=[50,50]) #first pond is home location

pp.plot_pts()
plt.show()
