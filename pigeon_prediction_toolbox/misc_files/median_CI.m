function [med, CI] = median_CI(data, alpha)

if nargin < 2
    alpha = 0.05;
end
test_CI = linspace(min(data), max(data), 1000);
data = data(~isnan(data));
med = median(data);
if nargout == 2
for i = 1:length(test_CI)
    P(i) = signtest(data, test_CI(i));
    
end


CI(1) = min(test_CI(P>alpha));
CI(2) = max(test_CI(P>alpha));
end