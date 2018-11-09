function [Tree,Selected_Node] = Monte_Carlo_Selection(Tree,v)
Selected_Node = v;
sucIDs = successors(Tree,v);

while nnz(sucIDs) ~= 0
    %update the UCB value
    for j = 1:nnz(sucIDs)
        if mod(Tree.Nodes.Generation(sucIDs(j)),2)
            Tree.Nodes.UCB_Value(sucIDs(j)) = UCBmin_function(Tree.Nodes.Total_Reward(sucIDs(j)), Tree.Nodes.Visited_Time(sucIDs(j)), Tree.Nodes.Visited_Time(1));
        else
            Tree.Nodes.UCB_Value(sucIDs(j)) = UCBmax_function(Tree.Nodes.Total_Reward(sucIDs(j)), Tree.Nodes.Visited_Time(sucIDs(j)), Tree.Nodes.Visited_Time(1));
        end
    end
    %select
    if mod(Tree.Nodes.Generation(Selected_Node),2) == 1
        sucIDs = successors(Tree,Selected_Node);
        max_UCB = max(Tree.Nodes.UCB_Value(sucIDs));
        ID = find(Tree.Nodes.UCB_Value(sucIDs) == max_UCB);
        Selected_Node = sucIDs(ID(1));
    else
        sucIDs = successors(Tree,Selected_Node);
        min_UCB = min(Tree.Nodes.UCB_Value(sucIDs));
        ID = find(Tree.Nodes.UCB_Value(sucIDs) == min_UCB);
        Selected_Node = sucIDs(ID(1));
    end
    sucIDs = successors(Tree,Selected_Node);
end

end