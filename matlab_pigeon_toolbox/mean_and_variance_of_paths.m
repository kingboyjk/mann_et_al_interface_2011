function [mean, variance] = mean_and_variance_of_paths(x, N, method)
% [mean, variance] = mean_and_variance_of_paths(x, N, method)
% 
% Inputs:
% x: A cell of the paths
% N: The standardised length for the output (paths will be changed to this
% size for analysis.
% method: 'point-by-point' gives the variance of the 1st point, 2nd
% point...etc of each path. 'nearest-neighbour' uses the nearest neighbour
% distance to each path from the 1st, 2nd etc points on the mean
%
% Ouputs
% mean: The point-by-point mean of the paths (N by 2)
% variance: The variance calculated by method. Note: variance, NOT standard
% deviation. Variance is estimated as sum((x-mean)^2)/(numpaths-1)

%author: Richard Mann
%date: 17 March 2009

if nargin < 3
    method = 'point-by-point';
end


mean = zeros(N, 2);
for i = 1:numel(x)
    y{i} = change_path_size(x{i}, N, 'spline');
    mean = mean + y{i}(:, 1:2)/numel(x);
end

variance = zeros(N, 1);

switch method
    case 'point-by-point'   
        for i = 1:numel(x)
            variance = variance + sum((y{i}(:, 1:2)-mean).^2, 2)/(numel(x)-1);
        end
    case 'nearest-neighbour'
        for i = 1:numel(x)
            nn = nearest_neighbour(y{i}(:, 1:2), mean);
            variance = variance + nn.^2/(numel(x)-1);
        end
    otherwise
        method = 'point-by-point'
        [mean, variance] = mean_and_variance_of_paths(x, N, method);
end

mean(:, 3) = linspace(0, 1, length(mean))';       