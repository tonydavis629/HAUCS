from src.data.dataset import polygon, ponds, plot_poly, plot_pts

polygons = polygon(num_vrtx=4, xlims=[0, 1], ylims=[0, 1]).create_polygons(3)
plot_poly(polygons)
pp = ponds(density=35,polygon=polygons)
pond_cord = pp.pond_loc
plot_pts(pond_cord)