nSets = numel(dataStructure.haukeSets);
lvl = dataStructure.lvl;
center = dataStructure.center;
hs0 = dataStructure.haukeSets{1};
sz = size(hs0.imageData);
[kx, ky] = shakenBGH.generateCoordinates(lvl, sz(2:3), [center(1) center(2)]);
circCenters = zeros(2, 3);

% Create Masks
phi = linspace(0, 2*pi, 10);
r = 0.1;
BW = cell(3,1);
for i = 1:3
    c = 1/sqrt(3)*[cosd(i*120) sind(i*120)];
    [x, y] = FitBaseFigure.kToPixelS([c(1)+r*cos(phi); c(2)+r*sin(phi)], lvl, center);
    BW{i} = roipoly(squeeze(hs0.fftP(3,:,:)), x,y);
end

for iS = 1:nSets
    hs = dataStructure.haukeSets{iS};
    phase = squeeze(hs.fftP(3,:,:));
    t = dataStructure.parameters(iS,1);
    run = dataStructure.parameters(iS,2);
    for i=1:3
        A = phase(BW{i});
        bs(run+1, t,i,2) = mean(A);
    end
end

