% Input the distribution P in the graph, return a random position based on the probability
function position = Random_Postion_Generator(p1) 
    Possible_Position = find(p1 ~= 0);
    if nnz(Possible_Position) == 1
        position = Possible_Position;
        return
    end
    Probability = p1(Possible_Position); 
    range = 1e12;
    X = randi([1,range]);
    Base = range*Probability(1);
    
    for i = 2:nnz(Possible_Position)
        if X <= Base
           position = Possible_Position(i-1);
           return
        else
            Base = Base + range*Probability(i);
        end
    end
    position = Possible_Position(i);
end
% Test the random generate process
% clear
% load('data\Initial_No245.mat')
% 
% p1 = p(4,:);
% Possible_Position = find(p(4,:) ~= 0);
% Probability = p1(Possible_Position);
% times = zeros(nnz(Possible_Position),1);
% for k = 1:10000
%     position = random_postion(p1);
%     times(find(Possible_Position == position)) = times(find(Possible_Position == position)) + 1;      
% 
% end