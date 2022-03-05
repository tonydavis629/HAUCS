from haucs.data.dataset import PondsDataset
import pickle
import matplotlib.pyplot as plt
import scipy.io as sio 

if __name__ == "__main__":

    for i in [50,100,200,300,500,700]:
        data = PondsDataset(farms=100, num_pts=i, xlims=[0, 1], ylims=[0, 1])

        GLOP = data.build_GLOP_dataset_2()
        with open('GLOP_dataset'+str(i)+'.pkl', 'wb') as f:
            pickle.dump(GLOP, f, pickle.HIGHEST_PROTOCOL)

        sized_ATSP_ds = data.build_ATSP_dataset_2()
        with open('ATSP_ponddataset'+str(i)+'.pkl', 'wb') as f:
            pickle.dump(sized_ATSP_ds, f, pickle.HIGHEST_PROTOCOL)

        (vertices,depot,loc,spacing) = data.build_HPP_dataset()
        ds_dic = {'vertices':vertices, 'ponds':loc, 'depot':depot, 'spacing':spacing}
        sio.savemat(str(i)+'ponds.mat',ds_dic)