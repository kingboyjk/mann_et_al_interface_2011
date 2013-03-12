function plot_mean_path_and_variance(mean, variance, n)
% plot_mean_path_and_variance(mean, variance)
%
% Plots a mean path and n (default 1) standard deviations perpendicular to the paths direction.
% Edit file to change colour settings
%
% Inputs: 
% mean: The mean path
% variance: variance (std^2);
% n: number of stds to plot

%Author: Richard Mann
%date: 17 March 2009


plot_path(mean, 'b')

dmean = diff(mean);
dmean(end+1, :) = dmean(end, :);

normx = dmean(:, 2)./sqrt(dmean(:, 1).^2+dmean(:, 2).^2); %normal vectors to direction
normy = -dmean(:, 1)./sqrt(dmean(:, 1).^2+dmean(:, 2).^2);

norm= n*[sqrt(variance).*normx, sqrt(variance).*normy];

hold on

plot_path(mean+norm, '--r'
plot_path(mean-norm, '--r')

hold off