classdef FilePickerFigure < BaseFigure
    properties
        %GUI elements
        todaybtn
        listbox
        changedirbtn
        showlastbtn
        checkboxdefringed
        checkboxexposure        
        currentfolder
        protocolbtn
        togglerunning
        toggleanalysis
        toggledefringe
        pushanalysis
        pushdefringe
        seldata1
        seldata2
        seldatadefringe1
        seldatadefringe2
        text
        textdefringe
        status
        daydownbtn
        dayupbtn 
        
        % Data  
        imagepackage
        imagepackagecropped
        protocolpackage
        
        %Helper
        filenamesabs
        filenames
        dayupstr
        daydownstr
        datestring
        t1
        tb
        indeximage
        selectedIDs
        selectedIDsDefringe
        exposurecorrection = 1





    end
    
    methods
        % constructor
        function o = FilePickerFigure()
            
        end
        
        % callbacks
        function o = onSelectionChange(o, source,callbackdata)
            if o.listbox.Max == 1
            o.compositor.plotfitdatax = [];
            o.compositor.plotfitdatay = [];
            o.compositor.currentabsorptionimage = o.filenamesabs{o.indeximage(source.Value)};
            if strcmp(o.compositor.currentabsorptionimage(12),'3')
                camerabefore = o.compositor.cameraID;
                o.compositor.cameraID = '3';
            else
                camerabefore = o.compositor.cameraID;
                o.compositor.cameraID = '0';
            end
            o.compositor.camerachange = ~(strcmp(camerabefore,o.compositor.cameraID));
            if o.compositor.camerachange
                o.compositor.camera = Camera(o.compositor.cameraID,o.compositor.species);
            end
            expression = 'atoms';
            replaceref = 'noatoms';
            replacedef = 'def';
            o.compositor.currentreferenceimage = regexprep(o.compositor.currentabsorptionimage,expression,replaceref);
            error = true;
            while(error)
                try
                    pathabs = fullfile([o.compositor.imageDirectory '/' o.compositor.currentabsorptionimage]);
                    pathref = fullfile([o.compositor.imageDirectory '/' o.compositor.currentreferenceimage]);
                    o.compositor.absorptionimage = imread(pathabs);
                    o.compositor.referenceimage = imread(pathref);
                    ref = double(o.compositor.referenceimage);
                    abs = double(o.compositor.absorptionimage);
                    testref = ref(100:400,:);
                    rowsumtestref = sum(testref,2);
                    indexvector = find(rowsumtestref ==0);
                    testabs = abs(100:400,:);
                    rowsumtestabs = sum(testabs,2);
                    indexvector2 = find(rowsumtestabs ==0);
                    if (isempty(indexvector) & isempty(indexvector2)) %sometimes there are ref images which seem to be loaded incompletely
                        error = false;
                    else
                        error = true;
                    end 
                catch
                    pause(2)
                end

            end

            o.compositor.absmaxcounts = max(max((abs)));
            o.compositor.refmaxcounts = max(max((ref)));
            
            
            
            if o.checkboxdefringed.Value == 1
                o.compositor.currentdefringedimage = regexprep(o.compositor.currentabsorptionimage,expression,replacedef);
                pathdef = fullfile([o.compositor.imageDirectory '/' o.compositor.currentdefringedimage]);
                
                error = true;
                countvariable = 0;
                while error
                    try
                        o.compositor.defringedimage = imread(pathdef);
                        error = false;
                    catch
                        if o.togglerunning.Value == 0
                            o.compositor.defringedimage =imread(pathref);
                            errordlg('Defringed image not found. Displaying non-defringed image instead...');
                            error = false;
                        else
                            pause(2);
                            countvariable = countvariable+1;
                            if countvariable > 100
                                o.compositor.defringedimage =imread(pathref);
                                error = false;
                            end
                        end
                        
                    end
                end
                def = double(o.compositor.defringedimage);
                
                o.compositor.image = od(def,abs);

            else
                if o.exposurecorrection
                    atomsroi = o.compositor.defringeatoms;
                    roi = o.compositor.defringeroi;
                    mask = false(size(abs));
                    mask(atomsroi(2):(atomsroi(2)+atomsroi(4)-1),atomsroi(1):(atomsroi(1)+atomsroi(3)-1)) = true;
                    atomsMask = mask;
                    clear('mask');
                    mask = false(size(abs));
                    mask(roi(2):(roi(2)+roi(4)-1),roi(1):(roi(1)+roi(3)-1)) = true;
                    mask = mask &...
                        ~atomsMask;
                    
                    exposureAtoms = sum(sum(abs.*mask));
                    exposureReferences = sum(sum(ref.*mask));
                    correction = exposureAtoms/exposureReferences;
                    ref = ref *correction;
                    o.compositor.image = od(ref,abs);
                else
                o.compositor.image = od(ref,abs);
                end
            end
            
            datestring = o.compositor.imageDirectory(end-22:end);
            datestringreduced = datestring(end-9:end);
            path = [o.compositor.camera.protocolpath datestring '/' datestringreduced '_' o.compositor.currentabsorptionimage(14:17) '_t_proto.dat'];
            o.compositor.currentprotocol = path;
            
