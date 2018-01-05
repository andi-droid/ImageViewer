classdef PixelHaukeFigure < FitBaseFigure
    properties
        haukeTimeSeries
        fftApprox
        fitApprox
        nonNormalizedData
        times
        
        
        fftPlot
        fitPlot
        filteredPlot
        nonNormalizedPlot
        filtered
    end
    
    methods
        % constructor
        function o = PixelHaukeFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            t = o.compositor.userIndeces.time.value;
            run = o.compositor.userIndeces.run.value;
            [px, py] = o.kToPixel(o.compositor.currentCoordinate);
            hs = o.data.getHaukeSet(t,run);
            if ~isempty(hs)
                % actual data
                o.haukeTimeSeries = squeeze(hs.imageData(:,py, px));
                
                % fft approximation
                [A, I] = max(squeeze(hs.fftA(2:end, py,px)));
                I = 3;
                A =  hs.fftA(I, py,px);
                o.times = hs.times;
                o.fftApprox = 0.5*hs.fftA(1, py,px)+2*A*cos(2*pi*hs.fftF(I)*o.times+hs.fftP(I, py,px));
                
                % fit approximation
                p = hs.fitPixel(px,py);
                %[p, upperBound, lowerBound]  = hs.startParams(px,py);
                %p = struct2array(p)
                o.fitApprox = hs.timeTraceFromParameters(p);
                %                o.fitApprox = fit.initialPixel(px,py);
                %                o.fitApprox = fit.resultPixel(px,py);
                o.nonNormalizedData = hs.getNonNormalizedTimeTrace(px,py);
%                 bpFilt = designfilt('bandpassfir','FilterOrder',9, ...
%                     'CutoffFrequency1',10e3,'CutoffFrequency2',12e3, ...
%                     'SampleRate',1/(o.times(2)-o.times(1)));
%                 o.filtered = filtfilt(bpFilt, o.haukeTimeSeries);
                ht = hs.times;
                N = numel(ht);
                NFFT = N;
                dt = ht(2)-ht(1);
                fftVals = fft(o.haukeTimeSeries, NFFT)/NFFT;
                nComp = 3;
                fftVals(nComp:(end-nComp))=0;
                o.filtered = real(ifft(fftVals, NFFT)*NFFT);
            else
                o.haukeTimeSeries = NaN(size(o.haukeTimeSeries));
                o.fftApprox = NaN(size(o.fftApprox));
                o.fitApprox = NaN(size(o.fitApprox));
            end
        end
        
        % implementing BaseFigure
        function onCreate(o)
            o.linkMouseWheelToIndex('time');
            o.listenToUserInput('time', @o.onRedraw);
            o.linkUpDownLeftRightToIndeces('frequency', 'run');
            o.listenToUserInput('frequency', @o.onRedraw)
            o.listenToUserInput('run', @o.onRedraw);
            o.registerCurrentCoordinateListener();
        end
        
        function onReplot(o)
            o.processData();
            o.plot = plot(o.axes, o.times, o.haukeTimeSeries,'.b');
            hold(o.axes, 'on');
            o.nonNormalizedPlot = plot(o.axes, o.times, o.nonNormalizedData,'.r');
            o.fftPlot = plot(o.axes, o.times, o.fftApprox,'--k');
            o.fitPlot = plot(o.axes, o.times, o.fitApprox,'--r');
            o.filteredPlot = plot(o.axes, o.times, o.filtered,'-b');
            hold(o.axes, 'off');
            o.axes.YLim = [0 0.25];
        end
        
        function onRedraw(o)
%              o.onReplot;
            o.processData();
            o.plot.XData = o.times;
            o.plot.YData = o.haukeTimeSeries;
            
            o.fftPlot.XData = o.times;
            o.fftPlot.YData = o.fftApprox;
            
            o.fitPlot.XData = o.times;
            o.fitPlot.YData = o.fitApprox;
            
            o.filteredPlot.XData = o.times;
            o.filteredPlot.YData = o.filtered;
            
            o.nonNormalizedPlot.XData = o.times;
            o.nonNormalizedPlot.YData = o.nonNormalizedData;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

