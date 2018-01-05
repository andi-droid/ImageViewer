classdef FFTVorticityFigure < FitBaseFigure
    properties
        phi
        
        background
        
        c
        t
        frequency
        run
        title
        memoryEffect = 0
    end
    
    methods
        % constructor
        function o = FFTVorticityFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;
            o.frequency = o.compositor.userIndeces.frequency.value;
            o.run = o.compositor.userIndeces.run.value;
            hs = o.data.getHaukeSet(o.t,o.run);
            if ~isempty(hs)
                o.phi = hs.getfftP(o.frequency);
                o.phi = v.vorticity(o.phi);
                BW = uZoneMask(1,size(o.phi, 1),size(o.phi, 2),o.compositor.data.center(2),o.compositor.data.center(1),o.compositor.data.lvl,1);
                out = o.phi(~BW);
                o.c = sum(abs(out(:)))/sum(double(~BW(:)));
                %o.phi = o.phi.*BW;
                
                if isempty(o.background)
                    o.background = zeros(size(o.phi));
                end
                if o.memoryEffect
                    o.background = o.background + 0.15*o.phi;
                end
                o.phi = o.phi + o.background;
            else
                o.phi = NaN(size(o.phi));
            end
            %o.phi = shakenBGH.vorticity(o.phi);
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time');
            o.linkUpDownLeftRightToIndeces('frequency', 'run');
            o.listenToUserInput('frequency');
            o.listenToUserInput('run');
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.phi);
            o.title = title(o.axes, num2str(o.c));
            colormap(o.axes, v.vortexmap(500));
            caxis(o.axes, [-1.2 1.2]);
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            o.addZones;

        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.phi;
            o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.c);
        end
    end
    
end

