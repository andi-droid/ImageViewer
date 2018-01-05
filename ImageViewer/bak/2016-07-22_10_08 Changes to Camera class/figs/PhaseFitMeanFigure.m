classdef PhaseFitMeanFigure < FitBaseFigure
    properties
        phi
        t
        averageCount
        title
    end
    
    methods
        % constructor
        function o = PhaseFitMeanFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;

            [hs, fits] = o.data.getHaukeSetsTime(o.t);
            o.averageCount = numel(hs);
            sz = size(hs{1}.imageData);
            res1 = NaN([o.averageCount, sz(1:2)]);
            res2 = NaN([o.averageCount, sz(1:2)]);
            for iHs =1:o.averageCount
                phase = fits{iHs}.display.pha1;
                res1(iHs, :,:) = sin(phase);
                res2(iHs, :,:) = cos(phase);                
            end
            s = squeeze(mean(res1,1));
            c = squeeze(mean(res2,1));
            o.phi = shakenBGH.vorticity(atan2(s, c));
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time', @o.onRedraw);
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.phi);
           
            colormap(o.axes, vortexmap(500));
            o.title = title(o.axes, num2str(o.averageCount));

            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            caxis(o.axes, [-1.5 1.5]);
            o.addZones;
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.phi;
            o.title.String = sprintf('average count: %d', o.averageCount);
        end
    end
    
end

