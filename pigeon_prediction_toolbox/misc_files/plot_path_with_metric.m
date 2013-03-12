function plot_path_with_metric(x, h);
% plot_path_with_metric(x, h)
% plots path x overlayed with colour coded metric h

%Author: Richard Mann
%Date: 17 March 2009


hld = ishold;

% Normalise to 0..1 for plotting
h = (h-min(h));
h = h/max(h);

hold on
for i = 1:length(x)
    plot(x(i, 1), x(i, 2),'o','MarkerEdgeColor',[.5 h(i) .5],'MarkerFaceColor',[.5 h(i) .5],'MarkerSize',5);
end
if hld == 0
  hold off
end

