function [Tree,Selected_Node] = Monte_Carlo_Selection(Tree,v)
Selected_Node = v;
sucIDs = successors(Tree,v);

%update the UCB value
for j = 1:nnz(Tree.Nodes.Generation)
    Tree.Nodes.UCB_Value(j) = UCBmax_function(Tree.Nodes.Total_Reward(j), Tree.Nodes.Visited_Time(j), Tree.Nodes.Visited_Time(1));
end

while nnz(sucIDs) ~= 0
    
    %select
    sucIDs = successors(Tree,Selected_Node);
    max_UCB = max(Tree.Nodes.UCB_Value(sucIDs));
    ID = find(Tree.Nodes.UCB_Value(sucIDs) == max_UCB);
    Selected_Node = sucIDs(ID(1));

    sucIDs = successors(Tree,Selected_Node);
end

end