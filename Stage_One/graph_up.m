clear
% n = 12;
% A = delsq(numgrid('L',n));
% G = graph(A,'OmitSelfLoops');
% H = plot(G)
%Initial p
Guard_position = 15;
load('data\Graph.mat')
 H = plot(G,'XData',x_lable,'YData',y_lable,'MarkerSize',5);
G.Nodes.P(Guard_position) = 1 ;
p(Guard_position) = 1;
p_next = 0;
for i=1:max(size(G.Nodes))
    if i == Guard_position
        G.Nodes.P(i) = 1;
        p(i) = 1;
        p_next(i) = 0;
    else
        G.Nodes.P(i) = 0;
        p(i) = 0;
        p_next(i) = 0;
    end
end

%update P for 1 step to T
for T = 1: 25
    highlight(H,[1:numel(p(T,:))],'NodeColor','b')
    list = find(p(T,:) ~= 0);
    highlight(H,list,'NodeColor','r')
    pause(1)
    
    p_c = p(T,:);
    for i = 1:nnz(list)
        N = neighbors(G,list(i));
        p_N = p_c(list(i))/nnz(N);
        for j = 1:nnz(N)
            Point = N(j);
            p_next(N(j)) = p_next(N(j)) + p_N;
        end       
    end
    p(T+1,:) = p_next;
    p_next = zeros(size(p_next));
    
end