classdef MultiImbalanceVorticityFigure < FitBaseFigure
    properties
        val
        valNonInterp
        run
        frequency
        iParam
    end
    
    methods
        % constructor
        function o = MultiImbalanceVorticityFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            for i=1:numel(o.data.haukeSets)
                ld1(i) = o.data.haukeSets{i}.info.latticeDepth1;
                ld2(i) = o.data.haukeSets{i}.info.latticeDepth2;
            end
            [~, ~ ,c] = unique(ld1);
            
%             o.run = o.compositor.userIndeces.run.value;
            imbalance = o.compositor.userIndeces.imbalance.value;
            time = o.compositor.userIndeces.time.value;
               
            s = c == imbalance  & o.data.parameters(:,1) == time;
            %s =  o.data.parameters(:,2) == runs & o.data.parameters(:,1) == time;
%             sbg = o.data.parameters(:,2)== o.run & o.data.parameters(:,1) == 2;
%             bg = v.pmod(o.data.haukeSets{sbg}.getfftP(3));            
            
            o.frequency = o.compositor.userIndeces.frequency.value;
             if any(s)
                hs = {o.data.haukeSets{s}};
             else
                 hs = [];
             end
            function initializeEmpty
                sz = size(o.compositor.data.haukeSets{1}.imageData);
                o.val = NaN(sz(2:3));
                o.valNonInterp = o.val;
            end
            if ~isempty(hs)
                sz = size(o.compositor.data.haukeSets{1}.getfftP(1));
                o.val = zeros(sz);
                o.valNonInterp = zeros(sz);
                fprintf('\n');
                for iSet=1:numel(hs)
                    %phase = hs{iSet}.fitResults.pha1;
                    phase = hs{iSet}.getfftP(o.frequency);
                    fprintf('I1: %f,\t I2: %f\n', hs{iSet}.info.latticeDepth1, hs{iSet}.info.latticeDepth2);
%                     phase = v.pmod(phase-bg);
                    %amp = squeeze(hs{iSet}.fftA(o.frequency,:,:));
                    vt = v.vorticity(phase);
                    %s = abs(vt(:))>0.1;
                    
                    %vt = (abs(vt)>1);
                    o.val = o.val + vt;
                    if ~hs{iSet}.interpolated
                        o.valNonInterp = vt;%iSet;
                        
                    end
                end
                o.val = min(o.val, 1);
                o.val = max(o.val, -1);
                o.val = 0.25*o.val;
                o.val = o.val+o.valNonInterp;
            else
                initializeEmpty;
            end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            fprintf('onCreate');
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time', @o.onRedraw);
            o.linkUpDownLeftRightToIndeces('imbalance2', 'imbalance');
            o.listenToUserInput('imbalance', @o.onRedraw);
            o.listenToUserInput('imbalance2', @o.onRedraw);

        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.val);
            colormap(o.axes, v.vortexmap(255));
            caxis(o.axes, [-1 1]);
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

