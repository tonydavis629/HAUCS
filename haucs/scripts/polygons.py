from data.dataset import PondsDataset, polygon, ponds, plot_poly, plot_pts
import matplotlib.pyplot as plt

polygons = polygon(num_vrtx=4, xlims=[0, 1], ylims=[0, 1])
multipoly, vertices= polygons.create_polygons(3)
plot_poly(multipoly)
print(vertices)
plt.show()