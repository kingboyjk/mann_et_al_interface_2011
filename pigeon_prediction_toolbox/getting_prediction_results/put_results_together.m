%Takes the output from the GetResultsScript and puts them together
%properly. Needs the variable 'sitenumber', use put_all_together to do all
%4 sites.

sitenames = {'HP', 'WW', 'BH', 'CH'};
numbirds = [8,8,7,8];
site = sitenames{sitenumber};
n = numbirds(sitenumber);

%bad_paths_cell lists which flights are inadmissable. Possible reasons:
%bird never returns home. tracker fails/outputs excessive noise. 
bad_paths_cell{1} = [1, 8;
    1, 16;
    1, 19;
    2, 6; %Hp
    5, 20;
    5, 6;%noise
    6, 13;
    7, 6]; %These paths are to be excluded

bad_paths_cell{2} = [1, 20;
    6, 1;
    7,8;
    8,4;
    8,8];



bad_paths_cell{3} = [2,1;
    2,5;
    3,4];

bad_paths_cell{4} = [1,5;
    8,18];

bad_paths = bad_paths_cell{sitenumber};

for i = 1:20
    idx = find(bad_paths(:, 2) == i); %find instances of a problem in path i
    idx_ok{i} = setdiff(1:n, bad_paths(idx, 1)); %which birds DON'T have a problem
end

try
    load([site, '_MH0.mat']);
catch
    disp('fail on 0')
end

try
    load([site, '_MH2.mat']);
    for i = 1:n
        for j = 1:18
            M2(i,j) = model_test1(i,j).test_logP-model_test_naive(i,j+2).test_logP;
            D2(i,j) = sqrt(mean(model_predict(i,j).prediction.variance_on_mean(:)));
        end
    end
    
    
    
    for i = 1:18
        indices = idx_ok{i};
        for j = 1:2
            indices = intersect(indices, idx_ok{i+j});
        end
        
        [X2(i), X2CI(i, :)] = median_CI(M2(indices, i));
        eX2(i,1) = -quantile(M2(indices, i), 0.25)+X2(i);
        eX2(i,2) = quantile(M2(indices, i), 0.75)-X2(i);
        [d2(i), d2CI(i, :)] = median_CI(D2(indices, i));
        ed2(i,1) = -quantile(D2(indices, i), 0.25)+d2(i);
        ed2(i,2) = quantile(D2(indices, i), 0.75)-d2(i);
        ed2(i) = std(D2(indices, i))/sqrt(numel(indices));
        M2(setdiff(1:size(M2,1),indices), i) = NaN;
        D2(setdiff(1:size(D2,1),indices), i) = NaN;
        
    end
    
catch
    disp('Fail on 2')
end


try
    load([site, '_MH3.mat']);
    for i = 1:n
        for j = 1:17
            M3(i,j) = model_test1(i,j).test_logP-model_test_naive(i,j+3).test_logP;
            D3(i,j) = sqrt(mean(model_predict(i,j).prediction.variance_on_mean(:)));
        end
    end
    
    
    
    for i = 1:17
        indices = idx_ok{i};
        for j = 1:3
            indices = intersect(indices, idx_ok{i+j});
        end
        
        [X3(i), X3CI(i, :)] = median_CI(M3(indices, i));
        eX3(i,1) = -quantile(M3(indices, i), 0.25)+X3(i);
        eX3(i,2) = quantile(M3(indices, i), 0.75)-X3(i);
        [d3(i), d3CI(i, :)] = median_CI(D3(indices, i));
        ed3(i,1) = -quantile(D3(indices, i), 0.25)+d3(i);
        ed3(i,2) = quantile(D3(indices, i), 0.75)-d3(i);
        ed3(i) = std(D3(indices, i))/sqrt(numel(indices));
        M3(setdiff(1:size(M3,1),indices), i) = NaN;
        D3(setdiff(1:size(D3,1),indices), i) = NaN;
        
    end
    
catch
    disp('Fail on 3')
end

try
    load([site, '_MH4.mat']);
    for i = 1:n
        for j = 1:16
            M4(i,j) = model_test1(i,j).test_logP-model_test_naive(i,j+4).test_logP;
            D4(i,j) = sqrt(mean(model_predict(i,j).prediction.variance_on_mean(:)));
        end
    end
    
    
    
    for i = 1:16
        indices = idx_ok{i};
        for j = 1:4
            indices = intersect(indices, idx_ok{i+j});
        end
        [X4(i), X4CI(i, :)] = median_CI(M4(indices, i));
        eX4(i,1) = -quantile(M4(indices, i), 0.25)+X4(i);
        eX4(i,2) = quantile(M4(indices, i), 0.75)-X4(i);
        [d4(i), d4CI(i, :)] = median_CI(D4(indices, i));
        ed4(i,1) = -quantile(D4(indices, i), 0.25)+d4(i);
        ed4(i,2) = quantile(D4(indices, i), 0.75)-d4(i);
        ed4(i) = std(D4(indices, i))/sqrt(numel(indices));
        M4(setdiff(1:size(M4,1),indices), i) = NaN;
        D4(setdiff(1:size(D4,1),indices), i) = NaN;
        
    end
    
catch
    disp('Fail on 4')
end

