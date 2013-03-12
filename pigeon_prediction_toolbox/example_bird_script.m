%Example script for the Prediction Toolbox

%Richard Mann (2009)

%Load data and prior_params

load example_paths
load example_priors %Loads prior_params structure

prior_params.number_of_samples = 1000; %Number of samples for Metropolis-Hastings Markov Chain Monte Carlo integration. Reduce to increase speed, increase for higher accuracy
prior_params.trim = [100, 50]; %This determines how much of the area around the loft and release will be trimmed. Use a 2X1 vector for different trims i.e [start_trim; end_trim]

%Trim paths around the loft and release

x = trim_path(x, prior_params.start, prior_params.end, ...
              prior_params.trim);
y = trim_path(y, prior_params.start, prior_params.end, ...
              prior_params.trim);


%Downsample paths for effective computation. Larger downsampling -> faster
%computation, lower accuracy. Can also use change_path_size() to use equal
%sized paths

downsample_rate = 5;

x{1} = x{1}(1:downsample_rate:end, :);
x{2} = x{2}(1:downsample_rate:end, :);
x{3} = x{3}(1:downsample_rate:end, :);
y{1} = y{1}(1:downsample_rate:end, :);


%Begin and end time index at trim points - helps remove circling effects

x{1}(:, 3) = linspace(0, 1, length(x{1}))';
x{2}(:, 3) = linspace(0, 1, length(x{2}))';
x{3}(:, 3) = linspace(0, 1, length(x{3}))';
y{1}(:, 3) = linspace(0, 1, length(y{1}))';


%Initialise model
disp('Initialising')
model = init_bird_model(prior_params); %Sets up model with hyper-parameter samples from the prior

%Train using x
disp('Training')
model_train = train_bird_model(model, x); %Trains by selecting hyper-parameter samples based on x

%Find P(y | z) from trained model
disp('Test 1: ')
model_test = test_bird_model(model_train, y, x);
disp(['log(P(y|z, trained) = ', num2str(model_test.test_logP)]);
disp('This gives the full prob(y|x)')

%Compare to P(y) from the trained model
disp('Test 2: ')
model_test2 = test_bird_model(model_train, y, []);
disp(['log(P(y| trained) = ', num2str(model_test2.test_logP)]);
%To P(y | z) for the untrained model
disp('Test 3: ')
model_test3 = test_bird_model(model, y, x);
disp(['log(P(y|z, untrained) = ', num2str(model_test3.test_logP)]);
%And to P(y) for the untrained model
disp('Test 4: ')
model_test4 = test_bird_model(model, y, []);
disp(['log(P(y|untrained) = ', num2str(model_test4.test_logP)]);
disp('This gives the full prob(y)')

%Make a graphical prediction
disp('Plotting a graphical prediction. Training data (black, x) and test data (red, y). Bounds indicate 1 S.D')
figure
plot_path(x, 'k');
hold on
plot_path(y, 'r');
prediction_times = linspace(0, 1, 50)'; %Time indices to make the
                                        %prediction on
model_prediction = marginal_predictions(model_train, prediction_times, x);
plot_prediction(model_prediction, 1); %Plot with 1 stand.dev
