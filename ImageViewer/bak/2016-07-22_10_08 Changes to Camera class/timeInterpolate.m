% ok, I confess this is a mess. But it has to be done quickly...
nitSteps = 5;

p = dataStructure.parameters;
% horror: replace time indeces by times
p(:,1) = dataStructure.times(p(:,1));

nRun = max(shiftdim(p(:,2)));

for iRun = 0:nRun
    % gather data
    s = p(:,2)== iRun;
    hs = {dataStructure.haukeSets{s}};
    quenchTimes = p(s,1);
    nSets = numel(dataStructure.haukeSets);
    for iT = 1:numel(quenchTimes)-1


        nt1 = size(hs{iT+0}.imageData,1);
        nt2 = size(hs{iT+1}.imageData,1);
        nt = min(nt1, nt2);

        for iIt=1:nitSteps
            newHs = HaukeSet;
            newHs.interpolated = 1;
            newHs.imageData = ((1-iIt/(nitSteps+1))*hs{iT}.imageData(1:nt,:,:) + iIt/(nitSteps+1)*hs{iT+1}.imageData(1:nt,:,:));
            newHs.times = hs{iT}.times;
            newHs.createFFTs();
            dataStructure.haukeSets{end+1}=newHs;
            newQuenchTime = ((1-iIt/(nitSteps+1))*quenchTimes(iT)+iIt/(nitSteps+1)*quenchTimes(iT+1));

            p = [p ; p(1,:)];
            p(end,1:2)=[newQuenchTime, iRun];
        end
    end

    % horror II: replace times by time indeces
    [newTimes,~,ic] = unique(p(:,1));
    p(:,1) = squeeze(ic);

    % write back results
    dataStructure.times = newTimes;
    dataStructure.parameters = p;
end