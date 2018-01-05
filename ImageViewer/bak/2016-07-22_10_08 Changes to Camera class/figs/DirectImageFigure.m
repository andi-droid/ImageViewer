classdef DirectImageFigure < FitBaseFigure
    properties
        image
        t
        frequency
        run
        title
    end
    
    methods
        % constructor
        function o = DirectImageFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;
            o.frequency = o.compositor.userIndeces.frequency.value;
            o.run = o.compositor.userIndeces.run.value;
            hs = o.data.getHaukeSet(o.t,o.run);
            %hs = o.data.getHaukeSet(2,3);
            if ~isempty(hs)
                o.image = squeeze(hs.imageData(o.frequency, :,:));
            else
                o.image = NaN(size(o.image));
            end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time', @o.onRedraw);
            o.linkUpDownLeftRightToIndeces('frequency', 'run');
            o.listenToUserInput('frequency', @o.onRedraw);
            o.listenToUserInput('run', @o.onRedraw);
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.image);
            o.title = title(o.axes, num2str(o.t));
            caxis(o.axes, [-0.02 0.1]);   
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.image;
            o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

