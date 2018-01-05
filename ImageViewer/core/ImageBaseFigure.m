classdef ImageBaseFigure < handle
    % make a multi axis basis and a single axis basis
    properties
        compositor
        data
        maxk
        
        figure
        controls
        axes
        plot
        box
        zoneOverlay
        pointer
        clims
        
        updateText
        updateCheckbox
        
        windowTitle = mfilename('class')
        bgcolor = [1 1 1 ]
        font =   'Verdana'
        
        vidObj
    end
    
    methods
        function h = create(o, compositor)
            o.compositor = compositor;
            o.data = compositor.data;
            o.figure = figure(  'Parent', 0,...
                'Name', o.windowTitle,...
                'Units', 'pixels',...
                'Color', o.bgcolor,...
                'WindowStyle', 'docked',...
                'NumberTitle', 'off',...
                'Color',[1 1 1 ]);
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            set(get(handle(o.figure), 'javaframe'), ...
                'GroupName', o.compositor.name);
            
            o.axes =  axes(...
                'Parent',o.figure,...
                'Units', 'normalized',...'DataAspectRatioMode', 'auto',...
                'OuterPosition', [0,0,1,1],...
                'box', 'off',...'DataAspectRatio', [1 1 1],...
                'FontName', o.font,...
                'Color', [1 1 1 ]);
            box(o.axes, 'off');
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            
            
            o.onCreate();
            o.replot();
            h = o.figure;
        end
        
        %