%             if o.compositor.loadprotocol
%                 o.onCheckboxprotocolUpdate(o.checkboxprotocol);
%             end
            
            
            
            switchroi = false;
            try
                o.compositor.croppedimage = o.compositor.image(o.compositor.roi(2):(o.compositor.roi(4)+o.compositor.roi(2)),o.compositor.roi(1):(o.compositor.roi(3)+o.compositor.roi(1)));
            catch
                switchroi = true;
                o.compositor.roi = [220    100   350   300];
                o.compositor.croppedimage = o.compositor.image(o.compositor.roi(2):(o.compositor.roi(4)+o.compositor.roi(2)),o.compositor.roi(1):(o.compositor.roi(3)+o.compositor.roi(1)));
            end
            o.compositor.datacroppedx = sum(o.compositor.croppedimage,1);
            o.compositor.datacroppedy = sum(o.compositor.croppedimage,2);
            croppedimagemaxcounts = max(max((o.compositor.croppedimage)));
            croppedimagemincounts = min(min((o.compositor.croppedimage)));
            o.compositor.croppedcontrast = croppedimagemaxcounts-croppedimagemincounts;
            o.compositor.datax = sum(o.compositor.image,1);
            o.compositor.datay = sum(o.compositor.image,2);
            
            o.compositor.cutOD = o.compositor.croppedimage(floor(o.compositor.roi(4)/2),:);
            
            if o.compositor.fitbuttonstate
                notify(o.compositor,'doFit');
            end
         
         
            notify(o.compositor, 'updateData');
            
            if o.compositor.camerachange
                notify(o.compositor, 'updateAxes');
            end
            
            if switchroi
                notify(o.compositor, 'updateDataAndResolution');
            end
            else
            o.selectedIDs = [];
            o.selectedIDs = o.listbox.String(o.listbox.Value);

            set(o.seldata1, 'String',o.selectedIDs{1});
            set(o.seldata2, 'String',o.selectedIDs{end});
                
            end
            
            function res = od(r,a)
                
                ISat = o.compositor.camera.ISat;
                E_Photon = o.compositor.camera.E_Photon;
                PixSize = o.compositor.camera.PixSize;
                Vergr   = o.compositor.camera.magnification;
                C_F = o.compositor.camera.C_F;
                TE = o.compositor.camera.TE;
                t_Bel = o.compositor.camera.t_Bel;
                QE = o.compositor.camera.QE;
                CountToInt = o.compositor.camera.CountToInt;
                
                res  = reallog(max(0.001,r./max(0.001,a))) + (r-a).*CountToInt/ISat;
            end
        end
        
        function updateParameters(o)
            a = dir([o.compositor.imageDirectory '/*_atoms.tif']);
            o.filenames = [];
            o.listbox.String = o.filenames;
            o.filenamesabs = {a.name};
            if ~isempty(o.filenamesabs)
                for i = 1:numel(o.filenamesabs)
                    o.filenames{i} = o.filenamesabs{i}(14:17);
                    
                end
            end
            [o.listbox.String,o.indeximage] = sort(o.filenames);
        end
        
        
        function onChangeDirectory(o,hsource,data)
            if o.togglerunning.Value == 1
            o.togglerunning.Value = 0;
            o.onTogglerunningUpdate(o.togglerunning);
            end
            tempimagedirectory = o.compositor.imageDirectory;
            o.compositor.imageDirectory = uigetdir(o.compositor.camera.imageDirectoryNode);


            try            
                o.updateParameters();
                o.listbox.Value = 1;
                o.onSelectionChange(o.listbox);
            catch
                o.compositor.imageDirectory = tempimagedirectory;
                o.updateParameters();
                o.listbox.Value = 1;
                o.onSelectionChange(o.listbox);
                errordlg('Error selecting directory. Try again')
            end
        end
        
        function onCheckboxdefringedUpdate(o,hsource,data)
            o.onSelectionChange(o.listbox);
        end
        
        function onCheckboxExposureUpdate(o,hsource,data)
            if hsource.Value ==1
                o.exposurecorrection = 1;
            else
                o.exposurecorrection = 0;
            end
            o.onSelectionChange(o.listbox);
        end
        
        function onProtocolPush(o,hsource,data)
            if ispc
                system(['notepad ' o.compositor.currentprotocol]);
            elseif isunix
                system(['gedit ' o.compositor.currentprotocol]);
            else
                disp('Implement for your OS in FilePickerFigure.m!')
            end
        end
        
        function onTogglerunningUpdate(o,hsource,data)
            if o.togglerunning.Value == 1
                o.listbox.Max = 1;
                o.togglerunning.BackgroundColor = [0,1,0];
                o.toggleanalysis.Value = 0;
                o.onToggleanalysisUpdate(o.toggleanalysis);
                o.onTodayBtnPush();
                o.onShowLastBtnPush();
                period = 1;
                dirLength = length(dir(o.compositor.imageDirectory));
                if o.checkboxdefringed.Value == 1
                    a = dir([o.compositor.imageDirectory '/*_def.tif']);
                else
                    a = dir([o.compositor.imageDirectory '/*_atoms.tif']);
                end
                filenames = {a.name};
                listlength = numel(filenames);
                o.compositor.timerobj = timer('TimerFcn', {@o.timerCallback,o.compositor.imageDirectory,dirLength,listlength}, 'Period', period, 'executionmode', 'fixedrate');;
                o.t1 = clock;
                start(o.compositor.timerobj);
            else
                o.togglerunning.BackgroundColor = [1,0,0];
                stop(o.compositor.timerobj);
                delete(o.compositor.timerobj);
                
            end
        end
        
        function onShowLastBtnPush(o,hsource,data)

            numberofelements = numel(o.listbox.String);
            o.listbox.Value = numberofelements;
            o.onSelectionChange(o.listbox);

        end
        
         function onToggleanalysisUpdate(o,hsource,data)
            if o.toggleanalysis.Value == 1
                if o.togglerunning.Value == 1
                o.togglerunning.Value = 0;
                o.onTogglerunningUpdate(o.togglerunning);
                end
                o.toggleanalysis.BackgroundColor = [0,1,0];
                o.pushanalysis.Visible = 'on';
                o.seldata1.Visible = 'on';
                o.seldata2.Visible = 'on';
                o.text.Visible = 'on';
                o.status.Visible = 'on';
                o.listbox.Max = 5000;
                dirLength = length(dir(o.compositor.imageDirectory));
                if o.checkboxdefringed.Value == 1
                    a = dir([o.compositor.imageDirectory '/*_def.tif']);
                else
                    a = dir([o.compositor.imageDirectory '/*_atoms.tif']);
                end
                filenames = {a.name};
                listlength = numel(filenames);
            else
                C = get(0, 'DefaultUIControlBackgroundColor');
                set(hsource, 'BackgroundColor', C);
                o.listbox.Max = 1;
                o.pushanalysis.Visible = 'off';
                o.seldata1.Visible = 'off';
                o.seldata2.Visible = 'off';
                o.text.Visible = 'off';
                o.status.Visible = 'off';
                
            end
         end
         
         function onToggledefringeUpdate(o,hsource,data)
            if o.toggledefringe.Value == 1
                if o.togglerunning.Value == 1
                o.togglerunning.Value = 0;
                o.onTogglerunningUpdate(o.togglerunning);
                end
                o.toggledefringe.BackgroundColor = [0,1,0];
                o.pushdefringe.Visible = 'on';
                o.seldatadefringe1.Visible = 'on';
                o.seldatadefringe2.Visible = 'on';
                o.textdefringe.Visible = 'on';
                o.listbox.Max = 7000;
                dirLength = length(dir(o.compositor.imageDirectory));
                a = dir([o.compositor.imageDirectory '/*_atoms.tif']);
                filenames = {a.name};
                listlength = numel(filenames);
            else
                C = get(0, 'DefaultUIControlBackgroundColor');
                set(hsource, 'BackgroundColor', C);
                o.listbox.Max = 1;
                o.pushdefringe.Visible = 'off';
                o.seldatadefringe1.Visible = 'off';
                o.seldatadefringe2.Visible = 'off';
                o.textdefringe.Visible = 'off';
                
            end
         end
        
         function onReadDataPush(o,hsource,data)

