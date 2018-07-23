function [ ] = odomCallback(src,~)
%ODOMCALLBACK Summary of this function goes here
%   Detailed explanation goes here


global current_x
global current_y
global current_th

current_x = src.Position

end

