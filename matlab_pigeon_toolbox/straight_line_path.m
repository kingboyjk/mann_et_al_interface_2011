function s = straight_line_path(start, finish, N)
%
% s = straight_line_path(start, finish, N)
%
% Inputs:
% start/finish: The co-ordinates (x,y) of the start and finish of the path
% N: The number of equally spaced points in the path
%
% Outputs
% s: The straight line path

%Author: Richard Mann
%date: 17 March 2009


for i = 1:2
    s(:, i) = linspace(start(i), finish(i), N);
end
