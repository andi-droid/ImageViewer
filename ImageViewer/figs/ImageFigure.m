 classdef ImageFigure < ImageBaseFigure
    properties
        % GUI elements
        roiRect
        overlaybtn
        zoombtn
        saverectbtn
        centeredits
        layout
        % Data
        image
        sizeofimage
        wjet
        %avg
        ID
        avgimages
        avgbtn
        avgstate = false
        avgNum = 10;
        avgNumedit;

        
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
            o.compositor.abscenter(icenter) = str2double(get(o.centeredits(icenter), 'String'));
            abscenter = o.compositor.abscenter;
            save('figs/last_abscenter.mat','abscenter');
        end
        
        function onEnteravgNum(o,hObject,callbackdata)
            o.avgNum = str2double(get(hObject,'string'));
        end
        
        function processData(o)
            o.image = o.compositor.image;
            o.sizeofimage = size(o.image);
            %o.compositor.croppedimage = o.image(o.compositor.roi(2):(o.compositor.roi(4)+o.compositor.roi(2)),o.compositor.roi(1):(o.compositor.roi(3)+o.compositor.roi(1)));
            if o.avgstate
               o.createavg();
               o.changeRect();
            end
        end
        
        
        function createavg(o)
            o.ID = str2double(o.compositor.currentabsorptionimage(14:17));
            o.avgimages(:,:,mod(o.ID,o.avgNum)+1) = o.image;
            o.image = nanmean(o.avgimages,3); %% is this ok?
        end
        
        
        function onAvgPush(o,hObject,callbackdata)
            buttonstate = get(hObject,'Value');
            if buttonstate == get(hObject,'Max')
                %o.onEnteravgNum();
                o.avgimages = NaN(size(o.image,1),size(o.image,2),o.avgNum);
                o.avgstate = true;
                o.onRedraw();
            else
                o.avgstate = false;
                o.onRedraw();
            end
        end
        
        
        function onOverlayPush(o,hObject,callbackdata)
            buttonstate = get(hObject,'Value');
            if buttonstate == get(hObject,'Max')
                o.zoneOverlay.lattice.center = o.compositor.abscenter;
                o.addZones;
                
                
            else
                %o.onReplot();
                o.zoneOverlay.axes = [];
                o.zoneOverlay.update();
                
            end
        end
        
         function onSaveRectPush(o,hObject,callbackdata)
             rect = o.compositor.roi;
             save('ROI.mat','rect');
        end
        
        % implementing BaseFigure
        function onCreate(o)
            C = get(0, 'DefaultUIControlBackgroundColor');
            set(o.figure, 'Color', C)
            addlistener(o.compositor, 'updateAxes', @o.onUpdateAxesEvent);
            if exist('figs/last_abscenter.mat')
                load('figs/last_abscenter.mat');
                o.compositor.abscenter = abscenter;
            else
                o.compositor.abscenter = o.compositor.camera.abscenter;
            end
            %o.compositor.abscenter = [377,254];
            %             o.linkMouseWheelToIndex('time');
            %             o.listenToUserInput('time', @o.onRedraw);
            %             o.linkUpDownLeftRightToIndeces('frequency', 'run');
            %             o.listenToUserInput('frequency', @o.onRedraw);
            %             o.listenToUserInput('run', @o.onRedraw);
            %o.layout  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0. 0. 1 1]);
            o.zoneOverlay = ZoneOverlay();
            o.zoneOverlay.lattice = BravaisLattice2D();
            o.overlaybtn = uicontrol(o.figure, 'Style', 'togglebutton', 'String', 'ZoneOverlay',...
                'Units', 'normalized',...
                'Position', [0.2 0.0 0.25 0.1],...
                'Value', 0,...
                'Callback', @o.onOverlayPush);
            
            o.avgbtn = uicontrol(o.figure, 'Style', 'togglebutton', 'String', 'Avg',...
                'Units', 'normalized',...
                'Position', [0.9 0.9 0.1 0.1],...
                'Value', 0,...
                'Callback', @o.onAvgPush);
            avgNumtext = uicontrol(o.figure, 'Style', 'text', 'String', 'AvgNum',...
                'Units', 'normalized',...
                'Position', [0.9 0.8 0.1 0.1]);
            
            o.avgNumedit = uicontrol(o.figure, 'Style', 'edit',...
                'Units', 'normalized',...
                'String',num2str(o.avgNum),...
                'Position', [0.9 0.75 0.1 0.1],...
                'Callback', {@o.onEnteravgNum});
            
            o.saverectbtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Save Rect',...
                'Units', 'normalized',...
                'Position', [0.4 0.9 0.2 0.1],...
                'Value', 0,...
                'Callback', @o.onSaveRectPush);
            
            o.zoombtn = uicontrol(o.figure, 'Style', 'togglebutton', 'String', 'Zoom',...
                'Units', 'normalized',...
                'Position', [0.0 0.0 0.15 0.1],...
                'Value', 0,...
                'Callback', @o.onZoomPush);
            
            centernames ={'Center x', 'Center y'};
            for i =1:2
                o.centeredits(i) = uicontrol(o.figure, 'Style', 'edit',...
                    'Units', 'normalized',...
                    'String',num2str(o.compositor.abscenter(i)),...
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
            if isempty(o.image)
                    o.axes.XLim = [1 1024];
                    o.axes.YLim = [1 512];

            else
                o.axes.XLim = [1 o.sizeofimage(2)];
                o.axes.YLim = [1 o.sizeofimage(1)];
            end
            o.axes.Visible = 'off';
            colormap(o.axes,o.wjet);
            o.clims = [0,5]; %old [-1,3.2] 2018-08-22
            set(o.axes, 'CLim', o.clims);
            daspect(o.axes, [1 1 1]);
            if ~isempty(o.image)
                o.roiRect = imrect(o.axes, o.compositor.roi,...
                    'PositionConstraintFcn', makeConstrainToRectFcn('imrect',o.axes.XLim,o.axes.YLim));
                o.roiRect.addNewPositionCallback(@(x,y)o.changeRect);
            else
                o.compositor.roi = o.compositor.camera.roi;
            end
            
            
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
%             if isempty(o.roiRect)
%                                 o.roiRect = imrect(o.axes, o.compositor.roi,...
%                     'PositionConstraintFcn', makeConstrainToRectFcn('imrect',o.axes.XLim,o.axes.YLim));
%                 o.roiRect = imrect(o.axes, o.compositor.roi);
%                 o.roiRect.addNewPositionCallback(@(x,y)o.changeRect);
%             end
            
            %o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

