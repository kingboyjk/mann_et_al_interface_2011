function model = train_bird_model(model, x)
%model = train_bird_model(model, x)
%
%Trains a model created by init_bird_model().
%
%Trains the model parameters based on the training paths x. x should be
%N-by-3 with x, y, t triplets. Do trimming outside of this code. 
%
%Uses the Metroplis-Hastings algorithm to assign new samples from the posterior
%distribution of the hyper-parameters.

%Richard Mann (2009)

%Options for linsolve
upper.UT = true;
lower.UT = true;
lower.TRANSA = true;

prior_params = model.prior_params;


%determine number of input paths. If not a cell must be 1 path
if(iscell(x))
    number_of_paths = numel(x);
else
    number_of_paths = 1;
end
%*************************************************************************

%Collect data from paths and remove the straight line.
%*************************************************************************
X = [];%data, includes x and y signals

for  i = 1:number_of_paths
    y = x{i};
    t = y(:, 3);   
    y = y(:, 1:2); %y is now just the positions
    sl = straight_line_path(prior_params.start, prior_params.end, 500);
    sl = fill_missing_data(sl, linspace(0, 1, 500)', sort(t, 'ascend')); %get sl at the right points
    y = y-sl; %remove the straight line
    X = [X; y];
    path_lengths(i) = size(y, 1);
    inputs{i}=t;
end

%**************************************************************************
%Use Metro.Hastings to generate new samples
%*************************************************************************

%Sort out properties of the parameters that aren't adjustable
parameters.model = prior_params.model;
parameters.standard_length = 500;
parameters.end_noise = log(prior_params.trim);
parameters.path_lengths = path_lengths;
parameters.inputs = inputs;

propcov = 0.025*eye(5); %This can be adjusted if the MH acceptance rate is unsuitable - aim for 0.25 acceptance.
proprnd = @(p) mvnrnd(p, propcov); %random generator for MH

for dim = 1:2 %Loop over X and Y
    
%Starting point for MCMC algorithm is from the prior
params_start(1) = normrnd(prior_params.log_input_scale1_mean, 0.1);
params_start(2) = normrnd(prior_params.log_output_scale1_mean, 0.1);
params_start(3) = normrnd(prior_params.log_input_scale2_mean, 0.1);
params_start(4) = normrnd(prior_params.log_output_scale2_mean, 0.1);
params_start(5) = normrnd(prior_params.log_noise_mean,0.1);


%******************THIS CODE FOR MH FROM MATLAB*****************************
logpdf = @(p) the_log_posterior(p, X(:, dim), prior_params, parameters); %logpdf for MH


[params_out, accept_rate] = mhsample(params_start, prior_params.number_of_samples, 'logpdf', logpdf, 'proprnd', proprnd, 'symmetric', 1, 'burnin', 100, 'thin',1); %The MH stage
%FOR DORA
%[params_out, accept_rate] = my_mhsample(params_start, prior_params.number_of_samples, logpdf, proprnd,100,1); %The MH stage

disp(['Metropolis Hastings Acceptance Rate: ', num2str(accept_rate)]);
%*************************************************************************


samples(dim).log_input_scale1 = params_out(:, 1); %Place generated samples into the structure
samples(dim).log_output_scale1 = params_out(:, 2);
samples(dim).log_input_scale2 = params_out(:, 3);
samples(dim).log_output_scale2 = params_out(:, 4);
samples(dim).log_noise = params_out(:, 5);

end

model.samples = samples; %Put the generated samples into the structure


function logP = the_log_posterior(adjust_params, X, prior_params, parameters) %The posterior calculator for MH

parameters.input_scale1 = adjust_params(1);
parameters.output_scale1 = adjust_params(2); %Fill the parameter structure with the adjustable parameters
parameters.input_scale2 = adjust_params(3);
parameters.output_scale2 = adjust_params(4);
parameters.noise = adjust_params(5);

K = calculate_joint_covariance(parameters); %covariance matrix


try
R = chol(K); %cholesky decomposition

logP= logmvnpdf_cholesky(X, R); %Likelihood

logP=logP + log(normpdf(adjust_params(1), prior_params.log_input_scale1_mean, prior_params.log_input_scale1_std)); %These lines multiply the likelihood by the prior
logP=logP + log(normpdf(adjust_params(2), prior_params.log_output_scale1_mean, prior_params.log_output_scale1_std));
logP=logP + log(normpdf(adjust_params(3), prior_params.log_input_scale2_mean, prior_params.log_input_scale2_std));
logP=logP + log(normpdf(adjust_params(4), prior_params.log_output_scale2_mean, prior_params.log_output_scale2_std));
logP=logP + log(normpdf(adjust_params(5), prior_params.log_noise_mean, ...
                   prior_params.log_noise_std));

catch
    
    logP = -inf; %In case of chol failure, assign negligible likelihood
    
end




