classdef PixelFFTFigure < FitBaseFigure
    properties
        FFTFreqSeries
        fftApprox
        fftPhase
        freqs

        phasePlot
        plot2
    end
    
    methods
        % constructor
        function o = PixelFFTFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o)
            t = o.compositor.userIndeces.time.value;
            run = o.compositor.userIndeces.run.value;
            [px, py] = o.kToPixel(o.compositor.currentCoordinate);
            hs = o.data.getHaukeSet(t,run);
            if ~isempty(hs)
                o.FFTFreqSeries = log(squeeze(hs.fftA(:, py, px)));
                o.fftPhase = mod(squeeze(hs.fftP(:, py, px))/2/pi,1)*(-7)-9;
                o.freqs = hs.fftF;
            else
                o.FFTFreqSeries = NaN(size(o.FFTFreqSeries));
                o.fftPhase = NaN(size(o.fftPhase));
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
            o.plot = plot(o.axes, o.freqs, o.FFTFreqSeries,'.b');
            hold(o.axes, 'on');
            o.plot2 = plot(o.axes, o.freqs(o.compositor.userIndeces.frequency.value), o.FFTFreqSeries(o.compositor.userIndeces.frequency.value),'or');
            %o.phasePlot = plot(o.axes, o.freqs, o.fftPhase,'.');
            %o.phasePlot.Color = [1 0 1];
            hold(o.axes, 'off');
            o.axes.YLim = [-14 -6];
        end
        
        function onRedraw(o)
            o.processData();
            o.plot.XData = o.freqs;
            o.plot.YData = o.FFTFreqSeries;

             o.plot2.XData = o.freqs(o.compositor.userIndeces.frequency.value);
             o.plot2.YData = o.FFTFreqSeries(o.compositor.userIndeces.frequency.value);
            %o.phasePlot.XData = o.freqs;
            %o.phasePlot.YData = o.fftPhase;
        end
        
         function onNewCurrentCoordinate(o,~)
            o.onRedraw();          
        end
    end
    
end

