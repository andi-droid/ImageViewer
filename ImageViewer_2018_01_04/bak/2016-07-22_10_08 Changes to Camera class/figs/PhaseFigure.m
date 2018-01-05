classdef PhaseFigure < FitBaseFigure
    properties
        phi
        t
        frequency
        run
        title
    end
    
    methods
        % constructor
        function o = PhaseFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;
            o.frequency = o.compositor.userIndeces.frequency.value;
            o.run = o.compositor.userIndeces.run.value;
            
            
            hs = o.data.getHaukeSet(o.t,o.run);
            
            
            if ~isempty(hs)
                o.phi = hs.getfftP(o.frequency);
            else
                o.phi = NaN(size(o.phi));
            end
            
%             hsbg = o.data.getHaukeSetsTime(2);
%             bg = zeros(size(o.phi));
%             for ihs = 1:numel(hsbg)
%                 bg = bg + v.pmod(hsbg{ihs}.getfftP(o.frequency));
%             end
%             bg = bg/numel(hsbg);
%             
            
%             hsbg = o.data.getHaukeSetsRun(o.run);
%             bg1 = zeros([numel(hsbg), size(o.phi)]);
%             for ihs = 1:numel(hsbg)
%                 bg1(ihs,:,:) = v.pmod(hsbg{ihs}.getfftP(o.frequency));
%             end
%             bg = pca(bg1(:,:));
%             bg = squeeze(mean(bg1,1));
            
            
            
            
%             o.phi(:) = v.pmod(o.phi-bg);
            %o.phi(:) = v.pmod(o.phi(:)-bg(:,1));
            %o.phi(:) = bg(:);
%             nSteps = 50;
%             p = zeros([nSteps, size(o.phi)]);
%             alpha = linspace(0,2*pi, nSteps);
%             for iAlpha =1:nSteps
%                 p(iAlpha, : ,:) = entropyfilt(v.pmod(o.phi+alpha(iAlpha)), true(5));
%             end
%             o.phi = (squeeze(mean(p,1)));
            
%             [DX,DY] = v.grad(-o.phi);
%             o.phi = DX.^2+DY.^2;
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time', @o.onUpdate);
            o.linkUpDownLeftRightToIndeces('frequency', 'run');
            o.listenToUserInput('frequency', @o.onUpdate);
            o.listenToUserInput('run', @o.onUpdate);
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.phi);
            o.title = title(o.axes, num2str(o.t));
            colormap(o.axes, v.phasemap(500));
            %colormap(o.axes, vortexmap(500));
            
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            o.addZones;
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.phi;
            o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

