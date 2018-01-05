clearvars -except dataStructure;
close all;

addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib'
addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib/GUI'
addpath('figs');
addpath('core');
addpath('lib');
addpath('../../compareExpTheo/core/'); % for the shakenBGH class
addpath('../../');
%addpath('../lib/');
% if ~exist('dataStructure', 'var')
%     %load etc
%dataStructure.createFFTs(2^nextpow2(300));
dataStructure.createFFTs();
%dataStructure.normalizeFFTs();
%     dataStructure.initFits();
%     dataStructure.initFitsFFT();
% end
o = FitCompositor();
o.data = dataStructure;
o.figures = {...
        PhaseFigure...PhaseFitFigure...PhaseFitMeanFigure,...ResnormFitFigure,...FrequencyFitFigure,...FrequencyFitAllTimesFigure,...ResnormFitAllTimesFigure,...
        AmplitudeFigure...
        DirectImageFigure...
        InfoFigure...
        PixelHaukeFigure...
        PixelQuenchFigure...
        FFTVorticityFigure...FFTMaxFigure...AllTimeGradientFigure...
        AllTimeVorticityFigure...DetermineBandStructureFigure...PixelFFTFigure...DetermineBandStructureFigure...
    };
o.userIndeces.time = UserIndex(1,1,numel(o.data.times));
o.userIndeces.frequency = UserIndex(3,1,200);
o.userIndeces.run = UserIndex(2,0,10);
o.create();

%% fit all