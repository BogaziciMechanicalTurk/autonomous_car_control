function [obs_list] = obs_gen(scan_msg,median_filter_size)
%OBS_GEN Summary of this function goes here
%   Detailed explanation goes here

scan = scan_msg.Ranges;
angle_inc = scan_msg.AngleIncrement;
angle_min = scan_msg.AngleMin;
angle_max = scan_msg.AngleMax;
scan_size = size(scan_msg.Ranges,1);

dc_th = 0.5;
min_dist_th = 0.8;
max_dist_th = 1.2;

min_rad = 0.05;
max_rad = 0.3;



% close filter
for i=1:scan_size
    if scan(i) < 0.2
        scan(i) = 30;
    end
end


% median filtering

scan = medfilt1(scan,median_filter_size);

obs_list = [];
pt_list = [];

i=2;

while i<scan_size
    
    start_idx = i;
    
    
    if abs(scan(i)-scan(i-1)) > dc_th
        i = i+1
        
        while i<scan_size && abs(scan(i)-scan(i-1)) < dc_th
            %radius = radius + sqrt(scan(i)^2 + scan(i-1)^2 - 2*scan(i)*scan(i-1)*cos(angle_inc));
            i = i+1;
        end
        
        radius = sqrt(scan(start_idx)^2 + scan(i-1)^2 - 2*scan(start_idx)*scan(i-1)*cos(angle_inc*(start_idx-i+1)));
        
    else
        i = i+1;
        continue;
    end
    
    %radius = radius - scan(i)*angle_inc;
    radius = radius/2;
    
    
    if radius>min_rad && radius<max_rad
        
           obs_list = [obs_list; scan(round((start_idx + i)/2))*cos((start_idx + i)/2*angle_inc+angle_min) ...
                              scan(round((start_idx + i)/2))*sin((start_idx + i)/2*angle_inc+angle_min) ...
                              radius];   
        
        
        
        (start_idx + i)/2;
        radius;         
    end    
    
    %i=i+1;
    
end


% clear outlier

tmp_list = [];

for i=1:size(obs_list,1)
    
    if abs(atan2(obs_list(i,2),obs_list(i,1)))>2*pi/3
        continue;
    end
    
    min_dist = 9999;
    for j=1:size(obs_list,1)
        
        if i==j
            continue;
        end
        
        dist = norm(obs_list(i,1:2) - obs_list(j,1:2));
        
        if dist<min_dist
            min_dist = dist;
        end  
        
        if dist < min_dist_th
            break;
        end
        
    end
    
    
    
    if  min_dist > min_dist_th && min_dist < max_dist_th
        
        tmp_list = [tmp_list;obs_list(i,:)];
        
    end
    
end

obs_list = tmp_list;

% figure;
% 

th = scan_msg.AngleMin:scan_msg.AngleIncrement:scan_msg.AngleMax;

polar(th',scan);
hold on;
% obs_list
% plot(obs_list(:,1),obs_list(:,2),'ro');
% hold off;



end