%         function linkMouseWheelToIndex(o, name)
%             function handleMouseWheel( ~, eventdata, ~)
%                 if eventdata.VerticalScrollCount < 0
%                     o.compositor.userindex.(name).increase();
%                 else
%                     o.compositor.userindex.(name).decrease();
%                 end
%             end
%             set(o.figure, 'WindowScrollWheelFcn', @handleMouseWheel);
%         end
        
        function linkUpDownLeftRightToIndeces(o, nameUD, nameLR)
            function handleKeyboardInput(~, event)
                if strcmp(event.Key,'downarrow')
                    if ~isempty(nameUD)
                        o.compositor.userIndeces.(nameUD).decrease();
                    end
                elseif strcmp(event.Key,'uparrow')
                    if ~isempty(nameUD)
                        o.compositor.userIndeces.(nameUD).increase();
                    end
                elseif strcmp(event.Key,'leftarrow')
                    if ~isempty(nameLR)
                        o.compositor.userIndeces.(nameLR).decrease();
                    end
                elseif strcmp(event.Key,'rightarrow')
                    if ~isempty(nameLR)
                        o.compositor.userIndeces.(nameLR).increase();
                    end
                elseif strcmp(event.Key,'v')
                    if ~isempty(o.vidObj)
                        disp('Stopping video');
                        close(o.vidObj);
                        delete(o.vidObj);
                        o.vidObj = [];
                    else
                        disp('Starting video');
                        o.vidObj = VideoWriter(['test.avi'], 'Uncompressed AVI');
                        o.vidObj.FrameRate = 5;
                        open(o.vidObj);
                    end
                end
            end
            set(o.figure, 'KeyPressFcn', @handleKeyboardInput);
        end
        
        function listenToUserInput(o, name, func)
            if nargin < 3, func = @o.onUpdate;end;
            function valueChange(~, ~)
                func();
            end
            addlistener(o.compositor.userindex.(name), 'value', 'PostSet', @valueChange);
        end
        
        % data helpers
        function [x, y] = kToPixel(o,k)
            [x, y] = FitBaseFigure.kToPixelS(k, o.compositor.data.lvl,...
                o.compositor.data.center);
        end
        
        function k = pixelToK(o,x,y)
            k = FitBaseFigure.pixelToKS(x, y, o.compositor.data.lvl,...
                o.compositor.data.center);
        end
        
        % pointer functionality
        function addDraggablePointer(o)
            if ishandle(o.pointer), delete(o.pointer);end
            p = o.compositor.currentCoordinate;
            o.pointer = impoint(o.axes, p(1), p(2), 'PositionConstraintFcn',...
                makeConstrainToRectFcn('impoint',o.axes.XLim, o.axes.YLim));
            o.pointer.addNewPositionCallback(@o.onPointerChanged);
            o.pointer.setColor('black');
        end
        
        function onPointerChanged(o, p)
            o.compositor.currentCoordinate = p;
        end
        
        function p = registerCurrentCoordinateListener(o)
            addlistener(o.compositor, 'currentCoordinate', 'PostSet', @o.onCurrentCoordinateChanged);
            p = o.compositor.currentCoordinate;
        end
        
        function onCurrentCoordinateChanged(o, ~, ~)
            % change pointer position, without triggering
            % onPointerChangedEvent, to avoid endless loop.
            p = o.compositor.currentCoordinate;
            if ishandle(o.pointer)
                o.pointer.setPosition(p);
            end
            o.onNewCurrentCoordinate(p);
        end
        
        function onNewCurrentCoordinate(o,p)
            % this has to be implemented by child class
        end
        
        % plotting helpers
        function addZones(o)
            %o.zoneOverlay = ZoneOverlay();
            %o.zoneOverlay.lattice = BravaisLattice2D();
            %%%%%
            hbar  = 6.62606896e-34 / (2*pi) ;
            mK = 39.9639992*1.660538e-27;
            PixSize = 13E-6;
            V = 2.15; %measured
            T = 2100*10e-6;
            kl = 2*pi/1064e-9;
            kp = hbar*kl/mK*T/PixSize*V;
            kp = 1.0*kp;
            rot = @(theta)[cosd(theta)  -sind(theta) ; sind(theta)  cosd(theta)];
            o.zoneOverlay.lattice.b1 = -0.5*kp*[3 sqrt(3)]*rot(-0.0);
            o.zoneOverlay.lattice.b2 = -0.5*kp*[3 -sqrt(3)]*rot(-0.0);
            %%%%
            %o.zoneOverlay.lattice.b1 = 1/(2*sqrt(3))*[3 sqrt(3)];
            %o.zoneOverlay.lattice.b2 = 1/(2*sqrt(3))*[3 -sqrt(3)];
            %o.zoneOverlay.lattice.center = o.compositor.abscenter;
            %o.zoneOverlay.lattice.center = [155 155];
            o.zoneOverlay.axes = o.axes;
            o.zoneOverlay.update();
            uistack(o.axes.Children(end-1),'top');
        end
        
        function imageF(o, data)
            o.plot = ImageBaseFigure.imageL(data, 'Parent', o.axes);
        end
        
        
        
        function onCheckboxUpdate(o, hoect, eventdata)
            o.onUpdate();
        end
        
        function replot(o)
            %if ishandle(o.axes), delete(o.axes); end;
            if ishandle(o.plot), delete(o.plot); end;
            o.onReplot();
             if ~isempty(o.vidObj)
               writeVideo(o.vidObj,getframe);
            end
        end
        
        function onUpdate(o)
            o.onRedraw();
            if ~isempty(o.vidObj)
               writeVideo(o.vidObj,getframe);
            end
        end
        
        function onUpdateDataEvent(o, ~, ~)
            o.onUpdate();
        end
        
        function onUpdateDataAndResolutionEvent(o, ~, ~)
            o.replot();
        end
        
        function onUpdateAxesEvent(o, ~, ~)
            o.replot();
        end
        
        
    end
    
    methods(Abstract)
        onCreate(o);
        onReplot(o);
        onRedraw(o);
    end
    
    methods(Static)
        function [x, y] = kToPixelS(k, lvl, center)
            % center is given in pixels
            if numel(k) == 2
                k = k(:);
                x = NaN(1);
                y = NaN(1);
            else
                sz = size(k);
                x = NaN([1, sz(2:end)]);
                y = NaN([1, sz(2:end)]);
            end
            x(:) = round(center(1) + k(1,:)*lvl);
            y(:) = round(center(2) + k(2,:)*lvl);
        end
        
        function k = pixelToKS(x, y, lvl, center)
            k(1,:) = (x-center(1))/lvl;
            k(2,:) = (y-center(2))/lvl;
        end
        
        function plot = imageL(data, varargin)
            % center is given in pixels
            nx = size(data,2);
            ny = size(data,1);
            plot = imagesc(data,...
                varargin{:});
            
             a = ancestor(plot, 'axes');
%             a.YDir = 'normal';
            daspect(a, [1 1 1]);
        end
    end
    
end