classdef HistoryFigure < FitBaseFigure
    properties
        integratedOD
        clearbtn
        historyedit
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
        function o = HistoryFigure()
            o.windowTitle = mfilename('class');
        end
        
        function onClearBtnPush(o,hsource,data)
            o.compositor.atomnumberhistory = [];
            delete(o.plot);
            o.onReplot();
        end
        
        function onEnterLength(o,hObject,callbackdata)
            historylength = str2double(get(o.historyedit, 'String'));
            o.compositor.historylength = historylength;
        end
        
        function processData(o)
            % now t should take the role of the HaukeT
%             t = o.compositor.userIndeces.time.value;
%             run = o.compositor.userIndeces.run.value;
%             [px, py] = o.kToPixel(o.compositor.currentCoordinate);
%             [hs, o.times] = o.data.getHaukeSetsRun(run);
            
            o.integratedOD = o.compositor.atomnumberhistory;
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

              o.clearbtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Clear',...
                'Units', 'normalized',...
                'Position', [0.0 0.0 0.2 0.05],...
                'Callback', @o.onClearBtnPush);
            
                        
            o.historyedit = uicontrol(o.figure, 'Style', 'edit',...
                'Units', 'normalized',...
                'String',num2str(500),...
                'Position', [0.2 0.0 0.2 0.05],...
                'Callback', @o.onEnterLength);
        end
        
        function onReplot(o)
            o.processData();
            o.plot = plot(o.axes, o.integratedOD,'or');
            grid(o.axes,'on');
            o.axes.YLim = [0,2500];
        end
        
        function onRedraw(o)
            o.onReplot;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

