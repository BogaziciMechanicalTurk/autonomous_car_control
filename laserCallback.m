function [ ] = laserCallback(src,~)
%LASERCALLBACK Summary of this function goes here
%   Detailed explanation goes here
global scan_x
global scan_y
global scan_th

global current_x
global current_y
global current_th

scan_x = current_x;
scan_y = current_y;
scan_th = current_th;

%scan = src.LatestMessage.Ranges;

%scan_list = [scan_list; scan];

end

