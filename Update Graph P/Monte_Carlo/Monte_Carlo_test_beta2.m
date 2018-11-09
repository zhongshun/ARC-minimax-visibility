clear all; close all; clc;
%Robustness constant
epsilon = 0.000000001;


%Snap distance (distance within which an observer location will be snapped to the
%boundary before the visibility polygon is computed)
snap_distance = 0.05;


%Read environment geometry from file
environment = read_vertices_from_file('./ARC_1.environment');


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
Initial_Robot = [1;15];
Initial_Target = [7;9];
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
    'o' , 'Markersize' , 15 , 'MarkerEdgeColor' , [0.6,0.9,0.6]  , 'MarkerFaceColor' , 'k' );
plot3( Initial_Target(1) , Initial_Target(2) , 0.3 , ...
    '*' , 'Markersize' , 15 , 'MarkerEdgeColor' , 'b' , 'MarkerFaceColor' , 'k' );
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

 


Negtive_Reward = 10;
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
Monte_Carlo.Nodes.Visited_Time = 0;
Monte_Carlo.Nodes.Total_Reward = 0;
Monte_Carlo.Nodes.UCB_Value = 99999;
Count = 1;
Total_Visited = 1;

%Build the monte carlo tree

%robot_move
Parent = Count;
for random_robot = 1:5
    
    
    if random_robot == 1
        Input_robot = [0;0];
    elseif random_robot == 2
        Input_robot = [1;0];
    elseif random_robot == 3
        Input_robot = [0;1];
    elseif random_robot == 4
        Input_robot = [-1;0];
    elseif random_robot == 5
        Input_robot = [0;-1];
    end
    
    if in_environment( [Monte_Carlo.Nodes.Robot_x(Parent)+Input_robot(1), Monte_Carlo.Nodes.Robot_y(Parent)+Input_robot(2)] , environment , epsilon )
        Monte_Carlo=addedge(Monte_Carlo,Parent,Count+1);
        Monte_Carlo.Nodes.Robot_x(Count+1) = Monte_Carlo.Nodes.Robot_x(Parent)+Input_robot(1);
        Monte_Carlo.Nodes.Robot_y(Count+1) = Monte_Carlo.Nodes.Robot_y(Parent)+Input_robot(2);
        Monte_Carlo.Nodes.Target_x(Count+1) = Monte_Carlo.Nodes.Target_x(Parent);
        Monte_Carlo.Nodes.Target_y(Count+1) = Monte_Carlo.Nodes.Target_y(Parent);
        
        V{1} = visibility_polygon( [Monte_Carlo.Nodes.Robot_x(Count+1) Monte_Carlo.Nodes.Robot_y(Count+1)] , environment , epsilon , snap_distance );
        Monte_Carlo.Nodes.Robot_Region{Count+1} = poly2mask(V{1}(:,1),V{1}(:,2),50, 50) | Monte_Carlo.Nodes.Robot_Region{Parent};
        Monte_Carlo.Nodes.Robot_Reward(Count+1) = bwarea(Monte_Carlo.Nodes.Robot_Region{Count+1});
        
        Monte_Carlo.Nodes.Generation(Count+1) = Monte_Carlo.Nodes.Generation(Parent) + 1;
        Monte_Carlo.Nodes.Parent(Count+1) = Parent;
        Monte_Carlo.Nodes.UCB_Value(Count+1) = 99999;
        Count = Count + 1;
    end
end

Monte_Carlo.Nodes.Visited_Time(Parent) = Monte_Carlo.Nodes.Visited_Time(Parent) + 1;

i2 = 1;
i3 = 1;
i4 = 1;
%Monte carlo tree rollout
for i = 1 :100
    Total_Visited = Total_Visited + 1;
    %1. Choose the node to rollout
    roll_node = 1;
    while Monte_Carlo.Nodes.Generation(roll_node) ~= End_Step
            sucIDs = successors(Monte_Carlo,roll_node);
            if min(Monte_Carlo.Nodes.Visited_Time(sucIDs)) == 0
                ID = find(Monte_Carlo.Nodes.Visited_Time(sucIDs) == 0);
                roll_node = sucIDs(ID(1));
            else
                max_UCB = max(Monte_Carlo.Nodes.UCB_Value(sucIDs));
                ID = find(Monte_Carlo.Nodes.UCB_Value(sucIDs) == max_UCB);
                roll_node = sucIDs(ID(1));
            end
    end
    %2. Start Rollout Simulation
    Rollout_Robot_Position = [ Monte_Carlo.Nodes.Robot_x(roll_node); Monte_Carlo.Nodes.Robot_y(roll_node) ];
    Monte_Carlo_Reward = Monte_Carlo_Rollout(Rollout_Robot_Position, Initial_Target, 7, environment, Negtive_Reward);
    %3. Backpropagation
    Monte_Carlo.Nodes.Total_Reward(roll_node) = Monte_Carlo.Nodes.Total_Reward(roll_node) + Monte_Carlo_Reward;
    Monte_Carlo.Nodes.Visited_Time(roll_node) = Monte_Carlo.Nodes.Visited_Time(roll_node) + 1;
    Monte_Carlo.Nodes.UCB_Value(roll_node) = UCB_function(Monte_Carlo.Nodes.Total_Reward(roll_node), Monte_Carlo.Nodes.Visited_Time(roll_node), Total_Visited);
    
    if roll_node == 2
        mean2(i2) = Monte_Carlo.Nodes.Total_Reward(2) / Monte_Carlo.Nodes.Visited_Time(2);
        i2 = i2 + 1;
    elseif roll_node == 3
        mean3(i3) = Monte_Carlo.Nodes.Total_Reward(3) / Monte_Carlo.Nodes.Visited_Time(3);
        i3 = i3 + 1;
    elseif roll_node == 4
        mean4(i4) = Monte_Carlo.Nodes.Total_Reward(4) / Monte_Carlo.Nodes.Visited_Time(4);
        i4 = i4 + 1;
    end
    
    Backpropagation_node = roll_node;
    while Monte_Carlo.Nodes.Parent(Backpropagation_node) ~= 0
        Backpropagation_node = Monte_Carlo.Nodes.Parent(Backpropagation_node);
        Monte_Carlo.Nodes.Total_Reward(Backpropagation_node) = Monte_Carlo.Nodes.Total_Reward(Backpropagation_node) + Monte_Carlo_Reward;
        Monte_Carlo.Nodes.Visited_Time(Backpropagation_node) = Monte_Carlo.Nodes.Visited_Time(Backpropagation_node) + 1;
        Monte_Carlo.Nodes.UCB_Value(Backpropagation_node) = UCB_function(Monte_Carlo.Nodes.Total_Reward(Backpropagation_node), Monte_Carlo.Nodes.Visited_Time(Backpropagation_node), Total_Visited);
    end
end


