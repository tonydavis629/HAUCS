from haucs.data.dataset import PondsDataset, polygon, ponds, plot_poly
import matplotlib.pyplot as plt

polygons = polygon(num_vrtx=4, xlims=[0, 1000], ylims=[0, 1000])
multipoly, vertices= polygons.create_polygons(3)
pond = ponds(num_pts=300, polygon = multipoly)
pond.plot_pts()
plt.show()