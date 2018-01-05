phi = linspace(0, 2*pi, 100);
lvl = dataStructure.lvl;
center = dataStructure.center;
circCenters = zeros(2, 3);

for iS = 1:numel(dataStructure.haukeSets)
    iS
    hs = dataStructure.haukeSets{iS};
    
    t = dataStructure.parameters(iS,1);
    run = dataStructure.parameters(iS,2);

    amp = squeeze(hs.fftA(3,:,:));
    phase = squeeze(hs.fftP(3,:,:));
    
    BW = uZoneMask(1,size(amp, 1),size(amp, 2), center(2),center(1),lvl,1);
    
    %amp(~BW) = nan;
    %amp = amp/max(amp(:));
    
    %phase(~BW) = nan;
    phase(:) = v.pmod(phase(:));
    
    [DX,DY] = v.grad(-phase);
    val = DX.^2+DY.^2;
    val = val./amp;
    
    [DX,DY] = v.grad(val);
    
    if t > 4
        for i = 1:3
            circCenters(:, i) = 1/sqrt(3)*[cosd(i*120) sind(i*120)];
        end
        
        
        %%% find best circle match
        maxR = round(lvl/sqrt(3))-5;
        error = nan(maxR, 3);
        for iR = 1:maxR
            for i =1:3
                [ix, iy] = FitBaseFigure.kToPixelS(circCenters(:,i), lvl, center);
                error(iR, i) = ringError(val, [ix; iy; iR]);
            end
        end
        
        [r, ir] = min(error);
        rstart = ir/lvl;
        
        opt =optimset('MaxFunEvals',1000,'TolFun',1e-10,'MaxIter',1000,'TolX',1E-10,'display','none');
        x = nan(3,3);
        
        theta = asin(amp);
        
        for i=1:3
            [ix, iy] = FitBaseFigure.kToPixelS(circCenters(:,i), lvl, center);
            x(i,:) = fminsearch(@(x)ringError(val,x), [ix,iy,ir(i)] , opt);
            bs(run+1, t, i, :) = [t ,x(i,3)/lvl];
        end
        
    end
end