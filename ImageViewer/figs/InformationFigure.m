classdef InformationFigure < BaseFigure
    properties
        % GUI elements
        text
        layout
        fitbtn
        radios
        popupfits
        checkbox
        
        % Data
        startparams
        startparams2
        fitydata
        fitydata2
        xdata
        ydata
        xdata2
        ydata2
        
        
        % Helper
        paramNames
        fit
        fit2
        fitFctName = 'Gauss';
        fitFct
        calculatedstartparams = true
        AtomfaktorRb
        AtomfaktorK
        AtomfaktorLi6_D2
        AtomfaktorLi7_D2
        BECFit
        FermiFit
        Nges
        frac
        temp
        tempF
        
        
        
    end
    
    methods
        % constructor
        function o = InformationFigure()
            o.windowTitle = mfilename('class');
        end
        
        function onFitBtn(o,hObject,callbackdata)
            buttonstate = get(hObject,'Value');
            if buttonstate == get(hObject,'Max')
                o.processFit();
                o.compositor.fitbuttonstate = true;
                %set(hObject,'String','Fit off');
                set(hObject,'BackgroundColor','green');
                %o.onRedraw();
                
            else
                o.compositor.fitbuttonstate = false;
                o.compositor.plotfitdatax = [];
                o.compositor.plotfitdatay = [];
                o.compositor.fitdatax = [];
                o.compositor.fitdatay = [];
                notify(o.compositor, 'updateFitResults');
                %set(hObject,'String','Fit');
                C = get(0, 'DefaultUIControlBackgroundColor');
                set(hObject, 'BackgroundColor', C)
                %o.onRedraw();
            end
        end
        
        function setFit(o,hSource,callbackdata)
            items = get(hSource,'String');
            index_selected = get(hSource,'Value');
            item_selected = items{index_selected};
            o.fitFctName = item_selected;
            buttonstate = get(o.fitbtn,'Value');
            if buttonstate == get(o.fitbtn,'Max')
                o.processFit();
            end
            
        end
        
        function onCheckboxUpdate(o,hSource,callbackdata)
            if get(hSource,'Value')
                o.compositor.plotfitstate = true;
            else
                o.compositor.plotfitstate = false;
            end
            notify(o.compositor,'updatePlotFit');
            
        end
        
        function onRadioClick(o,hSource,callbackdata,iRadio)
            for i = 1:4
                set(o.radios(i), 'Value', i==iRadio);
            end
            
            if get(o.radios(2),'Value')
                o.compositor.species = 'K';
                o.compositor.camera = Camera(o.compositor.cameraID,'K');
            elseif get(o.radios(1),'Value')
                o.compositor.species = 'Rb';
                o.compositor.camera = Camera(o.compositor.cameraID,'Rb');
            elseif get(o.radios(3),'Value')
                o.compositor.species = 'Li7';
                o.compositor.camera = Camera(o.compositor.cameraID,'Li7');
            elseif get(o.radios(4),'Value')
                o.compositor.species = 'Li6';
                o.compositor.camera = Camera(o.compositor.cameraID,'Li6');
            end
            
            notify(o.compositor,'updateData');
            
        end
        
        function processFit(o)
            if strcmp(o.fitFctName,'Gauss')
                options = optimset('Display','off');
                
                o.ydata = (o.compositor.datacroppedx(:))';
                o.xdata = 1:numel(o.ydata);
                
                o.ydata2 = (o.compositor.datacroppedy(:))';
                o.xdata2 = 1:numel(o.ydata2);
                
                o.fit = GeneralFitFunctions(o.fitFctName,o.xdata,o.ydata);
                o.fit2 = GeneralFitFunctions(o.fitFctName,o.xdata2,o.ydata2);
                o.fitFct = o.fit.fitFunction;
                o.paramNames = o.fit.paramNames;
                
                if o.calculatedstartparams
                    o.startparams = o.fit.startParams;
                    o.startparams2 = o.fit2.startParams;
                end
                
                [gfity,~] = lsqcurvefit(o.fitFct, o.startparams,o.xdata(1:end),o.ydata(1:end),[],[],options);
                [gfity2,~] = lsqcurvefit(o.fitFct, o.startparams2,o.xdata2(1:end),o.ydata2(1:end),[],[],options);
                o.fitydata = gfity;
                o.fitydata2 = gfity2;
                o.compositor.fitdatax=gfity;
                o.compositor.fitdatay=gfity2;
                o.compositor.plotfitdatax = o.fitFct(o.fitydata,sort(o.xdata));
                o.compositor.plotfitdatay = o.fitFct(o.fitydata2,sort(o.xdata2));
