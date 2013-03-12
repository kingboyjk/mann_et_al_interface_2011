function [t_waypoints, marg_likelihood, MIGratio, x] = find_waypoints(x, prior_params, n, L)
%[t_waypoints, marg_likelihood, MIGratio, x] = find_waypoints(x, prior_params, n, L)
%
%Locates up to n waypoints from a set of paths, x, based on a structure
%containing the priors, prior_params.
%
%Each path is resampled to be L points long before the analysis begins.
%L must be bigger than n.
%
%The waypoints are output as proportional time indices between 0 and 1. The
%marginal likelihood and the MIG ratio can also be output, and the resampled paths.
%
%The bayes factor for moving to the m-th waypoint is
%marg_likelihood(m)-marg_likelihood(m-1).

%Richard Mann (2009)
if nargin < 4
    L = 100;
    if nargin < 3
        n = 10;
    end
end


x = change_path_size(x, L);
t = linspace(0, 1, length(x{1}))';
numpath = numel(x);
for path_ind = 1:numpath;
    x{path_ind}(:, 3) = t;
end




t_waypoints = [];
MIGratio = [];
marg_likelihood = [];
model = init_bird_model(prior_params);

disp('Training model for hyper-parameters')
%model_train = train_bird_model(model,x(1:numpath-2));
model_train = model;
baseline = 0;
disp('Establishing a baseline reading')


for path_ind = 1:numpath
    model_test = test_bird_model(model_train, x(path_ind), x(setdiff(1:numpath, path_ind)));%Predict
    %path_ind
    %from
    %not-path_ind
    %FULLY
    %as
    %baseline
    baseline = baseline + model_test.test_logP;
end

disp('Finding optimal waypoints');


while(length(t_waypoints) < n)
    
    points_left = setdiff(1:L, t_waypoints);
    point_likelihood = zeros(numel(points_left), 1);
    
    
    parfor point_ind = 1:numel(points_left)
        y = cell(numel(x), 1);
        
        t_waypoints_try = sort([t_waypoints; points_left(point_ind)]);
        
        for path_ind = 1:numpath
            y{path_ind} = x{path_ind}(t_waypoints_try, :);
        end
        
        parfor_point_likelihood = 0;
        
        
        for path_ind = 1:numpath
            
            model_test = test_bird_model(model_train, x(path_ind), y(setdiff(1:numpath, path_ind))); %Predict path_ind from not-path_ind
          
            
            parfor_point_likelihood = parfor_point_likelihood + model_test.test_logP;
            
        end
        
        point_likelihood(point_ind) = parfor_point_likelihood;
        
        
    end
    
    
    [max_point_likelihood, best_point_ind] = max(point_likelihood);
    
    marg_likelihood = [marg_likelihood, log(mean(exp(point_likelihood-max_point_likelihood)))+max_point_likelihood-baseline];
    
    t_waypoints = [t_waypoints; points_left(best_point_ind)];
    
    MIGratio = [MIGratio; max_point_likelihood-baseline];
    
    
    disp(['Number of waypoints identified: ' num2str(length(t_waypoints))])
    
    
end

t_waypoints = t(t_waypoints);


