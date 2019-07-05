classdef IntegratedODyFigure < BaseFigure
    properties
        % Data
        integratedOD

    end
    
    methods
        % constructor
        function o = IntegratedODyFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)

            
            o.integratedOD = o.compositor.datay;

        end
        
        % implementing BaseFigure
        function onCreate(o)
            
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);

        end
        
        function onReplot(o)
            o.processData();
            o.plot = plot(o.axes, o.integratedOD,'-k',...
                'Linewidth',1.5);
            axis(o.axes,'tight');
            grid(o.axes,'on');
            view(o.axes,[-90,90]);
            set(o.axes, 'xdir','reverse')
            set(o.axes,'XAxisLocation','top')
        end
        
        function onRedraw(o)
            o.onReplot;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

