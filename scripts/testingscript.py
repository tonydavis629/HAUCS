from haucs.data.dataset import PondsDataset, polygon, ponds
# pp = PondsDataset(2, 3, 10, [0,1],[0,1])
# print(pp.build_loc_dataset())

poly = polygon(num_vrtx=4, xlims=[0, 1], ylims=[0, 1])
multipoly,_=poly.create_polygons(3)
pond = ponds(num_pts=100, polygon = multipoly)
print(len(pond.loc))