classdef CroppedImageFigure < ImageBaseFigure
    properties
        image
        maskedimage
        t
        text
        frequency
        run
        title
        layout
        zoombtn
        maskbtn
        maskstate = false
        mask
        wjet
        maxcount
        roicenter =[157,153]
        popupmasks
        maskname = '1. BZ'
        overlaybtn
        maskcounttext
        maskcounts
        cmapslider
        cmapmax = 2;
    end
    
    methods
        % constructor
        function o = CroppedImageFigure()
            o.windowTitle = mfilename('class');
            B = load('wjet.mat');
            C = B.wjet;
            o.wjet = C/255;
            
        end
        
        function setMask(o,hSource,callbackdata)
            items = get(hSource,'String');
            index_selected = get(hSource,'Value');
            item_selected = items{index_selected};
            o.maskname = item_selected;
            o.onMaskPush(o.maskbtn);
        end
        
        function processData(o)
            o.image = o.compositor.croppedimage;
            o.maxcount = abs(max(max(o.image)));
            if o.maskstate
                o.maskedimage = o.image.*o.mask;
            end
        end
        
        function createMask(o)
            LVL = 56;
            dimx = size(o.image,2);
            dimy = size(o.image,1);
            if strcmp(o.maskname,'1. BZ')
                BW=uZoneMask(1,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'2. BZ')
                BW=uZoneMask(2,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'3. BZ')
                BW=uZoneMask(3,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'1.+2. BZ')
                BW1=uZoneMask(1,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
                BW2=uZoneMask(2,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
                BW = BW1 + BW2;
            end
            o.mask = BW;
        end
        
        function onMaskPush(o,hObject,callbackdata)
            buttonstate = get(hObject,'Value');
            if buttonstate == get(hObject,'Max')
                o.createMask();
                o.maskedimage = o.image.*o.mask;
                o.maskstate = true;
                o.onRedraw();
            else
                o.maskstate = false;
                o.onRedraw();
            end
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
        
        function onOverlayPush(o,hObject,callbackdata)
            buttonstate = get(hObject,'Value');
            if buttonstate == get(hObject,'Max')
                o.zoneOverlay.lattice.center = o.roicenter;
                o.addZones;
                
                
            else
                %o.onReplot();
                o.zoneOverlay.axes = [];
                o.zoneOverlay.update();
            end
        end
        
        function setCmapmax(o,hObject,callbackdata)
            o.cmapmax = get(hObject,'Value');
            o.onRedraw();
        end
        
        % implementing BaseFigure
        function onCreate(o)
            C = get(0, 'DefaultUIControlBackgroundColor');
            set(o.figure, 'Color', C)
            %             o.linkMouseWheelToIndex('time');
            %             o.listenToUserInput('time', @o.onRedraw);
            %             o.linkUpDownLeftRightToIndeces('frequency', 'run');
            %             o.listenToUserInput('frequency', @o.onRedraw);
            %             o.listenToUserInput('run', @o.onRedraw);
            addlistener(o.compositor, 'updateDataAndResolution', @o.onUpdateDataAndResolutionEvent);
            %o.layout  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0. 0. 1 1]);
            
            o.zoombtn = uicontrol(o.figure, 'Style', 'togglebutton', 'String', 'Zoom',...
                'Units', 'normalized',...
                'Position', [0.0 0.0 0.15 0.1],...
                'Value', 0,...
                'Callback', @o.onZoomPush);
            
            o.maskbtn = uicontrol(o.figure, 'Style', 'togglebutton', 'String', 'BZMask',...
                'Units', 'normalized',...
                'Position', [0.5 0.0 0.2 0.1],...
                'Value', o.maskstate,...
                'Callback', @o.onMaskPush);
            
            o.popupmasks = uicontrol('Style', 'popupmenu',...
                'String', {'1. BZ','2. BZ','1.+2. BZ'},...
                'units', 'normalized',...
                'Position', [0.7 0.0 0.2 0.1],...
                'Callback', @o.setMask,...
                'Value',1);
            
            o.zoneOverlay = ZoneOverlay();
            o.zoneOverlay.lattice = BravaisLattice2D();
            o.overlaybtn = uicontrol(o.figure, 'Style', 'togglebutton', 'String', 'ZoneOverlay',...
                'Units', 'normalized',...
                'Position', [0.2 0.0 0.25 0.1],...
                'Value', 0,...
                'Callback', @o.onOverlayPush);
            
            %o.maskcounttext  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0.8 0.9 0.2 0.1]);
            
            o.cmapslider = uicontrol('Style', 'slider',...
                'units', 'normalized',...
                'Position', [0.9 0.2 0.05 0.6],...
                'Min', 0,...
                'Max', 15.0,...
                'Value',0.5,...
                'Callback', @o.setCmapmax);
            
        end
        
        function onReplot(o)
            
            o.processData();
            
            if o.maskstate
                o.imageF(o.maskedimage);
                o.maskcounts = nansum(nansum(o.maskedimage));
            else
                o.imageF(o.image);
                o.maskcounts = nansum(nansum(o.image));
            end
            o.text = ['Counts(Mask): ' num2str(round(o.maskcounts))];
            %o.title = title(o.axes, num2str(o.t));
            %caxis(o.axes, [-0.02 0.1]);
            %             if ~empty(sizeofimage)
            %             o.axes.XLim = sizeofimage(2);
            %             o.axes.YLim = sizeofimage(1);
            %             end
            o.axes.Visible = 'off';
            colormap(o.axes,o.wjet);
            %o.clims = [0,0.1];
            if isempty(o.maxcount)
                o.clims = [-0.1, 0.5];
            else
                o.clims = [-0.1,o.maxcount];
            end
            %o.clims = [-0.1,o.maxcount];
            %set(o.axes, 'CLim', o.clims);
            set(o.axes, 'CLim', [-0.1,o.cmapmax]);
            daspect(o.axes, [1 1 1]);
            %axis(o.axes,'equal');
            %imscrollpanel(o.figure,o.plot);
            %o.axes.XLim = [1 size(o.image,2)];
            %o.axes.YLim = [1 size(o.image,1)];
            
            o.axes.XLim = [1 o.compositor.roi(3)+1];
            o.axes.YLim = [1 o.compositor.roi(4)+1];
            
            %o.maskcounttext.String = o.text;
        end
        
        function onRedraw(o)
            o.processData();
            %             if isempty(o.maxcount)
            %                 o.clims = [-0.1, 0.5];
            %             else
            %                 o.clims = [-0.1,o.maxcount];
            %             end
            %             %o.clims = [-0.1,o.maxcount];
            %             set(o.axes, 'CLim', o.clims);
            if o.maskstate
                o.plot.CData =o.maskedimage;
                o.maskcounts = nansum(nansum(o.maskedimage));
            else
                o.plot.CData = o.image;
                o.maskcounts = nansum(nansum(o.image));
            end
            set(o.axes, 'CLim', [-0.1,o.cmapmax]);
            o.text = ['Counts(Mask): ' num2str(round(o.maskcounts))];
            %o.roicenter(1) = size(o.image,2)/2;
            %o.roicenter(2) = size(o.image,1)/2;
            o.roicenter(1) = o.compositor.abscenter(1)-o.compositor.roi(1);
            o.roicenter(2) = o.compositor.abscenter(2)-o.compositor.roi(2);
            %                         o.axes.XLim = [1 size(o.image,2)];
            %             o.axes.YLim = [1 size(o.image,1)];
            %o.maskcounttext.String = o.text;
            %o.title.String = sprintf('time: %d, hauke: %d, run: %d', o.t, o.frequency, o.run);
        end
    end
    
end

