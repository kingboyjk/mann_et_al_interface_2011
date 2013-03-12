function [x, t] = read_standard_data(filename)
%[x,t] = read_standard_data(filename)
%
%Finds the longitude, latitude and time columns and imports them as x =
%[long, lat] and t = time. Re-normalises time to begin at 1.
%
%
%Relies on readtext.m (downloadable, COPYRIGHT (C) Peder Axensten (peder at axensten dot se), 2006-2007.)
%
%Richard Mann (2009)
data = readtext(filename, '\t', '', '', 'textual');
titles = data(1, :);
longidx = find(strcmpi('longitude', titles));
latidx = find(strcmpi('latitude', titles));
timeidx=find(strcmpi('time', titles));
if isempty(longidx) %if no labels we assume long, lat
    longidx = 1;
    latidx = 2;
    timeidx = [];
end


%Look for time format
if isempty(timeidx)
    t = [1:size(data, 1)-1]';
    
else
    
example_time = data{2, timeidx};
times = data(2:end, timeidx);
if ~sum(ismember(example_time, ':')) > 0 %if no colons in time format put them in
    for i = 1:numel(times)
        times{i} = [times{i}(1:end-4), ':', times{i}(end-3:end-2), ':', times{i}(end-1:end)]; %Put colons in
        t(i) = datenum(times{i});
    end
else
    for i = 1:numel(times)
        t(i) = datenum(times{i});
    end
end
t=t(:);
t = t-t(1);
t = t*24*3600; %adjust from days to seconds
t = t+1; %start t at 1

end

data = readtext(filename, '\t', '', '', 'numeric');
x = data(2:end, [longidx, latidx]);


  
  
 
  
  
  
  
  
  
  
  