classdef AbsorptionImageFigure < ImageBaseFigure
    properties
        % GUI elements
        tb
        text
        
        % Data
        image
        
        % Helper
        wjet
        
    end
    
    methods
        % constructor
        function o = AbsorptionImageFigure()
            o.windowTitle = mfilename('class');
                  B = load('wjet.mat');
                  C = B.wjet;
                  o.wjet = C/255;
        end
        
        function processData(o)
                o.image = o.compositor.absorptionimage;
                 o.text{1} = '';
                 o.text{2} = ['Max counts absorption: ' num2str(o.compositor.absmaxcounts)];
                 o.text{3} = ['Max counts reference: ' num2str(o.compositor.refmaxcounts)];
        end
        
        % implementing BaseFigure
        function onCreate(o)
                C = get(0, 'DefaultUIControlBackgroundColor');
                set(o.figure, 'Color', C)

            o.tb  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0.25 0.8 0.45 0.15]);
            o.axes.Visible = 'off';
            set(o.tb,'String','Info');
        end
        
        function onReplot(o)
            o.processData();
            o.tb.String = o.text;
            o.imageF(o.image);
            %o.title = title(o.axes, num2str(o.t));
            %caxis(o.axes, [-0.02 0.1]);   
%             o.axes.XLim = [1 1024];
%             o.axes.YLim = [1 512];
            o.axes.XLim = [1 1392];
            o.axes.YLim = [1 1024];
            colormap(o.axes,o.wjet);
            o.clims = [-5000,15000];
            set(o.axes, 'CLim', o.clims);
            o.axes.Visible = 'off';
            axis(o.axes,'equal');
            
        end
        
        function onRedraw(o)
            o.processData();
            o.tb.String = o.text;
            o.plot.CData = o.image;
            %o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

