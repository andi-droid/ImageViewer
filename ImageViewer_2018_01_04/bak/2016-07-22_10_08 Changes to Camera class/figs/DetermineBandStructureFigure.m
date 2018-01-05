classdef DetermineBandStructureFigure < FitBaseFigure
    properties
        val
        t
        run
        solver
        HTheo
        
        linex, liney
        DX,DY
        ky, kx
        
        qplot
        linePlot
        growingLinePlot
        potentialPlot
        
        xsave
        bs
        debug = 0;
    end
    
    methods
        % constructor
        function o = DetermineBandStructureFigure()
            o.windowTitle = mfilename('class');
            o.solver = ZtsSolver();
            if o.debug
                o.solver.rePlotFunc = @o.replotLine;
                o.solver.potentialFunc = @o.replotPotential;
            end
            % taa   tbb  tab delta
           params = [5.5301 6.9662 -0.010763     2.6864 0 0];
           [Eff_H,lvl, ip] = TBHGenerator.shakingSmooth(...
                                'Amplitude', 2e3,...
                                'ShakingFrequency', 11.9e3,...
                                'TBParameter', params,...
                                'Phase', pi/2,...
                                'PhaseDelay', pi,...
                                'Points', 91);               
            ip.lvl = lvl;
            %o.H.nu = o.frequency;% ist eigentlich in ip schon drinnen
            o.HTheo = shakenBGH;
            o.HTheo.load(Eff_H, ip);     
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;

            o.run = o.compositor.userIndeces.run.value;
            
            hs = o.data.getHaukeSet(o.t,o.run);
            phi = linspace(0, 2*pi, 100);

            if ~isempty(hs)
                %if isstruct(hs.fitResults)
                
                %o.val = hs.fitResults.fftP(3,:,:);
                amp = squeeze(hs.fftA(3,:,:));
                BW = uZoneMask(1,size(amp, 1),size(amp, 2),o.compositor.data.center(2),o.compositor.data.center(1),o.compositor.data.lvl,1);
                amp(~BW) = nan;
                amp = amp/max(amp(:));
                phase = squeeze(hs.fftP(3,:,:));
                phase(:) = v.pmod(phase(:));
                [o.DX,o.DY] = v.grad(-phase);
                o.val = o.DX.^2+o.DY.^2;
                %o.val = o.val./amp;
                
                o.val(~BW) = nan;
                [o.DX,o.DY] = v.grad(o.val);
       
                if o.t >4
                vort = v.vorticity(phase);
                %%% find static vorties
                center = zeros(2, 3);
                       
                for i = 1:3
                    center(:, i) = 1/sqrt(3)*[cosd(i*120) sind(i*120)];
                end
                
                
                %%% find best circle match
                maxR = round(o.compositor.data.lvl/sqrt(3))-5;
                error = nan(maxR, 3);
                for iR = 1:maxR
                    for i =1:3
                        [ix, iy] = o.kToPixel(center(:,i));
                        error(iR, i) = o.ringError([ix; iy; iR]);
                    end
                end

                [r, ir] = min(error);
                rstart = ir/o.compositor.data.lvl;
                opt =optimset('MaxFunEvals',1000,'TolFun',1e-10,'MaxIter',1000,'TolX',1E-10,'display','none');
                x = nan(3,3);
                theta = asin(amp);
                for i=1:3
                    [ix, iy] = o.kToPixel(center(:,i));
                    x(i,:) = fminsearch(@o.ringError, [ix,iy,ir(i)] , opt);
                    o.bs(o.t, i, :) = [o.t ,x(i,3)/o.compositor.data.lvl];
                    
                    k = o.pixelToK(x(i,1),x(i,2));    
                    o.linex{i} = k(1)+x(i,3)/o.compositor.data.lvl*cos(phi);
                    o.liney{i} = k(2)+x(i,3)/o.compositor.data.lvl*sin(phi);
                    
                    [xl, yl] = o.kToPixel([o.linex{i}; o.liney{i}]);
                    BW = roipoly(o.val, xl,yl);
                    
                    theta(BW) = - theta(BW);
                end

                end 
            else
                sz = size(o.compositor.data.haukeSets{1}.imageData);
                o.val = NaN(sz(2:3));
            end
        end
        
        function [dVx, dVy] = derivative(o, kx, ky)
            dVx = interp2(o.kx, o.ky, o.DX, kx, ky);
            dVy = interp2(o.kx, o.ky, o.DY, kx, ky);
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time', @o.onRedraw);
            o.linkUpDownLeftRightToIndeces('', 'run');
            o.listenToUserInput('run', @o.onRedraw);
            
            sz = size(o.compositor.data.haukeSets{1}.imageData);
            [o.kx, o.ky] = shakenBGH.generateCoordinates(o.compositor.data.lvl, sz(2:3), [o.compositor.data.center(1) o.compositor.data.center(2)]);
            o.bs = zeros(o.compositor.userIndeces.time.maxValue -...
                        o.compositor.userIndeces.time.minValue+1, 3, 2); 
        end
        
        function onReplot(o)
            o.processData();
            subplot(1,2,1, o.axes);

            o.imageF(o.val);
            
            
            o.axes.XLim = [-0.9561 0.4404];
            o.axes.YLim = [-1.1862 0.2103];
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            
            caxis(o.axes, pi*[-1 1]);

            
            
            o.addZones;
            
            hold(o.axes, 'on');
            for i=1:3
                o.linePlot{i} = plot(o.axes, o.linex{i}, o.liney{i});
                o.linePlot{i}.Color = [ 0 0 0];
                o.linePlot{i}.LineWidth = 2;
            end
            hold(o.axes, 'off');
    
            o.axes =  axes(...
                'Parent',o.figure,...
                'Units', 'normalized',...'DataAspectRatioMode', 'auto',...
                'Box', 'off',...'DataAspectRatio', [1 1 1],...
                'FontName', o.font,...
                'Color', [1 1 1 ]);
            
            subplot(1,2,2, o.axes);
            
