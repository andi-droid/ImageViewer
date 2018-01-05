classdef NondefringedFigure < BaseFigure
    
    % @todo implement emptiness of ImageSets
    properties
        imageSet
        userInput
        clims
        
        c
        atoms
        refs
        refs_defringed
        
        roiRect
        atomRect
        r_roi = [138,39,829,462]
        r_atoms = [247,68,238,423]
%         r_roi = [181,39,394,462]
%         r_atoms = [247,68,238,395]
        pushupdate
        pushsave
        
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
        function o = NondefringedFigure(varargin)
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
        
        function onUpdateODImageset(o,hobj,data)
            o.imageSet = OD_ImageSet(o.compositor.imagesetref, o.compositor.imagesetabs);
            o.imageSet.populate();
            o.linkMouseWheelToIndex();
            o.imageindex = 1;
            o.onReplot();
            o.onUpdatePush();
            
        end
        
        function onUpdatePush(o, hoect, eventdata, handles)
            set(o.pushupdate,'BackgroundColor', 'red');
            drawnow();
            
            o.atoms = MaskedImageSet(o.compositor.imagesetabs);
            o.refs = MaskedImageSet(o.compositor.imagesetref);
            o.r_roi = round(o.roiRect.getPosition());
            o.r_atoms = round(o.atomRect.getPosition());
            o.c = zeros(o.atoms.nImages);
            
            
            o.updateDependentDataSets();
            
%             o.cViewer.coefficients = o.c;
%             o.cViewer.replot();
%             o.replot();
            
%             %quick and dirty -> handle to handle?
%             o.odViewerDefringed.imageSet = o.odISdefringed;
%             %o.odViewer.imageSet = o.odISdefringed;
%             o.odViewer.imageSet = o.odIS;
            o.compositor.imagesetdef = [];
            o.compositor.imagesetdef = o.refs_defringed;
            
            set(o.pushupdate,'BackgroundColor', 'default');
            drawnow();
            notify(o.compositor,'updateDefringedImageSet');
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
        
%         function handleMouseWheel(o, hoect, eventdata, handles)
%             if eventdata.VerticalScrollCount < 0
%                 o.onNextShot();
%             else
%                 o.onPreviousShot();
%             end
%         end
        
        % image change
        function onNextShot(o)
            o.userInput.(o.indexName) = min(o.userInput.(o.indexName)+1, o.imageSet.getNImages());
        end
        function onPreviousShot(o)
            o.userInput.(o.indexName) = max(o.userInput.(o.indexName)-1, 1);
        end
        
         function onSavePush(o,~,~)
            r_roi = o.r_roi;
            r_atoms = o.r_atoms;
            save('../Preparation/roi_defringing.mat','r_roi','r_atoms');
        end
        
        
         function updateDependentDataSets(o)
            % updated mask
            atomsMask = o.atoms.maskFromRect(o.r_atoms);
            mask = o.atoms.maskFromRect(o.r_roi) &...
                ~atomsMask;
            o.atoms.applyMask(mask);
            o.refs.applyMask(mask);
            
            % defringe
            o.refs_defringed = copy(o.refs);
            o.c = AnalysisFramework.defringe(o.refs_defringed, o.atoms);
            
%             nImages = o.atomsO.getNImages();
%             
%             
%             o.correction = NaN(nImages,1);
%             o.blackAtoms = false(nImages,1);
%             o.blackRefs = false(nImages,1);
%             o.atomSTD = NaN(nImages,1);
%             o.referenceSTD = NaN(nImages,1);
%             %Raw images
%             for iImage=1:nImages
%                 mAtoms  = o.atomsO.getImage(iImage).matrix();
%                 mRefsO  = o.refsO.getImage(iImage).matrix();
%                 % exposure correction
%                 exposureAtoms = sum(sum(mAtoms.*mask));
%                 exposureReferences = sum(sum(mRefsO.*mask));
%                 o.correction(iImage) = exposureAtoms/exposureReferences;
%                 % find black images
%                 o.blackAtoms(iImage) = sum(mAtoms(:)) < 1;
%                 o.blackRefs(iImage) = sum(mRefsO(:)) < 1;
%                 % find noise images
%                 o.atomSTD(iImage) = std(mAtoms(:));
%                 o.referenceSTD(iImage) =std(mRefsO(:));
%             end
            
            % OD Images
