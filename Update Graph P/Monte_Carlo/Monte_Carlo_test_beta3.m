clear all; close all; clc;
%Robustness constant
epsilon = 0.000000001;


%Snap distance (distance within which an observer location will be snapped to the
%boundary before the visibility polygon is computed)
snap_distance = 0.05;


%Read environment geometry from file
environment = read_vertices_from_file('./MCTS1.environment');


%Calculate a good plot window (bounding box) based on outer polygon of environment
environment_min_x = min(environment{1}(:,1));
environment_max_x = max(environment{1}(:,1));
environment_min_y = min(environment{1}(:,2));
environment_max_y = max(environment{1}(:,2));
X_MIN = environment_min_x-0.1*(environment_max_x-environment_min_x);
X_MAX = environment_max_x+0.1*(environment_max_x-environment_min_x);
Y_MIN = environment_min_y-0.1*(environment_max_y-environment_min_y);
Y_MAX = environment_max_y+0.1*(environment_max_y-environment_min_y);


%Initial Information
Initial_Robot = [1;1];
Initial_Target = [30;1];
End_Step = 2;

%Clear plot and form window with desired properties
clf; set(gcf,'position',[200 500 700 600]); hold on;
axis equal; axis off; axis([X_MIN X_MAX Y_MIN Y_MAX]);


clf; set(gcf,'position',[200 500 700 600]); hold on;
axis equal; axis off; axis([X_MIN X_MAX Y_MIN Y_MAX]);

%Plot environment
patch( environment{1}(:,1) , environment{1}(:,2) , 0.1*ones(1,length(environment{1}(:,1)) ) , ...
    'w' , 'linewidth' , 1.5 );
for i = 2 : size(environment,2)
    patch( environment{i}(:,1) , environment{i}(:,2) , 0.1*ones(1,length(environment{i}(:,1)) ) , ...
        'k' , 'EdgeColor' , [0 0 0] , 'FaceColor' , [0.8 0.8 0.8] , 'linewidth' , 1.5 );
end


%             Plot observer
plot3( Initial_Robot(1) , Initial_Robot(2) , 0.3 , ...
    'o' , 'Markersize' , 5 , 'MarkerEdgeColor' , [0.6,0.9,0.6]  , 'MarkerFaceColor' , 'k' );
plot3( Initial_Target(1) , Initial_Target(2) , 0.3 , ...
    '*' , 'Markersize' , 5 , 'MarkerEdgeColor' , 'b' , 'MarkerFaceColor' , 'k' );
hold on

%Compute and plot visibility polygon
W{1} = visibility_polygon( [Initial_Target(1) Initial_Target(2)] , environment , epsilon , snap_distance );

patch( W{1}(:,1) , W{1}(:,2) , 0.1*ones( size(W{1},1) , 1 ) , ...
    'y' , 'linewidth' , 1.5 );
plot3( W{1}(:,1) , W{1}(:,2) , 0.1*ones( size(W{1},1) , 1 ) , ...
    'b*' , 'Markersize' , 5 );



%Compute and plot visibility polygon for the target
V{1} = visibility_polygon( [Initial_Robot(1) Initial_Robot(2)] , environment , epsilon , snap_distance );
Area = polyarea(V{1}(:,1),V{1}(:,2));
Reward(Initial_Robot(1),Initial_Robot(2)) = Area;

patch( V{1}(:,1) , V{1}(:,2) , 0.1*ones( size(V{1},1) , 1 ) , ...
    [0.9,0.6,0.6] , 'linewidth' , 1.5 );
plot3( V{1}(:,1) , V{1}(:,2) , 0.1*ones( size(V{1},1) , 1 ) , ...
    'b*' , 'Markersize' , 5 );
hold off




Negtive_Reward = 30;
Total_scan = false(1000,1000);
%Root node
Monte_Carlo = digraph([1],[]);
Monte_Carlo.Nodes.Robot_x= Initial_Robot(1);
Monte_Carlo.Nodes.Robot_y= Initial_Robot(2);
Monte_Carlo.Nodes.Target_x=Initial_Target(1);
Monte_Carlo.Nodes.Target_y=Initial_Target(2);
Monte_Carlo.Nodes.Generation = 1;
Monte_Carlo.Nodes.Parent = 0;
Monte_Carlo.Nodes.Robot_Region{1} = poly2mask(V{1}(:,1),V{1}(:,2),50, 50);
Monte_Carlo.Nodes.Robot_Reward = bwarea(Monte_Carlo.Nodes.Robot_Region{1});
Monte_Carlo.Nodes.Visited_Time = 1;
Monte_Carlo.Nodes.Total_Reward = 0;
Monte_Carlo.Nodes.Detection_time = 0;
Monte_Carlo.Nodes.UCB_Value = 99999;
Count = 1;
Total_Visited = 1;
Terminal_level = 19;
Plan_level = 21;

%Build the monte carlo tree

