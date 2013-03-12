function efficiency = path_efficiency(x)
% efficiency = path_efficiency(x) 
% 
% Calculates the efficiency of a path (or cell of paths), defined as
% straight line distance flown divided by the total arc length of the path
  
  if iscell(x)
    for i = 1:numel(x)
      efficiency(i) = path_efficiency(x{i});
    end
  else
    efficiency =sqrt(sum((x(end, :)-x(1, :)).^2))/sum(sqrt(sum(diff(x).^2, 2)));
  end
  