%             o.selectedIDs = [];
%             o.selectedIDs = o.listbox.String(o.listbox.Value);
% 
%             set(o.seldata1, 'String',o.selectedIDs{1});
%             set(o.seldata2, 'String',o.selectedIDs{end});
            o.selectedIDs = [];
            o.compositor.imagepackagecropped = [];
            o.compositor.imagepackage = [];
            o.compositor.protocolpackage = [];
            start = str2double(o.seldata1.String);
            stop = str2double(o.seldata2.String);
            range = [];
            range(1:numel(o.filenames)) = 0;
            range(start:stop) = 1;
            range = logical(range);
            o.selectedIDs = o.listbox.String(range);
            IDrange = start:stop;
            o.compositor.selectedIDs = IDrange;
            o.readoutData(range);
            
         end
        
         function onDefringePush(o,hsource,data)

%             o.selectedIDs = [];
%             o.selectedIDs = o.listbox.String(o.listbox.Value);
% 
%             set(o.seldata1, 'String',o.selectedIDs{1});
%             set(o.seldata2, 'String',o.selectedIDs{end});
            o.selectedIDsDefringe = [];
            start = str2double(o.seldatadefringe1.String);
            stop = str2double(o.seldatadefringe2.String);
            range = [];
            range(1:numel(o.filenames)) = 0;
            range(start:stop) = 1;
            range = logical(range);
            o.selectedIDsDefringe = o.listbox.String(range);
            IDrange = start:stop;
            o.compositor.selectedIDsDefringe = IDrange;
            o.readoutDataDefringe(range);
            
        end
        
        function onTodayBtnPush(o,hsource,data)

            formatdate = 'yyyy_mm_dd';
            today = datestr(now,formatdate);
            year = [o.compositor.camera.basepath today(1:4) '/'];
            month = [year today(1:7) '/'];
            day = [month today];
            o.compositor.imageDirectory = day;
            o.updateParameters();
            o.listbox.Value = 1;
            o.onSelectionChange(o.listbox);
            
        end
        
        
        function onDayupBtnPush(o,hsource,data)
            if o.togglerunning.Value == 0
            formatdate = 'yyyy_mm_dd';
            actualday = o.compositor.currentabsorptionimage(1:10);
            actualdate = datenum(actualday,formatdate);
            dayup = actualdate+1;
            o.dayupstr = datestr(dayup,formatdate);
            o.compositor.imageDirectory(end-9:end) = o.dayupstr;
            o.compositor.imageDirectory(end-17:end-11) = o.dayupstr(1:7);
            o.compositor.imageDirectory(end-22:end-19) = o.dayupstr(1:4);
            try
                o.updateParameters();
                o.listbox.Value = 1;
                o.onSelectionChange(o.listbox);
            catch
                o.onTodayBtnPush();
                errordlg('This is the latest folder.');
            end
            else
                errordlg('This is the latest folder.');
            end
        end
        

        
        function onDaydownBtnPush(o,hsource,data)
            if o.togglerunning.Value == 0
            formatdate = 'yyyy_mm_dd';
            actualday = o.compositor.currentabsorptionimage(1:10);
            actualdate = datenum(actualday,formatdate);
            daydown = actualdate-1;
            o.daydownstr = datestr(daydown,formatdate);
            o.compositor.imageDirectory(end-9:end) = o.daydownstr;
            o.compositor.imageDirectory(end-17:end-11) = o.daydownstr(1:7);
            o.compositor.imageDirectory(end-22:end-19) = o.daydownstr(1:4);
            o.updateParameters();
            o.listbox.Value = 1;
            o.onSelectionChange(o.listbox);
            else
                errordlg('First deactivate Contiuous Mode')
            end
            
        end
        
        
        function timerCallback(o, src, eventdata,dirName,dirLength,listlength)
            t2 = clock;
            t12 = etime(t2,o.t1);
            set(o.tb,'String',[num2str(round(t12)) ' s']);
            drawnow
            if t12 < 80
                set(o.tb,'BackgroundColor',[0,1,0]);
            else
                set(o.tb,'BackgroundColor',[1,0,0]);
            end
            formatdate = 'yyyy_mm_dd';
            today = datestr(now,formatdate);
            year = [o.compositor.camera.basepath today(1:4) '/'];
            month = [year today(1:7) '/'];
            day = [month today];
            if o.checkboxdefringed.Value == 1
                a = dir([o.compositor.imageDirectory '/*_def.tif']);
            else
                a = dir([o.compositor.imageDirectory '/*_atoms.tif']);
            end
            filenames = {a.name};
            listlengthnew = numel(filenames);
            persistent dirSize;
            persistent beginFlag;
            if isempty(beginFlag)
                %dirSize = dirLength;
                dirSize = listlength;
                beginFlag = 0;
            end
            %if length(dir(dirName)) > dirSize
            if listlengthnew > dirSize
                t3 = clock;
                o.compositor.telapsed = etime(t3,o.t1);
                o.t1 = clock;
                %disp('A new file is available')
                %tic;
                %dirSize = length(dir(dirName));
                dirSize = listlengthnew;
                o.listbox.String = o.filenames;
                o.updateParameters();
                numberofelements = numel(o.listbox.String);
                o.listbox.Value = numberofelements;
                o.onSelectionChange(o.listbox);
            end
            if strcmp(o.compositor.imageDirectory,day) == false
                pause(60);
                beginFlag = [];
                dirSize =[];
                o.togglerunning.Value = 0;
                o.onTogglerunningUpdate(o.togglerunning);
                pause(4);
                error = true;
                while error
                    try
                        o.onTodayBtnPush(o.todaybtn);
                        error = false;
                    catch
                        pause(60)
                        error = false;
                    end
                end
                pause(4);
                o.togglerunning.Value = 1;
                o.onTogglerunningUpdate(o.togglerunning);
            end
        end
        
        function onEnterValue(o,source,data)

        end
        
        function onEnterValuedefringe(o,source,data)

        end
        
        function readoutData(o,indexselection)
            expression = 'atoms';
            replaceref = 'noatoms';
            replacedef = 'def';
            o.imagepackage = zeros(numel(o.selectedIDs),size(o.compositor.absorptionimage,2),size(o.compositor.absorptionimage,1));
            o.imagepackagecropped = zeros(numel(o.selectedIDs),size(o.compositor.croppedimage,2),size(o.compositor.croppedimage,1));
            o.protocolpackage = cell(numel(o.selectedIDs));
            o.imagepackage = [];
            o.imagepackagecropped = [];
            o.protocolpackage = {};
            datestring = o.compositor.imageDirectory(end-22:end);
            datestringreduced = datestring(end-9:end);
            
            selectedfilenamesabs = o.filenamesabs(indexselection);
            
            selectedfilenamesref = regexprep(selectedfilenamesabs,expression,replaceref);
            selectedfilenamesdef = regexprep(selectedfilenamesabs,expression,replacedef);
            position = [0.7 0.6 0.3 0.1];
            h = uiwaitbar(position);
            for i = 1:numel(o.selectedIDs)
                    name = selectedfilenamesabs{i};
                    protocol = load([o.compositor.camera.protocolpath datestring '/mat/' datestringreduced '_' name(14:17) '_t_proto.mat']);
                    pathabs = fullfile([o.compositor.imageDirectory '/' selectedfilenamesabs{i}]);
                    pathref = fullfile([o.compositor.imageDirectory '/' selectedfilenamesref{i}]);
                    error = true;
                    while(error)
                    if o.checkboxdefringed.Value == 1
                        pathdef = fullfile([o.compositor.imageDirectory '/' selectedfilenamesdef{i}]);
                        def = double(imread(pathdef));
                        abs = double(imread(pathabs));
                        testref = def(100:400,:);
                        rowsumtestref = sum(testref,2);
                        indexvector = find(rowsumtestref ==0);
                         testabs = abs(100:400,:);
                    rowsumtestabs = sum(testabs,2);
                    indexvector2 = find(rowsumtestabs ==0);
                        if (isempty(indexvector) & isempty(indexvector2))%sometimes there are ref images which seem to be loaded incompletely
                            error = false;
                        else
                            error = true;
                        end 
                        image = od(def,abs);
                    else
                        abs = double(imread(pathabs));
                        ref = double(imread(pathref));
                        testref = ref(100:400,:);
                        rowsumtestref = sum(testref,2);
                        indexvector = find(rowsumtestref ==0);
                                                 testabs = abs(100:400,:);
                    rowsumtestabs = sum(testabs,2);
                    indexvector2 = find(rowsumtestabs ==0);
                        if (isempty(indexvector) & isempty(indexvector2)) %sometimes there are ref images which seem to be loaded incompletely
                            error = false;
                        else
                            error = true;
                        end 
                        image = od(ref,abs);
                    end
                    end
                    croppedimage = image(o.compositor.roi(2):(o.compositor.roi(4)+o.compositor.roi(2)),o.compositor.roi(1):(o.compositor.roi(3)+o.compositor.roi(1)));
                    o.compositor.imagepackage(i,:,:) = image;
                    o.compositor.imagepackagecropped(i,:,:) = croppedimage;
                    o.compositor.protocolpackage{i} = protocol;
                    status = i/numel(o.selectedIDs);
                    uiwaitbar(h,status);
                    drawnow
            end
            
            notify(o.compositor,'updateImagePackage');
            notify(o.compositor,'updateAnalysisFigure');
            delete(h)
            
            function res = od(r,a)
                
                ISat = o.compositor.camera.ISat;
                E_Photon = o.compositor.camera.E_Photon;
                PixSize = o.compositor.camera.PixSize;
                Vergr   = o.compositor.camera.magnification;
                C_F = o.compositor.camera.C_F;
                TE = o.compositor.camera.TE;
                t_Bel = o.compositor.camera.t_Bel;
                QE = o.compositor.camera.QE;
                CountToInt = o.compositor.camera.CountToInt;
                
                res  = reallog(max(0.001,r./max(0.001,a))) + (r-a).*CountToInt/ISat;
            end
        end
        
        function readoutDataDefringe(o,indexselection)
            expression = 'atoms';
            replaceref = 'noatoms';
            replacedef = 'def';
            datestring = o.compositor.imageDirectory(end-22:end);
            datestringreduced = datestring(end-9:end);
            
            selectedfilenamesabs = o.filenamesabs(indexselection);
            
            selectedfilenamesref = regexprep(selectedfilenamesabs,expression,replaceref);
            
            for i = 1:numel(o.selectedIDsDefringe)
                    name = selectedfilenamesabs{i};
                    pathabs{i} = fullfile([o.compositor.imageDirectory '/' selectedfilenamesabs{i}]);
                    pathref{i} = fullfile([o.compositor.imageDirectory '/' selectedfilenamesref{i}]);

            end
            
            o.compositor.imagesetabs = ImageSet.load(pathabs);
            o.compositor.imagesetref = ImageSet.load(pathref);
            
            notify(o.compositor,'updateODImageset');
