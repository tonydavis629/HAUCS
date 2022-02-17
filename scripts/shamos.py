from haucs.data.dataset import polygon, ponds

def shamos():
    polygons = polygon(num_vrtx=4, xlims=[0, 1], ylims=[0, 1])
    multipoly, vertices= polygons.create_polygons(num_polygons=3)
    pondset = ponds(num_pts=100,polygon=multipoly) 
    return vertices


