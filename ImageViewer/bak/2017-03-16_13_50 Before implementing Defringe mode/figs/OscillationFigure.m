classdef OscillationFigure < BaseFigure
    properties
        % GUI elements 
        clearbtn
        checkboxfitormean
        
        % Data
        centerx
        centery
        xaxisdata
        
        % Plots
        plotx
        ploty

    end
    
    methods
        % constructor
        function o = OscillationFigure()
            o.windowTitle = mfilename('class');
        end
        
        function onClearBtnPush(o,hsource,data)
            notify(o.compositor,'clearPlot');    
        end
        
        function onClearPlot(o,hsource,data)
            o.compositor.oscillationx = [];
            o.compositor.oscillationy = [];
            o.compositor.historyxdata = [];
            delete(o.plotx);
            delete(o.ploty);
            o.onReplot();
            
        end
        
        
        function onUseFitResults(o,hsource,data)
            if o.compositor.fitormean
                

                    o.compositor.oscillationx(end+1) = o.compositor.fitdatax(3);
                    o.compositor.oscillationy(end+1) = o.compositor.fitdatay(3);


                
            else
                
                x = 1:length(o.compositor.datacroppedx);
                y = 1:length(o.compositor.datacroppedy);
                centerofmassx = sum(o.compositor.datacroppedx.*x)/sum(o.compositor.datacroppedx);
                centerofmassy = sum(o.compositor.datacroppedy'.*y)/sum(o.compositor.datacroppedy);

                    o.compositor.oscillationx(end+1) = centerofmassx;
                    o.compositor.oscillationy(end+1) = centerofmassy;


            end
        end
        
        function onUpdateHistory(o,hsource,data)
            o.onClearBtnPush(o.clearbtn);
        end
        
        function onCheckboxfitormeanUpdate(o,hsource,data)
            if o.checkboxfitormean.Value == 1;
                o.compositor.fitormean = true;
            else
                o.compositor.fitormean = false;
            end       
        end
        

        
        function processData(o)

            
             o.centerx = o.compositor.oscillationx;
             o.centery = o.compositor.oscillationy;
             o.xaxisdata = o.compositor.historyxdata;

        end
        
        % implementing BaseFigure
        function onCreate(o)
            
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);
            addlistener(o.compositor, 'updateHistory', @o.onUpdateHistory);
            addlistener(o.compositor, 'useFitResults', @o.onUseFitResults);
            addlistener(o.compositor, 'clearPlot', @o.onClearPlot);


              o.clearbtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Clear',...
                'Units', 'normalized',...
                'Position', [0.0 0.0 0.2 0.05],...
                'Callback', @o.onClearBtnPush);
            
              o.checkboxfitormean = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Fit/Mean'},...
                'Position',[0.8 0.0 0.2 0.05],...
                'Value',1,...
                'Callback', @o.onCheckboxfitormeanUpdate);
            
                        
        end
        
        function onReplot(o)
            o.processData();
            o.plotx = plot(o.axes,o.xaxisdata, o.centerx,'+r');
            hold(o.axes, 'on');
            o.ploty = plot(o.axes,o.xaxisdata, o.centery,'+b');
            grid(o.axes,'on');
            xlabel(o.axes,o.compositor.history_xlab);
            ylabel(o.axes,'Position (px)');
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

