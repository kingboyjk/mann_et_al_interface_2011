function plot_path(x, varargin)
% plot_path(x, style)
% plots the path x with color and line specified by style
% if x is a cell of paths it will plot all on one figure

%Author: Richard Mann
%date: 17 March 2009
% Updated 28 May 2009, Robin Freeman
%     - Added varargin to allow multiple arguments to be passed to plot

if nargin ==1
    style = 'b';
end
if iscell(x)
    hold on
    for i = 1:numel(x)
        plot_path(x{i}, varargin{:})
    end
    
else
    plot(x(:, 1), x(:, 2), varargin{:})
end
