function Tree = Monte_Carlo_Expand(Tree,v,environment)
epsilon = 0.000000001;
snap_distance = 0.05;

Parent = v;
Count = nnz(Tree.Nodes.Generation);
if mod(Tree.Nodes.Generation(Parent),2) == 1
    for random_robot = 2:5
        %         if random_robot == 1
        %             Input_robot = 1*[0;0];
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
        
        if in_environment( [Tree.Nodes.Robot_x(Parent)+Input_robot(1), Tree.Nodes.Robot_y(Parent)+Input_robot(2)] , environment , epsilon )
            Tree=addedge(Tree,Parent,Count+1);
            Tree.Nodes.Robot_x(Count+1) = Tree.Nodes.Robot_x(Parent)+Input_robot(1);
            Tree.Nodes.Robot_y(Count+1) = Tree.Nodes.Robot_y(Parent)+Input_robot(2);
            Tree.Nodes.Target_x(Count+1) = Tree.Nodes.Target_x(Parent);
            Tree.Nodes.Target_y(Count+1) = Tree.Nodes.Target_y(Parent);
            
            V{1} = visibility_polygon( [Tree.Nodes.Robot_x(Count+1) Tree.Nodes.Robot_y(Count+1)] , environment , epsilon , snap_distance );
            Tree.Nodes.Robot_Region{Count+1} = poly2mask(V{1}(:,1),V{1}(:,2),50, 50) | Tree.Nodes.Robot_Region{Parent};
            Tree.Nodes.Robot_Reward(Count+1) = bwarea(Tree.Nodes.Robot_Region{Count+1});
            
            Tree.Nodes.Generation(Count+1) = Tree.Nodes.Generation(Parent) + 1;
            Tree.Nodes.Parent(Count+1) = Parent;
            Tree.Nodes.UCB_Value(Count+1) = 99999;
            Tree.Nodes.Visited_Time(Count+1) = 0;
            Tree.Nodes.Detection_time(Count+1) = Tree.Nodes.Detection_time(Parent);
            Count = Count + 1;
        end
    end
else
    for random_target = 2:5
        %         if random_target == 1
        %             Input_target = [0;0];
        if random_target == 2
            %         elseif random_target == 2
            Input_target = 1*[1;0];
        elseif random_target == 3
            Input_target = 1*[0;1];
        elseif random_target == 4
            Input_target = 1*[-1;0];
        elseif random_target == 5
            Input_target = 1*[0;-1];
        end
        
        if in_environment( [Tree.Nodes.Target_x(Parent)+Input_target(1), Tree.Nodes.Target_y(Parent)+Input_target(2)] , environment , epsilon )
            Tree=addedge(Tree,Parent,Count+1);
            Tree.Nodes.Robot_x(Count+1) = Tree.Nodes.Robot_x(Parent);
            Tree.Nodes.Robot_y(Count+1) = Tree.Nodes.Robot_y(Parent);
            Tree.Nodes.Target_x(Count+1) = Tree.Nodes.Target_x(Parent)+Input_target(1);
            Tree.Nodes.Target_y(Count+1) = Tree.Nodes.Target_y(Parent)+Input_target(2);
            
            Tree.Nodes.Robot_Region{Count+1} = Tree.Nodes.Robot_Region{Parent};
            Tree.Nodes.Robot_Reward(Count+1) = Tree.Nodes.Robot_Reward(Parent);
            
            Tree.Nodes.Generation(Count+1) = Tree.Nodes.Generation(Parent) + 1;
            Tree.Nodes.Parent(Count+1) = Parent;
            Tree.Nodes.UCB_Value(Count+1) = -99999;
            Tree.Nodes.Visited_Time(Count+1) = 0;
            V{1} = visibility_polygon( [Tree.Nodes.Robot_x(Count+1) Tree.Nodes.Robot_y(Count+1)] , environment , epsilon , snap_distance );
            if in_environment( [Tree.Nodes.Target_x(Count+1), Tree.Nodes.Target_y(Count+1)] , environment , epsilon )
                Tree.Nodes.Target_x(Count+1) = Tree.Nodes.Target_x(Parent)+Input_target(1);
                Tree.Nodes.Target_y(Count+1) = Tree.Nodes.Target_y(Parent)+Input_target(2);
                if in_environment( [Tree.Nodes.Target_x(Count+1) Tree.Nodes.Target_y(Count+1)] , V , epsilon )
                    Tree.Nodes.Detection_time(Count+1) = Tree.Nodes.Detection_time(Parent)+1;
                else
                    Tree.Nodes.Detection_time(Count+1) = Tree.Nodes.Detection_time(Parent);
                end
            end
            Count = Count + 1;
        end
        
        
        
    end
end

end