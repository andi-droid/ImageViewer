clearvars
close all;


addpath '//afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Matthias/Code/2016-05-09 MatlabLib'
addpath '//afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Matthias/Code/2016-05-09 MatlabLib/GUI'
addpath('figs');
addpath('core');
addpath('lib');



o = ImageCompositor();
o.figures = {...
        FilePickerFigure...
        IntegratedODxFigure...
        IntegratedODCroppedxFigure...
        InformationFigure...
        IntegratedODyFigure...       
        ImageFigure...        
        CroppedImageFigure... 
        IntegratedODCroppedyFigure...
        ProtocolFigure...
        FitControlFigure...
        ImagePackageFigure...
        AbsorptionImageFigure...
        ReferenceImageFigure...       
        CutODFigure...        
        OscillationFigure... 
        AnalysisFigure...
        IODDefyFigure...
        NondefringedFigure...
        DefringedFigure...
        IODDefxFigure...
        HistoryFigure...
   
    };

%o.userindex.imagenumber = UserIndex(1,1,5000);


o.camera = Camera('3','K');



o.create();

%% fit all