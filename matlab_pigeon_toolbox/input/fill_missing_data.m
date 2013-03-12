function [y, t_out] = fill_missing_data(x, t_in, t_out)
%[y, t_out] = fill_missing_data(x, t_in, t_out)
%
%Interpolates to fill any missing times in the data.
%If t_out is not specified a sampling of 1Hz is assumed between the start
%and end of t_in
%
%Uses a spline fit to interpolate. This largely replicates the
%functionality of change+path_size.m
%
%Richard Mann (2009)

if nargin < 3
    t_out = t_in(1):1:t_in(end);
    t_out = t_out(:);
end

y =interp1(t_in, x, t_out);
