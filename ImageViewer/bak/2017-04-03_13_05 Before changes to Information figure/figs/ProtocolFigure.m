classdef ProtocolFigure < BaseFigure
    properties
        %GUI elements
        radios

        popupduration
        popupanalog
        popupvisa
        editvisatext
        editvisatextnumber
        editvisatextnumber2
        textcommandnr
        textnumbernr
        popupanalysis
        checkboxaverage
        
    end
    
    methods
        % constructor
        function o = ProtocolFigure()
            o.windowTitle = mfilename('class');
        end
        
        function onRadioClick(o,hSource,callbackdata,iRadio)
            for i = 1:4
                set(o.radios(i), 'Value', i==iRadio);
                drawnow()
            end
            o.onReplot();
            o.compositor.historystring = get(o.radios(iRadio),'String');
            o.compositor.analysisstring = get(o.radios(iRadio),'String');
            o.compositor.indexslotduration = 1;
            o.compositor.indexanalog = 1;
            o.compositor.indexvisa = 1;
            o.compositor.visacommand = 'CURR';
            o.compositor.visacommandnumber = 1;
            o.compositor.visacommandnumber2 = 1;
            notify(o.compositor,'updateHistory');
            notify(o.compositor,'updateAnalysis');
            o.onReplot();
           
        end
        
        function setTimeSlot(o,hSource,callbackdata)
            items = get(hSource,'String');
            index_selected = get(hSource,'Value');
            item_selected = items{index_selected};
            o.compositor.indexslotduration = index_selected;
            notify(o.compositor,'updateAnalysis');


        end
        
        function setAnalogSlot(o,hSource,callbackdata)
            items = get(hSource,'String');
            index_selected = get(hSource,'Value');
            item_selected = items{index_selected};
            o.compositor.history_xlab = item_selected;
            o.compositor.analysis_xlab = item_selected;
            o.compositor.indexanalog = index_selected;
            notify(o.compositor,'updateAnalysis');


        end
        
        function setVisaSlot(o,hSource,callbackdata)
            item = get(hSource,'String');
            index_selected = get(hSource,'Value');
            o.compositor.indexvisa = index_selected;
            notify(o.compositor,'updateAnalysis');
  
        end
        
        function setVisaCommand(o,hSource,callbackdata)
            o.compositor.visacommand = get(hSource,'String');
            o.compositor.history_xlab = o.compositor.visacommand;
            notify(o.compositor,'updateAnalysis');
        end
        
        function setVisaCommandNumber(o,hSource,callbackdata)
            o.compositor.visacommandnumber = str2num(get(hSource,'String'));
            notify(o.compositor,'updateAnalysis');
        end
        
        function setVisaCommandNumber2(o,hSource,callbackdata)
            o.compositor.visacommandnumber2 = str2num(get(hSource,'String'));
            notify(o.compositor,'updateAnalysis');
        end
        
        function setAnalysisMethod(o,hSource,callbackdata)
            items = get(hSource,'String');
            index_selected = get(hSource,'Value');
            item_selected = items{index_selected};
            o.compositor.analysismethod = item_selected;
            if strcmp(item_selected,'Momentum resolved')
                notify(o.compositor,'addPointer')
            else
                notify(o.compositor,'deletePointer')
            end
            notify(o.compositor,'updateAnalysis');
        end
        
        function onAverage(o,hSource,callbackdata)
            if hSource.Value == 1
                o.compositor.average = 1;
            else
                o.compositor.average = 0;
            end
            notify(o.compositor,'updateAnalysis');
        end
        
        
        
        % implementing BaseFigure
        function onCreate(o)
                C = get(0, 'DefaultUIControlBackgroundColor');
                set(o.figure, 'Color', C)
            o.axes.Visible = 'off';

            
            %o.tb  = uicontrol('style','edit', 'Parent', o.figure,'Units', 'normalized', 'Position', [0.7 0.1 0.2 0.1]);
            
            
                        radioLabels = {'ID','Duration','Analog','VISA'};
                        for iRadio=1:numel(radioLabels)
                            o.radios(iRadio) = uicontrol(o.figure, 'Style', 'radiobutton', ...
                                'Callback', {@o.onRadioClick, iRadio}, ...
                                'Units',    'normalized', ...
                                'Position', [0.05 (0.75-iRadio*0.1) 0.3 0.1], ...
                                'String',   radioLabels{iRadio}, ...
                                'Value',    iRadio==1);
                        end
                        
                 o.popupanalysis = uicontrol('Style', 'popupmenu',...                
                'String', {'Atomnumber','Position','Mask 1+2 BZ','Momentum resolved','Ratio 2 Areas'},... 
                'units', 'normalized',...
                'Position', [0.35 0.85 0.3 0.1],...
                'Callback', @o.setAnalysisMethod);
            
                o.checkboxaverage = uicontrol('Style', 'checkbox',...                
                'String', {'Average Data'},... 
                'units', 'normalized',...
                'Value',1,...
                'Position', [0.75 0.85 0.25 0.1],...
                'Callback', @o.onAverage);
                        
                 
        end
        
        function onReplot(o)
            delete(o.popupduration);
            delete(o.popupanalog);
            delete(o.popupvisa);
            delete(o.editvisatext);
            delete(o.editvisatextnumber);
            delete(o.editvisatextnumber2);
            delete(o.textcommandnr);
            delete(o.textnumbernr);
            
            try
            
            if get(o.radios(2),'Value')
                o.popupduration = uicontrol('Style', 'popupmenu',...
                'String', o.compositor.protocolpackage{1,1}.p.timeSlotNames,...
                'units', 'normalized',...
                'Position', [0.30 0.55 0.3 0.1],...
                'Callback', @o.setTimeSlot);
            end
            
            if get(o.radios(3),'Value')
                o.popupanalog = uicontrol('Style', 'popupmenu',...                
                'String', o.compositor.protocolpackage{1,1}.p.analogNames,... 
                'units', 'normalized',...
                'Position', [0.30 0.45 0.3 0.1],...
                'Callback', @o.setAnalogSlot);
            
                o.popupduration = uicontrol('Style', 'popupmenu',...
                'String', o.compositor.protocolpackage{1,1}.p.timeSlotNames,...
                'units', 'normalized',...
                'Position', [0.65 0.45 0.2 0.1],...
                'Callback', @o.setTimeSlot);
            end

            if get(o.radios(4),'Value')
                o.popupvisa = uicontrol('Style', 'popupmenu',...                
                'String', o.compositor.protocolpackage{1,1}.p.visaText,... 
                'units', 'normalized',...
                'Position', [0.30 0.35 0.3 0.1],...
                'Callback', @o.setVisaSlot);
            
                o.editvisatext = uicontrol('Style', 'edit',...                
                'String', 'CURR',... 
                'units', 'normalized',...
                'Position', [0.65 0.35 0.15 0.1],...
                'Callback', @o.setVisaCommand);
            
            
                o.editvisatextnumber = uicontrol('Style', 'edit',...                
                'String', '1',... 
                'units', 'normalized',...
                'Position', [0.65 0.25 0.05 0.1],...
                'Callback', @o.setVisaCommandNumber);
            
                o.editvisatextnumber2 = uicontrol('Style', 'edit',...                
                'String', '1',... 
                'units', 'normalized',...
                'Position', [0.65 0.15 0.05 0.1],...
                'Callback', @o.setVisaCommandNumber2);
            
                o.textcommandnr = uicontrol('Style', 'text',...                
                'String', 'Command No.',... 
                'units', 'normalized',...
                'Position', [0.30 0.25 0.25 0.1]);
            
                 o.textnumbernr = uicontrol('Style', 'text',...                
                'String', 'Number of element',... 
                'units', 'normalized',...
                'Position', [0.30 0.15 0.25 0.1]);
            end
            
            catch
            errordlg('You might want to load protocols first. Check if they are properly converted!');   
            end
       
            
        end
        
        function onRedraw(o)
            o.onReplot();
        end
        
    end
    
end
