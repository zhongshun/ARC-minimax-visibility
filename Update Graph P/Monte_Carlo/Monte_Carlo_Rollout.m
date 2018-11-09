function Monte_Carlo_Reward = Monte_Carlo_Rollout(Initial_Robot, Initial_Sensor, Detection_time,Time_step, environment, Negtive_Reward)
% clear Vis
format long;


%Robustness constant
epsilon = 0.000000001;


%Snap distance (distance within which an observer location will be snapped to the
%boundary before the visibility polygon is computed)
snap_distance = 0.05;


%Read environment geometry from file
% environment = read_vertices_from_file('./ARC_2.environment');
environment_min_x = min(environment{1}(:,1));
environment_max_x = max(environment{1}(:,1));
environment_min_y = min(environment{1}(:,2));
environment_max_y = max(environment{1}(:,2));
X_MIN = environment_min_x-0.1*(environment_max_x-environment_min_x);
X_MAX = environment_max_x+0.1*(environment_max_x-environment_min_x);
Y_MIN = environment_min_y-0.1*(environment_max_y-environment_min_y);
Y_MAX = environment_max_y+0.1*(environment_max_y-environment_min_y);

%Compute and plot visibility polygon
W{1} = visibility_polygon( [Initial_Sensor(1) Initial_Sensor(2)] , environment , epsilon , snap_distance );
%Compute and plot visibility polygon for the target
V{1} = visibility_polygon( [Initial_Robot(1) Initial_Robot(2)] , environment , epsilon , snap_distance );
Area = polyarea(V{1}(:,1),V{1}(:,2));
Reward(Initial_Robot(1),Initial_Robot(2)) = Area;


Initial_Robot = Initial_Robot;
Initial_Sensor = Initial_Sensor;
Negtive_Reward = Negtive_Reward;
End_generation = Time_step;

Total_scan = false(1000,1000);
Monte_Carlo = graph([1],[]);
Monte_Carlo.Nodes.Robot_x= Initial_Robot(1);
Monte_Carlo.Nodes.Robot_y= Initial_Robot(2);
Monte_Carlo.Nodes.Sensor_x=Initial_Sensor(1);
Monte_Carlo.Nodes.Sensor_y=Initial_Sensor(2);
Monte_Carlo.Nodes.Generation = 1;
Monte_Carlo.Nodes.Robot_Region{1} = poly2mask(V{1}(:,1),V{1}(:,2),50, 50);
Monte_Carlo.Nodes.Robot_Reward = bwarea(Monte_Carlo.Nodes.Robot_Region{1});
Monte_Carlo.Nodes.Detection_time = Detection_time;


for Count = 1:Time_step
    %robot_move
    while 1
        random_robot =  randi([2,5]);
        
        %         if random_robot == 1
        %             Input_robot = [0;0];
        if random_robot == 2
            %         elseif random_robot == 2
            Input_robot = 1*[1;0];
        elseif random_robot == 3
            Input_robot = 1*[0;1];
        elseif random_robot == 4
            Input_robot = 1*[-1;0];
        elseif random_robot == 5
            Input_robot = 1*[0;-1];
        end
        
        if in_environment( [Monte_Carlo.Nodes.Robot_x(Count)+Input_robot(1), Monte_Carlo.Nodes.Robot_y(Count)+Input_robot(2)] , environment , epsilon )
            %             Monte_Carlo=addedge(Monte_Carlo,Count,Count+1);
            Monte_Carlo.Nodes.Robot_x(Count+1) = Monte_Carlo.Nodes.Robot_x(Count)+Input_robot(1);
            Monte_Carlo.Nodes.Robot_y(Count+1) = Monte_Carlo.Nodes.Robot_y(Count)+Input_robot(2);
            V{1} = visibility_polygon( [Monte_Carlo.Nodes.Robot_x(Count+1) Monte_Carlo.Nodes.Robot_y(Count+1)] , environment , epsilon , snap_distance );
            Monte_Carlo.Nodes.Robot_Region{Count+1} = poly2mask(V{1}(:,1),V{1}(:,2),50, 50) | Monte_Carlo.Nodes.Robot_Region{Count};
            Monte_Carlo.Nodes.Robot_Reward(Count+1) = bwarea(Monte_Carlo.Nodes.Robot_Region{Count+1});
            break;
        end
        
    end
    
    
    
    
    %sensor_move
    while 1
        random_sensor =  randi([2,5]);
        
        %         if random_sensor == 1
        %             Input_sensor = [0;0];
        if random_sensor == 2
            %         elseif random_sensor == 2
            Input_sensor = 1*[1;0];
        elseif random_sensor == 3
            Input_sensor = 1*[0;1];
        elseif random_sensor == 4
            Input_sensor = 1*[-1;0];
        elseif random_sensor == 5
            Input_sensor = 1*[0;-1];
        end
        
        if in_environment( [Monte_Carlo.Nodes.Sensor_x(Count)+Input_sensor(1), Monte_Carlo.Nodes.Sensor_y(Count)+Input_sensor(2)] , environment , epsilon )
            Monte_Carlo.Nodes.Sensor_x(Count+1) = Monte_Carlo.Nodes.Sensor_x(Count)+Input_sensor(1);
            Monte_Carlo.Nodes.Sensor_y(Count+1) = Monte_Carlo.Nodes.Sensor_y(Count)+Input_sensor(2);
            if in_environment( [Monte_Carlo.Nodes.Sensor_x(Count+1) Monte_Carlo.Nodes.Sensor_y(Count+1)] , V , epsilon )
                Monte_Carlo.Nodes.Detection_time(Count+1) = Monte_Carlo.Nodes.Detection_time(Count)+1;
            else
                Monte_Carlo.Nodes.Detection_time(Count+1) = Monte_Carlo.Nodes.Detection_time(Count);
            end
            break;
        end
        
    end
    
    %caculate reward value
    
    Monte_Carlo.Nodes.Robot_Reward(Count+1) =  Monte_Carlo.Nodes.Robot_Reward(Count+1) - Negtive_Reward* Monte_Carlo.Nodes.Detection_time(Count+1);
    
end
Monte_Carlo_Reward = Monte_Carlo.Nodes.Robot_Reward(Time_step+1);
Monte_Carlo.Nodes.Generation(Count) = Count+1;


end