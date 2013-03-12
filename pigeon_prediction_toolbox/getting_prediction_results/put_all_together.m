%This script puts together all the results from GetResultsScript for all
%sites.

%The important results with respect to the Interface Journal paper are
%commented.

%Richard Mann (2009)

bigM2 = zeros(31, 18); 
bigM3 = zeros(31, 17);
bigM4= zeros(31, 16);
bigD2 = zeros(31, 18);
bigD3 = zeros(31, 17);
bigD4 = zeros(31, 16);


sitenumber = 1;
put_results_together
save HPresults X* eX* M* D* d* ed*
bigM2(1:8, :) = M2;
bigM3(1:8, :) = M3;
bigM4(1:8, :) = M4;
bigD2(1:8, :) = D2;
bigD3(1:8, :) = D3;
bigD4(1:8, :) = D4;
clear X* eX* M* D* d* ed*


sitenumber = 2;
put_results_together
save WWresults X* eX* M* D* d* ed*
bigM2(9:16, :) = M2;
bigM3(9:16, :) = M3;
bigM4(9:16, :) = M4;
bigD2(9:16, :) = D2;
bigD3(9:16, :) = D3;
bigD4(9:16, :) = D4;
clear X* eX* M* D* d* ed*


sitenumber = 3;
put_results_together
save BHresults X* eX* M* D* d* ed*
bigM2(17:23, :) = M2;
bigM3(17:23, :) = M3;
bigM4(17:23, :) = M4;
bigD2(17:23, :) = D2;
bigD3(17:23, :) = D3;
bigD4(17:23, :) = D4;
clear X* eX* M* D* d* ed*



sitenumber = 4;
put_results_together
save CHresults X* eX* M* D* d* ed*
bigM2(24:31, :) = M2;
bigM3(24:31, :) = M3;
bigM4(24:31, :) = M4;
bigD2(24:31, :) = D2;
bigD3(24:31, :) = D3;
bigD4(24:31, :) = D4;
clear X* eX* M* D* d* ed*

%The following section calculates what we ultimately want, the MIG based on
%prdictions using 2, 3 and 4 paths (bigXn). bigeXn gives the 25th and 75th
%percentile (the inter-quartile range)

for i = 1:18
    [bigX2(i), bigeX2(i, :)] = median_CI(bigM2(:, i));
    [bigd2(i), biged2(i, :)] = median_CI(bigD2(:, i));
end
for i = 1:17
    [bigX3(i), bigeX3(i, :)] = median_CI(bigM3(:, i));
    [bigd3(i), biged3(i, :)] = median_CI(bigD3(:, i));
end
for i = 1:16
    [bigX4(i), bigeX4(i, :)] = median_CI(bigM4(:, i));
    [bigd4(i), biged4(i, :)] = median_CI(bigD4(:, i));
end


save BIGresults big*

