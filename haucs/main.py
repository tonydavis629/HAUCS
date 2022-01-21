from scripts import create_data

if __name__ == '__main__':
    create_data.main(num_polygons=3, density=35, xlims=[0, 1], ylims=[0, 1], depot_loc=[.5,.5], show=False)