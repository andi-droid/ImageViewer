doPlot = true;

nSets = numel(dataStructure.haukeSets);
lvl = dataStructure.lvl;
center = dataStructure.center;
hs0 = dataStructure.haukeSets{1};
sz = size(hs0.imageData);
[kx, ky] = shakenBGH.generateCoordinates(lvl, sz(2:3), [center(1) center(2)]);
circCenters = zeros(2, 3);
BW = uZoneMask(1,sz(2),sz(3), center(2),center(1),1.3*lvl,1);

for i = 1:3
    c = 1/sqrt(3)*[cosd(i*120-60) sind(i*120-60)];
    [x(i), y(i)] = FitBaseFigure.kToPixelS([c(1); c(2)], lvl, center);
end
[x(4),y(4)] = FitBaseFigure.kToPixelS([0; 0], lvl, center);
res = nan(nSets, 2, 4);

for iS = 1:nSets
    iS
    hs = dataStructure.haukeSets{iS};
    phase = squeeze(hs.fftP(3,:,:));
    t = dataStructure.parameters(iS,1);
    run = dataStructure.parameters(iS,2);
    
    vort = v.vorticity(phase);
    vort(~BW) = 0;
    
    % find positive vortices
    p = vort>0.1;
    CC= bwconncomp(p);
    S = regionprops(CC,'Centroid');
    pc = nan(2, numel(S));
    pc(:) = [S.Centroid];
    
    % find negativ vortices
    m = vort<-0.1;
    CC= bwconncomp(m);
    S = regionprops(CC,'Centroid');
    mc = nan(2, numel(S));
    mc(:) = [S.Centroid];
    
    % find closest to expected positions
    closest = nan(2, 4);
    for i=1:3
        d = hypot(pc(1,:)-x(i), pc(2,:)-y(i));
        [m,ind] = min(d);
        if m < 10
            closest(:,i)=[pc(1,ind) pc(2,ind)];
        end
    end
    d = hypot(mc(1,:)-x(4), mc(2,:)-y(4));
    [m,ind] = min(d);
    if m < 6
        closest(:,4)=[mc(1,ind) mc(2,ind)];
    end
        
    if doPlot
        imagesc(vort);

        hold on;
        plot(pc(1,:),pc(2,:),'+k');
        plot(mc(1,:),mc(2,:),'+r');
        plot(x,y,'ob');
        plot(closest(1,:),closest(2,:),'or');
        hold off;
    end
    res(iS,:,:) = closest;
    
    for i=1:4
        bs(run+1, t,i,:) = closest(:,i);
    end
end