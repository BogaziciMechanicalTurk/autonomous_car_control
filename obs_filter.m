function [ g1,g2 ] = obs_filter( obs_list )
%obs_filter Summary of this function goes here
%   Detailed explanation goes here

% grouping

g1 = [];
g2 = [];

% start with the closest

is_assigned = zeros(size(obs_list,1));

min_dist = 9999;
min_idx = 0;

for i=1:size(obs_list,1)
    if(norm(obs_list(i,:))<min_dist)
        min_idx = i;
        min_dist = norm(obs_list(i,:));
    end
end


if min_idx < 1
    return
end

g1 = [min_idx];
is_assigned(min_idx) = 1;


% grow with neighbours

i=1;

while i<size(g1,1)+1
    
    c_idx = g1(i);
    
    for j=1:size(obs_list,1)
        if (~is_assigned(j))
            dist = norm(obs_list(c_idx,1:2) - obs_list(j,1:2));
            
            if(dist>0.8 && dist < 1.2)
                g1 = [g1;j];
                is_assigned(j) = 1;
            end
        end
    end
    
    i = i+1;
end

% unassigned closest

min_dist = 9999;
min_idx = 0;

for i=1:size(obs_list,1)
    if(norm(obs_list(i,:))<min_dist && ~is_assigned(i))
        min_idx = i;
        min_dist = norm(obs_list(i,:));
    end
end

if min_idx < 1
    return
end

g2 = [min_idx];
is_assigned(min_idx) = 1;

% grow with neighbours

i=1;

while i<size(g2,1)+1
    
    c_idx = g2(i);
    
    for j=1:size(obs_list,1)
        if (~is_assigned(j))
            dist = norm(obs_list(c_idx,1:2) - obs_list(j,1:2));
            
            if(dist>0.8 && dist < 1.2)
                g2 = [g2;j];
                is_assigned(j) = 1;
            end
        end
    end
    
    i = i+1;
end




end

