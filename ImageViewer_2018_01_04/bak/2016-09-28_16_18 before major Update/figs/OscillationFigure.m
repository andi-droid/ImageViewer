classdef OscillationFigure < BaseFigure
    properties
        clearbtn
        historyedit
        checkboxfitormean
        centerx
        centery
        ids
        plotx
        ploty
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
        function o = OscillationFigure()
            o.windowTitle = mfilename('class');
        end
        
        function onClearBtnPush(o,hsource,data)
            o.compositor.oscillationx = [];
            o.compositor.oscillationy = [];
            o.compositor.idhistoryos = [];
            delete(o.plotx);
            delete(o.ploty);
            o.onReplot();
        end
        
        function onCheckboxfitormeanUpdate(o,hsource,data)
            if o.checkboxfitormean.Value == 1;
                o.compositor.fitormean = true;
            else
                o.compositor.fitormean = false;
            end       
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
            
             o.centerx = o.compositor.oscillationx;
             o.centery = o.compositor.oscillationy;
             o.ids = o.compositor.idhistoryos;
%             for iqt =1:numel(hs)
%                 o.quenchTimeSeries(iqt) = shiftdim(squeeze(hs{iqt}.imageData(t,py, px)));                
%             end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);
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
            
              o.checkboxfitormean = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Fit/Mean'},...
                'Position',[0.5 0.0 0.2 0.05],...
                'Value',1,...
                'Callback', @o.onCheckboxfitormeanUpdate);
            
                        
            o.historyedit = uicontrol(o.figure, 'Style', 'edit',...
                'Units', 'normalized',...
                'String',num2str(5000),...
                'Position', [0.2 0.0 0.2 0.05],...
                'Callback', @o.onEnterLength);
        end
        
        function onReplot(o)
            o.processData();
            o.plotx = plot(o.axes,o.ids, o.centerx,'+r');
            hold(o.axes, 'on');
            o.ploty = plot(o.axes,o.ids, o.centery,'+b');
            grid(o.axes,'on');
            o.axes.YLim = [0,300];
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

