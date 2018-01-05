classdef IntegratedODxFigure < BaseFigure
    properties
        integratedOD

    end
    
    methods
        % constructor
        function o = IntegratedODxFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)

            
            o.integratedOD = o.compositor.datax;

        end
        
        % implementing BaseFigure
        function onCreate(o)
            
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);

        end
        
        function onReplot(o)
            %addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);
            o.processData();
            o.plot = plot(o.axes, o.integratedOD,'-b',...
                'Linewidth',1.5);
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

