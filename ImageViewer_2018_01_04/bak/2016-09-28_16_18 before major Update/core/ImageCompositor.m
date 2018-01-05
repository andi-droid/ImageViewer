% this class needs the following from the library:
% BaseFrame, BaseFigure, (UserInput has been integrated into this class)

 % In next version
 % don't make properties observable anymore but use events
 % make the change of property (coordinate and time) a generic concept
classdef ImageCompositor < BaseFrame
    properties
        % data
        camera
        cameraID
        camerachange = false
        
        species = 'K'
        data
        datax
        datay
        datacroppedx
        datacroppedy
        
        atomnumberhistory
        idhistorynr
        idhistoryos
        historylength = 5000
        fitorcount = true
        history_ylab
        history_x
        history_y
        indexslotduration
        indexanalog
        
        oscillationx
        oscillationy
        oscillationlength = 5000
        fitormean = true
        
        protocol
        currentprotocol
        currentabsorptionimage
        absorptionimage
        currentreferenceimage
        referenceimage
        currentdefringedimage
        defringedimage
        image
        croppedimage
        cutOD
        croppedcontrast = 0.1
        atomnumberfitmean
        
        loadprotocol = false
        
        fitbuttonstate = true
        plotfitstate = false
        fitdatax
        fitdatay
        
        plotfitdatax
        plotfitdatay
        
        absmaxcounts
        refmaxcounts
        
        timerobj
        telapsed
        
        roi = [220    100   350   300];
        
        
        imageDirectory = '//afs/physnet.uni-hamburg.de/project/bfm/Daten/2016/2016_07/2016_07_01'

        % figures
        figures;
        userIndices
    end
    properties(SetObservable)
        currentCoordinate = [0 0]
    end
    events
        updateData
        updateDataAndResolution
        updateFitResults
        updateAxes
    end
    
    methods
        function o = ImageCompositor()
            o@BaseFrame();
            o.name = 'Image Viewer';
            o.nXPanes = 4;
            o.nYPanes = 3;
        end
        
        function onCreate(o)     

            for iFigure=1:numel(o.figures)
                o.figures{iFigure}.create(o);
            end
            
        end        
    end
    
end
