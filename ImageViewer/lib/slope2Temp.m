function [Temp] = slope2Temp(slope)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

kb = 1.38064852*10^-23; %Boltzmann const
u = 1.660539*10^-27;
m = 6*u; %mass of atom
M = 4; %magnification
px = 6.45*10^-6; %pixel size
tu = 10^-3; %time unit

Temp = (m/kb)*slope/(tu^2)*(px/M)^2;


end

