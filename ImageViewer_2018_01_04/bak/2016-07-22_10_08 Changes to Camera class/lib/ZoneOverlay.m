classdef ZoneOverlay < handle & matlab.mixin.Copyable
    properties
        axes
        BZPlots
        HexPlots
        lattice
        
        doPlot = true;
        ls
        le
        X
        Y
    end
    
    methods
        function update(o)
            if any(ishandle(o.BZPlots))
                delete(o.BZPlots);
            end
            if any(ishandle(o.HexPlots))
                delete(o.HexPlots);
            end
            
            [o.ls, o.le] = o.lattice.braggPlaneLines(5*sqrt(abs(o.lattice.V())),5*sqrt(abs(o.lattice.V())));
            %o.plots = zeros(numel(o.axes),size(ls,1));
            [o.X, o.Y] = o.lattice.cellPolies(5*sqrt(abs(o.lattice.V())));
            % Do the actual overlaying
            if o.doPlot
                for iAxis = 1:numel(o.axes)
                    hold(o.axes(iAxis), 'on');
                    o.BZPlots(iAxis,:) = plot(o.axes(iAxis),[o.ls(:,1) o.le(:,1)]',[o.ls(:,2) o.le(:,2)]','r-');
                    o.HexPlots(iAxis,:) = plot(o.axes(iAxis), o.X, o.Y,'k-');
                    hold(o.axes(iAxis), 'off');
                end
            end
        end
    end
    
end

