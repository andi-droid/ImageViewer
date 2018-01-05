clear all;
addpath('../lib'); % for ImageSet and OD imageset and dataset
addpath('core');
addpath('figs');
addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib'
addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib/GUI'
dataPath = '/afs/physnet.uni-hamburg.de/project/bfm/Auswertung/2016/2016_05/2016_05_19_Doublequench/dominik/data/averaged/';
%dataPath2 = '/afs/physnet.uni-hamburg.de/project/bfm/Auswertung/2016/2016_01/2016_01_05_MTCompensation/Analysis/dominik/averageAndFit/data/averaged/';

smoothingFactors = [15 10 5 3 2];
for iSmoothing = 1:numel(smoothingFactors)
smoothing = smoothingFactors(iSmoothing);
% filterOptions = {'bandpassfir',...
%     'FilterOrder',8, ...
%     'CutoffFrequency1',10e3,...
%     'CutoffFrequency2', 14e3};
filterOptions = [];
fitOptions = optimset('MaxFunEvals',1000,'TolFun',1e-8,'MaxIter',1000,'TolX',1e-8,'display','none');
fitname = 'Band pass 8th order 10kHz to 14kHz';
vortexname = sprintf('smoothing %u no filter_FFT interpolated last 2 timesteps skipped', smoothing);
v.mkdir('vortexlines');
v.mkdir(sprintf('vortexlines/%s', vortexname));

foldername = sprintf('%s%.0e_%.0e_%u/', fitname, fitOptions.TolFun, fitOptions.TolX,  smoothing);

hs = HaukeSet;
%hs.fftA3 = 1;

%%
files = {...
    '2016_02_04_Double_quench_11kHz9_2kHz_recropped.mat'...
    '2016_05_19_Double_quench_11kHz905_2kHz.mat'...
    '2016_05_20_Double_quench_11kHz905_2kHz_41V33.mat'...
    '2016_05_20_Double_quench_11kHz905_2kHz_41V41.mat'...
    '2016_05_20_Double_quench_11kHz905_2kHz_41V00.mat'...
    '2016_05_23_Double_quench_11kHz905_2kHz_41V45_olddipolepower.mat'...
    '2016_05_23_Double_quench_11kHz905_2kHz_41V45_imbalance.mat'...
    '2016_05_25_Double_quench_11kHz905_2kHz_41V45_neu.mat'...
    '2016_05_25_Double_quench_11kHz905_1kHz_41V2-4.mat'...
    '2016_05_26_Double_quench_11kHz905_2kHz_41V45_real.mat'...
    '2016_05_27_Double_quench_11kHz905_2kHz_41V45-42V7.mat'...
    '2016_05_30_Double_quench_11kHz905_2kHz_41V7-42V8.mat'...
    '2016_05_30_Double_quench_11kHz905_2kHz_41V6.mat'...
    '2016_05_31_Double_quench_11kHz905_2kHz_42V6_newcalib.mat'...
    '2016_05_31_Double_quench_5kHz495_2kHz_21V3.mat'...
    '2016_05_31_Double_quench_8kHz264_2kHz_29V0-30V3.mat'...
    '2016_06_01_Double_quench_8kHz264_2kHz_30V5-30V9.mat'...
    '2016_06_01_Double_quench_11kHz905_2kHz_42V0-42V8.mat'...
    '2016_06_02_Double_quench_11kHz9_2kHz_41V0-41V5.mat'...
    '2016_06_02_Double_quench_11kHz9_2kHz_42V6_reversed.mat'...
    '2016_06_03_Hauke_quench_11kHz_2kHz_41V0.mat'...
    '2016_06_03_Double_quench_11kHz905_2kHz_41V0_improvedquality.mat'...
    '2016_06_03_Double_quench_11kHz236_2kHz_41V0.mat'...
    '2016_06_03_Double_quench_11kHz236_2kHz_40V6-42V4.mat'...
    '2016_06_06_Double_quench_11kHz236_2kHz_41V10-41V15.mat'...
    '2016_06_06_Double_quench_11kHz236_2kHz_41V12-41V22.mat'...
    '2016_06_06_Double_quench_11kHz236_2kHz_41V12-41V24.mat'...
    '2016_06_08_Double_quench_7kHz8125_2kHz_29V0-30V2.mat'...
    '2016_06_09_Double_quench_7kHz8125_0kHz9_29V5.mat'...
    '2016_06_09_Double_quench_11kHz494_0kHz75_40V9.mat'...
    '2016_06_10_Double_quench_11kHz494_0kHz9_40V9.mat'...
    '2016_06_10_Double_quench_11kHz494_3kHz7_41V0.mat'...
    '2016_06_10_Double_quench_9kHz434_2kHz_35V0.mat'...
    '2016_06_10_Double_quench_9kHz434_2kHz_34V0-35V4.mat'...
    };

v.mkdir([dataPath 'fitresults']);
v.mkdir([dataPath 'bare']);
v.mkdir(['fitresults/' foldername]);

