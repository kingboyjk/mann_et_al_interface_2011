function model = marginal_predictions(model, prediction_times, x)
%model = marginal_predictions(model, prediction_times, x)
%
%Takes a model and gives the posterior ( P(y|x) ) mean and
%covariance at an inputed set of time samples
%
%Find the predicted mean, variance and standard error as model.prediction.
%{mean, variance, variance_on_mean}


%Richard Mann (2009)

%Options for linsolve
upper.UT = true;
lower.UT = true;
lower.TRANSA = true;

samples = model.samples;
prior_params = model.prior_params;

%PROCESS TRAINING DATA

%Determine number of x paths. If not a cell must be 1 path
X = [];%data, includes x and y signals
if isempty(x)
  x_inputs = {};
  x_path_lengths = [];
  
else
  
  if(iscell(x))
    number_of_paths = numel(x);
  else
    number_of_paths = 1;
  end
  %*************************************************************************
  
  %Collect data from paths and remove the straight line.
  %**********************************************************************
  
  for i = 1:number_of_paths
    
    t = x{i}(:, 3);
    z = x{i}(:, 1:2); %z is now just the positions
    
    sl = straight_line_path(prior_params.start, prior_params.end, 500);
    sl = fill_missing_data(sl, linspace(0, 1, 500)', sort(t, 'ascend')); %get sl at the right points
    
    z = z-sl; %remove the straight line
    X = [X; z];
    x_path_lengths(i) = size(z, 1);
    x_inputs{i}=t;
    
  end
end


t = prediction_times;
y_path_lengths = size(t, 1); %The length and times for the predictions
y_inputs{1}=t;



model.prediction.mean = zeros(y_path_lengths, 2);
model.prediction.variance = zeros(y_path_lengths, 2);
model.prediction.variance_on_mean = zeros(y_path_lengths, 2);
parameters.model = prior_params.model;
parameters.standard_length = 500;
parameters.end_noise = log(prior_params.trim);


parameters.path_lengths = [x_path_lengths, y_path_lengths];
parameters.inputs = [x_inputs, y_inputs];

for dim = 1:2 %loop over both dimensions
  model.prediction.Sigma{dim} = zeros(y_path_lengths);
  model.prediction.Sigma_mean{dim} = zeros(y_path_lengths);
  
  sample = 1;
  while sample  <= prior_params.number_of_samples %Loop over all the
                                                %samples from MH
    
 
    
    %Place sample values into parameters
    parameters.path_lengths = [x_path_lengths, y_path_lengths];
    parameters.inputs = [x_inputs, y_inputs];
    parameters.input_scale1 = samples(dim).log_input_scale1(sample);
    parameters.output_scale1 = samples(dim).log_output_scale1(sample);
    parameters.input_scale2 = samples(dim).log_input_scale2(sample);
    parameters.output_scale2 = samples(dim).log_output_scale2(sample);
    parameters.noise = samples(dim).log_noise(sample);
    
    %Calculate covariance matrix
    K_full = calculate_joint_covariance(parameters);
    K_test = K_full(sum(x_path_lengths)+1:end, sum(x_path_lengths)+1:end);
    
    %Calculate the covariance just over the habitual path
    parameters.path_lengths = [y_path_lengths];
    parameters.inputs = [y_inputs];
    parameters.output_scale1 = -3000;
    parameters.noise = -3000; %set these parameters to 0 for no observed path
    K_mean = calculate_joint_covariance(parameters);
    
    
    
    
    %if no training data make naive prediction
    if isempty(X)
      predict_mean = zeros(y_path_lengths, 1);
      predict_K = K_test;
      predict_K_mean = K_mean;
    else %else predict based on training data
      
      K_train = K_full(1:sum(x_path_lengths), 1:sum(x_path_lengths));
      R_train = chol(K_train);
      
      K_testtrain = K_full(sum(x_path_lengths)+1:end, 1:sum(x_path_lengths));
      predict_mean = K_testtrain*linsolve(R_train,linsolve(R_train, X(:, dim), lower), upper);
      predict_K = K_test-K_testtrain*linsolve(R_train, linsolve(R_train, K_testtrain', lower), upper);
      predict_K_mean = K_mean-K_testtrain*linsolve(R_train, linsolve(R_train, K_testtrain', lower), upper);
    end
    
    model.prediction.mean(:, dim) = model.prediction.mean(:, dim) +(1/prior_params.number_of_samples)*predict_mean;
    model.prediction.Sigma{dim} = model.prediction.Sigma{dim} + (1/prior_params.number_of_samples)*(predict_K + predict_mean*predict_mean');
    model.prediction.Sigma_mean{dim} = model.prediction.Sigma_mean{dim} + (1/prior_params.number_of_samples)*(predict_K_mean + predict_mean*predict_mean');
    
    %Now replicate the p[rediction as long as the sample doesn't change
    while sample < (prior_params.number_of_samples) && (samples(dim).log_input_scale1(sample+1) == samples(dim).log_input_scale1(sample))
            model.prediction.mean(:, dim) = model.prediction.mean(:, dim) +(1/prior_params.number_of_samples)*predict_mean;
            model.prediction.Sigma{dim} = model.prediction.Sigma{dim} + (1/prior_params.number_of_samples)*(predict_K + predict_mean*predict_mean');
            model.prediction.Sigma_mean{dim} = model.prediction.Sigma_mean{dim} + (1/prior_params.number_of_samples)*(predict_K_mean + predict_mean*predict_mean');
            sample = sample+1;
    end
    
  sample = sample +1;      
  end
  
  model.prediction.Sigma{dim} = model.prediction.Sigma{dim} - model.prediction.mean(:, dim)*model.prediction.mean(:, dim)';
  model.prediction.Sigma_mean{dim} = model.prediction.Sigma_mean{dim} - model.prediction.mean(:, dim)*model.prediction.mean(:, dim)';
  model.prediction.variance(:, dim) = diag(model.prediction.Sigma{dim});
  model.prediction.variance_on_mean(:, dim) = diag(model.prediction.Sigma_mean{dim});
  
  

end

sl = straight_line_path(prior_params.start, prior_params.end, 500);
sl = fill_missing_data(sl, linspace(0, 1, 500)', sort(t, 'ascend')); %get sl at the right points
model.prediction.mean = model.prediction.mean+sl; %Add the sl back onto
                                                    %the mean

        
        
    
          
        


  
   
      
            
            
            
            
            
            
            

