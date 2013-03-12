function y = change_path_size(x, N, method)
% y = change_path_size(x, N, options)
%
% Inputs:
% x: Input path. If a cell is input function will resize all elements
% N: Output path size
% method: 'linear' or 'spline'. Default is spline (can also use any method
% availbale in function 'interp1'

%author: Richard Mann
%date: 17 March 2009

%Check for options and validity
if nargin < 3
    method = 'spline';
end

if iscell(x)
    for i = 1:numel(x)
        y{i} = change_path_size(x{i}, N, method);
    end
else
    if size(x, 2) == 3
        input_t = x(:, 3);
        
    else
        input_t = linspace(0, 1, length(x))';
    end
    
    
    output_t = linspace(0, 1, N)';
    y = interp1(input_t, x(:, 1:2), output_t, method);
    
    if size(x, 2) ==3
        y(:, 3) = output_t;
    end
    
            
end
