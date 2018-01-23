classdef LiProtocol < handle
    %Class for reading xlm-runlogs and writing mat-protocols
    properties
        
        % cicero variables
        VariableName          
        VariableValue           
        Relevant                      
        Description                   
        PermanentVariable        
        PermanentValue          
        VariableFormula        
        ListDriven             
        ListNumber          
        DerivedVariable
        IsSpecialVariable
        MySpecialVariableType
        Table %all variables in a table
        Cell %all variables in a cell array
        
        % timestamp
        date
        id
    end
    
   	methods            
      	function o = LiProtocol(date,id) %constructor
            o.date = date;
            o.id = id;
        end
        
        function read(o,filename) %xml-reader
            %disp('Is this done somewhere???');
            xDoc = xmlread(filename); 
            allListitems = xDoc.getElementsByTagName('Variable');
            Var=cell(12,allListitems.getLength); %Var{1,:} willcontain variable names, Var{2,:} willcontain variable values
            o.VariableName = cell(allListitems.getLength, 1);
            o.VariableValue = cell(allListitems.getLength, 1);
            o.Relevant = cell(allListitems.getLength, 1);
            o.Description = cell(allListitems.getLength, 1);
            o.PermanentVariable = cell(allListitems.getLength, 1);
            o.PermanentValue = cell(allListitems.getLength, 1);
            o.VariableFormula = cell(allListitems.getLength, 1);
            o.ListDriven = cell(allListitems.getLength, 1);
            o.ListNumber = cell(allListitems.getLength, 1);
            o.DerivedVariable = cell(allListitems.getLength, 1);
            o.IsSpecialVariable = cell(allListitems.getLength, 1);
            o.MySpecialVariableType = cell(allListitems.getLength, 1);

            for k=0:allListitems.getLength-1
                thisListitem = allListitems.item(k);
                
                thisList = thisListitem.getElementsByTagName('VariableName');
                thisElement = thisList.item(0);
                Var{1,k+1} = char(thisElement.getFirstChild.getData);
                o.VariableName{k+1} = char(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('VariableValue');
                thisElement = thisList.item(0);
                Var{2,k+1} = str2double(thisElement.getFirstChild.getData);
                o.VariableValue{k+1} = str2double(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('Relevant');
                thisElement = thisList.item(0);
                Var{3,k+1} = char(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('Description');
                thisElement = thisList.item(0);
                try
                    Var{4,k+1} = char(thisElement.getFirstChild.getData);
                    o.Description{k+1} = char(thisElement.getFirstChild.getData);
                catch
                    
                end
                
                thisList = thisListitem.getElementsByTagName('PermanentVariable');
                thisElement = thisList.item(0);
                Var{5,k+1} = char(thisElement.getFirstChild.getData);
                o.PermanentVariable{k+1} = char(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('PermanentValue');
                thisElement = thisList.item(0);
                Var{6,k+1} = str2double(thisElement.getFirstChild.getData);
                o.PermanentValue{k+1} = str2double(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('VariableFormula');
                thisElement = thisList.item(0);
                try 
                    Var{7,k+1} = char(thisElement.getFirstChild.getData);
                    o.VariableFormula{k+1} = char(thisElement.getFirstChild.getData);
                catch
                    
                end
                
                thisList = thisListitem.getElementsByTagName('ListDriven');
                thisElement = thisList.item(0);
                Var{8,k+1} = char(thisElement.getFirstChild.getData);
                o.ListDriven{k+1} = char(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('ListNumber');
                thisElement = thisList.item(0);
                Var{9,k+1} = str2double(thisElement.getFirstChild.getData);
                o.ListNumber{k+1} = str2double(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('DerivedVariable');
                thisElement = thisList.item(0);
                Var{10,k+1} = char(thisElement.getFirstChild.getData);
                o.DerivedVariable{k+1} = char(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('IsSpecialVariable');
                thisElement = thisList.item(0);
                Var{11,k+1} = char(thisElement.getFirstChild.getData);
                o.IsSpecialVariable{k+1} = char(thisElement.getFirstChild.getData);
                
                thisList = thisListitem.getElementsByTagName('MySpecialVariableType');
                thisElement = thisList.item(0);
                Var{12,k+1} = char(thisElement.getFirstChild.getData);
                o.MySpecialVariableType{k+1} = char(thisElement.getFirstChild.getData);
            end

            % display as table
            T=cell2table(Var,'RowNames',{'VariableName','VariableValue','Relevant','Description','PermanentVariable',...
            'PermanentValue','VariableFormula','ListDriven','ListNumber','DerivedVariable','IsSpecialVariable','MySpecialVariableType'});
            
            o.Table=T;
            o.Cell=Var;
        end 
    end
    
    methods(Static)
       
        function copy(ciceropath,imageviewerpath)
        %moves logs into subfolders according to their date     
            xmlfiles = dir([ciceropath '/*.xml']);
            for iFile = 1:numel(xmlfiles)
                xmlname = xmlfiles(iFile).name;
                d=datestr(datenum(xmlname(10:19),'yyyy-mm-dd'),'yyyy_mm_dd');
                cpath = sprintf('%s%s%s%s%s%s%s',imageviewerpath,filesep,d(1:4),filesep,d(1:7),filesep,d(1:10));
                if ~exist(cpath, 'dir'), mkdir(cpath); end
                copyfile(sprintf('%s%s%s',ciceropath,filesep,xmlname),sprintf('%s%s%s',cpath,filesep,xmlname))               
            end
            clgfiles = dir([ciceropath '/*.clg']);
            for iFile = 1:numel(clgfiles)
                clgname = clgfiles(iFile).name;
                d=datestr(datenum(clgname(10:19),'yyyy-mm-dd'),'yyyy_mm_dd');
                cpath = sprintf('%s%s%s%s%s%s%s',imageviewerpath,filesep,d(1:4),filesep,d(1:7),filesep,d(1:10));
                if ~exist(cpath, 'dir'), mkdir(cpath); end
                copyfile(sprintf('%s%s%s',ciceropath,filesep,clgname),sprintf('%s%s%s',cpath,filesep,clgname))                
            end   
        end
        
      	function write(cpath)
            %writes protocol2 files for imageviewer  
            %disp('Is this executed somewhere???');
            matpath  = [cpath filesep 'mat' filesep];
            if ~exist(matpath, 'dir'), mkdir(matpath); end
            files = dir([cpath,filesep,'*.xml']);
            for iFile = 1:numel(files)
                filename = files(iFile).name;
                protocolFilename = [cpath filesep filename];
                
                d = filename(10:19);
                id = filename(10:end-4);
                
                matFilename =[matpath id '_t_proto.mat'];
                if exist(matFilename, 'file'), continue; end
%                 fname =sprintf('%s/%s%s%s%s%s%s',cpath,'Protocol-',da,'T',ti,'.xml'); %complete file path and name
             	fprintf('converting file %s\n', protocolFilename);
                try
                    p = LiProtocol(d,id);
                    p.read(protocolFilename);
                    save(matFilename, 'p','-v7.3');
                catch e
                    fprintf('Error when reading %s:\n%s', protocolFilename, e.message );
                end
                clear('p','d');
            end
        end
        
    	function xml2matAgent(imageviewerpath)
            while(true)
                d = datestr(now,'yyyy_mm_dd');
                cpath = sprintf('%s%s%s%s%s%s%s', imageviewerpath,filesep,d(1:4),filesep,d(1:7),filesep,d(1:10));
                %LiProtocol.copy(ciceropath,imageviewerpath)
                LiProtocol.write(cpath)
                pause(5);
            end
        end
        
        function xml2matDay(imageviewerpath, d)
            cpath = sprintf('%s%s%s%s%s%s%s', imageviewerpath,filesep,d(1:4),filesep,d(1:7),filesep,d(1:10));
            LiProtocol.write(cpath)
        end
        
    end
end