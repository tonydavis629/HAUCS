# Hybrid Aerial Underwater Robotic System
The Hybrid Aerial Underwater Robotic System (HAUCS) is a research project at Florida Atlantic University that aims to automate laborious tasks related to aquaculture. 

The first task to automate is the monitoring of fish pond dissolved oxygen (DO). DO is extremely important to closely monitor in aquaculture because DO depletion can result in rapid and catastrophic loss. 

This will be achieved by creating waypoint missions for a team of drones which will land in each pond with an oxygen sensor. The drones will report the measured DO to the central control server, which will continuously update the drone's missions in order to measure each pond at a frequency of once per hour. The goal is to have a system that can minimize the amount of drones needed and be robust enough to redirect missions in case of drone failure or inclement weather. 

## Methods

A number of algorithms have been designed to solve this type of problem, commonly referred to as the vehicle routing problem. Our task is to visit each pond within a monitoring cycle once and return to the depot, while  minimizing the number of drones required by taking the most efficient paths. 

This repository will implement multiple methods in order to determine the most appropriate for our purpose. They are:

Optimal Path Planning Algorithm with a Back and Forth Pattern [Mukherjee]
Attention Model [Kool]

Google OR Tools [Google]