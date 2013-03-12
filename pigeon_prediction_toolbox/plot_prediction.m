function h =  plot_prediction(model, variance_type, number_std, col, plot_type)
%
% plot_prediction(model, variance_type, number_std, col, plot_tyep)
%
% Plots the prediction from the output of prediction_wrapper
%
% Inputs: model: The output of prediction_wrapper
% variance_type: either 'total', 'mean' or 'both'. 'total' plots the total variance
% (i.e. both uncertainty on the mean path and the variation around the
% mean). 'mean' plots just the uncertainty on the mean. Both obviously
% plots both!
% number_std: The number of standard deviations to plot (default is 1).
% 1.96 gives a 95% C.I
% col: plot colour. Default is 'b' (blue)
% plot_type: 'lines' or 'circles' to represent uncertainty. Default is
% circles

%Richard Mann (2009)

if ~isfield(model, 'prediction')
    disp('Input structure contains no prediction!')
else
    
    if nargin < 5
        plot_type = 'lines';
        if nargin < 4
            col = 'b'; %Default colour is blue
            if nargin < 3
                number_std = 1; %Default number of standard deviations
            end
            
        end
    end
    
    
    
    mean = model.prediction.mean;
    
    switch variance_type %Using either total variance or the variance on the mean
        case 'total'
            std = sqrt(model.prediction.variance);
        case 'mean'
            std = sqrt(model.prediction.variance_on_mean);
        case 'both'
            if strcmp(col, 'r') %Plot the mean uncertainty in red unless total uncertainty is red
                mcol = 'g';
            else
                mcol = 'r';
            end
            plot_prediction(model, 'mean', number_std, mcol, plot_type);
            hold on
            std = sqrt(model.prediction.variance);
        otherwise
            std = sqrt(model.prediction.variance);
    end
    
    h =plot(mean(:, 1), mean(:, 2), col, 'LineWidth', 3);
    hold on
    
    switch plot_type
        case 'circles'
            
            ellipse(number_std*std(:, 1), number_std*std(:, 2), zeros(length(std)), mean(:, 1), mean(:, 2), col);
            
        otherwise %use lines unless circles specified
            
            dmean = diff(mean);
            dmean(end+1, :) = dmean(end,:); %assume direction unchanged at end
            
            normx = dmean(:, 2)./sqrt(dmean(:, 1).^2+dmean(:, 2).^2); %Normal vector to movement direction
            normy = -dmean(:, 1)./sqrt(dmean(:, 1).^2+dmean(:, 2).^2);
            
            delta_x = number_std*std(:, 1).*normx; %Determine the amount of uncertainty perpendiular to flight
            delta_y = -number_std*std(:, 2).*normy;
            
            plot(mean(:, 1)-delta_x, mean(:, 2)+delta_y, ['--' col]);
            plot(mean(:, 1)+delta_x, mean(:, 2)-delta_y, ['--' col]);
    end
    
    hold off
    
end
