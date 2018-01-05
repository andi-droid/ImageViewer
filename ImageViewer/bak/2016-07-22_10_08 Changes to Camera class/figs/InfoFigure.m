classdef InfoFigure < FitBaseFigure
    properties
        text
        tb
    end
    
    methods
        % constructor
        function o = InfoFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            t = o.compositor.userIndeces.time.value;
            frequency = o.compositor.userIndeces.frequency.value;
            run = o.compositor.userIndeces.run.value;
            hs = o.data.getHaukeSet(t,run);
            if isempty(hs)
                o.text = [];
            else
            s = hs.info;
            s.frequency = frequency;
            s.run = run;
            s.atomCount = o.compositor.data.M;
            s.atomCountDeviation = o.compositor.data.STD;
            s.FFT_Frequency = hs.getfftF(3);
            
            
            C = v.struct2Text(s);

             o.text = cell(size(C,2),1);
             for iLine = 1:size(C,2)
                o.text{iLine} = [C{1,iLine} ' =  ' C{2,iLine}];
             end
            end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.listenToUserInput('time', @o.onRedraw);
            o.listenToUserInput('frequency', @o.onRedraw);
            o.listenToUserInput('run', @o.onRedraw);
            o.registerCurrentCoordinateListener;
            o.tb  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0 0 1 1]);
            o.axes.Visible = 'off';
            set(o.tb,'String','Hello World');
        end
        
        function onReplot(o)
            o.onRedraw;
        end
        
        function onRedraw(o)
            o.processData();
            o.tb.String = o.text;
        end
    end
    
end

