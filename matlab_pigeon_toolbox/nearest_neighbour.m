function [nnDistance, nnIndex, nnValues] = nearest_neighbour(x1, x2, signed)
% [nnDistance, nnIndex, nnValues] = nearestNeighbour(x1, x2, options)
%
% Inputs:
% x1: The varying path (x, y format) - If a x1 is a cell function will
% output a cell of results, for many-to-1 comparison
% x2: The reference path that distances are measured from.
% signed: signed = {true, false}. Default is false. If signed == true is
% used then distance is output as either +ve or -ve depending which side
% the varying path lies on. (NB: signed option currently not well defined)
%
% Outputs
% nnDistance: The (signed) nearest neighbour distance from each point on
% x2 to the nearest point on x1. Ouput is the same length as x2.
% nnIndex: The index of the nearest point on x1 for each point on x2.
% Ouput is the same length as x2
% nnValues: The actual nearest neighbour positions on x1 from x2. Output is
% same length as x2

% author: Richard  Mann
% date: 17 March 2009
% Updated 28 May 2009, Robin Freeman

%Check for signed option
if nargin < 3
    signed = false;
end

%If input is a cell, recurse over all elements.
if iscell(x1)
    for i = 1:numel(x1)
        [nnDistance{i}, nnIndex{i} nnValues{i}] = nearest_neighbour(x1{i}, x2, signed);
    end
else
    
    %Assign storage
    nnDistance = zeros(length(x2),1);
    nnIndex = zeros(length(x2), 1);
    nnValues = zeros(length(x2), 2);
    
    for i = 1:size(x2, 1)
        
        dsqr = sum([x1(:, 1)-x2(i, 1), x1(:, 2)-x2(i, 2)].^2, 2);
        
        [nnSqrDist, nnIndex(i)] = min(dsqr(:));
        
        nnValues(i, :) = x1(nnIndex(i),:);
        
        nnDistance(i) = sqrt(nnSqrDist);
        
    end
    
    
    %Code to make output signed
    if signed == true
        v = diff(x2); %direction of bird
        v(end+1, :) = v(end,:); %asume direction remains the same at the end
        side = zeros(length(x2),1);
        
        %For each nearest neighbour point, decide which side of x2 it lies
        for i = 1:size(x2, 1)
            testv = x1(nnIndex(i), :)-x2(i, :); %nn test vector
            side = sign(v(i, :)*testv'); %sign of dot product 
            nnDistance(i) = nnDistance(i)*side;
        end
        
    end
    
    
end


  
  
  