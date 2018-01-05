classdef FFTFilterFigure < FitBaseFigure
    properties
        val
        t
        run
        
        linex
        liney
        DX
        DY
        X
        Y
        
        ky,kx
        
        qplot
        linePlot
        growingLinePlot
        potentialPlot
        
        xsave
    end
    
    methods
        % constructor
        function o = FFTFilterFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;
            o.run = o.compositor.userIndeces.run.value;
            
            hs = o.data.getHaukeSet(o.t,o.run);
            phi = linspace(0, 2*pi, 100);
            r = 0.2;
            c = [-0.289, -0.5];
            o.linex = c(1)+r*cos(phi);
            o.liney = c(2)+r*sin(phi);
            
            if ~isempty(hs)
                %o.val = hs.fitResults.fftP(3,:,:);
                amp = squeeze(hs.fftA(3,:,:));
                o.val = squeeze(hs.fftP(3,:,:));
                o.val(:) = v.pmod(o.val(:));
                [o.DX,o.DY] = v.grad(-o.val);
                o.val = o.DX.^2+o.DY.^2;
                o.val = exp(o.val);
                %o.val = o.val./amp;
                
                [o.DX,o.DY] = v.grad(o.val);
                
                o.val = ifft2(ifftshift(fftshift(fft2(o.val))));
                %o.val = o.val>5;
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
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.val);
            
            o.axes.XLim = [-0.9561 0.4404];
            o.axes.YLim = [-1.1862 0.2103];
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            
            %caxis(o.axes, [5 100]);
            caxis(o.axes, [0 5]);
            %colormap(o.axes, v.vortexmap(500));
            
            o.addZones;
        end
        
        function onRedraw(o)
            o.processData();
            o.onReplot();
        end
        
    end
    
end

