function Tree = Monte_Carlo_Expand(Tree,v,environment,Graph)
epsilon = 0.000000001;
snap_distance = 0.05;

Parent = v;
Count = nnz(Tree.Nodes.Generation);

Child_Nodes = neighbors(Graph,Tree.Nodes.Robot_GraphLabel(v));

for random_robot = 1:nnz(Child_Nodes)
    
    
        Tree=addedge(Tree,Parent,Count+1);
        Tree.Nodes.Robot_GraphLabel(Count+1) = Child_Nodes(random_robot);
        Tree.Nodes.Robot_x(Count+1) = 2*Graph.Nodes.Position_x(Child_Nodes(random_robot));
        Tree.Nodes.Robot_y(Count+1) = 2*Graph.Nodes.Position_y(Child_Nodes(random_robot));
        
        
        V{1} = visibility_polygon( [Tree.Nodes.Robot_x(Count+1) Tree.Nodes.Robot_y(Count+1)] , environment , epsilon , snap_distance );
        Tree.Nodes.Robot_Region{Count+1} = poly2mask(V{1}(:,1),V{1}(:,2),50, 50) | Tree.Nodes.Robot_Region{Parent};
        Tree.Nodes.Robot_Reward(Count+1) = bwarea(Tree.Nodes.Robot_Region{Count+1});
        
        Tree.Nodes.Generation(Count+1) = Tree.Nodes.Generation(Parent) + 1;
        Tree.Nodes.Parent(Count+1) = Parent;
        Tree.Nodes.UCB_Value(Count+1) = 99999;
        Tree.Nodes.Visited_Time(Count+1) = 0;
%        Tree.Nodes.Detection_time(Count+1) = Tree.Nodes.Detection_time(Parent);
        Count = Count + 1;
    
end


end