# Installation

It is highly recommended you install HAUCS into a virtual environment. To install HAUCS to your environment, run

    git clone https://github.com/tonydavis629/HAUCS
    cd HAUCS
    pip install -e .

# Hybrid Aerial Underwater Robotic System
The Hybrid Aerial Underwater Robotic System (HAUCS) is a research project at Florida Atlantic University that aims to automate laborious tasks related to aquaculture. 

The first task to automate is the monitoring of fish pond dissolved oxygen (DO). DO is extremely important to closely monitor in aquaculture because DO depletion can result in rapid and catastrophic loss. 

This will be achieved by creating waypoint missions for a team of drones which will land in each pond with an oxygen sensor. The drones will report the measured DO to the central control server, which will continuously update the drone's missions in order to measure each pond at a frequency of once per hour. The goal is to have a system that can minimize the amount of drones needed to monitor each pond and be robust enough to redirect missions in case of drone failure or inclement weather. 

## Methods

A number of algorithms have been designed to solve this type of problem, commonly referred to as the vehicle routing problem. Our task is to visit each pond while  minimizing the number of drones required by minimizing the length of the longest single route. Each drone will start and end its mission at the same depot location.

This repository will implement multiple methods in order to compare and determine the most appropriate for our purpose. They are:

Optimal Path Planning Algorithm with a Back and Forth Pattern [1]

Attention Transformer Model [2]

Residual Edge-Graph Attention Network [3]

Google OR Tools [4]

Important considerations are the optimal gap and computational complexity. Aquaculture farms have hundreds of ponds, so using optimal methods to determine the drone routing will not be possible for larger farms. Optimality and computation time will be recorded for multiple simulated fish farms and compared.


#### References

[1] S. Mukherjee, B. Ouyang, K. Namuduri, and P. S. Wills, “Multi-Agent Systems (MAS) related data analytics in the Hybrid Aerial Underwater Robotic System (HAUCS),” in Big Data III: Learning, Analytics, and Applications, Online Only, United States, Apr. 2021, p. 13. doi: 10.1117/12.2588710.

[2] W. Kool, H. van Hoof, and M. Welling, “ATTENTION, LEARN TO SOLVE ROUTING PROBLEMS!,” p. 25, 2019.

[3] K. Lei, P. Guo, Y. Wang, X. Wu, and W. Zhao, “Solve routing problems with a residual edge-graph attention neural network,” arXiv:2105.02730 [cs], May 2021, Accessed: Jan. 07, 2022. [Online]. Available: http://arxiv.org/abs/2105.02730

[4] Google. (n.d.). Vehicle routing problem | OR-tools | google developers. Google. Retrieved January 18, 2022, from https://developers.google.com/optimization/routing/vrp 