%             FitBaseFigure.imageL(squeeze(o.HTheo.Z(5,:,:)),...
%                                 o.HTheo.lvl,o.HTheo.center, 'Parent', o.axes);
            
%             o.addZones;

            %x = 1/sqrt(3)*cosd(120) + o.bs(:, 1, 2);
            %y = 1/sqrt(3)*sind(120)*ones(size(o.bs(:, 1, 2)));
            x = 1/sqrt(3)*cosd(120) + linspace(0,1,200);
            y = 1/sqrt(3)*sind(120)*ones(1,200);
            E = interp2(o.HTheo.kx, o.HTheo.ky,  squeeze(o.HTheo.Z(5,:,:)), x, y)/(v.hbar*1);
            %plot(o.axes, E,  o.bs(:, 1, 2), '+k');
            plot(o.axes, E,  linspace(0,1,200), '-k');
            
            hold(o.axes, 'on');
            for i=1:3
               plot(o.axes, max(00, 0.5*pi./(o.data.times*1e-3 + 2/11.9e3)), o.bs(:, i, 2),'-');
               plot(o.axes, max(00, 0.5*pi./(o.data.times(o.t)*1e-3 + 2/11.9e3)), o.bs(o.t, i, 2),'or');
            end
             hold(o.axes, 'off');
            xlim([0 4e3]);
        end
        
        function onRedraw(o)
            o.processData();
            o.onReplot();
        end

        function replotPotential(o, dVx, dVy, x, y)
            o.potentialPlot.XData = x;
            o.potentialPlot.YData = y;
            o.potentialPlot.UData = dVx;
            o.potentialPlot.VData = dVy;
        end
        
        function replotGrowingLine(o, x, y)
            v.saveDelete(o.growingLinePlot);
            hold(o.axes, 'on');
            o.growingLinePlot = plot(o.axes, x, y,'-x');
            hold(o.axes, 'off');
            o.growingLinePlot.Color = [ 0 0 0];
            o.growingLinePlot.LineWidth = 2;
        end
        
        function e = ringError(o,x)
            xy = v.discreteCircle(x(1:2),x(3));
            s = 0;
            norm = 1;
            for i = 1:size(xy,2)
                if xy(2,i) < size(o.val,1) && xy(1,i) < size(o.val,2)
                    newval=o.val(xy(2,i),xy(1,i));
                    if ~isnan(newval)
                        norm = norm+1;
                        s = s + log(1+newval);
                    end
                end
                %o.val(xy(2,i),xy(1,i)) = x(3)/33;;
            end
            e = 1/s*norm;
        end
        function drawRing(o,x, r)
            xy = v.discreteCircle(x(1:2),x(3));
            for i = 1:size(xy,2)
                o.val(xy(2,i),xy(1,i)) = r;
            end
        end
    end
    
end