%                 a(1)= o.compositor.fitdatax(2).*sqrt(2*pi).*o.compositor.fitdatax(4);
%                 a(2)= o.compositor.fitdatay(2).*sqrt(2*pi).*o.compositor.fitdatay(4);
%                 o.compositor.atomnumberfitmean = mean(a);
				notify(o.compositor, 'updateFitResults');
            end
            
            if strcmp(o.fitFctName,'2D BEC')
                tic;
                [Nges,frac,temp,Param] = BECFit2D();
                
                o.Nges = Nges;
                o.frac = frac;
                o.temp = temp;
                y_index = 1:size(o.compositor.croppedimage,1);
                x_index = 1:size(o.compositor.croppedimage,2);
                [Xb,Yb] = meshgrid(x_index,y_index);
                o.BECFit = Param(1)+Param(2).*dilog2(exp(-((Xb-Param(3))./Param(4)).^2-((Yb-Param(5))./Param(6)).^2)) + real(Param(7).*(1-((Xb-Param(8))./Param(9)).^2 - ((Yb-Param(10))./Param(11)).^2).^(1.5));
                BECFitx = sum(o.BECFit,1);
                BECFity = sum(o.BECFit,2);
                o.compositor.plotfitdatax = BECFitx;
                o.compositor.plotfitdatay = BECFity;
                o.compositor.frac=round(o.frac,2);
                fprintf('Fitting took %d \n', toc);
                notify(o.compositor, 'updateFitResults');
            end
            
            function [Nges,frac,temp,outParam]=BECFit2D()
                
                cut = 3.5;
                Atomfaktor = o.compositor.camera.Atomfaktor; %(o.compositor.camera.PixSize.^2/o.compositor.camera.magnification.^2) .* 2 .* pi .* (1+ 4.*(DetuningRb.^2/GammaRb.^2)) ./ (3.*LambdaRb.^2);
                y_index = 1:size(o.compositor.croppedimage,1);
                x_index = 1:size(o.compositor.croppedimage,2);
                [Xb,Yb] = meshgrid(x_index,y_index);
                [~,I1] = max(sum(o.compositor.croppedimage'));
                [~,I2] = max(sum(o.compositor.croppedimage));
                [~,I3] = min(abs(sum(o.compositor.croppedimage') - exp(-0.5).*max(sum(o.compositor.croppedimage')))); %grobe Bestimmung der "Breite"
                [~,I4] = min(abs(sum(o.compositor.croppedimage) - exp(-0.5).*max(sum(o.compositor.croppedimage))));
                inParam = [0,1,I2,abs(I2-I4), I1,abs(I1-I3), 5, I2,abs(I2-I4), I1,abs(I1-I3)];
                options = optimset('Display','on','Algorithm','trust-region-reflective','TolFun',1e-10,'TolX',1e-10,'MaxFunEvals',1e3,'MaxIter',1e3);
                [outParam,a,residual,tt,ttt,tttt,J] = lsqnonlin(@(Param) Param(1)+Param(2).*dilog2(exp(-((Xb-Param(3))./Param(4)).^2-((Yb-Param(5))./Param(6)).^2)) + real(Param(7).*(1-((Xb-Param(8))./Param(9)).^2 - ((Yb-Param(10))./Param(11)).^2).^(1.5)) - o.compositor.croppedimage,inParam,[-inf,0,0,0,0,0,0,0,0,0,0],[inf,2.5,inf,inf,inf,inf,inf,inf,inf,inf,inf],options);
                N = length(Xb).*length(Yb) - length(outParam);
                stdErrors = sqrt(diag(inv(J'*J)*a/N));
                fehlerFit     = mean(mean(abs(residual)));
                Nbec          = (2./5).*outParam(7).*outParam(9).*outParam(11).*pi.*Atomfaktor;
                fehlerNbec    = Nbec.*sqrt((stdErrors(7)./outParam(7)).^2 + (stdErrors(9)./outParam(9)).^2 + (stdErrors(11)./outParam(11)).^2);
                Ntherm        = outParam(2).*outParam(4).*outParam(6).*1.2021.*pi.*Atomfaktor;
                fehlerNtherm  = Ntherm.*sqrt((stdErrors(2)./outParam(2)).^2 + (stdErrors(4)./outParam(4)).^2 + (stdErrors(6)./outParam(6)).^2);
                
                Nges            = Nbec + Ntherm;
                fehlerNges      = sqrt(fehlerNbec.^2+fehlerNtherm.^2);
                frac            = Nbec./Nges;
                fehlerfrac      = frac.*sqrt((fehlerNbec./Nbec).^2 + (fehlerNges./Nges).^2);
                temp            = (1-Nbec./Nges).^(2./3);
                fehlertemp      = 2./3.*temp.*fehlerfrac.*(1-frac).^(-1);
            end
            
            if strcmp(o.fitFctName,'2D Fermi')
                tic;
                [temp,Param] = FermiFit2D();
                o.tempF = temp;
                A = Param(1);
                b = Param(2);
                sigx = Param(3);
                sigy = Param(4);
                mx = Param(5);
                my = Param(6);
                xc  = Param(7);
                yc = Param(8);
                fug  = Param(9);
                y_index = 1:size(o.compositor.croppedimage,1);
                x_index = 1:size(o.compositor.croppedimage,2);
                [X,Y] = meshgrid(x_index,y_index);
                o.FermiFit = A.*dilog2(-fug.*exp(-((X-xc).^2)./(2.*sigx.^2)).*exp(-((Y-yc).^2)./(2.*sigy.^2)))./dilog2(-fug)+b+mx.*X+my.*Y;
                FermiFitx = sum(o.FermiFit,1);
                FermiFity = sum(o.FermiFit,2);
                o.compositor.plotfitdatax = FermiFitx;
                o.compositor.plotfitdatay = FermiFity;
                fprintf('Fitting took %d \n', toc);
                notify(o.compositor, 'updateFitResults');
            end
            
            function [temps,outParam]=FermiFit2D()
                cut_fehler = 99.0;
                y_index = 1:size(o.compositor.croppedimage,1);
                x_index = 1:size(o.compositor.croppedimage,2);
                [Xb,Yb] = meshgrid(x_index,y_index);
                [~,I1] = max(sum(o.compositor.croppedimage'));
                [~,I2] = max(sum(o.compositor.croppedimage));
                [~,I3] = min(abs(sum(o.compositor.croppedimage') - exp(-0.5).*max(sum(o.compositor.croppedimage')))); % grobe Bestimmung der "Breite"
                [~,I4] = min(abs(sum(o.compositor.croppedimage) - exp(-0.5).*max(sum(o.compositor.croppedimage))));
                inParam = [1, 0, 0.7.*abs(I2-I4), 0.7.*abs(I1-I3), 0, 0, I2, I1, 500];
                options = optimset('Display','on','Algorithm','trust-region-reflective','TolFun',1e-10,'TolX',1e-10,'MaxFunEvals',1e3,'MaxIter',1e3);
                [outParam,a,residual,~,~,~,J] = lsqnonlin(@(Param)Fermi2D(Param,Xb,Yb,o.compositor.croppedimage),inParam,[-inf,-inf,-inf,-inf,-inf,-inf,-inf,-inf,0],[],options);
                N = length(Xb).*length(Yb) - length(outParam);
                stdErrors = sqrt(diag(inv(J'*J)*a/N));
                fehler      = mean(mean(abs(residual)));
                if      outParam(9) < stdErrors(9,1)
                    maxtemps    = NaN;
                    temps       = NaN;
                    mintemps    = NaN;
                    fehler     = NaN;
                    ratio     = NaN;
                    deltasig    = NaN;
                    
                elseif  fehler>cut_fehler
                    maxtemps    = NaN;
                    temps       = NaN;
                    mintemps    = NaN;
                    ratio      = NaN;
                    deltasig    = NaN;
                else
                    maxtemps    = Temperatur(outParam(9)-stdErrors(9,1));
                    temps       = Temperatur(outParam(9));
                    mintemps    = Temperatur(outParam(9)+stdErrors(9,1));
                    ratio      = outParam(3)./outParam(4);
                    deltasig    = 2.*abs(outParam(3)-outParam(4))./(outParam(3)+outParam(4));
                end
            end
            
        end
        
        function processData(o)
            
            atomcount(1) = sum(o.compositor.datacroppedx);
            atomcount(2) = sum(o.compositor.datacroppedy);
            
            atomnumber = atomcount.*o.compositor.camera.Atomfaktor;
            if ~isempty(o.compositor.fitdatax)
                atomnumberfit(1) = o.compositor.fitdatax(2).*o.compositor.fitdatax(4)*sqrt(2*pi).*o.compositor.camera.Atomfaktor;
                atomnumberfit(2) = o.compositor.fitdatay(2).*o.compositor.fitdatay(4)*sqrt(2*pi).*o.compositor.camera.Atomfaktor;
                o.compositor.atomsx = atomnumberfit(1);
                o.compositor.atomsy = atomnumberfit(2);
				o.compositor.atomnumberfitmean = round(nanmean(atomnumberfit));
                sigmax = o.compositor.fitdatax(4);
                sigmay = o.compositor.fitdatay(4);
				centerx = o.compositor.fitdatax(3);
                centery = o.compositor.fitdatay(3);
            else
                atomnumberfit = [];
                sigmax = [];
                sigmay = [];
                centerx = [];
                centery = [];
            end
                                  
            if ~isempty(o.compositor.currentabsorptionimage)
                o.text{1} = ['Date: ' o.compositor.currentabsorptionimage(1:4) '/' o.compositor.currentabsorptionimage(6:7) '/' o.compositor.currentabsorptionimage(9:10)];
                o.text{2} = ['Camera: ' o.compositor.cameraID];
                o.text{3} = ['ID: ' o.compositor.currentabsorptionimage(14:17)];
                o.text{4} = ['Experimental cycle time: ' num2str(round(o.compositor.telapsed)) 's'];
                o.text{5} = ['Atomnumber: ' num2str(round(mean(atomnumber)))];
                o.text{6} = ['Atomnumber(Fit): ' num2str(round(nanmean(atomnumberfit)))];
                o.text{7} = ['Width x(px): ' num2str(round(sigmax))];
                o.text{8} = ['Width y(px): ' num2str(round(sigmay))];
                o.text{9} = ['Center x(px): ' num2str(round(centerx))];
                o.text{10} = ['Center y(px): ' num2str(round(centery))];
                o.text{11} = ['Temperature (T/Tf): ' num2str(round(o.tempF,2))];
                o.text{12} = ['Cond. Fraction: ' num2str(round(o.frac,2))];
                o.text{13} = ['Atomnumber(FitX): ' num2str(round(atomnumberfit(1)))];
                o.text{14} = ['Atomnumber(FitY): ' num2str(round(atomnumberfit(2)))];
            end
        end
        
        function onDoFit(o,hsource,data)
            o.processFit();
            notify(o.compositor,'useFitResults');
        end
        
        % implementing BaseFigure
        function onCreate(o)
            addlistener(o.compositor, 'updateData', @o.onUpdateDataEvent);
            addlistener(o.compositor, 'updateFitResults', @o.onUpdateFitResults);
            addlistener(o.compositor, 'doFit', @o.onDoFit);
            o.layout  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0. 0. 1 1]);
            o.axes.Visible = 'off';
            set(o.layout,'String','Info');
            
            o.fitbtn = uicontrol(o.figure, 'Style', 'togglebutton',...
                'String', 'Fit',...
                'Units', 'normalized',...
                'Position', [0.3 0.1 0.4 0.2],...
                'Value', 1,...
                'BackgroundColor','green',...
                'Callback', @o.onFitBtn);
            
            radioLabels = {'Rb','K','Li7','Li6'};
            value = find(strcmp(radioLabels,o.compositor.camera.species)==1);
            for iRadio=1:numel(radioLabels)
                o.radios(iRadio) = uicontrol(o.figure, 'Style', 'radiobutton', ...
                    'Callback', {@o.onRadioClick, iRadio}, ...
                    'Units',    'normalized', ...
                    'Position', [0.1 (iRadio*0.1)-0.1 0.2 0.1], ...
                    'String',   radioLabels{iRadio}, ...
                    'Value',    iRadio==value);
            end
            
            o.popupfits = uicontrol('Style', 'popupmenu',...
                'String', {'Gauss','2D BEC','2D Fermi'},...
                'units', 'normalized',...
                'Position', [0.75 0.2 0.2 0.1],...
                'Callback', @o.setFit);
            
            o.checkbox = uicontrol('Style','checkbox',...
                'Units', 'normalized',...
                'String',{'Show Fit'},...
                'Position',[0.75 0.1 0.2 0.1],...
                'Callback', @o.onCheckboxUpdate);
            
            
        end
        
        function onReplot(o)
            o.onRedraw;
            
            
        end
        
        function onRedraw(o)
            o.processData();
            o.layout.String = o.text;
        end
    end
    
end