for iFile=numel(files):-1:22
    clearvars -except iFile files M STD fitOptions filterOptions foldername smoothing P dataPath vortexname smoothingFactors iSmoothing;
    [~, currentName, ~] = fileparts(files{iFile});
    currentFile = ['fitresults/' foldername currentName '.mat'];
    currentFileBare = [dataPath 'bare/' currentName '.mat'];
    %% load files
    if exist(currentFile, 'file') == 2
        fsprintf('Fit exists already: %s\n skipping\n', currentFile);
        continue;
    end
        
    if exist(currentFileBare, 'file') == 2 && 1 
        fprintf('re-loading: %s\n', files{iFile});
        load(currentFileBare, 'dataStructure', 'P' );
    elseif ~exist([dataPath files{iFile}],'file') == 2
        fsprintf('Could not find file: %s\n', files{iFile});
        continue;
    else
        fprintf('loading: %s\n', files{iFile});
        load([dataPath files{iFile}]);
        %% load into bare Hauke sets
        dataStructure = DataStructure();
        parameters = NaN(10*numel(datasets), 2); %take the two relevant parameters
        dataStructure.lvl = 58;
        dataStructure.center = datasets(1).center;

        % atom count and std
        A = {datasets.atomCountDefringed};
        for i=1:numel(A), m(i) =mean(A{i}); end;
        dataStructure.M = mean(m);
        dataStructure.STD = std(m)/mean(m);

        % main loop
        iHaukeSet = 1;
        for iDataset =1:numel(datasets)
            ds = datasets(iDataset);
            p = [ds.DataPoints.parameter];

            % only use sets with more than 24 hauke times
            if ds.nDataPoints < 24
                continue;
            end

            % correct changing run index number
            holdID = 4;
            switch size(p,1)
                case 7
                    haukeID = 6;
                    runID = 7;
                case 8
                    haukeID = 7;
                    runID = 8;
            end

            P{iDataset} = p;

            % create new Hauke Set in collection
            dataStructure.haukeSets{iHaukeSet} = HaukeSet;
            parameters(iHaukeSet,:) = p([holdID runID],1);

            haukeSet = dataStructure.haukeSets{iHaukeSet};
            haukeSet.atomCount = ds.atomCountDefringed;
            haukeSet.times = squeeze(p(haukeID,:))/100*1e-3;

            % normalize Images
            is = copy(ds.ODDefringedImageSet);
            haukeSet.atomCount = haukeSet.atomCount/mean(haukeSet.atomCount);
            is.everyPixel(@(x)x./haukeSet.atomCount);

            haukeSet.imageData = double(is.getRaw3DData());

            iHaukeSet = iHaukeSet +1;
        end
        % convert quench/hold times to indeces
        parameters = parameters(1:(iHaukeSet-1),:);
        [C,~,ic] = unique(parameters(:,1));
        dataStructure.times = C;
        parameters(:,1) = squeeze(ic);
        dataStructure.parameters = parameters;
        dataStructure.filename = currentName;
        
        % save bare data
        save(currentFileBare, 'dataStructure', 'P' );
    end    
    
    
    %% post processing
    timeInterpolate;
    nSets = numel(dataStructure.haukeSets);    
    % filter images
    fprintf('%u:filtering\n', iFile);
    for iSet =1:nSets
        dataStructure.haukeSets{iSet}.filter( ...
            filterOptions, 'smoothing', smoothing);
    end
    
    % create ffts as they are needed as initialization for the fit
    fprintf('%u:fft\n', iFile);
    dataStructure.createFFTs();
    
    % fit and clean up data
%     fprintf('%u:fit', iFile);
%     for iSet=1:nSets
%         hs = dataStructure.haukeSets{iSet};
%         hs.fitOptions = fitOptions;
%         hs.fitSet(dataStructure.center);
%         %hs.reduceFFT();
%         fprintf('%u:%u\t/\t%u', iFile, iSet, nSets);
%     end
    runs = unique(dataStructure.parameters(:,2));
    for iRun = 1:numel(runs)
        o = FitCompositor();
        o.data = dataStructure;
        vortFig = AllTimeVorticityFigure;
        o.figures = {vortFig};
        o.userIndeces.time = UserIndex(1,1,numel(o.data.times));
        o.userIndeces.frequency = UserIndex(3,1,200);
        o.userIndeces.run = UserIndex(runs(iRun),0,max(runs));
        o.create();
        pause(0.1);
        drawnow;
        print('-painters',vortFig.figure, sprintf('vortexlines/%s/%s_Run%u', vortexname, currentName, runs(iRun)) , '-dpng','-r100');
        close all;
        pause(0.1);
        o = [];
        vortFig = [];
        pause(0.1);
        %clearvars -except iFile files M STD fitOptions filterOptions foldername smoothing P dataPath vortexname iRun dataStructure runs currentName smoothingFactors iSmoothing;
    end
    
    

    
    

end
end