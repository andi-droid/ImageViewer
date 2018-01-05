classdef AmplitudeFigure < FitBaseFigure
    properties
        amp
        t
        frequency
        run
        title
    end
    
    methods
        % constructor
        function o = AmplitudeFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;
            o.frequency = o.compositor.userIndeces.frequency.value;
            o.run = o.compositor.userIndeces.run.value;
            hs = o.data.getHaukeSet(o.t,o.run);
            if ~isempty(hs)
                o.amp = hs.getfftA(o.frequency);
            else
                o.amp = NaN(size(o.amp));
            end
        end
        
        % implementing BaseFigure
     function onCreate(o)
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time', @o.onRedraw);
            o.linkUpDownLeftRightToIndeces('frequency', 'run');
            o.listenToUserInput('frequency', @o.onRedraw);
            o.frequency = o.compositor.userIndeces.frequency;
            o.listenToUserInput('run', @o.onRedraw);
            p=o.registerCurrentCoordinateListener;
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.amp);
            o.title = title(o.axes, num2str(o.t));
           
            
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
                        o.addDraggablePointer();
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.amp;
            o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

