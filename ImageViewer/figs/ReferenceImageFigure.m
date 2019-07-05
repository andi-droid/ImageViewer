classdef ReferenceImageFigure < ImageBaseFigure
    properties
        % Data
        image
        sizeofimg
        %Helper
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
                o.sizeofimg = size(o.image);
        end
        
        % implementing BaseFigure
        function onCreate(o)
                C = get(0, 'DefaultUIControlBackgroundColor');
                set(o.figure, 'Color', C)
                
                addlistener(o.compositor, 'updateAxes', @o.onUpdateAxesEvent);

        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.image);
            %o.title = title(o.axes, num2str(o.t));
            %caxis(o.axes, [-0.02 0.1]);
            if isempty(o.image)
            o.axes.XLim = [1 1024];
            o.axes.YLim = [1 512];
            else
            o.axes.XLim = [1 o.sizeofimg(2)];
            o.axes.YLim = [1 o.sizeofimg(1)];
            end
            colormap(o.axes,o.wjet);
            o.clims = [0,1750];
             o.clims = [0,17000];%For Pixelfly USB
            set(o.axes, 'CLim', o.clims);
            o.axes.Visible = 'off';
            axis(o.axes,'equal');
        end
        
        function onRedraw(o)
            o.onReplot();
            o.plot.CData = o.image;
            %o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

