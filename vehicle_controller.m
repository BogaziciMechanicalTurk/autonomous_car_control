function [steering_th,speed] = vehicle_controller( target,scan_msg,speed_min,speed_max,fs_dist,stop_dist,stop_fov,median_filter_size)

    steering_th = atan2(target(2),target(1));
    speed = max(speed_min,speed_max*cos(steering_th));
    
    scan = scan_msg.Ranges;
    angle_inc = scan_msg.AngleIncrement;
    angle_min = scan_msg.AngleMin;
    angle_max = scan_msg.AngleMax;
    scan_size = size(scan_msg.Ranges,1);
    
    scan = medfilt1(scan,median_filter_size);
%     scan = movmean(scan,11);
    
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
    
    speed = min(speed,max(0,speed*(min_scan-stop_dist)/(fs_dist-stop_dist)));
    

end