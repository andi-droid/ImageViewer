classdef IntegratedODCroppedxFigure < BaseFigure
    properties
        % Data
        integratedOD

    end
    
    methods
        % constructor
        function o = IntegratedODCroppedxFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)

            
            o.integratedOD = o.compositor.datacroppedx;

        end
        
        function onUpdatePlotFit(o,hsource,data)
            o.onRedraw();
        end
        
        % implementing BaseFigure
        function onCreate(o)
            
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);
            addlistener(o.compositor, 'updatePlotFit', @o.onUpdatePlotFit);

        end
        
        function onReplot(o)
            o.processData();
            o.plot = plot(o.axes, o.integratedOD,'-b',...
                'Linewidth',1.5);
            hold(o.axes,'on');
            if o.compositor.plotfitstate
                o.plot = plot(o.axes, o.compositor.plotfitdatax,'-r',...
                    'Linewidth',1.5);
            end
            axis(o.axes,'tight');
            grid(o.axes,'on');
            hold(o.axes,'off');
        end
        
        function onRedraw(o)
            o.onReplot;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

