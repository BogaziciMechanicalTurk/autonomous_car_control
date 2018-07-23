function [ trajectory ] = trajectory_gen( obs_list,g1,g2,step_size)
%trajectory_gen Summary of this function goes here
%   Detailed explanation goes here

% curve fit

% figure;
hold on;

plot(obs_list(:,1),obs_list(:,2),'ro');

pf = polyfit(obs_list(g1',1),obs_list(g1',2),2);

x_samp = 0:step_size:20;

y_samp1 = pf(1)*x_samp.^2 + pf(2)*x_samp + pf(3);

plot(x_samp,y_samp1,'r');

pf = polyfit(obs_list(g2',1),obs_list(g2',2),2);

y_samp2 = pf(1)*x_samp.^2 + pf(2)*x_samp + pf(3);

plot(x_samp,y_samp2,'-r');

plot(x_samp,(y_samp1+y_samp2)/2,'g');

trajectory = [x_samp; (y_samp1+y_samp2)/2]';

hold off;


end

