p = dataStructure.parameters;

% select runs
runs = [ 6, 3];
selection = false(size(p,1),1);
for iRun = 1:numel(runs)
    selection = selection | p(:,2)==runs(iRun);
end

% find common times
