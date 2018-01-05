classdef FrequencyFitAllTimesFigure < FitBaseFigure
    properties
        val
        times
        title
    end
    
    methods
        % constructor
        function o = FrequencyFitAllTimesFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            d = o.compositor.data;
            p = d.parameters;
            np = size(p,1);
            f = zeros(1,np);
            for iP = 1:np
                f(iP)= mean(d.fits{iP}.display.fre1(:));
            end
            maxR = max(p(:,2))+1;
            for iRun = 1:maxR
                index = find(squeeze(p(:,2))-iRun-1==0);
                o.times{iRun} = p(index,1);
                o.val{iRun} = f(index);
            end
            
        end
        
        % implementing BaseFigure
        function onCreate(o)

            
        end
        
        function onReplot(o)
            o.processData();
            hold(o.axes, 'on');
            for i=1:numel(o.times)
                o.plot{i} = plot(o.times{i}, o.val{i});
            end
            hold(o.axes, 'off');
        end
        
        function onRedraw(o)
            o.processData();
            o.onReplot;
        end
    end
    
end

