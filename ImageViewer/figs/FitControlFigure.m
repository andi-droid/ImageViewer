classdef FitControlFigure < BaseFigure
    properties
        % GUI elements
        param
        edits
        editsstartparam
        calccheckbox
        fitbtn
        clearbtn
        popupfits
        text
        tb
        editslowerbound
        editsupperbound
        
        
        % Data
        startparams
        lowerbound
        upperbound
        fitdata
        xdata
        ydata
        plotfitdata
        
        
        % Helper
        fit
        fitFctName = 'Gauss';
        fitFct
        calculatedstartparams = true
        %newFitParams
        paramNames
        
        
        
        
        
    end
    
    methods
        % constructor
        function o = FitControlFigure()
            o.windowTitle = mfilename('class');
        end
        
        function onFitBtn(o,hObject,callbackdata)
            
            o.processFit();
            
        end
        
        function setFit(o,hSource,callbackdata)
            items = get(hSource,'String');
            index_selected = get(hSource,'Value');
            item_selected = items{index_selected};
            o.fitFctName = item_selected;
        end
        
        
        
        
        function processFit(o)
            o.compositor.analysisplotfitdatax = [];
            o.compositor.analysisplotfitdatay = [];
            numberParams = numel(o.paramNames);
            for iParam = 1:numberParams
                newFitParams(iParam) = str2double(get(o.editsstartparam(iParam), 'String'));
                newlowerbound(iParam) = str2double(get(o.editslowerbound(iParam), 'String'));
                newupperbound(iParam) = str2double(get(o.editsupperbound(iParam), 'String'));
            end
            
            if strcmp(o.fitFctName,'Gauss')
                options = optimset('Display','off');
                %
                o.ydata = o.compositor.ydataanalysis; %';
                o.xdata = o.compositor.xdataanalysis;
                %
                
                %
                o.fit = GeneralFitFunctions(o.fitFctName,o.xdata,o.ydata);
                o.fitFct = o.fit.fitFunction;
                o.paramNames = o.fit.paramNames;
                
                
                
                %
                if o.calculatedstartparams
                    o.startparams = o.fit.startParams;
                    o.lowerbound = o.fit.lowerBound;
                    o.upperbound = o.fit.upperBound;
                    for i = 1:numel(o.startparams)
                        set(o.editsstartparam(i), 'String',num2str(o.startparams(i)));
                    end
                    for i = 1:numel(o.lowerbound)
                        set(o.editslowerbound(i), 'String',num2str(o.lowerbound(i)));
                    end
                    
                    for i = 1:numel(o.upperbound)
                        set(o.editsupperbound(i), 'String',num2str(o.upperbound(i)));
                    end
                    
                else
                    o.startparams = newFitParams;
                    o.lowerbound = newlowerbound;
                    o.upperbound = newupperbound;
                    
                end
                
                %
                [gfit,~] = lsqcurvefit(o.fitFct, o.startparams,o.xdata(1:end),o.ydata(1:end),o.lowerbound,o.upperbound,options);
                
                o.fitdata = gfit;
                xdata = unique(o.xdata);
                %o.compositor.analysisplotfitdatax = xdata(1):0.00001:xdata(end);
                o.compositor.analysisplotfitdatax = linspace(xdata(1),xdata(end),1000);
                o.compositor.analysisplotfitdatay = o.fitFct(o.fitdata,o.compositor.analysisplotfitdatax);
                
                
                
                o.onUpdateFitResults();
                notify(o.compositor, 'updateAnalysisFitResults');
            end
            
            if strcmp(o.fitFctName,'Lorentz')
                
                options = optimset('Display','off');
                %
                o.ydata = o.compositor.ydataanalysis; %'
                o.xdata = o.compositor.xdataanalysis;
                %
                
                %
                o.fit = GeneralFitFunctions(o.fitFctName,o.xdata,o.ydata);
                o.fitFct = o.fit.fitFunction;
                o.paramNames = o.fit.paramNames;
                
                
                
                %
                if o.calculatedstartparams
                    o.startparams = o.fit.startParams;
                    o.lowerbound = o.fit.lowerBound;
                    o.upperbound = o.fit.upperBound;
                    for i = 1:numel(o.startparams)
                        set(o.editsstartparam(i), 'String',num2str(o.startparams(i)));
                    end
                    for i = 1:numel(o.lowerbound)
                        set(o.editslowerbound(i), 'String',num2str(o.lowerbound(i)));
                    end
                    
                    for i = 1:numel(o.upperbound)
                        set(o.editsupperbound(i), 'String',num2str(o.upperbound(i)));
                    end
                else
                    o.startparams = newFitParams;
                    o.lowerbound = newlowerbound;
                    o.upperbound = newupperbound;
                end
                %
                [gfit,~] = lsqcurvefit(o.fitFct, o.startparams,o.xdata(1:end),o.ydata(1:end),o.lowerbound,o.upperbound,options);
                
                o.fitdata = gfit;
                
                
                xdata = unique(o.xdata);
                o.compositor.analysisplotfitdatax = linspace(xdata(1),xdata(end),1000);
                %o.compositor.analysisplotfitdatax = xdata(1):0.001:xdata(end);
                o.compositor.analysisplotfitdatay = o.fitFct(o.fitdata,o.compositor.analysisplotfitdatax);
                
                o.onUpdateFitResults();
                notify(o.compositor, 'updateAnalysisFitResults');
            end
            
            
            
            if strcmp(o.fitFctName,'Sinus')
                
                options = optimset('Display','off');
                %
                o.ydata = o.compositor.ydataanalysis'; %'
                o.xdata = o.compositor.xdataanalysis;
                %
                
                %
                o.fit = GeneralFitFunctions(o.fitFctName,o.xdata,o.ydata);
                o.fitFct = o.fit.fitFunction;
                o.paramNames = o.fit.paramNames;
                
                
                
                %
                if o.calculatedstartparams
                    o.startparams = o.fit.startParams;
                    o.lowerbound = o.fit.lowerBound;
                    o.upperbound = o.fit.upperBound;
                    for i = 1:numel(o.startparams)
                        set(o.editsstartparam(i), 'String',num2str(o.startparams(i)));
                    end
                    for i = 1:numel(o.lowerbound)
                        set(o.editslowerbound(i), 'String',num2str(o.lowerbound(i)));
                    end
                    
                    for i = 1:numel(o.upperbound)
                        set(o.editsupperbound(i), 'String',num2str(o.upperbound(i)));
                    end
                else
                    o.startparams = newFitParams;
                    o.lowerbound = newlowerbound;
                    o.upperbound = newupperbound;
                end
                %
                [gfit,~] = lsqcurvefit(o.fitFct, o.startparams,o.xdata(1:end),o.ydata(1:end),o.lowerbound,o.upperbound,options);
                
                o.fitdata = gfit;
                
                
                xdata = unique(o.xdata);
                %o.compositor.analysisplotfitdatax = xdata(1):0.00001:xdata(end);
                o.compositor.analysisplotfitdatax = linspace(xdata(1),xdata(end),1000);
                o.compositor.analysisplotfitdatay = o.fitFct(o.fitdata,o.compositor.analysisplotfitdatax);
                o.onUpdateFitResults();
                notify(o.compositor, 'updateAnalysisFitResults');
            end
            
            if strcmp(o.fitFctName,'ToFFit')
                
                options = optimset('Display','off');
                %
                o.ydata = o.compositor.ydataanalysis'; %'
                o.xdata = o.compositor.xdataanalysis;
                %
                
                %
                o.fit = GeneralFitFunctions(o.fitFctName,o.xdata,o.ydata);
                o.fitFct = o.fit.fitFunction;
                o.paramNames = o.fit.paramNames;
                
                
                
                %
                if o.calculatedstartparams
                    o.startparams = o.fit.startParams;
                    o.lowerbound = o.fit.lowerBound;
                    o.upperbound = o.fit.upperBound;
                    for i = 1:numel(o.startparams)
                        set(o.editsstartparam(i), 'String',num2str(o.startparams(i)));
                    end
                    for i = 1:numel(o.lowerbound)
                        set(o.editslowerbound(i), 'String',num2str(o.lowerbound(i)));
                    end
                    
                    for i = 1:numel(o.upperbound)
                        set(o.editsupperbound(i), 'String',num2str(o.upperbound(i)));
                    end
                else
                    o.startparams = newFitParams;
                    o.lowerbound = newlowerbound;
                    o.upperbound = newupperbound;         
                end
                %
                [gfit,~] = lsqcurvefit(o.fitFct, o.startparams,o.xdata(1:end),o.ydata(1:end),o.lowerbound,o.upperbound,options);
                
                o.fitdata = gfit;
                
                
                xdata = unique(o.xdata);
                o.compositor.analysisplotfitdatax = linspace(xdata(1),xdata(end),1000);
                o.compositor.analysisplotfitdatay = o.fitFct(o.fitdata,o.compositor.analysisplotfitdatax);
                
                o.onUpdateFitResults();
                notify(o.compositor, 'updateAnalysisFitResults');
            end
            
        end
        
        function onUpdateFitResults(o)
            newFitParams = o.fitdata;
            numberParams = numel(o.paramNames);
            for iParam = 1 : numberParams
                set(o.param(iParam),'String',o.paramNames{iParam});
                set(o.param(iParam),'Visible','on');
                set(o.edits(iParam), 'String',sprintf('%2.3d', newFitParams(iParam)));
                set(o.edits(iParam),'Visible','on');
                set(o.editsstartparam(iParam),'Visible','on');
                set(o.editslowerbound(iParam),'Visible','on');
                set(o.editsupperbound(iParam),'Visible','on');
            end
            
            for iParam = numberParams+1 : 7
                set(o.edits(iParam),'Visible','off');
                
                set(o.param(iParam),'Visible','off');
                set(o.editsstartparam(iParam),'Visible','off');
                set(o.editslowerbound(iParam),'Visible','off');
                set(o.editsupperbound(iParam),'Visible','off');
            end
        end
        
        
        function onClearFit(o,hsource,data)
                o.compositor.analysisplotfitdatax = [];
                o.compositor.analysisplotfitdatay = [];
                
                o.onUpdateFitResults();
                notify(o.compositor, 'updateAnalysisFitResults');
            
        end
        
        function onCalcCheckbox(o,hsource,data)
            if o.calccheckbox.Value == 1;
                o.calculatedstartparams = true;
            else
                o.calculatedstartparams = false;
            end
            
        end
        
        % implementing BaseFigure
        function onCreate(o)
            
            
            paramNames = {'par1','par2','par3','par4','par5','par6','par7'};
            %o.axes.Visible = 'off';
            
            
            
            
            
            
            
            o.tb  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0. 0. 1 1]);
            %o.axes.Visible = 'off';
            set(o.tb,'String','Info');
            
            title = 'Fit Results';
            uicontrol(...
                'Parent',o.figure,...
                'Units','normalized',...
                'Style','Text',...
                'Position', [0.12 0.75 0.2 0.1],...
                'String', title,...
                'HorizontalAlignment', 'center');
            
            uicontrol(...
                'Parent',o.figure,...
                'Units','normalized',...
                'Style','Text',...
                'Position', [0.34 0.75 0.2 0.1],...
                'String', 'Initial',...
                'HorizontalAlignment', 'center');
            
            uicontrol(...
                'Parent',o.figure,...
                'Units','normalized',...
                'Style','Text',...
                'Position', [0.56 0.75 0.2 0.1],...
                'String', 'lower',...
                'HorizontalAlignment', 'center');
            
            
            uicontrol(...
                'Parent',o.figure,...
                'Units','normalized',...
                'Style','Text',...
                'Position', [0.78 0.75 0.2 0.1],...
                'String', 'upper',...
                'HorizontalAlignment', 'center');
            
            
            
            o.fitbtn = uicontrol(o.figure, 'Style', 'pushbutton',...
                'String', 'Update Fit',...
                'Units', 'normalized',...
                'Position', [0.65 0.9 0.2 0.1],...
                'Callback', @o.onFitBtn);
            
            o.calccheckbox = uicontrol(o.figure, 'Style', 'checkbox',...
                'String', 'Use calc. Params',...
                'Units', 'normalized',...
                'Position', [0.3 0.0 0.4 0.1],...
                'Value', 1,...
                'Callback', @o.onCalcCheckbox);
            
            
            
            for iParam=1:numel(paramNames)
                o.param(iParam) = uicontrol(o.figure,'Style','Text',...
                    'Units', 'normalized',...
                    'Position', [0.0 0.8-(0.1*iParam) 0.1 0.1],...
                    'String', paramNames{iParam},...
                    'HorizontalAlignment', 'right');
                o.edits(iParam) =  uicontrol(o.figure,'Style','edit',...
                    'Units', 'normalized',...
                    'Position', [0.12 0.8-(0.1*iParam) 0.2 0.1],...
                    'BackgroundColor',[0.6,1.0,0.6]);
                
                o.editsstartparam(iParam) =  uicontrol(o.figure,'Style','edit',...
                    'Units', 'normalized',...
                    'Position', [0.34 0.8-(0.1*iParam) 0.2 0.1]);
                
                o.editslowerbound(iParam) =  uicontrol(o.figure,'Style','edit',...
                    'Units', 'normalized',...
                    'Position', [0.56 0.8-(0.1*iParam) 0.2 0.1]);
                
                o.editsupperbound(iParam) =  uicontrol(o.figure,'Style','edit',...
                    'Units', 'normalized',...
                    'Position', [0.78 0.8-(0.1*iParam) 0.2 0.1]);
                
                
            end
            
            o.popupfits = uicontrol('Style', 'popupmenu',...
                'String', {'Gauss','Lorentz','Sinus','ToFFit'},...
                'units', 'normalized',...
                'Position', [0.4 0.9 0.2 0.1],...
                'Callback', @o.setFit);
            
            o.clearbtn = uicontrol('Style','pushbutton',...
                'Units', 'normalized',...
                'String',{'Clear Fit'},...
                'Position',[0.0 0.0 0.2 0.1],...
                'Callback', @o.onClearFit);
            
            
        end
        
        function onReplot(o)
            o.onRedraw;
            
            
        end
        
        function onRedraw(o)
            o.tb.String = o.text;
        end
    end
    
end

