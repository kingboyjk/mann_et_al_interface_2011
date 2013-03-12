function model = test_bird_model(model, y, x)
%model = test_bird_model(model, y, x)
%Calculates integral p(y|x, theta)P(theta|training) dtheta given a previously trained or untrained model. If model
%is trained on x this is simply p(y|x). 
%
%the calculated log-probability of the test data (y) is given by
%model.test_logP. model.std_test_logP gives a rough estimate of the
%accuracy of that answer.

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
        z = x{i}(:, 1:2); %y is now just the positions
        
        sl = straight_line_path(prior_params.start, prior_params.end, 500);
        sl = fill_missing_data(sl, linspace(0, 1, 500)', sort(t, 'ascend')); %get sl at the right points
        
        z = z-sl; %remove the straight line
        X = [X; z];
        x_path_lengths(i) = size(z, 1);
        x_inputs{i}=t;
        
    end
end

%PROCESS TEST DATA

%determine number of y paths. If not a cell must be 1 path
if(iscell(y))
    number_of_paths = numel(y);
else
    number_of_paths = 1;
end
%*************************************************************************

%Collect data from paths and remove the straight line.
%*************************************************************************
Y = [];%data, includes x and y signals

for i = 1:number_of_paths
    
    t = y{i}(:, 3);
    z = y{i}(:, 1:2); %y is now just the positions
    
    sl = straight_line_path(prior_params.start, prior_params.end, 500);
    sl = fill_missing_data(sl,linspace(0, 1, 500)', sort(t, 'ascend')); %get sl at the right points
    
    z = z-sl; %remove the straight line
    Y = [Y; z];
    y_path_lengths(i) = size(z, 1);
    y_inputs{i}=t;
    
end

model.test_logP = 0;
model.std_test_logP=0;

parameters.model = prior_params.model;
parameters.standard_length = 500;
parameters.end_noise = log(prior_params.trim);
parameters.path_lengths = [x_path_lengths, y_path_lengths];
parameters.inputs = [x_inputs, y_inputs];

for dim = 1:2 %loop over both dimensions
      
    LL = zeros(prior_params.number_of_samples, 1);
    sample = 1;
    while sample <= prior_params.number_of_samples
        
        try
       %Place sample values into parameters 
        parameters.input_scale1 = samples(dim).log_input_scale1(sample);
        parameters.output_scale1 = samples(dim).log_output_scale1(sample);
        parameters.input_scale2 = samples(dim).log_input_scale2(sample);
        parameters.output_scale2 = samples(dim).log_output_scale2(sample);
        parameters.noise = samples(dim).log_noise(sample);
        
        %Calculate covariance matrix
       
        K_full = calculate_joint_covariance(parameters);
        K_test = K_full(sum(x_path_lengths)+1:end, sum(x_path_lengths)+1:end);
        
        %if no training data make naive prediction
        if isempty(X)
            predict_mean = zeros(size(Y,1), 1);
            predict_K = K_test;
        else %else predict based on training data
            
            K_train = K_full(1:sum(x_path_lengths), 1:sum(x_path_lengths));
            R_train = chol(K_train);
            
            K_testtrain = K_full(sum(x_path_lengths)+1:end, 1:sum(x_path_lengths));
            predict_mean = K_testtrain*linsolve(R_train,linsolve(R_train, X(:, dim), lower), upper);
            predict_K = K_test-K_testtrain*linsolve(R_train, linsolve(R_train, K_testtrain', lower), upper);
        end
        
        predict_R = chol(predict_K);
        %Calculate logP of test data for sample times the weighting
        LL(sample) = logmvnpdf_cholesky(Y(:, dim)-predict_mean, predict_R);
        catch
            LL(sample) = -inf; %In cas of chol failure, assign negligable likelihood
        end
            
        %Now replicate the log-likelihood for any subsequent samples that
        %are the same
        while sample < (prior_params.number_of_samples) && (samples(dim).log_input_scale1(sample+1) == samples(dim).log_input_scale1(sample))
            LL(sample+1) = LL(sample);
            sample = sample+1;
        end
        
        
    sample = sample+1;   
    end
    
    %*************************************************************************
    %Marginalise using Vanilla Monte Carlo to obtain estimate of integral
    %log int_P(x|theta)P(theta)d_theta = Evidence.
    %*************************************************************************
    order_mag = max(LL);
    L = exp(LL-order_mag);
    model.test_logP = model.test_logP + log(mean(L)) + order_mag;
    model.std_test_logP = model.std_test_logP + (1/prior_params.number_of_samples)*(var(L)/mean(L)^2);
  
    
%     fprintf('\n')
end

model.std_test_logP = sqrt(model.std_test_logP);
        
        
        
    
          
        


  
   
      
            
            
            
            
            
            
            

