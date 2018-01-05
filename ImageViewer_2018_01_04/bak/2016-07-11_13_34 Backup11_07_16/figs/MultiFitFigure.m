classdef MultiFitFigure < FitBaseFigure
    properties
        val
        t
        run
        iParam
    end
    
    methods
        % constructor
        function o = MultiFitFigure(iParam)
            o.iParam = iParam;
            if iParam > 7
                switch iParam
                    case 8
                        o.windowTitle = 'Fit - Vorticity';
                        
                end
            else
                o.windowTitle = HaukeSet.paramNamesExt{iParam};%mfilename('class');
            end
            %o.windowTitle = num2str(iParam);
        end
        
        function processData(o)
            o.t = o.compositor.userIndeces.time.value;
            o.run = o.compositor.userIndeces.run.value;
            hs = o.data.getHaukeSet(o.t,o.run);
            function initializeEmpty
                sz = size(o.compositor.data.haukeSets{1}.imageData);
                o.val = NaN(sz(2:3));
            end
            if ~isempty(hs)
                if isstruct(hs.fitResults)
                    if o.iParam < 8
                        o.val = hs.fitResults.(HaukeSet.paramNamesExt{o.iParam});
                        if o.iParam == 4
                            o.val(:) = mod(o.val(:)-pi/2,2*pi)-pi;
                        end
                        if o.iParam == 2
                            o.val(:) = o.val(:);
                        end
                    else
                        switch o.iParam 
                            case 8
                                o.val = hs.fitResults.pha1;
                                o.val(:) = mod(o.val(:)-pi/2,2*pi)-pi;
                                %                         order = 3;
                                %                         h = 1/order^2*ones(order);
                                %                         o.val = IT.filterPhase2D(o.val, h);
                                %o.val = edge(shakenBGH.grad(o.val), 0.1);

                                o.val = v.vorticity(o.val);
                                %s = o.val > 2;
                                %o.val(~s) = 0;
                            case 9
                                o.val = hs.fitResults.iterations;
                        end

                    end

                else
                    initializeEmpty;
                end
            else
                initializeEmpty;
            end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time', @o.onRedraw);
            o.linkUpDownLeftRightToIndeces('', 'run');
            o.listenToUserInput('run', @o.onRedraw);
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.val);
            
            o.axes.XLim = [-1.2 1.2];
            o.axes.YLim = [-1.2 1.2];
            if o.iParam == 4
                caxis(o.axes, [-pi pi]);
                colormap(o.axes, v.phasemap(500));
            elseif o.iParam == 8
                caxis(o.axes, [-1.2 1.2]);
                colormap(o.axes, v.vortexmap(500));
            elseif o.iParam == 5
                caxis(o.axes, [11 14]*1e3);
            end
            
            o.addZones;
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.val;
        end
    end
    
end

