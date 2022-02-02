from haucs.data.dataset import PondsDataset, arr2cord, polygon, ponds, plot_poly, plot_pts
import matplotlib.pyplot as plt

def create_data(num_polygons, density, xlims, ylims, depot_loc, show=bool):
    polygons = polygon(num_vrtx=4, xlims=xlims, ylims=ylims)
    multipoly, vertices= polygons.create_polygons(num_polygons)
    pp = ponds(density=density,polygon=multipoly, depot_loc=depot_loc)

    if show==True:
        plot_poly(multipoly)
        plot_pts(pp.loc)
        plt.show()

    FAU_cordrange = [(26.36876368992361, 26.368727642878998),(-80.10428560129569, -80.10427487245977)]
    pond_cord = arr2cord(pp.loc,FAU_cordrange)
    return pond_cord

if __name__ == "__main__":

    create_data(num_polygons=3, density=2, xlims=[0, 1], ylims=[0, 1], depot_loc=[.5,.5], show=True)