%%
%Monte carlo tree rollout
% for i = 1 :3000
while 1
    %pause(0.1)
    v = 1;
    %%selection
    [Monte_Carlo,v] = Monte_Carlo_Selection(Monte_Carlo,v);
    %% expand or rollout
    if Monte_Carlo.Nodes.Generation(v) ~= Terminal_level && Monte_Carlo.Nodes.Visited_Time(v) ~= 0 
        Monte_Carlo = Monte_Carlo_Expand(Monte_Carlo,v,environment);
    else %2. Start Rollout Simulation
        roll_node = v;
        Rollout_Robot_Position = [ Monte_Carlo.Nodes.Robot_x(roll_node); Monte_Carlo.Nodes.Robot_y(roll_node) ];
        Rollout_Target_Position = [ Monte_Carlo.Nodes.Target_x(roll_node); Monte_Carlo.Nodes.Target_y(roll_node) ];
        Rollout_Time_step = Plan_level - fix(Monte_Carlo.Nodes.Generation(roll_node)/2);
        Monte_Carlo_Reward = Monte_Carlo_Rollout(Rollout_Robot_Position, Rollout_Target_Position, Monte_Carlo.Nodes.Detection_time(roll_node),Rollout_Time_step, environment, Negtive_Reward);
        %% 3. Backpro pagation
        Monte_Carlo.Nodes.Total_Reward(roll_node) = Monte_Carlo.Nodes.Total_Reward(roll_node) + Monte_Carlo_Reward;
        Monte_Carlo.Nodes.Visited_Time(roll_node) = Monte_Carlo.Nodes.Visited_Time(roll_node) + 1;
%         if mod(Monte_Carlo.Nodes.Generation(roll_node),2)
%             Monte_Carlo.Nodes.UCB_Value(roll_node) = UCBmin_function(Monte_Carlo.Nodes.Total_Reward(roll_node), Monte_Carlo.Nodes.Visited_Time(roll_node), Monte_Carlo.Nodes.Visited_Time(1));
%         else
%             Monte_Carlo.Nodes.UCB_Value(roll_node) = UCBmax_function(Monte_Carlo.Nodes.Total_Reward(roll_node), Monte_Carlo.Nodes.Visited_Time(roll_node), Monte_Carlo.Nodes.Visited_Time(1));
%         end
%         
        
        Backpropagation_node = roll_node;
        while Monte_Carlo.Nodes.Parent(Backpropagation_node) ~= 0
            Backpropagation_node = Monte_Carlo.Nodes.Parent(Backpropagation_node);
            Monte_Carlo.Nodes.Total_Reward(Backpropagation_node) = Monte_Carlo.Nodes.Total_Reward(Backpropagation_node) + Monte_Carlo_Reward;
            Monte_Carlo.Nodes.Visited_Time(Backpropagation_node) = Monte_Carlo.Nodes.Visited_Time(Backpropagation_node) + 1;
%             if mod(Monte_Carlo.Nodes.Generation(Backpropagation_node),2)
%                 Monte_Carlo.Nodes.UCB_Value(Backpropagation_node) = UCBmin_function(Monte_Carlo.Nodes.Total_Reward(Backpropagation_node), Monte_Carlo.Nodes.Visited_Time(Backpropagation_node), Monte_Carlo.Nodes.Visited_Time(1));
%             else
%                 Monte_Carlo.Nodes.UCB_Value(Backpropagation_node) = UCBmax_function(Monte_Carlo.Nodes.Total_Reward(Backpropagation_node), Monte_Carlo.Nodes.Visited_Time(Backpropagation_node), Monte_Carlo.Nodes.Visited_Time(1));
%             end
        end
    end

%     for j = 1:nnz(Monte_Carlo.Nodes.Robot_x)
%         if mod(Monte_Carlo.Nodes.Generation(j),2)
%             Monte_Carlo.Nodes.UCB_Value(j) = UCBmin_function(Monte_Carlo.Nodes.Total_Reward(j), Monte_Carlo.Nodes.Visited_Time(j), Monte_Carlo.Nodes.Visited_Time(1));
%         else
%             Monte_Carlo.Nodes.UCB_Value(j) = UCBmax_function(Monte_Carlo.Nodes.Total_Reward(j), Monte_Carlo.Nodes.Visited_Time(j), Monte_Carlo.Nodes.Visited_Time(1));
%         end
%     end
end

%     plot(Monte_Carlo);


%%plot the best path
P = 1;
path = 1;
sucIDs = successors(Monte_Carlo,P);
while nnz(sucIDs) 
        max_Visited_Time = max(Monte_Carlo.Nodes.Visited_Time(sucIDs));
        ID = find(Monte_Carlo.Nodes.Visited_Time(sucIDs) == max_Visited_Time);
        P = sucIDs(ID(1));
        path = [path P];
        sucIDs = successors(Monte_Carlo,P);
end

Robot_Position = [Initial_Robot(1); Initial_Robot(2)];
Target_Position = [Initial_Target(1); Initial_Target(2)];

for k=2:nnz(path)
    if ~mod(k,2)
        Robot_Position = [Robot_Position [Monte_Carlo.Nodes.Robot_x(path(k)); Monte_Carlo.Nodes.Robot_y(path(k))]];
    else
        Target_Position = [Target_Position [Monte_Carlo.Nodes.Target_x(path(k)); Monte_Carlo.Nodes.Target_y(path(k))]];
    end
        
end


