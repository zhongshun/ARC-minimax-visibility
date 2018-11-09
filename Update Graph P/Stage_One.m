clear
%%Initialize
addpath('c:/Users/Zhongshun Zhang/Desktop/ARC research/VisiLibity/VisiLibity.2016_12_26/src/');
addpath('.\Monte_Carlo')
addpath('Functions\')
load('data\Initial_No245.mat')
load('data\Graph.mat')
environment = read_vertices_from_file('c:/Users/Zhongshun Zhang/Desktop/ARC research/VisiLibity/VisiLibity.2016_12_26/src/MCTS1.environment');

%Plot_VisiLibity(10,1,environment, 'r')
%Plot_VisiLibity(1,13,environment, 'r')
%%
agent = 2*[4,3];
guard = 2*[20 10];%Initial guard position
load('data\Initial_No245.mat') % get the distribution of the guard up to T = 26
[Agent_VisiLibity, Guard_VisiLibity] = Plot_Environement(agent,guard,environment);
%%Input data
Negtive_Reward = 100;
Monte_Carlo = digraph([1],[]);
Monte_Carlo.Nodes.Robot_x= agent(1);
Monte_Carlo.Nodes.Robot_y= agent(2);
Monte_Carlo.Nodes.Generation = 1;
Monte_Carlo.Nodes.Parent = 0;
Monte_Carlo.Nodes.Robot_Region{1} = poly2mask(Agent_VisiLibity{1}(:,1),Agent_VisiLibity{1}(:,2),50, 50);
Monte_Carlo.Nodes.Robot_Reward = bwarea(Monte_Carlo.Nodes.Robot_Region{1});
Monte_Carlo.Nodes.Visited_Time = 0;
Monte_Carlo.Nodes.Total_Reward = 0;
Monte_Carlo.Nodes.UCB_Value = 99999;
Count = 1;
Total_Visited = 1;

%%
%Monte carlo tree rollout
for i = 1 :100
    %1. selection
    
    
end