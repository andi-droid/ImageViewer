classdef DefringedImageFigure < ImageBaseFigure
    properties
        image
        t
        frequency
        run
        title
    end
    
    methods
        % constructor
        function o = DefringedImageFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
                o.image = o.compositor.defringedimage;
        end
        
        % implementing BaseFigure
        function onCreate(o)
%             o.linkMouseWheelToIndex('time');
%             o.listenToUserInput('time', @o.onRedraw);
%             o.linkUpDownLeftRightToIndeces('frequency', 'run');
%             o.listenToUserInput('frequency', @o.onRedraw);
%             o.listenToUserInput('run', @o.onRedraw);
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.image);
            %o.title = title(o.axes, num2str(o.t));
            %caxis(o.axes, [-0.02 0.1]);   
            o.axes.XLim = [1 1024];
            o.axes.YLim = [1 512];
            o.axes.Visible = 'off';
            o.clims = [0,0.1];
            set(o.axes, 'CLim', o.clims);
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.image;
            %o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

