function model = init_bird_model(prior_params)
%model = init_bird_model(prior_params)
%
%Initialises a model structure with priors and samples
%If prior_params is a filename, load 'prior_params' from file

%Richard Mann (2009)

if ischar(prior_params)
    loadstruct = load(prior_params);
    prior_params = loadstruct.prior_params;
end
model.prior_params= prior_params;

number_of_samples = prior_params.number_of_samples;

for dim = 1:2
    
samples(dim).log_input_scale1 = normrnd(prior_params.log_input_scale1_mean, prior_params.log_input_scale1_std, number_of_samples, 1);
samples(dim).log_output_scale1 = normrnd(prior_params.log_output_scale1_mean, prior_params.log_output_scale1_std, number_of_samples, 1); %Generating samples from the prior
samples(dim).log_input_scale2 = normrnd(prior_params.log_input_scale2_mean, prior_params.log_input_scale2_std, number_of_samples, 1); %These will be replaced by MH algorithm in the training stage
samples(dim).log_output_scale2 = normrnd(prior_params.log_output_scale2_mean, prior_params.log_output_scale2_std, number_of_samples, 1);
samples(dim).log_noise = normrnd(prior_params.log_noise_mean, prior_params.log_noise_std, number_of_samples, 1);

end

model.samples=samples;  %Place naive samples from the prior


