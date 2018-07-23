%laser = rossubscriber('/scan');


steerPub = rospublisher('/Steering', 'std_msgs/Float32');
speedPub = rospublisher('/Speed', 'std_msgs/Float32');

% jaguar
jaguarPub = rospublisher('/drrobot_player1/drrobot_cmd_vel', 'geometry_msgs/Twist');
jaguar_msg = rosmessage(jaguarPub);


% kobuki
kobukiPub = rospublisher('/mobile_base/commands/velocity','geometry_msgs/Twist');

kobuki_msg = rosmessage(kobukiPub);
kobuki_msg.Linear.X = 0;
kobuki_msg.Angular.Z = 0;


steer_msg = rosmessage(steerPub);
speed_msg = rosmessage(speedPub);

scanSub = rossubscriber('/scan',@laserCallback);
odomSub = rossubscriber('/odom');

steering_th = 0;
speed = 0;
speed_max = 30/3.6;
speed_min = 5/3.6;
look_ahead = 2;
step_size = 0.1;
fs_dist = 1;
stop_dist = 0.5;
stop_fov = pi/2;
median_filter_size = 21;

jaguar_vmax = 0.5;
jaguar_wmax = 0.35;

% kobuki parameter

v_max = 0.2;
w_max = pi/2;

steer_msg.Data = steering_th;
speed_msg.Data = speed;

scan = scan_1;


pause(1);
%scan_msg = scanSub.LatestMessage;

scan_msg = rosmessage('sensor_msgs/LaserScan');

scan_msg.Ranges = scan;
scan_msg.AngleMin = -pi+2*pi/size(scan,2);
scan_msg.AngleMax = pi;
scan_msg.AngleIncrement = 2*pi/size(scan,2);

global scan_x
global scan_y
global scan_th

global current_x
global current_y
global current_th

global count

global scan_list
global position_list


count = 0;

% odom_msg = odomSub.LatestMessage;
% 
% current_x = odom_msg.Pose.Pose.Position.X;
% current_y = odom_msg.Pose.Pose.Position.Y;
% 
% eul = quat2eul([odom_msg.Pose.Pose.Orientation.X ...
%                 odom_msg.Pose.Pose.Orientation.Y ...
%                 odom_msg.Pose.Pose.Orientation.Z ...
%                 odom_msg.Pose.Pose.Orientation.W]);
% 
% current_th = eul(3);

current_x = 0;
current_y = 0;
current_th = 0;

scan_x = current_x;
scan_y = current_y;
scan_th = current_th;

obs_x = current_x;
obs_y = current_y;
obs_th = current_th;

init = 0;


while 1
    
    scan_msg = scanSub.LatestMessage;
%     odom_msg = odomSub.LatestMessage;
%     
%     current_x = odom_msg.Pose.Pose.Position.X;
%     current_y = odom_msg.Pose.Pose.Position.Y;
%     eul = quat2eul([odom_msg.Pose.Pose.Orientation.X ...
%                     odom_msg.Pose.Pose.Orientation.Y ...
%                     odom_msg.Pose.Pose.Orientation.Z ...
%                     odom_msg.Pose.Pose.Orientation.W]);
%     
%     current_th = eul(3);
%     tic

    position_list = [position_list; current_x current_y current_th];
    
    rel_pose = [current_x - scan_x; ...
                current_y - scan_y; ...
                current_th - scan_th;];
            
%     scan_msg = transform_laser(scan_msg,rel_pose,median_filter_size);
    
%     toc
    

    if init==0
        obs_list = obs_gen(scan_msg,median_filter_size);
        [g1,g2] = obs_filter(obs_list);
        init = 1;
    else
        prev_obs_list = obs_list;
        prev_g1 = g1;
        prev_g2 = g2;
        obs_list = obs_gen(scan_msg,median_filter_size);
        [g1,g2] = obs_filter(obs_list);
    end
      
    
%     toc
       
    if (size(g1,1) < 3 || size(g2,1) < 3)
        rel_pose = [current_x - obs_x; ...
                    current_y - obs_y; ...
                    current_th - obs_th;];
        obs_list = transform_obs(ref_obs_list,rel_pose);
        g1 = prev_g1;
        g2 = prev_g2;
    else
        obs_x = current_x;
        obs_y = current_y;
        obs_th = current_th;
        ref_obs_list = obs_list;
    end
    
    tic
    
    trajectory = trajectory_gen_r(obs_list,g1,g2,step_size);
    
    toc
    
     
    target = trajectory(1+look_ahead/step_size,:);
    
    hold on;

    plot(target(1),target(2),'rx');

    hold off;
    
    [steering_th,speed] = vehicle_controller(target,scan_msg,speed_min,speed_max,fs_dist,stop_dist,stop_fov,median_filter_size);
    
    steering_th
    speed
%     
%     steer_msg.Data = steering_th;
%     speed_msg.Data = speed;
%     
%     send(steerPub,steer_msg);
%     send(speedPub,speed_msg);
%     
%     kobuki_msg.Linear.X = v_max*speed/speed_max;
%     kobuki_msg.Angular.Z = w_max*sin(steering_th);
%     
%     send(kobukiPub,kobuki_msg);    
    
    jaguar_msg.Linear.X = jaguar_vmax*speed/speed_max;
    jaguar_msg.Angular.Z = jaguar_wmax*sin(steering_th);
    
    jaguar_msg.Linear.X;
    jaguar_msg.Angular.Z;
    
%     send(jaguarPub,jaguar_msg);
    
    pause(0.1)
    
    %break;
    
    
    
    
end