from haucs.data.dataset import PondsDataset
import pickle
import matplotlib.pyplot as plt

if __name__ == "__main__":

    for i in [50]:
        data = PondsDataset(farms=10, num_pts=i, xlims=[0, 1], ylims=[0, 1])

        GLOP = data.build_GLOP_dataset()
        with open('GLOP_dataset'+str(i)+'.pkl', 'wb') as f:
            pickle.dump(GLOP, f, pickle.HIGHEST_PROTOCOL)