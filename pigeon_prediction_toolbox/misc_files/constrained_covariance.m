 % function K = constrained_covariance (parameters)
%
% calculates a single block of the the covariance matrix for the
% habitual route covariance defined in "Predictibility of homing
% trajectories reveals route learning in pigeons" by Mann, et al.,
% 2009, equation 12.
%
% _arguments_
%
%          points1: the first set of points
%          points2: the second set of points
%  hyperparameters: a vector containing the input and output
%                   scale for the covariance function
% constraint_noise: the noise to add in for the start/finish
%                   constraints
%    output_length: the "duration" associated with this block
%
% _returns_
% 
% K: the desired covariance matrix
%
% author: roman garnett
%   date: 3 february 2009

% Copyright (c) 2009, Roman Garnett <rgarnett@robots.ox.ac.uk>
% 
% Permission to use, copy, modify, and/or distribute this software for any
% purpose with or without fee is hereby granted, provided that the above
% copyright notice and this permission notice appear in all copies.
% 
% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

function [K gradient_cell] = constrained_covariance (points1, points2, hyperparameters, constriction_noise,cp)

if nargin < 5
    cp = [];
end
%For the covFun  we use the Matern32
    covFun = @covMatern32;
    
% we contrain the paths at the fixed time indices 0 and 1
constriction_points = [0; cp;1];

% ensure column vector
hyperparameters = hyperparameters(:);

% calculate required components of the covariance
[temp initial_covariance] = covFun(hyperparameters, points1, points2);
[temp K1_constriction] = covFun(hyperparameters, points1, constriction_points);
[temp K_constriction_constriction] = covFun(hyperparameters, constriction_points, constriction_points);
[temp K2_constriction] = covFun(hyperparameters, points2, constriction_points);

% add in noise to the constraints
K_constriction_constriction = ...
  K_constriction_constriction + diag(exp(2 * constriction_noise)) * eye(length(constriction_points));

% apply the start/finish constraints
K = initial_covariance - K1_constriction * (K_constriction_constriction \ K2_constriction');


if (nargout == 2) 
  for i = 1:numel(hyperparameters)

initial_covariance_gradient = covFun(hyperparameters, points1, points2, i);
    K1_constriction_gradient = covFun(hyperparameters, points1, constriction_points, i);
    K_constriction_constriction_gradient = covFun(hyperparameters, constriction_points, constriction_points, i);
    K2_constriction_gradient = covFun(hyperparameters, points2, constriction_points, i);
    
    answer = initial_covariance_gradient - ...
      K1_constriction * (K_constriction_constriction \ K_constriction_constriction_gradient) * (K_constriction_constriction \ K2_constriction') - ...
      K1_constriction * (K_constriction_constriction \ K2_constriction_gradient') - ...
      K1_constriction_gradient * (K_constriction_constriction \ K2_constriction');

    gradient_cell{i} = answer;
  end
end  

  
  