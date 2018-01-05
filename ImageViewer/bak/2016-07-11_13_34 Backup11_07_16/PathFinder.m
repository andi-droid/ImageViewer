classdef PathFinder < handle
    
    properties
        nstepmax = 2e2  % max number of iterations
        h = 1e-1;       % time-step 
        tol1 = 1e-5     % parameter used as stopping criterion
        % Plotting
        nstepplot = 1e0 % frequency of plotting
        rePlotFunc
        potentialFunc
        
    end
    
    methods
        function [x, y] = solve(o, derivativeFunc, xS, yS)        
            x = xS;
            y = yS;
            for iStep=1:o.nstepmax
                [dVx, dVy] = derivativeFunc(x(end), y(end));
                % 1. evolve
                x = [x  x(end) + o.h*dVx];
                y = [y  y(end) + o.h*dVy];
                
                
                if and(~isempty(o.rePlotFunc),mod(iStep,o.nstepplot) == 0)
                    o.rePlotFunc(x,y);
                    %o.potentialFunc(dVx, dVy, x, y);
                end
                

            end
            
        end
        
    end
    
end

