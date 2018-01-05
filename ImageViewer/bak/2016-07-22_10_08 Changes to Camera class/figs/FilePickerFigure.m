classdef FilePickerFigure < PlainBaseFigure
    properties
        currentfolder
        listbox
        filenamesabs
        filenames
        changedirbtn
        showlastbtn
        checkboxdefringed
        checkboxrunning
        todaybtn
        daydownbtn
        dayupbtn
        dayupstr
        daydownstr
        radios
        tb
        t1
        basepath = '//afs/physnet.uni-hamburg.de/project/bfm/Daten/';
    end
    
    methods
        % constructor
        function o = FilePickerFigure()
            imagepath= '//afs/physnet.uni-hamburg.de/project/bfm/Daten/2016/2016_06/2016_06_05';
            a = dir([imagepath '/*_atoms.tif']);
            o.filenamesabs = {a.name};
            
            
            
        end
        
        % callbacks
        function o = onSelectionChange(o, source,callbackdata)
            o.compositor.plotfitdatax = [];
            o.compositor.plotfitdatay = [];
            o.compositor.currentabsorptionimage = o.filenamesabs{source.Value};
            if strcmp(o.compositor.currentabsorptionimage(12),'3')
                camerabefore = o.compositor.cameraID;
                o.compositor.cameraID = 'Andor';   
            else
                camerabefore = o.compositor.cameraID;
                o.compositor.cameraID = 'PCO';
            end
            o.compositor.camerachange = ~(strcmp(camerabefore,o.compositor.cameraID));
%             if o.compositor.camerachange
%             notify(o.compositor,'updateDataAndResolution');
%             end
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
                if strcmp(o.compositor.cameraID,'Andor')
                    cameraNr = 1;
                else
                    cameraNr = 2;
                end
                ISat = o.compositor.camera{cameraNr}.ISat;
                E_Photon = o.compositor.camera{cameraNr}.E_Photon;
                PixSize = o.compositor.camera{cameraNr}.PixSize;
                Vergr   = o.compositor.camera{cameraNr}.magnification;
                C_F = o.compositor.camera{cameraNr}.C_F;
                TE = o.compositor.camera{cameraNr}.TE;
                t_Bel = o.compositor.camera{cameraNr}.t_Bel;
                QE = o.compositor.camera{cameraNr}.QE;
                CountToInt = o.compositor.camera{cameraNr}.CountToInt;
                
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
                    pause(2);
                    countvariable = countvariable+1;
                    if countvariable > 100
                    o.compositor.defringedimage =imread(pathref);
                    errordlg('Defringed image not found. Displaying non-defringed image instead...');
                    error = false;
                    end
                end
            end
                def = double(o.compositor.defringedimage);
                o.compositor.image = od(def,abs);
            else
                o.compositor.image = od(ref,abs);
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
            
            %             integral = sum(sum(o.compositor.croppedimage));
            %             if length(o.compositor.atomnumberhistory) < 20
            %                 o.compositor.atomnumberhistory(end+1) = integral;
            %             else
            %                 o.compositor.atomnumberhistory = o.compositor.atomnumberhistory(2:end);
            %                 o.compositor.atomnumberhistory(end+1) = integral;
            %             end
            if o.compositor.fitbuttonstate
                o.compositor.figures{4}.processFit();
                if length(o.compositor.atomnumberhistory) < o.compositor.historylength
                    o.compositor.atomnumberhistory(end+1) = o.compositor.atomnumberfitmean;
                else
                    o.compositor.atomnumberhistory = o.compositor.atomnumberhistory(2:end);
                    o.compositor.atomnumberhistory(end+1) = o.compositor.atomnumberfitmean;
                end
                
            end
            %o.t3=clock;
%                         if o.compositor.camerachange
%             notify(o.compositor,'updateDataAndResolution');
%                         else

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
        
        function onCheckboxrunningUpdate(o,hsource,data)
            if o.checkboxrunning.Value == 1
                period = 1;
                dirLength = length(dir(o.compositor.imageDirectory));
                o.compositor.timerobj = timer('TimerFcn', {@o.timerCallback,o.compositor.imageDirectory,dirLength}, 'Period', period, 'executionmode', 'fixedrate');;
                o.t1 = clock;
                start(o.compositor.timerobj);
            else
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
        
        
        function timerCallback(o, src, eventdata,dirName,dirLength)
            t2 = clock;
            t12 = etime(t2,o.t1);
            set(o.tb,'String',[num2str(round(t12)) ' s']);
            formatdate = 'yyyy_mm_dd';
            today = datestr(now,formatdate);
            year = [o.basepath today(1:4) '/'];
            month = [year today(1:7) '/'];
            day = [month today];
            persistent dirSize;
            persistent beginFlag;
            if isempty(beginFlag)
                dirSize = dirLength;
                beginFlag = 0;
            end
            if length(dir(dirName)) > dirSize
                t3 = clock;
                o.compositor.telapsed = etime(o.t1,t3);
                o.t1 = clock;
                %disp('A new file is available')
                tic;
                dirSize = length(dir(dirName));
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
                o.checkboxrunning.Value = 0;
                o.onCheckboxrunningUpdate(o.checkboxrunning);
                pause(3);
                o.onTodayBtnPush(o.todaybtn);
                pause(3);
                o.checkboxrunning.Value = 1;
                o.onCheckboxrunningUpdate(o.checkboxrunning);
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
                'Position',[0.25 0.3 0.4 0.1],...
                'Callback', @o.onCheckboxdefringedUpdate);
            
            o.checkboxrunning = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Running...'},...
                'Position',[0.25 0.1 0.4 0.1],...
                'Callback', @o.onCheckboxrunningUpdate);
            
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
            
            o.tb  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0.7 0.1 0.2 0.1]);
            
            
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
