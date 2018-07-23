function [ output_msg ] = transform_laser( input_msg, rel_pose, median_filter_size)

output_msg = rosmessage('sensor_msgs/LaserScan');

output_msg.Ranges = medfilt1(input_msg.Ranges,median_filter_size);
output_msg.AngleMin = input_msg.AngleMin;
output_msg.AngleMax = input_msg.AngleMax;
output_msg.AngleIncrement = input_msg.AngleIncrement;


th = output_msg.AngleMin:output_msg.AngleIncrement:output_msg.AngleMax;

% to cart

x = output_msg.Ranges'.*cos(th);
y = output_msg.Ranges'.*sin(th);

cart_mat = [x;y;ones(1,size(output_msg.Ranges,1))];


% transform

R = [cos(-rel_pose(3)) -sin(-rel_pose(3)); sin(-rel_pose(3)) cos(-rel_pose(3))];
T = [R [-rel_pose(1);-rel_pose(2)]; 0 0 1];

cart_mat = T*cart_mat;

x = cart_mat(1,:);
y = cart_mat(2,:);

% back to polar

out = 6*ones(size(output_msg.Ranges));

idx = round((atan2(y,x)-output_msg.AngleMin)./output_msg.AngleIncrement)+1;

hyp_vec = hypot(x,y);

scan_size = size(output_msg.Ranges,1);

% idx(idx<1)=idx(idx<1)

for i=1:scan_size
    if(idx(i)<1)
        idx(i) = idx(i) + scan_size;
    end
   
    if(idx(i)<scan_size)
        out(idx(i)) = min(out(idx(i)),hyp_vec(i));
    end
    
end

% out(idx) = min(out(idx),hypot(x,y)');

output_msg.Ranges = out;

% polar(th,medfilt1(input_msg.Ranges',11))
% 
% figure;
% 
% polar(th,medfilt1(out',11))



end

