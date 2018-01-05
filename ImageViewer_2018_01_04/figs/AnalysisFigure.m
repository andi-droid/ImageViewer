classdef AnalysisFigure < BaseFigure
    properties
        % GUI elements
        savebtn
        savedatabtn
        
        % Data
        ydata
        plotydata = []
        plotxdata = []        
        
        % Helper
        mask
        maskname = '1. BZ'
        roicenter =[156,172]
        basedirectory
        string
        filename
        datestring
        
        % Plots
        plot2
        plot3
        ylab
        



    end
    
    methods
        % constructor
        function o = AnalysisFigure()
            o.windowTitle = mfilename('class');
        end
        
        
        
        
        function onUpdateAnalysisFigure(o,hsource,data)
            o.datestring = o.compositor.imageDirectory(end-9:end);
            o.ydata = [];
            o.plotxdata = [];
            o.compositor.xdataanalysis = [];
            o.roicenter(1) = o.compositor.abscenter(1)-o.compositor.roi(1);
            o.roicenter(2) = o.compositor.abscenter(2)-o.compositor.roi(2);
            
            if strcmp(o.compositor.analysismethod,'Atomnumber')
                %             for i = 1: size(o.compositor.imagepackagecropped,1)
                %                 image = o.compositor.imagepackagecropped(i,:,:);
                %                 ydata(i) = sum(sum(image));
                %             end
                o.ylab = 'Atomnumber ';
                [atomnumber,position,width] = o.processGaussFit();
                for i = 1: size(o.compositor.imagepackagecropped,1)
                    image = squeeze(o.compositor.imagepackagecropped(i,:,:));
                    atomnumber2(i) = sum(sum(image));
                end
                %ydata = atomnumber.*o.compositor.camera.Atomfaktor;
                ydata = atomnumber2.*o.compositor.camera.Atomfaktor;
                
            elseif strcmp(o.compositor.analysismethod,'Position')
                %                 for i = 1: size(o.compositor.imagepackagecropped,1)
                %                 x = 1:size(o.compositor.imagepackagecropped,3);
                %                 o.y = 1:size(o.compositor.imagepackagecropped,2);
                %                 datacroppedx = sum(squeeze(o.compositor.imagepackagecropped(i,:,:)),1);
                %                 datacroppedy = sum(squeeze(o.compositor.imagepackagecropped(i,:,:)),2);
                %                 centerofmassx = sum(datacroppedx*x')/sum(datacroppedx);
                %                 centerofmassy = sum(o.datacroppedy.*y')/sum(datacroppedy);
                %
                %                     ydata(i) = centerofmassx;
                %
                %                 end
                o.ylab = 'Position (pixel)';
                [atomnumber,position,width] = o.processGaussFit();
                ydata = position(1);
                
            elseif strcmp(o.compositor.analysismethod,'Mask 1+2 BZ')
                o.ylab = 'Population 2.BZ/1.BZ';
                o.maskname = '1. BZ';
                o.createMask();
                for i = 1: size(o.compositor.imagepackagecropped,1)
                    image = squeeze(o.compositor.imagepackagecropped(i,:,:));
                    image = image.*o.mask;
                    atomnumber1(i) = sum(sum(image));
                end
                
                o.maskname = '2. BZ';
                o.createMask();
                for i = 1: size(o.compositor.imagepackagecropped,1)
                    image = squeeze(o.compositor.imagepackagecropped(i,:,:));
                    image = image.*o.mask;
                    atomnumber2(i) = sum(sum(image));
                end
                
                ydata = atomnumber2./atomnumber1;
                
            elseif strcmp(o.compositor.analysismethod,'Momentum resolved')
                o.ylab = 'Density (a.u.)';
                atomnumber = squeeze(o.compositor.imagepackagecropped(:,round(o.compositor.currentCoordinate(2)),round(o.compositor.currentCoordinate(1))));
                ydata = atomnumber;
                
            elseif strcmp(o.compositor.analysismethod,'Ratio 2 Areas')
                o.ylab = 'Population 1./(1.+2.)';
                o.maskname = '2x BZ';
                o.createBigMask(364-o.compositor.roi(1),155-o.compositor.roi(2));
                for i = 1: size(o.compositor.imagepackagecropped,1)
                    image = squeeze(o.compositor.imagepackagecropped(i,:,:));
                    image = image.*o.mask;
                    atomnumber1(i) = sum(sum(image));
                end
                
                o.maskname = '2x BZ';
                o.createBigMask(360-o.compositor.roi(1),375-o.compositor.roi(2));
                for i = 1: size(o.compositor.imagepackagecropped,1)
                    image = squeeze(o.compositor.imagepackagecropped(i,:,:));
                    image = image.*o.mask;
                    atomnumber2(i) = sum(sum(image));
                end
                ydata = atomnumber1./(atomnumber1+atomnumber2);
            elseif strcmp(o.compositor.analysismethod,'Width X')
                o.ylab = 'Width X  ';
                [atomnumber,position,width] = o.processGaussFit();
                ydata = width(:,1);
            elseif strcmp(o.compositor.analysismethod,'Width Y')
                o.ylab = 'Width Y ';
                [atomnumber,position,width] = o.processGaussFit();
                ydata = width(:,2);
            end
            o.onChangeParameter();
            o.ydata = ydata;
            o.compositor.ydataanalysis = [];
            %o.compositor.xdataanalysis = [];
            o.compositor.ydataanalysis = o.ydata;
            
            %o.compositor.xdataanalysis = o.compositor.analysisxdata;
            
            o.onReplot();
                
                
        end
        
        function onChangeParameter(o)
            o.compositor.xdataanalysis= [];
            if strcmp(o.compositor.analysisstring,'ID')
                o.compositor.analysis_xlab = 'ID';
                o.compositor.xdataanalysis = o.compositor.selectedIDs;
                
            elseif strcmp(o.compositor.analysisstring,'Duration')
                indexduration = o.compositor.indexslotduration;
                for i = 1: numel(o.compositor.selectedIDs)
                    o.compositor.xdataanalysis(i) = o.compositor.protocolpackage{1,i}.p.slotDuration(indexduration);
                end
                o.compositor.analysis_xlab = o.compositor.protocolpackage{1,1}.p.timeSlotNames(indexduration);
                
            elseif strcmp(o.compositor.analysisstring,'Analog')
                
                indexduration = o.compositor.indexslotduration;
                indexanalog = o.compositor.indexanalog;
                for i = 1: numel(o.compositor.selectedIDs)
                    o.compositor.xdataanalysis(i) = o.compositor.protocolpackage{1,i}.p.analogVals(indexduration,indexanalog);
                end
                o.compositor.analysis_xlab = o.compositor.protocolpackage{1,1}.p.analogNames(indexanalog);
                
            elseif strcmp(o.compositor.analysisstring,'Variables')
                indexvariables = o.compositor.indexvariables;
                for i = 1:numel(o.compositor.selectedIDs)
                    % ATTENTION waitfromimg added manually
                    o.compositor.xdataanalysis(i) = o.compositor.protocolpackage{1,i}.p.VariableValue{indexvariables,1}+.25;
                end
                o.compositor.analysis_xlab = o.compositor.protocolpackage{1,1}.p.VariableName{indexvariables,1};
            else
                o.compositor.analysis_xlab = o.compositor.visacommand;
                %o.visavalue = [];
                %o.visavaluedouble = [];
                for i = 1: numel(o.compositor.selectedIDs)
                    if o.compositor.visacommandnumber2 == 1
                        visavalue = regexpi(o.compositor.protocolpackage{1,i}.p.visaText{o.compositor.indexvisa},[o.compositor.visacommand '\s+(?<os1>[-?\d\.]+)'], 'tokens');
                    elseif o.compositor.visacommandnumber2 == 2
                        visavalue = regexpi(o.compositor.protocolpackage{1,i}.p.visaText{o.compositor.indexvisa},[o.compositor.visacommand '\s+[-?\d\.]+\s+(?<os1>[-?\d\.]+)'], 'tokens');
                    elseif o.compositor.visacommandnumber2 == 3
                        visavalue = regexpi(o.compositor.protocolpackage{1,i}.p.visaText{o.compositor.indexvisa},[o.compositor.visacommand '\s+[-?\d\.]+\s+[-?\d\.]+\s+(?<os1>[-?\d\.]+)'], 'tokens');
                    elseif o.compositor.visacommandnumber2 == 4
                        visavalue = regexpi(o.compositor.protocolpackage{1,i}.p.visaText{o.compositor.indexvisa},[o.compositor.visacommand '\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+(?<os1>[-?\d\.]+)'], 'tokens');
                    elseif o.compositor.visacommandnumber2 == 5
                        visavalue = regexpi(o.compositor.protocolpackage{1,i}.p.visaText{o.compositor.indexvisa},[o.compositor.visacommand '\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+(?<os1>[-?\d\.]+)'], 'tokens');
                    elseif o.compositor.visacommandnumber2 == 6
                        visavalue = regexpi(o.compositor.protocolpackage{1,i}.p.visaText{o.compositor.indexvisa},[o.compositor.visacommand '\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+(?<os1>[-?\d\.]+)'], 'tokens');
                    elseif o.compositor.visacommandnumber2 == 7
                        visavalue = regexpi(o.compositor.protocolpackage{1,i}.p.visaText{o.compositor.indexvisa},[o.compositor.visacommand '\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+(?<os1>[-?\d\.]+)'], 'tokens');
                    elseif o.compositor.visacommandnumber2 == 8
                        visavalue = regexpi(o.compositor.protocolpackage{1,i}.p.visaText{o.compositor.indexvisa},[o.compositor.visacommand '\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+[-?\d\.]+\s+(?<os1>[-?\d\.]+)'], 'tokens');
                    end
                    warning('off','MATLAB:callback:error');
                    
                    visavaluedouble = str2double(visavalue{o.compositor.visacommandnumber});
                    o.compositor.xdataanalysis(i) = visavaluedouble;
                    
                end
            end
        end
        
        function [atomnumbermean, position, width] = processGaussFit(o)
            
            options = optimset('Display','off');
            width(size(o.compositor.imagepackagecropped,1),2) = 0;
            position(size(o.compositor.imagepackagecropped,1),2) = 0;
            atomnumber(size(o.compositor.imagepackagecropped,1),1) = 0;
            for i = 1: size(o.compositor.imagepackagecropped,1)
                
                datacroppedx = sum(squeeze(o.compositor.imagepackagecropped(i,:,:)),1);
                datacroppedy = sum(squeeze(o.compositor.imagepackagecropped(i,:,:)),2);
                
                ydata = (datacroppedx(:))';
                xdata = 1:numel(ydata);
                
                ydata2 = (datacroppedy(:))';
                xdata2 = 1:numel(ydata2);
                
                fit = GeneralFitFunctions('Gauss',xdata,ydata);
                fit2 = GeneralFitFunctions('Gauss',xdata2,ydata2);
                
                startparams = fit.startParams;
                startparams2 = fit2.startParams;
                
                [gfity,~] = lsqcurvefit(fit.fitFunction, startparams,xdata(1:end),ydata(1:end),[],[],options);
                [gfity2,~] = lsqcurvefit(fit.fitFunction, startparams2,xdata2(1:end),ydata2(1:end),[],[],options);
                fitydata = gfity;
                fitydata2 = gfity2;
                a(1)= fitydata(2).*sqrt(2*pi).*fitydata(4);
                a(2)= fitydata2(2).*sqrt(2*pi).*fitydata2(4);
                atomnumber(i) = mean(a);
                width(i,:) = [fitydata(4),fitydata2(4)];
                position(i,:) = [fitydata(3),fitydata2(3)];
                
                
            end
            atomnumbermean = atomnumber;
        end
        
        
        
        function processData(o)
                o.plotydata = [];
                o.plotxdata = [];
                Cneu = [];
                A = [];
                if o.compositor.average
                    [A,ia,ib] =unique(o.compositor.xdataanalysis,'stable');
                    
                    for i=1:numel(ia)
                        match = ib==i;
                        % careful here xxx
                        sel = o.ydata(match);
                        Cneu(i) = mean(sel);
                    end
                    
                    o.plotydata = Cneu;
                    o.plotxdata = A;
                else
                    o.plotydata = o.ydata;
                    o.plotxdata = o.compositor.xdataanalysis;
                end
                
            end
        
        function onUpdateAnalysisFitResults(o,hsource,data)
            
            o.onReplotfit();
        end
        
        function createMask(o)
            LVL = 58;
            dimx = size(o.compositor.imagepackagecropped,3);
            dimy = size(o.compositor.imagepackagecropped,2);
            if strcmp(o.maskname,'1. BZ')
            BW=uZoneMask(1,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'2. BZ')               
            BW=uZoneMask(2,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'3. BZ') 
            BW=uZoneMask(3,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'2x BZ') 
            BW=uZoneMask(1,dimy,dimx,o.roicenter(2),o.roicenter(1),2*LVL,1);
            elseif strcmp(o.maskname,'1.+2. BZ') 
                 BW1=uZoneMask(1,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
                 BW2=uZoneMask(2,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
                 BW = BW1 + BW2;
            end
            o.mask = BW;
        end
        
        function createBigMask(o,centerx,centery)
            LVL = 58;
            dimx = size(o.compositor.imagepackagecropped,3);
            dimy = size(o.compositor.imagepackagecropped,2);
            if strcmp(o.maskname,'1. BZ')
            BW=uZoneMask(1,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'2. BZ')               
            BW=uZoneMask(2,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'3. BZ') 
            BW=uZoneMask(3,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
            elseif strcmp(o.maskname,'2x BZ') 
            BW=uZoneMask(1,dimy,dimx,centery,centerx,2*LVL,1);
            elseif strcmp(o.maskname,'1.+2. BZ') 
                 BW1=uZoneMask(1,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
                 BW2=uZoneMask(2,dimy,dimx,o.roicenter(2),o.roicenter(1),LVL,1);
                 BW = BW1 + BW2;
            end
            o.mask = BW;
        end
        
        function onSaveBtnPush(o,hsource,data)
            o.basedirectory = pwd;
            o.filename = inputdlg({'Filename'},'Save',1,{'Figure'});
            o.filename = strjoin(o.filename);
            o.string = ['./AnalysisPlots/' o.datestring '_' o.filename];
            print(o.figure,[o.string '.pdf'],'-dpdf');
            %printdlg(o.figure);
        end
        
        function onSaveDataBtnPush(o,hsource,data)
            o.basedirectory = pwd;
            xsavedata = o.plotxdata';
            ysavedata = o.plotydata;
            o.filename = inputdlg({'Filename'},'Save',1,{'PlotData'});
            o.filename = strjoin(o.filename);
            o.string = ['./AnalysisPlots/plotdata/' o.datestring '_' o.filename];
            save([o.string '.mat'],'xsavedata','ysavedata')
            %print(o.figure,o.string,'-dpdf');
            %printdlg(o.figure);
        end
%         function onUpdateAnalysis(o,hsource,data)
%             o.onChangeParameter();
%             %o.onReplot();
%         end
        
        % implementing BaseFigure
        function onCreate(o)
            

            %addlistener(o.compositor, 'clearPlot', @o.onClearPlot);
            addlistener(o.compositor, 'updateAnalysis', @o.onUpdateAnalysisFigure);
            addlistener(o.compositor, 'updateAnalysisFigure', @o.onUpdateAnalysisFigure);
            addlistener(o.compositor, 'updateAnalysisFitResults', @o.onUpdateAnalysisFitResults);
            
            o.savebtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Save Figure',...
                'Units', 'normalized',...
                'Position', [0.0 0.0 0.2 0.05],...
                'Callback', @o.onSaveBtnPush);
            
            o.savedatabtn = uicontrol(o.figure, 'Style', 'pushbutton', 'String', 'Save PlotData',...
                'Units', 'normalized',...
                'Position', [0.7 0.0 0.25 0.05],...
                'Callback', @o.onSaveDataBtnPush);

       
                        
        end
        
        function onReplot(o)
            delete(o.plot);
            delete(o.plot2);
            delete(o.plot3);
            o.processData();
            o.plot = plot(o.axes,o.plotxdata, o.plotydata,'ob');
            grid(o.axes,'on');
            %xlabel(o.axes,'ID');
            xlabel(o.axes,o.compositor.analysis_xlab);
            ylabel(o.axes,o.ylab);
            %o.axes.YLim = [-10,10];
        end
        
        function onReplotfit(o)
            o.plot3 = plot(o.axes,o.plotxdata, o.plotydata,'ob');
            hold(o.axes,'on')
            o.plot2 = plot(o.axes,o.compositor.analysisplotfitdatax, o.compositor.analysisplotfitdatay,'-r');
            grid(o.axes,'on');
            %o.axes.YLim = [0,5000];
            %xlabel(o.axes,'ID');
            xlabel(o.axes,o.compositor.analysis_xlab);
            ylabel(o.axes,o.ylab);
            hold(o.axes,'off');
        end
        
        
        function onRedraw(o)
            o.onReplot;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