%             o.atomCount = NaN(nImages,1);
%             o.atomCountDefringed = NaN(nImages,1);
            
%             o.odIS = OD_ImageSet(o.refsO, o.atomsO, o.correction);
%             o.odIS.populate();
%             o.odISdefringed = OD_ImageSet(o.refs_defringed, o.atoms);
%             o.odISdefringed.populate();
%             for iImage = 1:nImages
%                 o.atomCount(iImage) = sum(sum(o.odIS.getImage(iImage).matrix().*atomsMask)) *  (13E-6^2/2.02^2) * 2 * pi / (3*766.700674872e-9^2);
%                 o.atomCountDefringed(iImage) = sum(sum(o.odISdefringed.getImage(iImage).matrix().*atomsMask)) *  (13E-6^2/2.02^2) * 2 * pi / (3*766.700674872e-9^2);
%             end
         end
        
         function linkMouseWheelToIndex(o)
            function handleMouseWheel( ~, eventdata, ~)
                if eventdata.VerticalScrollCount < 0
                    if o.imageindex < o.imageSet.nImages
                    o.imageindex = o.imageindex +1;
                    o.onRedraw();
                    notify(o.compositor,'indexup')
                    end
                else
                    if o.imageindex > 1
                    o.imageindex = o.imageindex -1;
                    notify(o.compositor,'indexdown')
                    o.onRedraw();
                    end
                end
            end
            set(o.figure, 'WindowScrollWheelFcn', @handleMouseWheel);
        end
        
        
        % implementing BaseFigure
        function onCreate(o)
                C = get(0, 'DefaultUIControlBackgroundColor');
                set(o.figure, 'Color', C)
%             addlistener(o.userInput, o.indexName, 'PostSet', @o.onCurrentImageNoChange);
            addlistener(o.compositor,'updateODImageset', @o.onUpdateODImageset);
%             % add listeners for changing current image
%             set(o.figure, 'WindowScrollWheelFcn', @o.handleMouseWheel,...
%                 'KeyPressFcn', @o.handleKeyboardInput,...%'DeleteFcn', @o.onClose,...
%                 'Position', [10 o.imageSet.getDimY()+100 o.imageSet.getDimX() o.imageSet.getDimY()]);

%             o.roiRect = imrect(o.axes, o.r_roi,...
%                 'PositionConstraintFcn', makeConstrainToRectFcn('imrect',get(o.axes,'XLim'),get(o.axes,'YLim')));
%             
%             o.atomRect = imrect(o.axes, o.r_atoms,...
%                 'PositionConstraintFcn', makeConstrainToRectFcn('imrect',get(o.axes,'XLim'),get(o.axes,'YLim')));
%             setColor(o.atomRect,'r');

            o.pushupdate = uicontrol('Style','pushbutton',...
                'Units', 'normalized',...
                'String',{'Defringe'},...
                'Position',[0.4 0.0 0.3 0.1],...
                'Visible','on',...
                'Callback', @o.onUpdatePush);
            
            o.pushsave = uicontrol('Style','pushbutton',...
                'Units', 'normalized',...
                'String',{'Save Rects'},...
                'Position',[0.8 0.0 0.2 0.1],...
                'Visible','on',...
                'Callback', @o.onSavePush);



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
            if ~isempty(o.imageSet)
            o.roiRect = imrect(o.axes, o.r_roi,...
                'PositionConstraintFcn', makeConstrainToRectFcn('imrect',[1 1024],[1 512]));
            
            o.atomRect = imrect(o.axes, o.r_atoms,...
                'PositionConstraintFcn', makeConstrainToRectFcn('imrect',[1 1024],[1 512]));
            setColor(o.atomRect,'r');
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
                %title(o.axes, ['Frequency: ' num2str(o.imageNames(o.userInput.(o.indexName))) ' Hz']);
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
            end
            set(o.axes, 'CLim', o.clims)
        end
    end
    
end

