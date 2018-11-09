function Plot_VisiLibity(x,y,environment,color)
x = 2*x;
y = 2*y;
W{1} = visibility_polygon( [x y] , environment , 0.000000001 , 0.05 );
hold on
plot3( x , y , 0.3 , ...
    '*' , 'Markersize' , 8, 'MarkerFaceColor' , [0.9,0.8,0.7],'MarkerFaceColor',color,'MarkerEdgeColor',color);
patch( W{1}(:,1) , W{1}(:,2) ,0.1*ones( size(W{1},1) , 1 ) , ...
                [0.7,0.7,0.9] , 'LineStyle' , 'none');
hold off
end