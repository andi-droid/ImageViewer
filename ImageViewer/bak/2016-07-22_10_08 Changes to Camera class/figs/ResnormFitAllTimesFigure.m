classdef ResnormFitAllTimesFigure < FitBaseFigure
    properties
        val
        title
    end
    
    methods
        % constructor
        function o = ResnormFitAllTimesFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            d = o.compositor.data;
            p = d.parameters;
            np = size(p,1);
            maxT = max(p(:,1));
            maxR = max(p(:,2))+1;
            o.val = zeros(maxT, maxR);
            for iP = 1:np
                o.val(p(iP,1),p(iP,2)+1) =...
                    sum(d.fits{iP}.display.resnorm(:));
            end
            
        end
        
        % implementing BaseFigure
        function onCreate(o)

            
        end
        
        function onReplot(o)
            o.processData();
            o.plot = imagesc(o.val, 'Parent', o.axes);            
            map = colormap('parula');
            map(1,:) = [1 1 1];
            colormap(o.axes, map);
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.val;
        end
    end
    
end

