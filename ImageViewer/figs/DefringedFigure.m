classdef DefringedFigure < BaseFigure
    
    % @todo implement emptiness of ImageSets
    properties
        imageSet
        userInput
        clims
        
        
        postplot
        
        indexName = 'currentImageNo';
        imageNames
        imageindex = 1;
        
        % PixelSelect
        allowPixelSelect = false;
        pointSelfSetting
        normalize
        useQuantileScale = true;
        useIndividualScale = false;
        pQuantile = 0.05;
        showColorbar = false;
    end
    
    methods
        function o = DefringedFigure(varargin)
            o.windowTitle = mfilename('class');
            switch nargin
                case 0, o.imageSet = [];
                case 1,     o.imageSet = varargin{1};
                    o.userInput = UserInput();
                    o.userInput.currentImageNo = 1;
                case 2,     [o.imageSet, o.userInput]  = varargin{:};
                otherwise,  error('Error initializing %s', mfilename('class'));
            end
        end
        
        
        % callbacks
        
        function onUpdateDefringedImageSet(o,hobj,data)
            o.imageSet = [];
            rect = o.compositor.roi;
            o.compositor.croppedDefringedIS = [];
            o.imageSet = OD_ImageSet(o.compositor.imagesetdef, o.compositor.imagesetabs);
            o.imageSet.populate();
            o.imageindex = 1;
            images = reshape(o.imageSet.images,[o.imageSet.nImages,o.imageSet.dimy,o.imageSet.dimx]);
            imagescropped = images(:,rect(2):(rect(2)+rect(4)-1),rect(1):(rect(1)+rect(3)-1));
            imagescroppedreshaped = reshape(imagescropped,[o.imageSet.nImages,o.compositor.roi(4),o.compositor.roi(3)]);
            o.compositor.croppedDefringedIS = imagescroppedreshaped;
            notify(o.compositor,'updateDataDefringedIntegratedOD');
            %o.linkMouseWheelToIndex();
            o.onReplot();
        end
        
        
        function onCurrentImageNoChange(o, eventSrc, eventData)
            o.onUpdate();
        end
        
        function handleKeyboardInput(o, src, event)
            if strcmp(event.Key,'downarrow')
                o.onNextShot();
            elseif strcmp(event.Key,'uparrow')
                o.onPreviousShot();
            end
        end
        
        function handleMouseWheel(o, hoect, eventdata, handles)
            if eventdata.VerticalScrollCount < 0
                o.onNextShot();
            else
                o.onPreviousShot();
            end
        end
        
        % image change
        function onNextShot(o)
            o.userInput.(o.indexName) = min(o.userInput.(o.indexName)+1, o.imageSet.getNImages());
        end
        function onPreviousShot(o)
            o.userInput.(o.indexName) = max(o.userInput.(o.indexName)-1, 1);
        end
        
        function linkMouseWheelToIndex(o)
            function handleMouseWheel( ~, eventdata, ~)
                if eventdata.VerticalScrollCount < 0
                    if o.imageindex < o.imageSet.nImages
                        o.imageindex = o.imageindex +1;
                        o.onRedraw();
                    end
                else
                    if o.imageindex > 1
                        o.imageindex = o.imageindex -1;
                        o.onRedraw();
                    end
                end
            end
            set(o.figure, 'WindowScrollWheelFcn', @handleMouseWheel);
        end
        
        function onIndexUp(o,~,~)
            
            o.imageindex = o.imageindex +1;
            if ~isempty(o.imageSet)
                o.onRedraw();
            end
        end
        
        function onIndexDown(o,~,~)
            
            o.imageindex = o.imageindex -1;
            if ~isempty(o.imageSet)
                o.onRedraw();
            end
        end
        
        
        % implementing BaseFigure
        function onCreate(o)
            C = get(0, 'DefaultUIControlBackgroundColor');
            set(o.figure, 'Color', C)
            %             addlistener(o.userInput, o.indexName, 'PostSet', @o.onCurrentImageNoChange);
            addlistener(o.compositor,'updateDefringedImageSet', @o.onUpdateDefringedImageSet);
            addlistener(o.compositor,'indexup', @o.onIndexUp);
            addlistener(o.compositor,'indexdown', @o.onIndexDown);
            %             % add listeners for changing current image
            %             set(o.figure, 'WindowScrollWheelFcn', @o.handleMouseWheel,...
            %                 'KeyPressFcn', @o.handleKeyboardInput,...%'DeleteFcn', @o.onClose,...
            %                 'Position', [10 o.imageSet.getDimY()+100 o.imageSet.getDimX() o.imageSet.getDimY()]);
            
            
            
            
            
        end
        
        function onReplot(o)
            if ~isempty(o.imageSet)
                %o.plot = imagesc(o.imageSet.getImage(o.userInput.(o.indexName)).matrix(), 'Parent', o.axes);
                o.plot = imagesc(o.imageSet.getImage(o.imageindex).matrix(), 'Parent', o.axes);
                if o.showColorbar
                    colorbar('location','southoutside');
                end
                
                set(o.axes,...
                    'DataAspectRatio', [1 1 1],...
                    'OuterPosition', [0, 0, 1, 1],...
                    'Position', [0.0, 0.0, 1, 0.95]);
                %'Position', [0.025, 0.025, 0.95, 0.95]);
                axis(o.axes, 'off');
                set(o.axes,'LooseInset',get(o.axes,'TightInset'))
                o.updateTitle();
                
                % Colormap
                if o.useIndividualScale
                    if o.useQuantileScale
                        for iImage=1:o.imageSet.getNImages()
                            o.clims(iImage,:) =  o.imageSet.getImage(iImage).get_quantile_scale(o.pQuantile);
                            %o.clims(iImage,:) =  [0,1.0];
                        end
                    end
                else
                    if o.useQuantileScale
                        o.clims =  o.imageSet.get_quantile_scale_indv_shots(o.pQuantile);
                        %o.clims(iImage,:) =  [0,1.0];
                    end
                end
                
                % Pixel Select
                if o.allowPixelSelect
                    [y, x] = ind2sub(o.imageSet.getDim(),o.userInput.currentPixel);
                    o.pointer = impoint(o.axes, x, y,...
                        'PositionConstraintFcn', makeConstrainToRectFcn('impoint',get(o.axes,'XLim'),get(o.axes,'YLim')));
                    o.pointer.addNewPositionCallback(@o.onPointerChanged);
                    o.pointer.setColor('black');
                    addlistener(o.userInput, 'currentPixel', 'PostSet', @o.onCurrentPixelChange);
                end
                o.onRedraw();
            else
                o.axes.Visible = 'off';
            end
            
        end
        
        function onRedraw(o)
            if o.useIndividualScale
                %set(o.axes, 'CLim', o.clims(o.userInput.(o.indexName),:));
            else
                set(o.axes, 'CLim', o.clims);
            end
            %set(o.plot ,'CData',o.imageSet.getImage(o.userInput.(o.indexName)).matrix());
            set(o.plot ,'CData',o.imageSet.getImage(o.imageindex).matrix());
            %set(o.axes,'children',flipud(get(o.axes,'children')));
            o.updateTitle();
        end
        
        function updateTitle(o)
            if isempty(o.imageNames)
                %title(o.axes, sprintf('Image#: \t %d of %d', o.userInput.(o.indexName), o.imageSet.nImages));
                title(o.axes, sprintf('Image#: \t %d of %d', o.imageindex, o.imageSet.nImages));
            else
                title(o.axes, ['Frequency: ' num2str(o.imageNames(o.userInput.(o.indexName))) ' Hz']);
                %title(o.axes, sprintf('Image#: \t %d', o.imageNames.(o.indexName)));
            end
        end
        
        function onPointerChanged(o, p)
            p = round(p);
            o.pointSelfSetting = true;
            o.userInput.currentPixel = sub2ind(o.imageSet.getDim(), p(2), p(1));
            o.pointSelfSetting = false;
        end
        
        function onCurrentPixelChange(o, eventSrc, eventData)
            if ~o.pointSelfSetting
                [y, x] = ind2sub(o.imageSet.getDim(),o.userInput.currentPixel);
                setPosition(o.pointer, x,y);
            end
        end
        
        % function onClose(o)
        %
        % end
        
        
        function forceUnscaled(o)
            xmargin = 10;
            ymargin = 10;
            barheight =150;
            set(o.axes, 'Units', 'pixels');
            set(o.axes, 'Position', [xmargin ymargin+barheight o.imageSet.getDimX o.imageSet.getDimY()]);
        end
        
        function update_clims(o)
            if o.useQuantileScale
                o.clims=o.imageSet.get_quantile_scale_indv_shots(o.pQuantile);
                o.clims=[-0.5,0.7];
            end
            set(o.axes, 'CLim', o.clims)
        end
    end
    
end

