a = [dataStructure.haukeSets{:}];
i = [a.info];
l = [i.latticeDepth1];
r = dataStructure.parameters(:,2);

[C,ia,ic] = unique(l);
map = parula(numel(ia));
figure;
hold on;
for iRun=1:size(bs,1)
    ind = ic(find(r==iRun-1,1))
    c = map(ind,:)
    for iCorner =4
        p = plot(bs(iRun, :,iCorner,1),bs(iRun, :,iCorner,2),'+');
        p.Color = c;
    end
end
hold off;