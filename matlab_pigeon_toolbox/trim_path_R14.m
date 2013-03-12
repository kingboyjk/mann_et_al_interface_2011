function [y,idx] =trim_path_R14(x, start, finish, r)
%Rename this file trim_path and use if trim_path() does not work  

% [x, idx] = trim_path(start, finish, r)
% Trims a path to remove points within a set distance of the start and
% finish. Keeps all points after bird FIRST leaves a ring of distance, r,
% around the start and untilt the bird FIRST enters a ring of distanc, r,
% around the finish.
%
%Inputs: 
%x: path to trim. If x is a cell function will recurse over elements and
%return a cell of results
%start/finish: the start and finish locations to trim around
%r: the radius of the trim
%
%Outputs
%y: the output path
%idx: the indices of the retained points

%Richard Mann (2009)

if numel(r) == 1
    r(2) = r(1);
end

if iscell(x)
    for i = 1:numel(x)
        [y{i}, idx{i}] = trim_path(x{i}, start, finish, r);
    end
else

idx = [1:size(x,1)]';
%y = bsxfun(@minus, x(:, 1:2),start);
y = x(:, 1:2) - repmat(start, length(x), 1);
idx1 = find(sum(y.^2, 2) > r(1)^2);
firstleave = min(idx1);
if isempty(firstleave)
  firstleave = 1;
end

%y=bsxfun(@minus, x(:, 1:2), finish);
y = x(:, 1:2) - repmat(finish, length(x), 1);
idx2 = find(sum(y.^2, 2) < r(2)^2);
firstenter = min(idx2);
if isempty(firstenter)
  firstenter = idx(end);
end

idx = firstleave:firstenter;
y=x(idx, :);

end