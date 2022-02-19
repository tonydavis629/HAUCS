from haucs.data.dataset import PondsDataset
import pickle
import matplotlib.pyplot as plt

if __name__ == "__main__":

    for i in [50,100,200,300,500,700]:
        data = PondsDataset(farms=250, num_pts=i, xlims=[0, 1], ylims=[0, 1])
        dataset_loc = data.build_loc_dataset()
        with open('ponddataset_loc'+str(i)+'.pkl', 'wb') as f:
            pickle.dump(dataset_loc, f, pickle.HIGHEST_PROTOCOL)

        dataset_dm = data.build_dm_dataset()
        with open('ponddataset_dm'+str(i)+'.pkl', 'wb') as f:
            pickle.dump(dataset_dm, f, pickle.HIGHEST_PROTOCOL)