%% preamble
clear all;
addpath('../lib'); % for ImageSet and OD imageset and dataset
addpath('core');
addpath('figs');
addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib'
addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib/GUI'

%% define Selection
selection.Name = 'First_Selection_for_Paper';
oldPath = '/afs/physnet.uni-hamburg.de/project/bfm/Auswertung/2016/2016_01/2016_01_05_MTCompensation/Analysis/dominik/averageAndFit/data/averaged/';
newPath = '/afs/physnet.uni-hamburg.de/project/bfm/Auswertung/2016/2016_05/2016_05_19_Doublequench/dominik/data/averaged/';
selection.workingPath = newPath; % this is the path where all the data is being saved
rawSelection = {...
    oldPath, '2016_02_04_Double_quench_11kHz9_2kHz_recropped.mat', 2:3, {'oldNonTrivial', 'oldTrivial'};
    newPath, '2016_06_03_Double_Quench_11.236kHz_2kHz_40V6-42V4', 13, {'Trivial'};
    newPath, '2016_06_03_Double_Quench_11.236kHz_2kHz_41V12-41V24', 3:6, {'NonTrivial1','NonTrivial2','NonTrivial3'}...
    };
selection.sets = cell2struct(rawSelection, {'path', 'fileName', 'runs', 'names'},2);        

%% check if Selection already exists
selection.path = [selection.workingPath  'selection/'];
selection.fileName = [selection.path selection.Name '.mat'];
if exist(selection.fileName, 'file') == 2
    fsprintf('Selection already exists: %s\n loading\n', selection.fileName);
    load(selection.fileName);
else
    % make File containing Selection
    v.mkdir(selection.path);
    
    % go through all files, check if they have been loaded once before and
    % extract given sets
    for iFile=1:size(selection.sets, 1)
        
        % load file
        currentPathBare = [selection.workingPath 'bare/' selection.sets(iFile).fileName];
        currentPath = [selection.workingPath selection.sets(iFile).fileName];
        if exist(currentPathBare, 'file') == 2 && 1 
            fprintf('re-loading: %s\n', selection.sets(iFile).fileName);
            load(currentPathBare);
        elseif ~exist(currentPath,'file') == 2
            fsprintf('Could not find file: %s\n skipping\n', selection.sets(iFile).fileName);
            continue;
        else
            fprintf('loading: %s\n', selection.sets(iFile).fileName);
            load(currentPath);
        end
        
        % extract sets
        fprintf('extracting sets');
    end
end
    