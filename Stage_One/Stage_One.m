clear
%%Initialize
addpath('c:/Users/Zhongshun Zhang/Desktop/ARC research/VisiLibity/VisiLibity.2016_12_26/src/');
addpath('.\Monte_Carlo')
addpath('Functions\')
%load('data\Initial_No245.mat')
load('data\Graph.mat')
environment = read_vertices_from_file('c:/Users/Zhongshun Zhang/Desktop/ARC research/VisiLibity/VisiLibity.2016_12_26/src/MCTS1.environment');

%Plot_VisiLibity(10,1,environment, 'r')
%Plot_VisiLibity(1,13,environment, 'r')
%%
agent = 2*[4,7];
Initial_Agent_Node = agent(1)/2 + 25*(agent(2)-2)/2;
guard = 2*[15 1];%Initial guard position
Initial_Guard_Node = guard(1)/2 + 25*(guard(2)-2)/2;
load('data\Initial_No15.mat') % get the distribution of the guard up to T = 26
[Agent_VisiLibity, Guard_VisiLibity] = Plot_Environement(agent,guard,environment);
%%Input data
Negtive_Reward = 100;
Monte_Carlo = digraph([1],[]);
Monte_Carlo.Nodes.Robot_GraphLabel = Initial_Agent_Node;
Monte_Carlo.Nodes.Robot_x= agent(1);
Monte_Carlo.Nodes.Robot_y= agent(2);

Monte_Carlo.Nodes.Generation = 1;
Monte_Carlo.Nodes.Parent = 0;
Monte_Carlo.Nodes.Robot_Region{1} = poly2mask(Agent_VisiLibity{1}(:,1),Agent_VisiLibity{1}(:,2),50, 50);
Monte_Carlo.Nodes.Robot_Reward = bwarea(Monte_Carlo.Nodes.Robot_Region{1});
Monte_Carlo.Nodes.Visited_Time = 1;
Monte_Carlo.Nodes.Total_Reward = 0;
Monte_Carlo.Nodes.UCB_Value = 99999;
Count = 1;
Total_Visited = 1;
Terminal_level = 10;
Plan_level = 15;

%%
%Monte carlo tree rollout
for i = 1 :10000
    v = 1;
    %%1. Selection
    [Monte_Carlo,v] = Monte_Carlo_Selection(Monte_Carlo,v);
    %%2. Expand or Rollout
    if Monte_Carlo.Nodes.Generation(v) ~= Terminal_level && Monte_Carlo.Nodes.Visited_Time(v) ~= 0
        %%Expand
        Monte_Carlo = Monte_Carlo_Expand(Monte_Carlo,v,environment,G);
    else
        %%Rollout Simulation
        roll_node = v;
        Rollout_Robot_Position = Monte_Carlo.Nodes.Robot_GraphLabel(roll_node);
        Rollout_Region = Monte_Carlo.Nodes.Robot_Region{v};
        Level = Monte_Carlo.Nodes.Generation(v);
        Random_Target = Random_Postion_Generator(p(Level,:));
        Rollout_Time_step = Plan_level - Monte_Carlo.Nodes.Generation(roll_node);
        Monte_Carlo_Reward = Monte_Carlo_Rollout(Rollout_Robot_Position, Random_Target,Rollout_Region, Rollout_Time_step, environment, Negtive_Reward,G);
        
        %% 3. Backpro pagation
        Backpropagation_node = roll_node;
        while Monte_Carlo.Nodes.Parent(Backpropagation_node) ~= 0
            Monte_Carlo.Nodes.Total_Reward(Backpropagation_node) = Monte_Carlo.Nodes.Total_Reward(Backpropagation_node) + Monte_Carlo_Reward;
            Monte_Carlo.Nodes.Visited_Time(Backpropagation_node) = Monte_Carlo.Nodes.Visited_Time(Backpropagation_node) + 1;
            Backpropagation_node = Monte_Carlo.Nodes.Parent(Backpropagation_node);
        end
            Monte_Carlo.Nodes.Total_Reward(Backpropagation_node) = Monte_Carlo.Nodes.Total_Reward(Backpropagation_node) + Monte_Carlo_Reward;
            Monte_Carlo.Nodes.Visited_Time(Backpropagation_node) = Monte_Carlo.Nodes.Visited_Time(Backpropagation_node) + 1;
    end
    
end