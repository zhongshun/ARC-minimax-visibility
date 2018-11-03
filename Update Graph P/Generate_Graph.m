G = graph([1],[]);
nodeIDs = 1;
x_lable=[];
y_lable=[];
i = 1;
G.Nodes.Position_x = 1;
G.Nodes.Position_y = 1;
for y = 1:15
    for x = 1:25
        G = addnode(G,nodeIDs);
        x_lable = [x_lable x];
        y_lable = [y_lable y];
        G.Nodes.Position_x(i) = x_lable(i);
        G.Nodes.Position_y(i) = y_lable(i);
        i = i + 1;
    end
end
G = rmnode(G,x*y+1);


for y = 1:15
    for x = 1:24
        G = addedge(G,25*(y-1)+x,25*(y-1)+x+1);
    end
end

for y = 1:14
    for x = 1:25
        G = addedge(G,25*(y-1)+x,25*(y)+x);
    end
end
G = rmedge(G,1,2);
 H = plot(G,'XData',x_lable,'YData',y_lable,'MarkerSize',5);
 axis([0,26,0,16])