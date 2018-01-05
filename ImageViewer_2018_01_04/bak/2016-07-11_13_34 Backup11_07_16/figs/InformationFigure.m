classdef InformationFigure < FitBaseFigure
    properties
        text
        tb
        fitbtn
        fit
        fit2
        fitFctName = 'Gauss';
        fitFct
        calculatedstartparams = true
        startparams
        startparams2
        fitydata
        fitydata2
        xdata
        ydata
        xdata2
        ydata2
        paramNames
        
        radios
        popupfits
        checkbox
        
        
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
        end
        
        function onCheckboxUpdate(o,hSource,callbackdata)
            if get(hSource,'Value')
                o.compositor.plotfitstate = true;
                o.compositor.figures{7}.onRedraw();
                o.compositor.figures{8}.onRedraw();
            else
                o.compositor.plotfitstate = false;
                o.compositor.figures{7}.onRedraw();
                o.compositor.figures{8}.onRedraw();
            end

        end
        
        function onRadioClick(o,hSource,callbackdata,iRadio)
            for i = 1:2
                set(o.radios(i), 'Value', i==iRadio);
            end
            
            if get(o.radios(2),'Value')
                o.compositor.species = 'K';
            else
                o.compositor.species = 'Rb';
            end
            
            notify(o.compositor,'updateData');
            %             if o.buttonpressed
            %                 o.processFit();
            %                 o.onRedraw();
            %             end
        end
        
        function processFit(o)
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
            a(1)= o.compositor.fitdatax(2).*sqrt(2*pi).*o.compositor.fitdatax(4);
            a(2)= o.compositor.fitdatay(2).*sqrt(2*pi).*o.compositor.fitdatay(4);
            o.compositor.atomnumberfitmean = mean(a);
            notify(o.compositor, 'updateFitResults');
        end
        
        function processData(o)
            %             t = o.compositor.userIndeces.time.value;
            %             frequency = o.compositor.userIndeces.frequency.value;
            %             run = o.compositor.userIndeces.run.value;
            %             hs = o.data.getHaukeSet(t,run);
            %             if isempty(hs)
            %                 o.text = [];
            %             else
            %             s = hs.info;
            %             s.frequency = frequency;
            %             s.run = run;
            %             s.atomCount = o.compositor.data.M;
            %             s.atomCountDeviation = o.compositor.data.STD;
            %             s.FFT_Frequency = hs.getfftF(3);
            %
            %
            %             C = v.struct2Text(s);
            %
            %              o.text = cell(size(C,2),1);
            %              for iLine = 1:size(C,2)
            %                 o.text{iLine} = [C{1,iLine} ' =  ' C{2,iLine}];
            %              end
            %             end
            
            atomcount(1) = sum(o.compositor.datacroppedx);
            atomcount(2) = sum(o.compositor.datacroppedy);
            if strcmp(o.compositor.cameraID, 'Andor')
                cameraNr =1;
            else
                cameraNr =2;
            end
            
            if o.compositor.species == 'K'
                DetuningK  = 0e6;
                GammaK     = 2.*pi.*6.035e6    ; % Linienbreite des zyklischen Uebergangs aus T.G. Tiecke "Properties of Potassium"
                LambdaK     = 766.700674872e-9 ; % Kalium D2 Detektionswellenlaenge, T.G. Tiecke "Properties of Potassium"
                AtomfaktorK  = (o.compositor.camera{cameraNr}.PixSize.^2/o.compositor.camera{cameraNr}.magnification.^2) .* 2 .* pi .* (1+ 4.*(DetuningK.^2/GammaK.^2)) ./ (3.*LambdaK.^2);
                atomnumber = atomcount.*AtomfaktorK;
                if ~isempty(o.compositor.fitdatax)
                    atomnumberfit(1) = o.compositor.fitdatax(2).*o.compositor.fitdatax(4)*sqrt(2*pi).*AtomfaktorK;
                    atomnumberfit(2) = o.compositor.fitdatay(2).*o.compositor.fitdatay(4)*sqrt(2*pi).*AtomfaktorK;
                    sigmax = o.compositor.fitdatax(4);
                    sigmay = o.compositor.fitdatay(4);
                else
                    atomnumberfit = [];
                     sigmax = [];
                    sigmay = [];
                end
            else
                DetuningRb = 0e6;
                GammaRb    = 2.*pi.*6.0666e6   ; % Linienbreite des zyklischen Uebergangs aus "Alkali D Line Data", Daniel Steck - August 2009
                LambdaRb    = 780.241209686e-9 ; % Rubidium D2 Detektionswellenlaenge, entnommen aus "Steck"
                AtomfaktorRb = (o.compositor.camera{cameraNr}.PixSize.^2/o.compositor.camera{cameraNr}.magnification.^2) .* 2 .* pi .* (1+ 4.*(DetuningRb.^2/GammaRb.^2)) ./ (3.*LambdaRb.^2);
                atomnumber = atomcount.*AtomfaktorRb;
                if ~isempty(o.compositor.fitdatax)
                    atomnumberfit(1) = o.compositor.fitdatax(2).*o.compositor.fitdatax(4)*sqrt(2*pi).*AtomfaktorRb;
                    atomnumberfit(2) = o.compositor.fitdatay(2).*o.compositor.fitdatay(4)*sqrt(2*pi).*AtomfaktorRb;
                    sigmax = o.compositor.fitdatax(4);
                    sigmay = o.compositor.fitdatay(4);
                else
                    atomnumberfit = [];
                    sigmax = [];
                    sigmay = [];
                end
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
            end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            %             o.listenToUserInput('time', @o.onRedraw);
            %             o.listenToUserInput('frequency', @o.onRedraw);
            %             o.listenToUserInput('run', @o.onRedraw);
            %             o.registerCurrentCoordinateListener;
            o.tb  = uicontrol('style','text', 'Parent', o.figure,'Units', 'normalized', 'Position', [0. 0. 1 1]);
            o.axes.Visible = 'off';
            set(o.tb,'String','Info');
            
                        o.fitbtn = uicontrol(o.figure, 'Style', 'togglebutton',...
                'String', 'Fit',...
                'Units', 'normalized',...
                'Position', [0.3 0.1 0.4 0.2],...
                'Value', 1,...
                'BackgroundColor','green',...
                'Callback', @o.onFitBtn);
            
            radioLabels = {'Rb','K'};
            for iRadio=1:numel(radioLabels)
                o.radios(iRadio) = uicontrol(o.figure, 'Style', 'radiobutton', ...
                    'Callback', {@o.onRadioClick, iRadio}, ...
                    'Units',    'normalized', ...
                    'Position', [0.1 (iRadio*0.1) 0.2 0.1], ...
                    'String',   radioLabels{iRadio}, ...
                    'Value',    iRadio==2);
            end
            
            o.popupfits = uicontrol('Style', 'popupmenu',...
           'String', {'Gauss','1D Bose','2D Fermi'},...
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
            o.tb.String = o.text;
        end
    end
    
end

