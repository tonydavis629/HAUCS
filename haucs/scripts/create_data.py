import sys
sys.path.append("..")
from data.dataset import PondsDataset, polygon, ponds, plot_poly, plot_pts
import matplotlib.pyplot as plt

def main(num_polygons, density, xlims, ylims, depot_loc, show=bool):
    polygons = polygon(num_vrtx=4, xlims=xlims, ylims=ylims)
    multipoly, vertices= polygons.create_polygons(num_polygons)
    plot_poly(multipoly)
    pp = ponds(density=density,polygon=multipoly, depot_loc=depot_loc)
    plot_pts(pp.pond_loc)

    if show==True:
        plt.show()

    # pond_ds = PondsDataset(pp)
    # print(pond_ds.distance_matrix)
if __name__ == "__main__":

    # main(sys.argv)
    main(num_polygons=3, density=35, xlims=[0, 1], ylims=[0, 1], depot_loc=[.5,.5], show=True)

