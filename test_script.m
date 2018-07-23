% stand alone testing script

load('scan_list.mat')

speed_max = 30/3.6;
speed_min = 5/3.6;
look_ahead = 2;
step_size = 0.1;
fs_dist = 1;
stop_dist = 0.5;
stop_fov = pi/2;
median_filter_size = 11;

dc_th = 0.5;
min_dist_th = 0.8;
max_dist_th = 1.2;

min_rad = 0.1;
max_rad = 0.3;

scan_size = 1081;
angle_min = -2.3562;
angle_max = 2.3562;
angle_inc = (angle_max-angle_min)/scan_size;
angle_min = angle_min + angle_inc;

for count = 1:size(scan_list,1)
    
    scan = scan_list(count,:);

    i=2;

    % median filtering

    scan = medfilt1(scan,median_filter_size);

    % obstacle generation
    
    obs_list = [];

    while i<scan_size

        start_idx = i;


        if abs(scan(i)-scan(i-1)) > dc_th
            i = i+1;

            while i<scan_size && abs(scan(i)-scan(i-1)) < dc_th
                i = i+1;
            end
            radius = sqrt(scan(start_idx)^2 + scan(i-1)^2 - 2*scan(start_idx)*scan(i-1)*cos(angle_inc*(start_idx-i+1)));

        else
            i = i+1;
            continue;
        end

        radius = radius/2;
        
        % radius filtering
        if radius>min_rad && radius<max_rad
            
            
            obs_list = [obs_list; scan(round((start_idx + i)/2))*cos((start_idx + i)/2*angle_inc+angle_min) ...
                                  scan(round((start_idx + i)/2))*sin((start_idx + i)/2*angle_inc+angle_min) ...
                                  radius];   

                 

            (start_idx + i)/2;
            radius;         
        end

    end

%     th = angle_min:angle_inc:angle_max;
%     
%     polar(th,scan);
%     hold on;
%     plot(obs_list(:,1),obs_list(:,2),'ro');
%     
%     waitforbuttonpress

    % distance filtering

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

        if min_dist > min_dist_th && min_dist < max_dist_th
            tmp_list = [tmp_list;obs_list(i,:)];
        end

    end

    obs_list = tmp_list;

    th = angle_min:angle_inc:angle_max;

    polar(th,scan);
    hold on;
    plot(obs_list(:,1),obs_list(:,2),'ro');
%     
%     waitforbuttonpress

    [g1,g2] = obs_filter(obs_list);

    plot(obs_list(g1',1),obs_list(g1',2),'bx');
    plot(obs_list(g2',1),obs_list(g2',2),'gx');
    % 
    %waitforbuttonpress;

    trajectory = trajectory_gen_r(obs_list,g1,g2,step_size);
    target = trajectory(1+look_ahead/step_size,:);

    hold on;

    plot(target(1),target(2),'rx');

    hold off;

    % vehicle controller

    steering_th = atan2(target(2),target(1))
    speed = max(speed_min,speed_max*cos(steering_th));

    target = trajectory(1+look_ahead/step_size,:);

    idx_fov = round(stop_fov/(angle_max-angle_min)*scan_size);

    idx_min = round((scan_size - idx_fov)/2);
    idx_max = idx_min + idx_fov;



    min_scan = 9999;
    for i=idx_min:idx_max

        if scan(i) < 0.02
            continue;
        end

        if(scan(i) < min_scan)
            min_scan = scan(i);
        end

    end

    min_scan;


    speed = min(speed_max,max(0,speed_max*(min_scan-stop_dist)/(fs_dist-stop_dist)))
    
    waitforbuttonpress
end