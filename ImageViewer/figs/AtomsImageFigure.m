classdef AtomsImageFigure < ImageBaseFigure
    properties
        % GUI elements
%         tb
%         text
%         
        % Data
        image
        sizeofimg
        roi
        
        % Helper
        wjet
        
    end
    
    methods
        % constructor
        function o = AtomsImageFigure()
            o.windowTitle = mfilename('class');
                  B = load('wjet.mat');
                  C = B.wjet;
                  o.wjet = C/255;
        end
        
        function processData(o)
                o.image = o.compositor.absorptionimage;
                o.sizeofimg = size(o.image);
%                  o.text{1} = '';
%                  o.text{2} = ['Max counts absorption: ' num2str(o.compositor.absmaxcounts)];
%                  o.text{3} = ['Max counts reference: ' num2str(o.compositor.refmaxcounts)];
        end
        
        % implementing BaseFigure
        function onCreate(o)
                C = get(0, 'DefaultUIControlBackgroundColor');
                set(o.figure, 'Color', C)

  %          o.tb  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0.25 0.8 0.45 0.15]);
            o.axes.Visible = 'off';
%            set(o.tb,'String','Info');
            
            addlistener(o.compositor, 'updateAxes', @o.onUpdateAxesEvent);

        end
        
        function onReplot(o)
            o.processData();
            o.roi = o.compositor.roi;
 %           o.tb.String = o.text;
            o.imageF(o.image);
            %o.title = title(o.axes, num2str(o.t));
            %caxis(o.axes, [-0.02 0.1]); 
            if isempty(o.image)
            o.axes.XLim = [1 1024];
            o.axes.YLim = [1 512];
            else
            o.axes.XLim = [1 o.sizeofimg(2)];
            o.axes.YLim = [1 o.sizeofimg(1)];
            %disp(o.compositor.roi);
            end
            %colormap(o.axes,o.wjet);
            o.clims = [0,800];
            o.clims = [0,o.compositor.camera.PixDepth*o.compositor.camera.ColorScaling];%For Pixelfly USB
            
            set(o.axes, 'CLim', o.clims);
            o.axes.Visible = 'off';
            axis(o.axes,'equal');
            
        end
        
        function onRedraw(o)
            o.onReplot();
%            o.tb.String = o.text;
            o.plot.CData = o.image;
            %o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

