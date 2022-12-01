

# Hybrid Aerial Underwater Robotic System
The Hybrid Aerial Underwater Robotic System (HAUCS) is a USDA funded research project at the Florida Atlantic University Harbor Branch Oceanographic Institute that aims to automate laborious aquaculture tasks. 

The first task to automate is the monitoring of fish pond dissolved oxygen (DO). DO is extremely important to monitor in aquaculture because DO depletion can result in rapid and catastrophic loss of fish. With HAUCS, aquaculture farmers can monitor their ponds' DO levels through an android application which reports realtime data, removing the need to measure the ponds by hand multiple times a day and at night.

This is achieved by coordinating a waterproof drone swarm equipped with DO and water quality sensors on their underside to land in each pond at regular intervals. The drones wirelessly transmit the measured DO to the central control server, which will continuously update the drone's missions in order to measure each pond at a frequency of once per hour. Time series DO models can be used to predict the value of DO given the current temperature, weather, wind, and color of the ponds in order to plan routes mroe effectively. The control system will make changes to routes in realtime in order to deal with inclement weather and hardware failures.

Future work will involve integrating autonomously controlled aerators to mix oxygen into ponds whose DO are too low.

## Installation

It is highly recommended you install HAUCS into a virtual environment. To install HAUCS, run

    git clone https://github.com/tonydavis629/HAUCS.git
    cd HAUCS
    pip install -e .
    pip install -r requirements.txt

## Routing Methods

A number of algorithms have been designed to solve this type of problem, commonly referred to as the vehicle routing problem. This repository implements multiple methods in haucs/solvers, they are:

HAUCS Path Planning Algorithm (HPP) [1][2] 

Graph Attention Transformer Model (GAM) [3]

Google Linear Optimization Package (GLOP) [4]

We compare them on simulated and field data to determine the most appropriate for our purpose. So far, our results and testing indicate that HPP is best for large scale farms (>200 ponds), while GLOP and GAM are best for smaller farms (<200 ponds).

## Sensor software

Code controlling the various sensors on the HAUCS drones are included in `payload`, `topside`, and `basestation`.

## Android

Firebase is used as the cloud platform for managing the pond data. Code for the Firebase instance and its Android application are found in `mobile_app`.

## References

[1] A. Davis, S. Mukherjee, P. S. Wills, and B. Ouyang, “Path planning algorithms for robotic aquaculture monitoring,” in Big Data IV: Learning, Analytics, and Applications, Orlando, United States, May 2022, p. 26. doi: 10.1117/12.2618783.

[2] S. Mukherjee, B. Ouyang, K. Namuduri, and P. S. Wills, “Multi-Agent Systems (MAS) related data analytics in the Hybrid Aerial Underwater Robotic System (HAUCS),” in Big Data III: Learning, Analytics, and Applications, Online Only, United States, Apr. 2021, p. 13. doi: 10.1117/12.2588710.

[3] W. Kool, H. van Hoof, and M. Welling, “Attention, Learn to Solve Routing Problems!” arXiv, Feb. 07, 2019. Accessed: Sep. 13, 2022. [Online]. Available: http://arxiv.org/abs/1803.08475

[4] Google. Vehicle routing problem | OR-tools | google developers. https://developers.google.com/optimization/routing/vrp 

## Citation

```
@inproceedings{https://doi.org/10.48550/arxiv.2204.09753,
  doi = {10.48550/ARXIV.2204.09753},
  url = {https://arxiv.org/abs/2204.09753},
  author = {Davis, Anthony and Mukherjee, Srijita and Wills, Paul S. and Ouyang, Bing},
  keywords = {Robotics (cs.RO), FOS: Computer and information sciences, FOS: Computer and information sciences},
  title = {Path Planning Algorithms for Robotic Aquaculture Monitoring},
  publisher = {arXiv},
  year = {2022},
  copyright = {Creative Commons Attribution 4.0 International}
}
```
