%This script runs through the experimental data file (allSites40k) and
%finds the MIG based on predictions using different numbers of paths.
%You must set the variable site (= 1,2,3 or 4) before running

%Richard Mann (2009)



warning off
nbirds = [8,8,7,8];
downrate=5;
sitePrefix = {'HP', 'WW', 'BH', 'CH'};

paramString = ['./data/priors_', sitePrefix{site},'_onmap_new.mat'];
load(paramString, 'prior_params');
prior_params.number_of_samples = 1000;
prior_params.trim = 100;
load allSites40k;


for i = site
    for j = 1:nbirds(site)
        for k = 1:20
            allSites40k(i).bird(j).path{k} = ...
                trim_path(allSites40k(i).bird(j).path{k}, prior_params.start, ...
                prior_params.end, prior_params.trim);
            allSites40k(i).bird(j).path{k} = [allSites40k(i).bird(j).path{k}, linspace(0,1, length(allSites40k(i).bird(j).path{k}))'];
            allSites40k(i).bird(j).path = change_path_size(allSites40k(i).bird(j).path, 100);
        end
    end
end

tic
model = init_bird_model(prior_params);

for j = 1:20
    parfor i = 1:nbirds(site)
        y = allSites40k(site).bird(i).path(j);
        model_test_naive(i,j) = test_bird_model(model, y, []);
    end
end
toc
save([sitePrefix{site},'_MH0.mat'], 'model_test_naive');

for j = 1:18
    parfor i = 1:nbirds(site)
        x = allSites40k(site).bird(i).path(j:j+1);
        y = allSites40k(site).bird(i).path(j+2);
        
        model_train = train_bird_model(model, x);
        model_test1(i,j) = test_bird_model(model_train, y, x);
        model_test2(i,j) = test_bird_model(model_train, y, []);
        model_predict(i,j) = marginal_predictions(model_train, linspace(0,1, 50)', ...
            x);
    end
end
toc
save([sitePrefix{site},'_MH2.mat'], 'model_test1', 'model_test2','model_predict');
clear model_test1 model_test2 model_train

for j = 1:17
    parfor i = 1:nbirds(site)
        x = allSites40k(site).bird(i).path(j:j+2);
        y = allSites40k(site).bird(i).path(j+3);
        
        model_train = train_bird_model(model, x);
        model_test1(i,j) = test_bird_model(model_train, y, x);
        model_test2(i,j) = test_bird_model(model_train, y, []);
        
        model_predict(i,j) = marginal_predictions(model_train, linspace(0,1, 50)', ...
            x);
    end
end
toc
save([sitePrefix{site},'_MH3.mat'], 'model_test1', 'model_test2','model_predict');
clear model_test1 model_test2 model_train

for j = 1:16
    parfor i = 1:nbirds(site)
        x = allSites40k(site).bird(i).path(j:j+3);
        y = allSites40k(site).bird(i).path(j+4);
        
        model_train = train_bird_model(model, x);
        model_test1(i,j) = test_bird_model(model_train, y, x);
        model_test2(i,j) = test_bird_model(model_train, y, []);
        
        model_predict(i,j) = marginal_predictions(model_train, linspace(0,1, 50)', ...
            x);
    end
end
toc
save([sitePrefix{site},'_MH4.mat'], 'model_test1', 'model_test2', 'model_predict');
clear model_test1 model_test2 model_train
