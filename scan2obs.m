dc_th = 0.5;

angle_inc = pi/512;
scan_size = 1024;


i=2;

% median filtering

scan = medfilt1(scan_1,1);

obs_list = [];

while i<scan_size
    
    radius = 0;
    
    start_idx = i;
    
    
    if abs(scan(i)-scan(i-1)) > dc_th
        radius = 0;
        i = i+1;
        
        while i<scan_size && abs(scan(i)-scan(i-1)) < dc_th
            radius = radius + sqrt(scan(i)^2 + scan(i-1)^2 - 2*scan(i)*scan(i-1)*cos(angle_inc));
            i = i+1;
        end
        
    else
        i = i+1;
        continue;
    end
    
    %radius = radius - scan(i)*angle_inc;
    radius = radius/2;
    
    if radius>0.05 && radius<0.5
        obs_list = [obs_list; scan(round((start_idx + i)/2))*cos((start_idx + i)/2*angle_inc) ...
                              scan(round((start_idx + i)/2))*sin((start_idx + i)/2*angle_inc) ...
                              radius];
        (start_idx + i)/2;
        radius;         
    end    
    
    i=i+1;
    
end





% clear outlier

tmp_list = [];

is_assigned = zeros(size(obs_list,1));

for i=1:size(obs_list,1)
    for j=1:size(obs_list,1)
        
        dist = norm(obs_list(i,1:2) - obs_list(j,1:2));
        
        if dist > 0.8 && dist < 1.2 && ~is_assigned(i)
            tmp_list = [tmp_list;obs_list(i,:)];
            is_assigned(i) = 1;
        end
        
    end
    
end

obs_list = tmp_list;

figure;

polar(th,scan);
hold on;
plot(obs_list(:,1),obs_list(:,2),'ro');


obs_list

% grouping

g_1 = [];
g_2 = [];

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

g_1 = [min_idx];
is_assigned(min_idx) = 1;

% grow with neighbours

i=1;

while i<size(g_1,1)+1
    
    c_idx = g_1(i)
    
    for j=1:size(obs_list,1)
        if (~is_assigned(j))
            dist = norm(obs_list(c_idx,1:2) - obs_list(j,1:2));
            
            if(dist>0.8 && dist < 1.2)
                g_1 = [g_1;j];
                is_assigned(j) = 1;
            end
        end
    end
    
    i = i+1;
end

% unassinged closest

min_dist = 9999;
min_idx = 0;

for i=1:size(obs_list,1)
    if(norm(obs_list(i,:))<min_dist && ~is_assigned(i))
        min_idx = i;
        min_dist = norm(obs_list(i,:));
    end
end

g_2 = [min_idx];
is_assigned(min_idx) = 1;



% grow with neighbours

i=1;

while i<size(g_2,1)+1
    
    c_idx = g_2(i)
    
    for j=1:size(obs_list,1)
        if (~is_assigned(j))
            dist = norm(obs_list(c_idx,1:2) - obs_list(j,1:2));
            
            if(dist>0.8 && dist < 1.2)
                g_2 = [g_2;j];
                is_assigned(j) = 1;
            end
        end
    end
    
    i = i+1;
end
% 
% plot(obs_list(g_1',1),obs_list(g_1',2),'bx');
% plot(obs_list(g_2',1),obs_list(g_2',2),'gx');
% 
% waitforbuttonpress;

% curve fit

pf = polyfit(obs_list(g_1',1),obs_list(g_1',2),2);

x_samp = 0:0.1:20;

y_samp1 = pf(1)*x_samp.^2 + pf(2)*x_samp + pf(3);

plot(x_samp,y_samp1,'r');

pf = polyfit(obs_list(g_2',1),obs_list(g_2',2),2);

y_samp2 = pf(1)*x_samp.^2 + pf(2)*x_samp + pf(3);

plot(x_samp,y_samp2,'r');

plot(x_samp,(y_samp1+y_samp2)/2,'g');
