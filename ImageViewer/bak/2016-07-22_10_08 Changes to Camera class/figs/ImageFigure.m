classdef ImageFigure < ImageBaseFigure
    properties
        image
        t
        frequency
        run
        title
        roiRect
        overlaybtn
        zoombtn
        wjet
        centeredits
        abscenter
    end
    
    methods
        % constructor
        function o = ImageFigure()
            o.windowTitle = mfilename('class');
            B = load('wjet.mat');
            C = B.wjet;
            o.wjet = C/255;
        end
        
        function onZoomPush(o,hObject,callbackdata)
            buttonstate = get(hObject,'Value');
            if buttonstate == get(hObject,'Max')
                zoom(o.figure,'on');
                %o.onRedraw();
                
            else
                zoom(o.figure,'off');
                %o.onRedraw();
            end
        end
        
        function onEnterCenter(o,hObject,callbackdata,icenter)
            o.abscenter(icenter) = str2double(get(o.centeredits(icenter), 'String'));
        end
        
        function processData(o)
            o.image = o.compositor.image;
            %o.compositor.croppedimage = o.image(o.compositor.roi(2):(o.compositor.roi(4)+o.compositor.roi(2)),o.compositor.roi(1):(o.compositor.roi(3)+o.compositor.roi(1)));
            
        end
        
        function onOverlayPush(o,hObject,callbackdata)
            buttonstate = get(hObject,'Value');
            if buttonstate == get(hObject,'Max')
                o.zoneOverlay.lattice.center = o.abscenter;
                o.addZones;
                
            else
                %o.onReplot();
                o.zoneOverlay.axes = [];
                o.zoneOverlay.update();
            end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            addlistener(o.compositor, 'updateAxes', @o.onUpdateAxesEvent);
            o.abscenter = [377,254];
            %             o.linkMouseWheelToIndex('time');
            %             o.listenToUserInput('time', @o.onRedraw);
            %             o.linkUpDownLeftRightToIndeces('frequency', 'run');
            %             o.listenToUserInput('frequency', @o.onRedraw);
            %             o.listenToUserInput('run', @o.onRedraw);
            o.zoneOverlay = ZoneOverlay();
            o.zoneOverlay.lattice = BravaisLattice2D();
            o.overlaybtn = uicontrol(o.figure, 'Style', 'togglebutton', 'String', 'ZoneOverlay',...
                'Units', 'normalized',...
                'Position', [0.2 0.0 0.25 0.1],...
                'Value', 0,...
                'Callback', @o.onOverlayPush);
            
            o.zoombtn = uicontrol(o.figure, 'Style', 'togglebutton', 'String', 'Zoom',...
                'Units', 'normalized',...
                'Position', [0.0 0.0 0.15 0.1],...
                'Value', 0,...
                'Callback', @o.onZoomPush);
            
            centernames ={'Cen x', 'Cen y'};
            for i =1:2
                o.centeredits(i) = uicontrol(o.figure, 'Style', 'edit',...
                    'Units', 'normalized',...
                    'String',num2str(o.abscenter(i)),...
                    'Position', [0.1 1.0-0.1*i 0.1 0.1],...
                    'Callback', {@o.onEnterCenter,i});
            end
            
            for i =1:2
                centertext(i) = uicontrol(o.figure, 'Style', 'text', 'String', centernames{i},...
                    'Units', 'normalized',...
                    'Position', [0.0 1.0-0.1*i 0.1 0.1]);
            end
            
            
        end
        
        function onReplot(o)
            o.processData();
            o.imageF(o.image);
            %o.title = title(o.axes, num2str(o.t));
            %caxis(o.axes, [-0.02 0.1]);
            if ~isempty(o.compositor.cameraID)
               if strcmp(o.compositor.cameraID,'Andor')
                   o.axes.XLim = [1 1024];
                   o.axes.YLim = [1 512];
                else
                    o.axes.XLim = [1 1392];
                    o.axes.YLim = [1 1024];
                end
            else
                o.axes.XLim = [1 1024];
                o.axes.YLim = [1 512];
            end
            o.axes.Visible = 'off';
            colormap(o.axes,o.wjet);
            o.clims = [-1,3.2];
            set(o.axes, 'CLim', o.clims);
            daspect(o.axes, [1 1 1]);
            o.roiRect = imrect(o.axes, o.compositor.roi,...
                'PositionConstraintFcn', makeConstrainToRectFcn('imrect',o.axes.XLim,o.axes.YLim));
            %o.roiRect = imrect(o.axes, o.compositor.roi);
            o.roiRect.addNewPositionCallback(@(x,y)o.changeRect);
            
            
        end
        
        function changeRect(o)
            o.compositor.roi = round(o.roiRect.getPosition());
            o.compositor.croppedimage = o.image(o.compositor.roi(2):(o.compositor.roi(4)+o.compositor.roi(2)),o.compositor.roi(1):(o.compositor.roi(3)+o.compositor.roi(1)));
            o.compositor.datacroppedx = sum(o.compositor.croppedimage,1);
            o.compositor.datacroppedy = sum(o.compositor.croppedimage,2);
            o.compositor.cutOD = o.compositor.croppedimage(floor(o.compositor.roi(4)/2),:);
            notify(o.compositor,'updateData');
            notify(o.compositor,'updateDataAndResolution');
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.CData = o.image;
            
            %o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

