% function [K, K_gradient] = calculate_joint_covariance(parameters)
%
% calculates the covariance function for the habitual route
% covariance defined in "Predictibility of homing trajectories
% reveals route learning in pigeons" by Mann, et al., 2009,
% equation 12.
%
% _arguments_
%
% parameters: a structure containing the needed information, with
%             fields:
%
%       path_lengths: a vector containing the length of each path
%       inputs: a cell of input points for each path
%       input_scale1: the log of the input scale for the observed
%                     covariance
%      output_scale1: the log of the output scale for the observed
%                     covariance
%       input_scale2: the log of the input scale for the habitual
%                     route covariance
%      output_scale2: the log of the output scale for the habitual
%                     route covariance
%       input_scale3: the log of the 2nd input scale for the habitual
%                     route covariance
%      output_scale3: the log of the 2nd output scale for the habitual
%                     route covariance
%          end_noise: the log of the noise to add to start/finish
%                     constraints
%              noise: the log of the noise to add to returned
%                     covariance
%    standard_length: the "duration" of the straight line path
%
% _returns_
% 
% K: the desired covariance matrix
%
% author: roman garnett
%   date: 3 february 2009

% Copyright (c) 2009, Roman Garnett <rgarnett@robots.ox.ac.uk>
% 
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

function [K, K_gradient] = calculate_joint_covariance (parameters, cp)
if nargin < 2
    cp = [];
end
% ensure parameters exist
fail = false;
if (~isfield(parameters, 'input_scale1'))
  disp('need parameters.input_scale1!'); fail = true;
end
if (~isfield(parameters, 'input_scale2'))
  disp('need parameters.input_scale2!'); fail = true;
end
if (~isfield(parameters, 'output_scale1'))
  disp('need parameters.output_scale1!'); fail = true;
end
if (~isfield(parameters, 'output_scale2'))
  disp('need parameters.output_scale2!'); fail = true;
end
if (~isfield(parameters, 'noise'))
  disp('need parameters.noise!'); fail = true;
end
if (~isfield(parameters, 'end_noise'))
  disp('need parameters.end_noise!'); fail = true;
end

if (fail)
  K = 0;
  return;
end


number_of_paths = numel(parameters.inputs);
path_lengths = zeros(number_of_paths, 1);
for i = 1:number_of_paths
    path_lengths(i) = length(parameters.inputs{i});
end

output_size = sum(path_lengths);

% precompute indicies for the blocks for each pair of paths
path_indices_begin = 1 + cumsum([0; path_lengths(1:end-1)]);
path_indices_end = cumsum(path_lengths);

hyperparameters1 = [parameters.input_scale1; parameters.output_scale1];
hyperparameters2 = [parameters.input_scale2; parameters.output_scale2];

K = zeros(output_size);
K_gradient = cell(5, 1);
if nargout == 2
    for k = 1:5
        K_gradient{k} = K;
    end
end


% calculate the blocks for the habitual route covariance
for i = 1:number_of_paths
  for j = 1:number_of_paths

   
    points1 = parameters.inputs{i}(:);
    points2 = parameters.inputs{j}(:);
    
    switch nargout
        case 1
            this_block = constrained_covariance(points1, points2, hyperparameters2, ...
                                        parameters.end_noise,cp);
        case 2
            [this_block, this_block_gradient] = constrained_covariance(points1, points2, hyperparameters2, ...
                                        parameters.end_noise);
    end
    
                                    
    indices1 = path_indices_begin(i):path_indices_end(i);
    indices2 = path_indices_begin(j):path_indices_end(j);
   
    K(indices1, indices2) = this_block;
    if nargout == 2
      for k = 1:2
          K_gradient{k}(indices1, indices2) = K_gradient{k}(indices1, indices2) + this_block_gradient{k};
      end
    end
  end
end


% add in the diagonal blocks for the observed path covariance
for i = 1:number_of_paths
  points = parameters.inputs{i}(:);
  switch nargout
      case 1
          this_block = constrained_covariance(points, points, hyperparameters1, ...
                                      parameters.end_noise,cp);
      case 2
          [this_block, this_block_gradient] = constrained_covariance(points, points, hyperparameters1, ...
                                      parameters.end_noise);
  end
  indices = path_indices_begin(i):path_indices_end(i);
  
  K(indices, indices) = K(indices, indices) + this_block;
 
  
  if nargout == 2
      for k = 1:2
          K_gradient{k+2}(indices, indices) = K_gradient{k+2}(indices, indices) + this_block_gradient{k};
      end
  end
  
  
end

% add in noise
K = K + diag(exp(2 * parameters.noise) * ones(1, output_size));

if nargout == 2
    K_gradient{5} = 2*diag(exp(2 * parameters.noise) * ones(1, output_size));
end














