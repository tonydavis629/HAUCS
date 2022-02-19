from haucs.data.dataset import PondsDataset, polygon, ponds, plot_poly
import matplotlib.pyplot as plt

poly = polygon(num_vrtx=4, xlims=[0, 1], ylims=[0, 1])
multipoly,vertices=poly.create_polygons(3)
pond = ponds(num_pts=100, polygon = multipoly)
plot_poly(multipoly)
vrtx = np.array(vertices)
plt.plot(vrtx[:,0],vrtx[:,1])
plt.show()