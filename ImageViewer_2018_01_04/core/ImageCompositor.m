% this class needs the following from the library:
% BaseFrame, BaseFigure, (UserInput has been integrated into this class)

 % In next version
 % don't make properties observable anymore but use events
 % make the change of property (coordinate and time) a generic concept
classdef ImageCompositor < BaseFrame
    properties
        % Status
        camera
        cameraID
        camerachange = false
        loadprotocol = true
        fitbuttonstate = true
        plotfitstate = false
        fitormean = true
        species = 'K'
        analysismethod = 'Atomnumber'
        average = 1
        selectedIDs = []
        selectedIDsDefringe = []
        fitorcount = true
        
        % Helper
        historystring = 'ID'
        analysisstring = 'ID'
        historylength = 5000
        oscillationlength = 5000
        history_xlab
        analysis_xlab = 'ID'
        indexslotduration
        indexanalog
        indexvisa
        indexvariables
        visacommand
        visacommandnumber
        visacommandnumber2
        
        
        
        % Image
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
        absmaxcounts
        refmaxcounts        
        imageDirectory
        roi = [200,230,500,500]
        abscenter =[376,272]
        
        defringeatoms = [896 469 169 98]
        defringeroi = [780 377 427 298]
        
        
        imagesetabs
        imagesetref
        imagesetdef
        croppedDefringedIS

        % Data        
        data
        datax
        datay
        datacroppedx
        datacroppedy
        plotfitdatax
        plotfitdatay
        analysisplotfitdatax
        analysisplotfitdatay        
        fitdatax
        fitdatay
        imagepackage
        imagepackagecropped
        protocolpackage
        ydataanalysis
        xdataanalysis
        atomnumberhistory
        widthhistoryx
        widthhistoryy
        historyxdata
        oscillationx
        oscillationy
        atomsx
        atomsy

        % Timer
        timerobj
        telapsed
        
        % Figures
        figures


    end
    properties(SetObservable)
        currentCoordinate = [1 1]
    end
    events
        updateData
        updateDataAndResolution
        updateFitResults
        updateAxes
        updateHistory
        updateAnalysis
        updatePlotFit
        doFit
        useFitResults
        clearPlot
        updateAnalysisFitResults
        updateImagePackage
        updateAnalysisFigure
        addPointer
        deletePointer
        updateODImageset
        updateDefringedImageSet
        indexup
        indexdown
        updateDataDefringedIntegratedOD
        closeevent
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
