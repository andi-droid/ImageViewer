clearvars;
close all;


% addpath '//afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Matthias/Code/2016-05-09 MatlabLib'
% addpath '//afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Matthias/Code/2016-05-09 MatlabLib/GUI'
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
        ...ReferenceImageFigure...
        ...AbsorptionImageFigure...
        ProtocolFigure...
        FitControlFigure...
        AnalysisFigure...
        NondefringedFigure...
        DefringedFigure...
        ImagePackageFigure...      
        CutODFigure...        
        OscillationFigure... 
        IODDefyFigure...
        IODDefxFigure...
        HistoryFigure...
        ...WidthFigure...
   
    };

o.camera = Camera('2','Li6');

o.create();
