from haucs.data.dataset import PondsDataset
import pickle
import matplotlib.pyplot as plt

# def create_data(farms, num_polygons, density, xlims, ylims, depot_loc, show=bool):
#     polygons = polygon(num_vrtx=4, xlims=xlims, ylims=ylims)
#     multipoly, vertices= polygons.create_polygons(num_polygons)
#     pp = ponds(density=density,polygon=multipoly, depot_loc=depot_loc) #first pond is home location

#     if show==True:
#         plot_poly(multipoly)
#         plot_pts(pp.loc)
#         plt.show()

#     dataset = PondsDataset(farms=farms, num_polygons=num_polygons, density=density, xlims=xlims, ylims=ylims, depot_loc=depot_loc)
#     return dataset

if __name__ == "__main__":

    # pondset = create_data(farms = 10, num_polygons=3, density=.25, xlims=[0, 100], ylims=[0, 100], depot_loc=[50,50], show=False)
    # data = PondsDataset(farms = 100, num_polygons=3, density=.25, num_vrtx=4, xlims=[0, 100], ylims=[0, 100], depot_loc=[50,50])
    for i in [100,300,500,700]:
        data = PondsDataset(farms=250, num_pts=i, xlims=[0, 1], ylims=[0, 1])
        dataset_loc = data.build_loc_dataset()
        with open('ponddataset_loc'+str(i)+'.pkl', 'wb') as f:
            pickle.dump(dataset_loc, f, pickle.HIGHEST_PROTOCOL)

        dataset_dm = data.build_dm_dataset()
        with open('ponddataset_dm'+str(i)+'.pkl', 'wb') as f:
            pickle.dump(dataset_dm, f, pickle.HIGHEST_PROTOCOL)