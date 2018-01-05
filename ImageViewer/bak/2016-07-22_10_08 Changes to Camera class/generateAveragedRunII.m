p = dataStructure.parameters;

% only use times that are present in both sets
runs = [ 6, 3, 2];
tMax = max(p(:,1));
res = NaN(numel(runs), tMax);
quenchTimes = 1:tMax;
for iRun = 1:numel(runs)
    for iqt=quenchTimes
        [~,id]=ismember(p(:,[1 2]), [iqt runs(iRun)], 'rows');
        f = find(id); assert(numel(f)==1||numel(f)==0);
        if numel(f)==1
            res(iRun, iqt) = find(id);
        end
    end
end
s = ~isnan(sum(res,1));
res = res(:,s);
quenchTimes = shiftdim(quenchTimes(s));

%find hauke times
times = [];
for iSelection = 1:numel(res)
    data = dataStructure.haukeSets{res(iSelection)};
    times = [times data.times];
end
times = unique(times);

hs1 = dataStructure.haukeSets{1};
data = NaN(numel(runs), size(res,2), numel(times), size(hs1.imageData,2), size(hs1.imageData,3));
for it=1:size(res,2)
    for iRun=1:size(res,1)
        hs = dataStructure.haukeSets{res(iRun, it)};
        [~,~,ic] =unique([hs.times times]);
        ic = ic(1:numel(hs.times));
        data(iRun, it, ic,:,:) = hs.imageData;
    end
end

av = squeeze(nanmean(data,1));

% write to dataSet
newRunNum = max(p(:,2))+1;
U = ones(numel(quenchTimes),1);
newP = [quenchTimes, newRunNum*U, p(1,3)*U, p(1,4)*U];
p = [p ; newP];
nSets = numel(dataStructure.haukeSets);
for iSet=1:numel(quenchTimes)
    hs = HaukeSet;
    hs.imageData = squeeze(av(iSet, :,:,:));
    hs.times = times;
    hs.atomCount = ones(numel(times),1);
    hs.createFFTs();
    dataStructure.haukeSets{nSets+iSet} = hs;
end
dataStructure.parameters = p;