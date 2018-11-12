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
    
    Initial_Robot = [1;16];
    Initial_Target = [7;9];
    sensor_x = [6	6	6	6	6	6	6	6	6	6	6	6	6	7	8	8	8	8	8	7];
    sensor_y =	[1	2	3	4	5	6	7	8	9	10	11	12	13	13	13	14	15	16	17	17];
    Record_Robot_path_x = Initial_Robot(1);
    Record_Robot_path_y = Initial_Robot(2);
    
    Record_Target_path_x = Initial_Target(1);
    Record_Target_path_y = Initial_Target(2);

    
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
    
    for i = 1: 2001
     Monte_Carlo_Reward = Monte_Carlo_Rollout(Initial_Robot, Initial_Target, 7, environment, 30);
     Monte_Carlo_reward_count(i)=Monte_Carlo_Reward;    
     MEAN(i) = mean(Monte_Carlo_reward_count);
    end
 

