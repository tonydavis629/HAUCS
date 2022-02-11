import haucs
from haucs.data.dataset import PondsDataset, polygon, ponds, plot_poly, plot_pts
import matplotlib.pyplot as plt

def create_data(farms, num_polygons, density, xlims, ylims, depot_loc, show=bool):
    polygons = polygon(num_vrtx=4, xlims=xlims, ylims=ylims)
    multipoly, vertices= polygons.create_polygons(num_polygons)
    pp = ponds(density=density,polygon=multipoly, depot_loc=depot_loc) #first pond is home location

    if show==True:
        plot_poly(multipoly)
        plot_pts(pp.loc)
        plt.show()

    dataset = PondsDataset(farms=farms)
    
    return dataset

if __name__ == "__main__":

    pondset = create_data(farms = 10, num_polygons=3, density=.25, xlims=[0, 100], ylims=[0, 100], depot_loc=[50,50], show=False)

