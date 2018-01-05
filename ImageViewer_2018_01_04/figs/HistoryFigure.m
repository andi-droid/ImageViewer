classdef HistoryFigure < BaseFigure
    properties
        % GUI elements
        checkboxfitorcount
        clearbtn
        popupanalysis
        
        % Data
        integratedOD
        widthx
        widthy
        xaxisdata
        
        % Plots
        plot2
        plot3
        
    end
    
    methods
        % constructor
        function o = HistoryFigure()
            o.windowTitle = mfilename('class');
        end
        
        function setAnalysisMethod(o,hSource,callbackdata)
            o.onReplot();
        end
        
        function onClearBtnPush(o,hsource,data)
            notify(o.compositor,'clearPlot');
        end
        
        
        function onClearPlot(o,hsource,data)
            o.compositor.atomnumberhistory = [];
            o.compositor.historyxdata = [];
            o.compositor.widthhistoryx = [];
            o.compositor.widthhistoryy = [];
            delete(o.plot);
            delete(o.plot2);

            o.onReplot();
        end
        
        function onUpdateHistory(o,hsource,data)
            o.onClearBtnPush(o.clearbtn);
        end
        
        function onUseFitResults(o,hsource,data)
            %if strcmp(o.compositor.historystring,'ID')
            o.compositor.history_xlab = 'ID';
            o.compositor.historyxdata(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
            
            if o.compositor.fitorcount
                
                o.compositor.atomnumberhistory(end+1) = o.compositor.atomnumberfitmean;
                %o.compositor.atomnumberhistory(end+1) = o.compositor.atomsx;
                %o.compositor.atomnumberhistory(end+1) = o.compositor.atomsy; %FIND HERE WICH ATOMNUMBER FIT YOU WANNA CHOSE.
                o.compositor.widthhistoryx(end+1) = o.compositor.fitdatax(4);
                o.compositor.widthhistoryy(end+1) = o.compositor.fitdatay(4);
                
                
            else
                integral = sum(sum(o.compositor.croppedimage));
                
                o.compositor.atomnumberhistory(end+1) = integral;
                
                
            end
            
            o.onReplot();
        end
        
        function onCheckboxfitorcountUpdate(o,hsource,data)
            if o.checkboxfitorcount.Value == 1;
                o.compositor.fitorcount = true;
            else
                o.compositor.fitorcount = false;
            end
        end
        
        
        function processData(o)
            
            
            if numel(o.compositor.widthhistoryx) > 0
            o.widthx = o.compositor.widthhistoryx;
            o.widthy = o.compositor.widthhistoryy;
            end
            %o.integratedOD = o.compositor.atomnumberhistory*o.compositor.camera.Atomfaktor;
            
            o.integratedOD = o.compositor.atomnumberhistory;
            o.xaxisdata = o.compositor.historyxdata;
            
        end
        
        %         function onUpdateHistoryFitResults(o,hsource,data)
        %
        %             o.onReplotfit();
        %         end
        
        % implementing BaseFigure
        function onCreate(o)
            
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            %addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);
            addlistener(o.compositor, 'updateHistory', @o.onUpdateHistory);
            addlistener(o.compositor, 'useFitResults', @o.onUseFitResults);
            addlistener(o.compositor, 'clearPlot', @o.onClearPlot);
            %addlistener(o.compositor, 'updateHistoryFitResults', @o.onUpdateHistoryFitResults);
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
            
            o.checkboxfitorcount = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Fit/Count'},...
                'Position',[0.8 0.0 0.2 0.05],...
                'Value',1,...
                'Callback', @o.onCheckboxfitorcountUpdate);
            
            o.popupanalysis = uicontrol('Style', 'popupmenu',...
                        'String', {'Atomnumber','Width'},...
                        'units', 'normalized',...
                        'Position', [0.4 0.95 0.2 0.05],...
                        'Callback', @o.setAnalysisMethod);
            
            
        end
        
        function onReplot(o)
            o.processData();
            items = get(o.popupanalysis,'String');
            index_selected = get(o.popupanalysis,'Value');
            item_selected = items{index_selected};
            if strcmp(item_selected,'Atomnumber') 
            o.plot = plot(o.axes,o.xaxisdata, o.integratedOD,'or');
            grid(o.axes,'on');
            xlabel(o.axes,o.compositor.history_xlab);
            ylabel(o.axes,'Atomnumber');
            o.axes.YLim = [0,1e8];
            elseif strcmp(item_selected,'Width') 
            o.plot = plot(o.axes,o.xaxisdata, o.widthx,'or');
            hold(o.axes,'on')
            o.plot2 = plot(o.axes,o.xaxisdata, o.widthy,'ob');
            grid(o.axes,'on');
%             o.plot3 = plot(o.axes,o.xaxisdata, (o.widthy+o.widthx)/2,'xk');
%             grid(o.axes,'on');
            xlabel(o.axes,o.compositor.history_xlab);
            ylabel(o.axes,'Width (px)');
            o.axes.YLim = [0,200];
            hold(o.axes,'off')
            end
        end
        
        %         function onReplotfit(o)
        %             o.plot3 = plot(o.axes,o.xaxisdata, o.integratedOD,'.r');
        %             hold(o.axes,'on')
        %             o.plot2 = plot(o.axes,o.xaxisdata, o.compositor.plotfitdata,'-g');
        %             grid(o.axes,'on');
        %             o.axes.YLim = [0,5000];
        %             xlabel(o.axes,o.compositor.history_xlab);
        %             ylabel(o.axes,'Atomnumber (a.u.)');
        %             hold(o.axes,'off');
        %         end
        
        function onRedraw(o)
            o.onReplot;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

