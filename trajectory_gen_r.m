function [ trajectory ] = trajectory_gen_r( obs_list,g1,g2,step_size)
%trajectory_gen_r Summary of this function goes here
%   Detailed explanation goes here

% curve fit

% figure;



hold on;

plot(obs_list(:,1),obs_list(:,2),'ro');

x = 0:step_size:20;

mdl1 = @(c,x) c(1)*x.*x+c(2)*x+c(3);
mdl2 = @(c,x) c(1)*x.*x+c(2)*x+c(4);

x_cell = {obs_list(g1',1)',obs_list(g2',1)'};
y_cell = {obs_list(g1',2)',obs_list(g2',2)'};

mdl_cell = {mdl1, mdl2};

c0 = [0 0 0 0];

[c,r,J,Sigma,mse,errorparam,robustw] = ...
            nlinmultifit(x_cell, y_cell, mdl_cell, c0);

[ypred1,delta1] = nlpredci(mdl1,x,c,r,'covar',Sigma);
[ypred2,delta2] = nlpredci(mdl2,x,c,r,'covar',Sigma);

ci = nlparci(c,r,'Jacobian',J);

plot(x,ypred1,'Color',[0.5 0 0]);
plot(x,ypred1+delta1,'Color',[0.5 0 0],'LineStyle',':');
plot(x,ypred1-delta1,'Color',[0.5 0 0],'LineStyle',':');

plot(x,ypred2,'Color',[0.5 0 0]);
plot(x,ypred2+delta2,'Color',[0.5 0 0],'LineStyle',':');
plot(x,ypred2-delta2,'Color',[0.5 0 0],'LineStyle',':');

plot(x,0.5*(ypred1+ypred2),'Color',[0 0.5 0]);

trajectory = [x; (ypred1+ypred2)/2]';


hold off;


end

