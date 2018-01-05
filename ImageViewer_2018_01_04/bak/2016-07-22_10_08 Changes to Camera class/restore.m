clear all;
close all;

addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib'
addpath '/afs/physnet.uni-hamburg.de/project/bfm/Benutzer/Dominik/projects/2016-05-09 MatlabLib/GUI'
addpath('figs');
addpath('core');
addpath('lib');
addpath('../../compareExpTheo/core/'); % for the shakenBGH class
addpath('../../');

load temp3.mat;
dataStructure.createFFTs();
%generateAveragedRunII;
%timeInterpolate;