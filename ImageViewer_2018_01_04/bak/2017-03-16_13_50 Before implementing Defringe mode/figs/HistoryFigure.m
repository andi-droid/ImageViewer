classdef HistoryFigure < BaseFigure
    properties
        % GUI elements
        checkboxfitorcount
        clearbtn
        
        % Data
        integratedOD
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
        
        function onClearBtnPush(o,hsource,data)
            notify(o.compositor,'clearPlot');    
        end
        
        
        function onClearPlot(o,hsource,data)
            o.compositor.atomnumberhistory = [];
            o.compositor.historyxdata = [];
            delete(o.plot);
            o.onReplot();
        end
        
        function onUpdateHistory(o,hsource,data)
            o.onClearBtnPush(o.clearbtn);
        end
        
        function onUseFitResults(o,hsource,data)
             %if strcmp(o.compositor.historystring,'ID')
                o.compositor.history_xlab = 'ID';
                o.compositor.historyxdata(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
%             elseif strcmp(o.compositor.historystring,'Last images')
%                 o.compositor.history_xlab = 'Last images';
%                 if length(o.compositor.historyxdata)>0
%                     o.compositor.historyxdata(end+1) = o.compositor.historyxdata(end)+1;
%                 else
%                     o.compositor.historyxdata = 1;
%                 end
%             elseif strcmp(o.compositor.historystring,'Duration')
%                 indexduration = o.compositor.indexslotduration;
%                 o.compositor.historyxdata(end+1) = o.compositor.protocol.slotDuration(indexduration);
%                 o.compositor.history_xlab = o.compositor.protocol.timeSlotNames(indexduration);
%             elseif strcmp(o.compositor.historystring,'Analog')
%                 
%                 indexduration = o.compositor.indexslotduration;
%                 indexanalog = o.compositor.indexanalog;
%                 o.compositor.historyxdata(end+1) = o.compositor.protocol.analogVals(indexduration,indexanalog);
%                 o.compositor.history_xlab = o.compositor.protocol.analogNames(indexanalog);
%             else
%                 o.compositor.history_xlab = o.compositor.visacommand;
%                 visavalue = regexpi(o.compositor.protocol.visaText{o.compositor.indexvisa},[o.compositor.visacommand '([\d\.]+)'], 'tokens');
%                 visavaluedouble = str2double(visavalue{o.compositor.visacommandnumber});
%                 o.compositor.historyxdata(end+1) = visavaluedouble; 
             %end
             
            if o.compositor.fitorcount
                
                    o.compositor.atomnumberhistory(end+1) = o.compositor.atomnumberfitmean;
                    

                
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
            
                        
        end
        
        function onReplot(o)
            o.processData();
            o.plot = plot(o.axes,o.xaxisdata, o.integratedOD,'.r');
            grid(o.axes,'on');
            xlabel(o.axes,o.compositor.history_xlab);
            ylabel(o.axes,'Atomnumber (a.u.)');
            o.axes.YLim = [0,2000];
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

