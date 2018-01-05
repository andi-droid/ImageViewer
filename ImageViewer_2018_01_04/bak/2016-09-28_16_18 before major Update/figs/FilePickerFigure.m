classdef FilePickerFigure < BaseFigure
    properties
        currentfolder
        listbox
        filenamesabs
        filenames
        changedirbtn
        showlastbtn
        checkboxdefringed
        checkboxprotocol
        protocolbtn
        togglerunning
        todaybtn
        daydownbtn
        dayupbtn
        dayupstr
        daydownstr
        datestring
        radios
        tb
        t1
        basepath = '//afs/physnet.uni-hamburg.de/project/bfm/Daten/';
        protocolpath = '//afs/physnet.uni-hamburg.de/project/bfm/ExpProtocols/'
    end
    
    methods
        % constructor
        function o = FilePickerFigure()
            
        end
        
        % callbacks
        function o = onSelectionChange(o, source,callbackdata)
            o.compositor.plotfitdatax = [];
            o.compositor.plotfitdatay = [];
            o.compositor.currentabsorptionimage = o.filenamesabs{source.Value};
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
                    error=false;
                catch
                    pause(2)
                end
            end
            o.compositor.absmaxcounts = max(max((abs)));
            o.compositor.refmaxcounts = max(max((ref)));
            
            
            
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
                o.compositor.image = od(ref,abs);
            end
            
            datestring = o.compositor.imageDirectory(end-22:end);
            datestringreduced = datestring(end-9:end);
            path = [o.protocolpath datestring '/' datestringreduced '_' o.compositor.currentabsorptionimage(14:17) '_t_proto.dat'];
            o.compositor.currentprotocol = path;
            
            if o.compositor.loadprotocol
                o.onCheckboxprotocolUpdate(o.checkboxprotocol);
            end
            
            
            
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
                o.compositor.figures{4}.processFit();
            end
            
            if o.compositor.fitorcount
                
                if length(o.compositor.atomnumberhistory) < o.compositor.historylength
                    o.compositor.atomnumberhistory(end+1) = o.compositor.atomnumberfitmean;
                    o.compositor.idhistorynr(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
                else
                    o.compositor.atomnumberhistory = o.compositor.atomnumberhistory(2:end);
                    o.compositor.atomnumberhistory(end+1) = o.compositor.atomnumberfitmean;
                    o.compositor.idhistorynr = o.compositor.idhistorynr(2:end);
                    o.compositor.idhistorynr(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
                end
                
            else
                integral = sum(sum(o.compositor.croppedimage));
                if length(o.compositor.atomnumberhistory) < o.compositor.historylength
                    o.compositor.atomnumberhistory(end+1) = integral;
                    o.compositor.idhistorynr(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
                else
                    o.compositor.atomnumberhistory = o.compositor.atomnumberhistory(2:end);
                    o.compositor.atomnumberhistory(end+1) = integral;
                    o.compositor.idhistorynr = o.compositor.idhistorynr(2:end);
                    o.compositor.idhistorynr(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
                end
                
            end
            
            if o.compositor.fitormean
                
                if length(o.compositor.oscillationx) < o.compositor.oscillationlength
                    o.compositor.oscillationx(end+1) = o.compositor.fitdatax(3);
                    o.compositor.oscillationy(end+1) = o.compositor.fitdatay(3);
                    o.compositor.idhistoryos(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
                else
                    o.compositor.oscillationx = o.compositor.oscillationx(2:end);
                    o.compositor.oscillationx(end+1) = o.compositor.fitdatax(3);
                    o.compositor.oscillationy = o.compositor.oscillationy(2:end);
                    o.compositor.oscillationy(end+1) = o.compositor.fitdatay(3);
                    o.compositor.idhistoryos = o.compositor.idhistoryos(2:end);
                    o.compositor.idhistoryos(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
                end
                
            else
                
                x = 1:length(o.compositor.datacroppedx);
                y = 1:length(o.compositor.datacroppedy);
                centerofmassx = sum(o.compositor.datacroppedx.*x)/sum(o.compositor.datacroppedx);
                centerofmassy = sum(o.compositor.datacroppedy'.*y)/sum(o.compositor.datacroppedy);
                if length(o.compositor.oscillationx) < o.compositor.oscillationlength
                    o.compositor.oscillationx(end+1) = centerofmassx;
                    o.compositor.oscillationy(end+1) = centerofmassy;
                    o.compositor.idhistoryos(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
                else
                    o.compositor.oscillationx = o.compositor.oscillationx(2:end);
                    o.compositor.oscillationx(end+1) = centerofmassx;
                    o.compositor.oscillationy = o.compositor.oscillationy(2:end);
                    o.compositor.oscillationy(end+1) = centerofmassy;
                    o.compositor.idhistoryos = o.compositor.idhistoryos(2:end);
                    o.compositor.idhistoryos(end+1) = str2double(o.compositor.currentabsorptionimage(14:17));
                end
            end
            
            
            notify(o.compositor, 'updateData');
            if o.compositor.camerachange
                notify(o.compositor, 'updateAxes');
                %o.compositor.figures{2}.onReplot();
            end
            if switchroi
                notify(o.compositor, 'updateDataAndResolution');
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
            o.listbox.String = o.filenames;
        end
        
        
        function onChangeDirectory(o,hsource,data)
            o.compositor.imageDirectory = uigetdir('//afs/physnet.uni-hamburg.de/project/bfm/Daten/2016/');
            o.updateParameters();
            o.listbox.Value = 1;
            o.onSelectionChange(o.listbox);
        end
        
        function onCheckboxdefringedUpdate(o,hsource,data)
            o.onSelectionChange(o.listbox);
        end
        
        function onCheckboxprotocolUpdate(o,hsource,data)
            if hsource.Value ==1
                o.compositor.loadprotocol = true;
                datestring = o.compositor.imageDirectory(end-22:end);
                datestringreduced = datestring(end-9:end);
                path = [o.protocolpath datestring '/' datestringreduced '_' o.compositor.currentabsorptionimage(14:17) '_t_proto.dat'];
                currentprotocol = load([o.protocolpath datestring '/mat/' datestringreduced '_' o.compositor.currentabsorptionimage(14:17) '_t_proto.mat']);
                o.compositor.protocol = currentprotocol.p;
                o.compositor.currentprotocol = path;
            else
                o.compositor.loadprotocol = false;
                o.compositor.currentprotocol = [];
            end
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
                o.togglerunning.BackgroundColor = [0,1,0];
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
        
        function onTodayBtnPush(o,hsource,data)
            formatdate = 'yyyy_mm_dd';
            today = datestr(now,formatdate);
            year = [o.basepath today(1:4) '/'];
            month = [year today(1:7) '/'];
            day = [month today];
            o.compositor.imageDirectory = day;
            o.updateParameters();
            o.listbox.Value = 1;
            o.onSelectionChange(o.listbox);
            
        end
        
        function onDayupBtnPush(o,hsource,data)
            actualday = o.compositor.currentabsorptionimage(9:10);
            dayup = str2double(actualday)+1;
            if dayup <10
                o.dayupstr = ['0' num2str(dayup)];
            else
                o.dayupstr = num2str(dayup);
            end
            o.compositor.imageDirectory(end-1:end) = o.dayupstr;
            o.updateParameters();
            o.listbox.Value = 1;
            o.onSelectionChange(o.listbox);
            
        end
        
        function onDaydownBtnPush(o,hsource,data)
            actualday = o.compositor.currentabsorptionimage(9:10);
            daydown = str2double(actualday)-1;
            if daydown <10
                o.daydownstr = ['0' num2str(daydown)];
            else
                o.daydownstr = num2str(daydown);
            end
            o.compositor.imageDirectory(end-1:end) = o.daydownstr;
            o.updateParameters();
            o.listbox.Value = 1;
            o.onSelectionChange(o.listbox);
            
        end
        
        
        function timerCallback(o, src, eventdata,dirName,dirLength,listlength)
            t2 = clock;
            t12 = etime(t2,o.t1);
            set(o.tb,'String',[num2str(round(t12)) ' s']);
            if t12 < 80
                set(o.tb,'BackgroundColor',[0,1,0]);
            else
                set(o.tb,'BackgroundColor',[1,0,0]);
            end
            formatdate = 'yyyy_mm_dd';
            today = datestr(now,formatdate);
            year = [o.basepath today(1:4) '/'];
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
        
        
        % implementing BaseFigure
        function onCreate(o)
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
            
            o.showlastbtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Show last',...
                'Units', 'normalized',...
                'Position', [0.25 0.5 0.4 0.1],...
                'Callback', @o.onShowLastBtnPush);
            
            o.checkboxdefringed = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Show defringed'},...
                'Position',[0.25 0.35 0.4 0.1],...
                'Callback', @o.onCheckboxdefringedUpdate);
            
            o.checkboxprotocol = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Load Protocol'},...
                'Position',[0.25 0.25 0.4 0.1],...
                'Callback', @o.onCheckboxprotocolUpdate);
            
            o.protocolbtn = uicontrol('Style','pushbutton',...
                'Units', 'normalized',...
                'String',{'Show Protocol'},...
                'Position',[0.7 0.25 0.3 0.1],...
                'Callback', @o.onProtocolPush);
            
            o.togglerunning = uicontrol('Style','togglebutton',...
                'Units', 'normalized',...
                'String',{'Running...'},...
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
            
            
            %             radioLabels = {'PCO','Andor'};
            %             for iRadio=1:numel(radioLabels)
            %                 o.radios(iRadio) = uicontrol(o.figure, 'Style', 'radiobutton', ...
            %                     'Callback', {@o.onRadioClick, iRadio}, ...
            %                     'Units',    'normalized', ...
            %                     'Position', [0.7 (0.5+iRadio*0.2) 0.3 0.1], ...
            %                     'String',   radioLabels{iRadio}, ...
            %                     'Value',    iRadio==2);
            %             end
        end
        
        function onReplot(o)
            
        end
        
        function onRedraw(o)
            o.onReplot();
        end
        
    end
    
end
