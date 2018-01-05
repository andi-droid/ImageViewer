clearvars -except dataStructure;
close all;

% addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib'
% addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib/GUI'
addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Matthias/Code/2016-05-09 MatlabLib'
addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Matthias/Code/2016-05-09 MatlabLib/GUI'
addpath('figs');
addpath('core');
addpath('lib');
%addpath('../../compareExpTheo/core/'); % for the shakenBGH class
addpath('../../');
%addpath('../lib/');
% if ~exist('dataStructure', 'var')
%     %load etc
%dataStructure.createFFTs(2^nextpow2(300));
%dataStructure.createFFTs();
%dataStructure.normalizeFFTs();
%     dataStructure.initFits();
%     dataStructure.initFitsFFT();
% end
tic
o = ImageCompositor();
%o.data = dataStructure;
o.figures = {...
        FilePickerFigure...
        ImageFigure...        
        CroppedImageFigure... 
        InformationFigure...
        IntegratedODxFigure...
        IntegratedODyFigure...
        IntegratedODCroppedxFigure...
        IntegratedODCroppedyFigure...       
        AbsorptionImageFigure...
        ReferenceImageFigure...
        RawInformationFigure...
        HistoryFigure...
        CutODFigure...

    };
%o.userIndeces.time = UserIndex(1,1,numel(o.data.times));
% o.userIndeces.frequency = UserIndex(3,1,200);
% o.userIndeces.run = UserIndex(0,0,250);
% o.userIndeces.imbalance = UserIndex(1,1,15);
% o.userIndeces.imbalance2 = UserIndex(1,1,15);

o.camera{1} = Camera('Andor');
o.camera{2} = Camera('PCO');


o.create();

%% fit all