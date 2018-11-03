clear
addpath('c:/Users/Zhongshun Zhang/Desktop/ARC research/VisiLibity/VisiLibity.2016_12_26/src/');
environment = read_vertices_from_file('c:/Users/Zhongshun Zhang/Desktop/ARC research/VisiLibity/VisiLibity.2016_12_26/src/MCTS1.environment');
agent = 2*[1,2];
guard = 2*[1 10];
[Agent_VisiLibity, Guard_VisiLibity] = Plot_Environement(agent,guard,environment);
Plot_VisiLibity(10,1,environment)