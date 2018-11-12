function Monte_Carlo_Reward = Monte_Carlo_Rollout(Agent, Guard, Rollout_Region, Time_step, environment, Negtive_Reward,G)
% clear Vis
format long;
Graph = G;

%Robustness constant
epsilon = 0.000000001;


%Snap distance (distance within which an observer location will be snapped to the
%boundary before the visibility polygon is computed)
snap_distance = 0.05;


%Read environment geometry from file
environment_min_x = min(environment{1}(:,1));
environment_max_x = max(environment{1}(:,1));
environment_min_y = min(environment{1}(:,2));
environment_max_y = max(environment{1}(:,2));
X_MIN = environment_min_x-0.1*(environment_max_x-environment_min_x);
X_MAX = environment_max_x+0.1*(environment_max_x-environment_min_x);
Y_MIN = environment_min_y-0.1*(environment_max_y-environment_min_y);
Y_MAX = environment_max_y+0.1*(environment_max_y-environment_min_y);

%The x-y coordinate position
Guard_x = G.Nodes.Position_x(Guard)*2;
Guard_y = G.Nodes.Position_y(Guard)*2;

Agent_x = G.Nodes.Position_x(Agent)*2;
Agent_y = G.Nodes.Position_y(Agent)*2;
%Compute and plot visibility polygon
W{1} = visibility_polygon( [Guard_x Guard_y] , environment , epsilon , snap_distance );
%Compute and plot visibility polygon for the target
V{1} = visibility_polygon( [Agent_x Agent_y] , environment , epsilon , snap_distance );

Total_scan = Rollout_Region;

%Monte_Carlo.Nodes.Detection_time = Detection_time;


for Count = 1:Time_step
    
    if in_environment( [Agent_x Agent_y] , W , epsilon )        
        Monte_Carlo_Reward = bwarea(Total_scan) - Negtive_Reward;
        return
    end
    
    
    
    
    %Agent_move
    Agent_child_Nodes = neighbors(Graph,Agent);
    Agent_next = Agent_child_Nodes(randi([1,nnz(Agent_child_Nodes)]));
    Agent_x = G.Nodes.Position_x(Agent_next)*2;
    Agent_y = G.Nodes.Position_y(Agent_next)*2;
    V{1} = visibility_polygon( [Agent_x Agent_y] , environment , epsilon , snap_distance );
    Total_scan = poly2mask(V{1}(:,1),V{1}(:,2),50, 50) | Total_scan;
    
    %Guard_move
    Guard_child_Nodes = neighbors(Graph,Guard);
    Guard_next = Guard_child_Nodes(randi([1,nnz(Guard_child_Nodes)]));
    Guard_x = 2*G.Nodes.Position_x(Guard_next)*2;
    Guard_y = 2*G.Nodes.Position_y(Guard_next)*2;
    W{1} = visibility_polygon( [Guard_x Guard_y] , environment , epsilon , snap_distance );       
     %caculate reward value     
end
    if in_environment( [Agent_x Agent_y] , W , epsilon )        
        Monte_Carlo_Reward = bwarea(Total_scan) - Negtive_Reward;
    else
        Monte_Carlo_Reward = bwarea(Total_scan);
    end


end