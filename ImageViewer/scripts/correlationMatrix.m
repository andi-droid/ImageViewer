nSets = size(res,1);
matrix = zeros(nSets);
for iSetI=1:nSets
    for iSetC=1:nSets
        d = hypot(res(iSetI,1,:)-res(iSetC,1,:), res(iSetI,2,:)-res(iSetC,2,:));
        matrix(iSetI, iSetC)=1/nanmean(d);
    end
    
end
figure; imagesc(matrix)