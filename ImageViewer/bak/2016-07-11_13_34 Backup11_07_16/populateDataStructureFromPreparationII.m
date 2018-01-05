reload = true;
if reload,% clear all; 
    reload = true; end;
addpath('../lib'); % for ImageSet
addpath('core');

filterOptions = [];
%filterOptions = {'bandpassfir',...
%    'FilterOrder',4, ...
%    'CutoffFrequency1',9e3,...
%    'CutoffFrequency2', 15e3};
smoothing=5;
selectedRuns = []; %empty means all

%basepath = '/afs/physnet.uni-hamburg.de/project/bfm/Auswertung/2016/2016_01/2016_01_05_MTCompensation/Analysis/dominik/averageAndFit/data/averaged/';
basepath = '/afs/physnet.uni-hamburg.de/project/bfm/Auswertung/2016/2016_05/2016_05_19_Doublequench/dominik/data/averaged/';

%filename = '2016_02_04_Double_quench_11kHz9_2kHz_complete_completefitdata_DampedSinus.mat';
%filename = '2016_02_04_Double_quench_11kHz9_2kHz_recropped.mat';
%filename = '2016_06_03_Double_quench_11kHz236_2kHz_40V6-42V4.mat';

%filename = '2016_06_06_Double_quench_11kHz236_2kHz_41V12-41V24.mat';
%filename = '2016_06_13_Double_quench_11kHz236_2kHz_40V9-41V5.mat';
%filename = '2016_06_14_Double_quench_11kHz236_2kHz_40V8-40V5.mat';
%filename = '2016_06_14_Double_quench_11kHz236_2kHz_40V94.mat';
%filename = '2016_06_14_Double_quench_11kHz236_2kHz_imbalance.mat';
%filename = '2016_06_15_Double_quench_11kHz236_2kHz_40V85-40V25.mat';
%filename = '2016_06_16_Double_quench_11kHz236_2kHz_imbalance_onetimestep.mat';
%filename = '2016_06_16_Double_quench_11kHz236_2kHz_imbalance_onetimestep_neworder.mat';
%filename = '2016_06_17_Double_quench_11kHz236_2kHz_imbalance_axis1and2.mat';
filename = '2016_06_20_Double_quench_11kHz236_2kHz_imbalance_axis1and2_2.mat';

if reload, load([basepath filename]); end;

storeData = datasets;
%%

%%
dataStructure = DataStructure;
parameters = NaN(10*numel(storeData), 2); %take the two relevant parameters
dataStructure.lvl = 58;
dataStructure.center = storeData(1).center;

% atom count and std
A = {datasets.atomCountDefringed};
for i=1:numel(A), m(i) =mean(A{i}); end;
dataStructure.M = mean(m);
dataStructure.STD = std(m)/mean(m);
        
iHaukeSet = 1;
for iDataset =1:numel(storeData)
    ds = storeData(iDataset);
    % only use sets with more than 5 hauke times
    if ds.nDataPoints < 25
        continue;
    end
    p = [ds.DataPoints.parameter];
    
    % correct changing run index number
    if size(p,1)==7
        haukeID = 6;
        runID = 7;
        latticeDepth1 = 5;
        latticeDepth2 = 5;
    else
        haukeID = 7;
        runID = 8;
        latticeDepth1 = 5;
        latticeDepth2 = 6;
    end
    
    % only prepare selected runs
    if exist('selectedRuns', 'var')
        if ~isempty(selectedRuns)
            if ~ismember(p(runID,1), selectedRuns)
                continue;
            end
        end
    end

    haukeSet = HaukeSet;
    % generate info
    haukeSet.info.latticeDepth1 = p(latticeDepth1,1);
    haukeSet.info.latticeDepth2 = p(latticeDepth2,1);
    haukeSet.info.dynamicsTime = p(4,1);
    haukeSet.info.smoothing = smoothing;
    
    is = copy(ds.ODDefringedImageSet);
    haukeSet.atomCount = ds.atomCountDefringed;

    % normalize Images
    haukeSet.atomCount = haukeSet.atomCount/mean(haukeSet.atomCount);
    is.everyPixel(@(x)x./haukeSet.atomCount);
    
    % get the real times
    haukeSet.times = squeeze(p(haukeID,:))/100*1e-3;
    haukeSet.imageData = double(is.getRaw3DData());
    
    haukeSet.filter(filterOptions,'smoothing',smoothing); 
    
    dataStructure.haukeSets{iHaukeSet} = haukeSet;
    % define order of parameters here: holdTime=4, runNo=7 (HaukeTime=6)
    % take DataPoints(1) as they all should be the same
    parameters(iHaukeSet,:) = p([4 runID],1);    

    iHaukeSet = iHaukeSet +1


end
%%
parameters = parameters(1:iHaukeSet-1,:);
[C,~,ic] = unique(parameters(:,1));
dataStructure.times = C;
parameters(:,1) = squeeze(ic);
dataStructure.parameters = parameters;

%% do this only when not saving
    dataStructure.createFFTs();