%             notify(o.compositor,'updateAnalysisFigure');
            
        end
        
        function onCloseEvent(o,~,~)
            if isa(o.compositor.timerobj,'timer')
            delete(o.compositor.timerobj);
            end
            warning('off','MATLAB:timer:deleterunning');
            delete(gcf);
        end
        
        
        % implementing BaseFigure
        function onCreate(o)
                            C = get(0, 'DefaultUIControlBackgroundColor');
                set(o.figure, 'Color', C)
            set(o.figure,'CloseRequestFcn',@o.onCloseEvent);
            o.axes.Visible = 'off';
            o.listbox = uicontrol(o.figure, 'Style','ListBox', ...
                'Units', 'normalized',...
                'Position', [0.0 0.0 0.2 1.0],...
                'string', o.filenames,...
                'Callback', @o.onSelectionChange);
            
            o.changedirbtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Change Directory',...
                'Units', 'normalized',...
                'Position', [0.25 0.9 0.4 0.1],...
                'Callback', @o.onChangeDirectory);
            
            o.showlastbtn = uicontrol(o.figure, 'Style', 'pushbutton',...
                'String', 'Show last',...
                'Units', 'normalized',...
                'Position', [0.25 0.55 0.4 0.1],...
                'Callback', @o.onShowLastBtnPush);
            
            o.checkboxdefringed = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Show defringed'},...
                'Position',[0.25 0.30 0.4 0.1],...
                'Callback', @o.onCheckboxdefringedUpdate);
            
            o.checkboxexposure = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Exposure correction'},...
                'Value',o.exposurecorrection,...
                'Position',[0.25 0.20 0.4 0.1],...
                'Callback', @o.onCheckboxExposureUpdate);
            
            o.protocolbtn = uicontrol('Style','pushbutton',...
                'Units', 'normalized',...
                'String',{'Show Protocol'},...
                'Position',[0.25 0.4 0.4 0.1],...
                'Callback', @o.onProtocolPush);
            
            o.toggleanalysis = uicontrol('Style','togglebutton',...
                'Units', 'normalized',...
                'String',{'Analysis Mode'},...
                'Position',[0.7 0.9 0.3 0.1],...
                'Callback', @o.onToggleanalysisUpdate);
            
            o.toggledefringe = uicontrol('Style','togglebutton',...
                'Units', 'normalized',...
                'String',{'Defringe View Mode'},...
                'Position',[0.7 0.4 0.3 0.1],...
                'Callback', @o.onToggledefringeUpdate);
            
            o.pushanalysis = uicontrol('Style','pushbutton',...
                'Units', 'normalized',...
                'String',{'Read Data'},...
                'Position',[0.7 0.7 0.3 0.1],...
                'Visible','off',...
                'Callback', @o.onReadDataPush);
            
            o.pushdefringe = uicontrol('Style','pushbutton',...
                'Units', 'normalized',...
                'String',{'Update'},...
                'Position',[0.7 0.2 0.3 0.1],...
                'Visible','off',...
                'Callback', @o.onDefringePush);
            
            o.seldata1  = uicontrol('style','edit', 'Parent', o.figure,'Units', 'normalized','Visible','off', 'Position', [0.7 0.8 0.145 0.1]);
            o.seldata2  = uicontrol('style','edit', 'Parent', o.figure,'Units', 'normalized', 'Visible','off','Position', [0.855 0.8 0.145 0.1],'Callback',@o.onEnterValue);
            o.text  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized','Visible','off','String',':', 'Position', [0.845 0.8 0.01 0.1]);
            
            o.seldatadefringe1  = uicontrol('style','edit', 'Parent', o.figure,'Units', 'normalized','Visible','off', 'Position', [0.7 0.3 0.145 0.1]);
            o.seldatadefringe2  = uicontrol('style','edit', 'Parent', o.figure,'Units', 'normalized', 'Visible','off','Position', [0.855 0.3 0.145 0.1],'Callback',@o.onEnterValuedefringe);
            o.textdefringe  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized','Visible','off','String',':', 'Position', [0.845 0.3 0.01 0.1]);
            
            o.togglerunning = uicontrol('Style','togglebutton',...
                'Units', 'normalized',...
                'String',{'Continuous'},...
                'Position',[0.25 0.1 0.4 0.1],...
                'Callback', @o.onTogglerunningUpdate);
            
            o.todaybtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Today',...
                'Units', 'normalized',...
                'Position', [0.25 0.7 0.4 0.1],...
                'Callback', @o.onTodayBtnPush);
            
            o.dayupbtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Day +',...
                'Units', 'normalized',...
                'Position', [0.45 0.8 0.2 0.1],...
                'Callback', @o.onDayupBtnPush);
            
            o.daydownbtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Day -',...
                'Units', 'normalized',...
                'Position', [0.25 0.8 0.2 0.1],...
                'Callback', @o.onDaydownBtnPush);
            
            o.tb  = uicontrol('style','edit', 'Parent', o.figure,'Units', 'normalized', 'Position', [0.7 0.1 0.2 0.1]);
            
    
            
            
        end
        
        function onReplot(o)
            
        end
        
        function onRedraw(o)
            o.onReplot();
        end
        
    end
    
end
