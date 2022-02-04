from haucs.data.dataset import PondsDataset, arr2cord, polygon, ponds, plot_poly, plot_pts

polygons = polygon(num_vrtx=4, xlims=[0, 1], ylims=[0, 1])
multipoly, vertices= polygons.create_polygons(num_polygons=3)
pondset = ponds(density=5,polygon=multipoly, depot_loc=[.5,.5])
print(pondset.loc)