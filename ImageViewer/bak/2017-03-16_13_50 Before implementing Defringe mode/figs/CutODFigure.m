classdef CutODFigure < BaseFigure
    properties
        % Data
            OD

    end
    
    methods
        % constructor
        function o = CutODFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)

            
            o.OD = o.compositor.cutOD;

        end
        
        % implementing BaseFigure
        function onCreate(o)
            
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);

        end
        
        function onReplot(o)
            o.processData();
            o.plot = plot(o.axes, o.OD,'-b');
            axis(o.axes,'tight');
            grid(o.axes,'on');
        end
        
        function onRedraw(o)
            o.onReplot;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

