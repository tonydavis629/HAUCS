from haucs.data.dataset import PondsDataset, polygon, ponds, plot_poly
import pickle
import matplotlib.pyplot as plt

polygons = polygon(num_vrtx=4, xlims=[0,1], ylims=[0,1])
multipoly, vertices= polygons.create_polygons(3)
pp = ponds(density=35,num_pts=200,polygon=multipoly, depot_loc=[.5,.5]) #first pond is home location


plot_poly(multipoly)
pp.plot_pts()
plt.show()
