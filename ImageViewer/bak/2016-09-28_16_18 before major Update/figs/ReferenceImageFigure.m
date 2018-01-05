classdef ReferenceImageFigure < ImageBaseFigure
    properties
        image
        t
        frequency
        run
        title
        wjet
    end
    
    methods
        % constructor
        function o = ReferenceImageFigure()
            o.windowTitle = mfilename('class');
                  B = load('wjet.mat');
                  C = B.wjet;
                  o.wjet = C/255;
        end
        
        function processData(o)
                o.image = o.compositor.referenceimage;
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
            colormap(o.axes,o.wjet);
            o.clims = [-5000,15000];
            set(o.axes, 'CLim', o.clims);
            o.axes.Visible = 'off';
            axis(o.axes,'equal');
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.image;
            %o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

