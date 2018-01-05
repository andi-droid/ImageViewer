classdef ZTEFigure < FitBaseFigure
    properties
        val
        t
        run
        solver
        pathFinder
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
        function o = ZTEFigure()
            o.windowTitle = mfilename('class');
            o.solver = ZtsSolver();
            o.pathFinder = PathFinder;
            %o.solver.rePlotFunc = @o.replotLine;
            %o.solver.potentialFunc = @o.replotPotential;
            o.pathFinder.rePlotFunc = @o.replotGrowingLine;
            o.pathFinder.potentialFunc = @o.replotPotential;
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
            function initializeEmpty
                sz = size(o.compositor.data.haukeSets{1}.imageData);
                o.val = NaN(sz(2:3));
            end
            if ~isempty(hs)
                %if isstruct(hs.fitResults)
                if 1
                    %o.val = hs.fitResults.fftP(3,:,:);
                    amp = squeeze(hs.fftA(3,:,:));
                    o.val = squeeze(hs.fftP(3,:,:));
                    o.val(:) = v.pmod(o.val(:));
                    [o.DX,o.DY] = v.grad(-o.val);
                    o.val = o.DX.^2+o.DY.^2;
                    o.val = o.val./amp;
                    
                    [o.DX,o.DY] = v.grad(o.val);
                    
                    %                     [x1,y1] = o.kToPixel(c);
                    %                     x = [x1, y1, r*o.compositor.data.lvl];
                    %                     xy = v.discreteCircle(x(1:2),x(3));
                    %                     for i = 1:size(xy,2)
                    %                         o.val(xy(2,i),xy(1,i))= 1e5;
                    %                     end
                    o.val = o.val>5;
                else
                    initializeEmpty;
                end
            else
                initializeEmpty;
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
            %[X, Y] = meshgrid(1:size(o.val,1), 1:size(o.val,2));
            %o.X =
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.val);
            
            
            o.axes.XLim = [-0.9561 0.4404];
            o.axes.YLim = [-1.1862 0.2103];
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            
            %caxis(o.axes, [5 100]);
            %caxis(o.axes, [0 1]);
            %colormap(o.axes, v.vortexmap(500));
            
            
            o.addZones;
            hold(o.axes, 'on');
            %             o.linePlot = plot(o.axes, o.linex, o.liney);
            %             o.linePlot.Color = [ 0 0 0];
            %             o.linePlot.LineWidth = 2;
            [dVx, dVy] = o.derivative(o.linex, o.liney);
            %o.potentialPlot = quiver(o.linex, o.liney, dVx, dVy,'Parent', o.axes);
            %             o.qplot = quiver(o.kx, o.ky, o.DX, o.DY,'Parent', o.axes);
            hold(o.axes, 'off');
            
            %[o.linex, o.liney] = o.solver.solve(@o.derivative,o.linex,o.liney);
            
            %   find minimum in circle
            %             [x, y] = o.kToPixel([o.linex; o.liney]);
            %             BW = roipoly(o.val, x,y);
            %             A = o.val(BW);
            %             X = o.kx(BW);
            %             Y = o.ky(BW);
            %             [~,ind] = max(A(:));
            %             o.replotGrowingLine(X(ind),Y(ind));
            %             [o.linex, o.liney] = o.pathFinder.solve(@o.derivative,X(ind),Y(ind));
            %o.replotLine(o.linex, o.liney)
            
            % fit circle
%             if isempty(o.xsave)
%                 r = 0.2;
%                 c = [-0.289, -0.5];
%                 [x1,y1] = o.kToPixel(c);
%                 o.xsave = [x1, y1, r*o.compositor.data.lvl];
%             end
%             opt =optimset('MaxFunEvals',1000,'TolFun',1e-10,'MaxIter',1000,'TolX',1E-10,'display','none');
%             x = fminsearch(@o.ringError, o.xsave, opt);
%               xy = v.discreteCircle(x(1:2),x(3));
%               for i = 1:size(xy,2)
%                   o.val(xy(2,i),xy(1,i))= 1e5;
%               end
%            o.plot.CData = o.val;
%            o.xsave=x;
        end
        
        function onRedraw(o)
            o.processData();
            %            o.plot.CData = o.val;
            o.onReplot();
            %             delete(o.qplot);
            %             hold(o.axes, 'on');
            %             quiver(o.kx, o.ky, o.DX, o.DY,'Parent', o.axes);
            %             hold(o.axes, 'off');
        end
        function replotLine(o, x, y)
            o.linePlot.XData = x;
            o.linePlot.YData = y;
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
            for i = 1:size(xy,2)
                s = s + log(o.val(xy(2,i),xy(1,i)));
            end
            e = 1/s;
        end
    end
    
end

