classdef HistoryFigure < BaseFigure
    properties
        % GUI elements
        togglefitorcount
        clearbtn
        popupanalysis
        radios
        
        % Data
        integratedOD
        widthx
        widthy
        centerx
        centery
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
            o.compositor.widthhistoryx = [];
            o.compositor.widthhistoryy = [];
            o.compositor.oscillationx = [];
            o.compositor.oscillationy = [];
            o.compositor.historyxdata = [];
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
                
                % HERE YOU CAN DECIDE WETHER YOU LOOK AT ONLY ONE
                % DIRECTION AK 20180307
                
                o.compositor.atomnumberhistory(end+1)   = o.compositor.atomnumberfitmean;
                %o.compositor.atomnumberhistory(end+1)  = o.compositor.atomsx;
                %o.compositor.atomnumberhistory(end+1)  = o.compositor.atomsy;
                
                o.compositor.widthhistoryx(end+1) = o.compositor.fitdatax(4);
                o.compositor.widthhistoryy(end+1) = o.compositor.fitdatay(4);
                
                o.compositor.oscillationx(end+1) = o.compositor.fitdatax(3);
                o.compositor.oscillationy(end+1) = o.compositor.fitdatay(3);
                
                
            else
                integral = sum(sum(o.compositor.croppedimage));
                o.compositor.atomnumberhistory(end+1) = integral*o.compositor.camera.Atomfaktor;
                
                o.compositor.widthhistoryx(end+1) = 0;
                o.compositor.widthhistoryy(end+1) = 0;
                
                x = 1:length(o.compositor.datacroppedx);
                y = 1:length(o.compositor.datacroppedy);
                centerofmassx = sum(o.compositor.datacroppedx.*x)/sum(o.compositor.datacroppedx);
                centerofmassy = sum(o.compositor.datacroppedy'.*y)/sum(o.compositor.datacroppedy);
                o.compositor.oscillationx(end+1) = centerofmassx;
                o.compositor.oscillationy(end+1) = centerofmassy;
            end
            
            o.onReplot();
        end
        
%         function onTogglefitorcountUpdate(o,hsource,data)
%             if o.togglefitorcount.Value == 1;
%                 o.compositor.fitorcount = true;
%                 o.togglefitorcount.String = 'Fit';
%             else
%                 o.compositor.fitorcount = false;
%                 o.togglefitorcount.String = 'Count/Mean';
%             end
%         end
        
        function onRadioClick(o,hSource,callbackdata,iRadio)
            for i = 1:2
                set(o.radios(i), 'Value', i==iRadio);
            end
            
            if get(o.radios(1),'Value')
                o.compositor.fitorcount = true;
            elseif get(o.radios(2),'Value')
                o.compositor.fitorcount = false;
            end
            
            notify(o.compositor,'updateData');
            
        end
        
        function setAnalysisMethod(o,hSource,data)
            o.onReplot();
        end
        
        
        function processData(o)
            
            o.integratedOD = o.compositor.atomnumberhistory;
            o.widthx = o.compositor.widthhistoryx;
            o.widthy = o.compositor.widthhistoryy;
            o.centerx = o.compositor.oscillationx;
            o.centery = o.compositor.oscillationy;
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
            
            o.popupanalysis = uicontrol('Style', 'popupmenu',...
                'String', {'Atomnumber','Width','Position'},...
                'units', 'normalized',...
                'Position', [0.4 0.95 0.2 0.05],...
                'Callback', @o.setAnalysisMethod);
            
%             o.togglefitorcount = uicontrol('Style','toggle',...
%                 'Units', 'normalized',...
%                 'String',{'Fit'},...
%                 'Position',[0.8 0.0 0.2 0.05],...
%                 'Value',1,...
%                 'Callback', @o.onTogglefitorcountUpdate);
            
            radioLabels = {'Fit','Counts'};
            value = find(strcmp(radioLabels,o.compositor.camera.species)==1);
            for iRadio=1:numel(radioLabels)
                o.radios(iRadio) = uicontrol(o.figure, 'Style', 'radiobutton', ...
                    'Callback', {@o.onRadioClick, iRadio}, ...
                    'Units',    'normalized', ...
                    'Position', [0.6+(iRadio*0.1) 0.95 0.2 0.05], ...
                    'String',   radioLabels{iRadio}, ...
                    'Value',    iRadio==1);
            end
            
            
        end
        
        function onReplot(o)
            o.processData();
            if o.popupanalysis.Value == 1
            o.plot = plot(o.axes,o.xaxisdata, o.integratedOD,'or');
            grid(o.axes,'on');
            xlabel(o.axes,o.compositor.history_xlab);
            ylabel(o.axes,'Atomnumber');
            o.axes.YLim = [00000,1.5e8];
           %o.axes.YLim = [00000,1];
            elseif o.popupanalysis.Value == 2
            o.plot = plot(o.axes,o.xaxisdata, o.widthx,'or');
            hold(o.axes,'on');
            o.plot2 = plot(o.axes,o.xaxisdata, o.widthy,'ob');
            grid(o.axes,'on');
            xlabel(o.axes,o.compositor.history_xlab);
            ylabel(o.axes,'Width');
            o.axes.YLim = [0,50]; 
            hold(o.axes,'off');
            else
            o.plot = plot(o.axes,o.xaxisdata, o.centerx,'+r');
            hold(o.axes, 'on');
            o.plot2 = plot(o.axes,o.xaxisdata, o.centery,'+b');
            grid(o.axes,'on');
            xlabel(o.axes,o.compositor.history_xlab);
            ylabel(o.axes,'Position (px)');
            o.axes.YLim = [0,1500];
            hold(o.axes,'off'); 
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

