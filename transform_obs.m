function [ obs_out ] = transform_obs( obs_in, rel_pose)
%TRANSFORM_OBS Summary of this function goes here
%   Detailed explanation goes here

R = [cos(-rel_pose(3)) -sin(-rel_pose(3)); sin(-rel_pose(3)) cos(-rel_pose(3))];
T = [R [-rel_pose(1);-rel_pose(2)]; 0 0 1];

obs_out = obs_in;
tmp_mat = T * [obs_out(:,1:2) ones(size(obs_out,1),1)]';

obs_out(:,1:2) = tmp_mat(1:2,:)';

end

