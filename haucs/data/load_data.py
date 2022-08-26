from haucs.data.dataset import PondsDataset
from haucs.utils.utils import coord2arr
import pickle
import matplotlib.pyplot as plt
import scipy.io as sio 
import numpy as np

if __name__ == "__main__":
    
    coords = np.loadtxt('C:\\Users\\anthonydavis2020\\Documents\github\\HAUCS\\haucs\\pondsmall.txt')
    ILponds, lat_range, long_range = coord2arr(coords)
    # ILponds = np.loadtxt('C:\\Users\\anthonydavis2020\\Documents\\github\\HAUCS\\haucs\\ILnormcoordsmall.txt', delimiter=',')

    data = PondsDataset(farms=1, num_pts=5, xlims=[0, 1], ylims=[0, 1])
    data.data = ILponds
    
    # sized_ATSP_ds = data.load_ATSP_dataset()
    # with open('C:\\Users\\anthonydavis2020\\Documents\\github\\HAUCS\\haucs\\ATSP_IL.pkl', 'wb') as f:
    #     pickle.dump(sized_ATSP_ds, f, pickle.HIGHEST_PROTOCOL)
    
    GLOP = data.load_GLOP_dataset()
    with open('C:\\Users\\anthonydavis2020\\Documents\\github\\HAUCS\\haucs\\GLOP_dataset_ILsmall.pkl', 'wb') as f:
        pickle.dump(GLOP, f, pickle.HIGHEST_PROTOCOL)

    # HPP data written in matlab in solvers/HPP