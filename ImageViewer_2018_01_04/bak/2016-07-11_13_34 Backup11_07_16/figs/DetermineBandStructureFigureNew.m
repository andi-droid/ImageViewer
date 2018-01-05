classdef DetermineBandStructureFigure < FitBaseFigure
    properties
        val
        t
        run
        solver
        
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
        
        theta
        phi
        sphere
        spacePlot
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
                p = prctile(amp(:),95);
                amp = amp/p;
                amp(:) = min(amp(:),1);
                o.phi = squeeze(hs.fftP(3,:,:));
                o.phi(:) = v.pmod(o.phi(:));
                [o.DX,o.DY] = v.grad(-o.phi);
                o.val = o.DX.^2+o.DY.^2;
                %o.val = o.val./amp;
                
                o.phi(~BW) = nan;
                
                [o.DX,o.DY] = v.grad(o.val);
                
                %                     [x1,y1] = o.kToPixel(c);
                %                     x = [x1, y1, r*o.compositor.data.lvl];
                %                     xy = v.discreteCircle(x(1:2),x(3));
                %                     for i = 1:size(xy,2)
                %                         o.val(xy(2,i),xy(1,i))= 1e5;
                %                     end
                %o.val = o.val>5;
                if o.t >4
                vort = v.vorticity(o.phi);
                %%% find static vorties
                center = zeros(2, 3);
                %                     for i = 1:3
                %                         phi = linspace(0, 2*pi, 10);
                %                         c = 1/sqrt(3)*[cosd(i*120-60) sind(i*120-60)];
                %                         [x, y] = o.kToPixel([c(1)+r*cos(phi); c(2)+r*sin(phi)]);
                %                         BW = roipoly(o.val, x,y);
                %                         A = o.val(BW);
                %                         X = o.kx(BW);
                %                         Y = o.ky(BW);
                %                         [~,ind] = max(A(:));
                %                         center(:, i) = [X(ind),Y(ind)];
                %                     end
                
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
                %                     for iR = 1:maxR-1
                %                         for i =1:1
                %                             [ix, iy] = o.kToPixel(center(:,i));
                %                             %r = diff(shiftdim(error(:,i)));
                %                             r = (shiftdim(error(:,i)));
                %                             o.drawRing([ix; iy;  iR], r(iR)/1e3);
                %                         end
                %                     end
                [r, ir] = min(error);
                rstart = ir/o.compositor.data.lvl;
                opt =optimset('MaxFunEvals',1000,'TolFun',1e-10,'MaxIter',1000,'TolX',1E-10,'display','none');
                x = nan(3,3);
                o.theta = asin(amp);
                for i=1:3
                    [ix, iy] = o.kToPixel(center(:,i));
                    x(i,:) = fminsearch(@o.ringError, [ix,iy,ir(i)] , opt);
                    o.bs(o.t, i, :) = [o.t ,x(i,3)/o.compositor.data.lvl];
                    
                    k = o.pixelToK(x(i,1),x(i,2));    
                    o.linex{i} = k(1)+0.5*x(i,3)/o.compositor.data.lvl*cos(phi);
                    o.liney{i} = k(2)+0.5*x(i,3)/o.compositor.data.lvl*sin(phi);
                    
                    [xl, yl] = o.kToPixel([o.linex{i}; o.liney{i}]);
                    BW = roipoly(o.val, xl,yl);
                    
                    o.theta(BW) = pi- o.theta(BW);
                end
                                
                %o.drawRing([ix(i); iy(i);  ir(i)], 1);
                o.val = o.theta;
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
                        o.compositor.userIndeces.time.minValue, 3, 2); 
        end
        
        function onReplot(o)
            subplot(1,2,1, o.axes);
            o.processData();
            
            o.imageF(o.val);
            
            
            o.axes.XLim = [-0.9561 0.4404];
            o.axes.YLim = [-1.1862 0.2103];
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            
            %caxis(o.axes, [5 100]);
            caxis(o.axes, pi*[-1 1]);
            %colormap(o.axes, v.vortexmap(500));
            
            
            o.addZones;
                   hold(o.axes, 'on');
            for i=1:3
                o.linePlot{i} = plot(o.axes, o.linex{i}, o.liney{i});
                o.linePlot{i}.Color = [ 0 0 0];
                o.linePlot{i}.LineWidth = 2;
            end
            hold(o.axes, 'off');
            
            %[dVx, dVy] = o.derivative(o.linex, o.liney);
            %o.potentialPlot = quiver(o.linex, o.liney, dVx, dVy,'Parent', o.axes);
            %             o.qplot = quiver(o.kx, o.ky, o.DX, o.DY,'Parent', o.axes);
            
            
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
            
%             o.axes =  axes(...
%                 'Parent',o.figure,...
%                 'Units', 'normalized',...'DataAspectRatioMode', 'auto',...
%                 'Box', 'off',...'DataAspectRatio', [1 1 1],...
%                 'FontName', o.font,...
%                 'Color', [1 1 1 ]);
%             
%             subplot(1,2,2, o.axes);
%             
%             [X,Y,Z]=sphere(40);
%             o.sphere=surf(o.axes, X,Y,Z);
%             set(o.sphere, 'FaceAlpha', 0.5);
%             o.sphere.FaceColor = 'interp';
%             o.sphere.EdgeColor = 'none';
%             lightangle(-45,30);
%             o.sphere.FaceLighting = 'gouraud';
%             o.sphere.AmbientStrength = 0.3;
%             o.sphere.DiffuseStrength = 0.8;
%             o.sphere.SpecularStrength = 0.9;
%             o.sphere.SpecularExponent = 25;
%             o.sphere.BackFaceLighting = 'lit';
%             
%             o.axes.Visible = 'off';
%             camera_distance = 3.;
%             camera_viewing_angle = 5;
%             campos([camera_distance*5 camera_distance*10 camera_distance*3]);
%             camlookat(o.sphere);
%             camva(camera_viewing_angle);
%             
%             colormap(o.axes, v.vortexmap(500));
%             
%             hold(o.axes, 'on');
%             
%             l = 1.5;
%             arrow3([-l 0 0],[l 0 0],':');
%             arrow3([0 -l 0],[0 l 0],':');
%             arrow3([0 0 -l],[0 0 l],'-2');
%             s = 1.01;
%             sx = sin(o.theta).*cos(o.phi);
%             sy = sin(o.theta).*sin(o.phi);
%             sz = cos(o.theta);
%             o.spacePlot = scatter3(o.axes, s*sx(:), s*sy(:),s*sz(:),'filled',...
%                  'MarkerFaceColor',[0.3 0 0]);
%             
% %             o.spacePlot.MarkerEdgeAlpha = 0;
% %             o.spacePlot.MarkerFaceAlpha = 0.2;
% %             o.spacePlot.Marker = 'o';
%             
%             hold(o.axes, 'off');
%             daspect(o.axes, [1 1 1]);
%             o.axes.XLim = [-l l];
%             o.axes.YLim = [-l l];
%             o.axes.ZLim = [-l l];
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
                if xy(2,i) < size(o.val,1) && xy(1,i) < size(o.val,2) 
                    s = s + log(1+o.val(xy(2,i),xy(1,i)));
                end
                %o.val(xy(2,i),xy(1,i)) = x(3)/33;;
            end
            e = 1/s*size(xy,2);
        end
        function drawRing(o,x, r)
            xy = v.discreteCircle(x(1:2),x(3));
            for i = 1:size(xy,2)
                o.val(xy(2,i),xy(1,i)) = r;
            end
        end
    end
    
end

