classdef FFTMaxFigure < FitBaseFigure
    properties
        phi
        t
        frequency
        run
        title
    end
    
    methods
        % constructor
        function o = FFTMaxFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;
            o.frequency = o.compositor.userIndeces.frequency.value;
            o.run = o.compositor.userIndeces.run.value;
            hs = o.data.getHaukeSet(o.t,o.run);
%             nf = size(hs.fftA,1);
%             [A, I]= max(hs.fftA(round(1):round(nf/4),:,:),[], 1);
             sz = size(hs.fftP);
            if ~isempty(hs)
                o.phi = zeros(sz(2:3));
%                 o.phi = squeeze(hs.fftP(I(:),:));
                
                o.phi(:) = mod(o.phi(:)+pi+pi/2,2*pi)-pi;
            else
                o.phi = NaN(size(o.phi));
            end
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

