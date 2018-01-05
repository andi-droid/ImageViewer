classdef AllTimeGradientFigure < FitBaseFigure
    properties
        val
        run
        iParam
    end
    
    methods
        % constructor
        function o = AllTimeGradientFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            o.run = o.compositor.userIndeces.run.value;
            %hs = o.data.getHaukeSetsRun(o.run);
            
            s = o.data.parameters(:,2)== o.run & o.data.parameters(:,1) < 12;
             if any(s)
                hs = {o.data.haukeSets{s}};
             else
                 hs = [];
             end
            function initializeEmpty
                sz = size(o.compositor.data.haukeSets{1}.imageData);
                o.val = NaN(sz(2:3));
            end
            if ~isempty(hs)
                sz = size(o.compositor.data.haukeSets{1}.imageData);
                o.val = zeros(sz(2:3));
                for iSet=1:numel(hs)
                    
                    %phase = hs{iSet}.fitResults.pha1;
                    phase = squeeze(hs{iSet}.fftP(3,:,:));
                    amp = squeeze(hs{iSet}.fftA(3,:,:));
                    phase = v.pmod(phase);
                    [DX,DY] = v.grad(phase);
                    %phase = v.pmod(DX.^2+DY.^2);
                    phase = DX.^2+DY.^2;
                    phase = phase./amp;
                    %s = phase > 1;
                    %phase(~s) = 0;
                    o.val = o.val + phase;
                end
            else
                initializeEmpty;
            end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.linkUpDownLeftRightToIndeces('', 'run');
            o.listenToUserInput('run', @o.onRedraw);
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.val);
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            o.addZones;
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.val;
        end
    end
    
end

