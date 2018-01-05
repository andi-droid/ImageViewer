classdef ProtocolFigure < BaseFigure
    properties
        radios
        popupduration
        popupanalog
        popupvisa
        
    end
    
    methods
        % constructor
        function o = ProtocolFigure()
            o.windowTitle = mfilename('class');
        end
        
        function onRadioClick(o,hSource,callbackdata,iRadio)
            for i = 1:5
                set(o.radios(i), 'Value', i==iRadio);
            end
            
            o.onReplot();
           
        end
        
        function setTimeSlot(o,hSource,callbackdata)
            items = get(hSource,'String');
            index_selected = get(hSource,'Value');
            item_selected = items{index_selected};
            o.compositor.history_ylab = item_selected;
            o.compositor.indexslotduration = index_selected;
            o.compositor.history_y = [];
            o.compositor.history_x = [];
        end
        
        function setAnalogSlot(o,hSource,callbackdata)
            items = get(hSource,'String');
            index_selected = get(hSource,'Value');
            item_selected = items{index_selected};
            o.compositor.history_ylab = item_selected;
            o.compositor.indexanalog = index_selected;
            o.compositor.history_y = [];
            o.compositor.history_x = [];
        end
        
        function setVisaSlot(o,hSource,callbackdata)
        end
        
        
        % implementing BaseFigure
        function onCreate(o)
            o.axes.Visible = 'off';

            
            %o.tb  = uicontrol('style','edit', 'Parent', o.figure,'Units', 'normalized', 'Position', [0.7 0.1 0.2 0.1]);
            
            
                        radioLabels = {'ID','Last images','Duration','Analog','VISA'};
                        for iRadio=1:numel(radioLabels)
                            o.radios(iRadio) = uicontrol(o.figure, 'Style', 'radiobutton', ...
                                'Callback', {@o.onRadioClick, iRadio}, ...
                                'Units',    'normalized', ...
                                'Position', [0.05 (0.75-iRadio*0.1) 0.3 0.1], ...
                                'String',   radioLabels{iRadio}, ...
                                'Value',    iRadio==1);
                        end
                        
                 
        end
        
        function onReplot(o)
            delete(o.popupduration);
            delete(o.popupanalog);
            delete(o.popupvisa);
            
            if get(o.radios(3),'Value')
                o.popupduration = uicontrol('Style', 'popupmenu',...
                'String', o.compositor.protocol.timeSlotNames,...
                'units', 'normalized',...
                'Position', [0.40 0.45 0.3 0.1],...
                'Callback', @o.setTimeSlot);
            end
            
            if get(o.radios(4),'Value')
                o.popupanalog = uicontrol('Style', 'popupmenu',...                
                'String', o.compositor.protocol.analogNames,... 
                'units', 'normalized',...
                'Position', [0.40 0.35 0.3 0.1],...
                'Callback', @o.setAnalogSlot);
            
                o.popupduration = uicontrol('Style', 'popupmenu',...
                'String', o.compositor.protocol.timeSlotNames,...
                'units', 'normalized',...
                'Position', [0.75 0.35 0.2 0.1],...
                'Callback', @o.setTimeSlot);
            end

            if get(o.radios(5),'Value')
                o.popupvisa = uicontrol('Style', 'popupmenu',...                
                'String', o.compositor.protocol.visaText,... 
                'units', 'normalized',...
                'Position', [0.40 0.25 0.3 0.1],...
                'Callback', @o.setVisaSlot);
            end
       
            
        end
        
        function onRedraw(o)
            o.onReplot();
        end
        
    end
    
end
