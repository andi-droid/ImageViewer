classdef IntegratedODyFigure < FitBaseFigure
    properties
        integratedOD
%         fftApprox
%         fitApprox
%         nonNormalizedData
%         times
%         
%         
%         fftPlot
%         fitPlot
%         filteredPlot
%         nonNormalizedPlot
%         filtered
    end
    
    methods
        % constructor
        function o = IntegratedODyFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            % now t should take the role of the HaukeT
%             t = o.compositor.userIndeces.time.value;
%             run = o.compositor.userIndeces.run.value;
%             [px, py] = o.kToPixel(o.compositor.currentCoordinate);
%             [hs, o.times] = o.data.getHaukeSetsRun(run);
            
            o.integratedOD = o.compositor.datay;
%             for iqt =1:numel(hs)
%                 o.quenchTimeSeries(iqt) = shiftdim(squeeze(hs{iqt}.imageData(t,py, px)));                
%             end
        end
        
        % implementing BaseFigure
        function onCreate(o)
%             o.linkMouseWheelToIndex('time');
%             o.listenToUserInput('time', @o.onRedraw);
%             o.linkUpDownLeftRightToIndeces('frequency', 'run');
%             o.listenToUserInput('frequency', @o.onRedraw)
%             o.listenToUserInput('run', @o.onRedraw);
%             o.registerCurrentCoordinateListener();
        end
        
        function onReplot(o)
            o.processData();
            o.plot = plot(o.axes, o.integratedOD,'-b');
            axis(o.axes,'tight');
        end
        
        function onRedraw(o)
            o.onReplot;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

