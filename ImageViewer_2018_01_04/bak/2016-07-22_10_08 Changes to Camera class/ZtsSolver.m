classdef ZtsSolver < handle
    
    properties
        nstepmax = 2e3  % max number of iterations
        n1 = 100;        % number of images along the string (try from  n1 = 3 up to n1 = 1e4)
        h = 1e-1;       % time-step (limited by the ODE step on line 83 & 84 but independent of n1)
        tol1 = 1e-5     % parameter used as stopping criterion
        % Plotting
        nstepplot = 1e0 % frequency of plotting
        rePlotFunc
        potentialFunc
    end
    
    methods
        function [x, y] = line(o, xa, ya, xb, yb)
            % initialization
            g1 = linspace(0,1,o.n1);
            x = (xb-xa)*g1+xa;
            y = (x-xa)*(yb-ya)/(xb-xa)+ya;
            
            %X = arrayfun(@plus, Xa , kron(g1',(Xb-Xa)/norm(Xb-Xa)));
            [x, y] = o.reparametrize(x, y);
        end
        
        function [x, y] = solve(o, derivativeFunc, x, y)        
            for iStep=1:o.nstepmax
                x0 = x;
                y0 = y;
            
                % string steps:
                [dVx, dVy] = derivativeFunc(x, y);
                % 1. evolve
                x = x + o.h*dVx;
                y = y + o.h*dVy;
                x(1) = x0(1);
                x(end) = x0(end);
                
                % 2. reparametrize
                [x, y] = o.reparametrize(x, y);
                
                if and(~isempty(o.rePlotFunc),mod(iStep,o.nstepplot) == 0)
                    o.rePlotFunc(x,y);
                    o.potentialFunc(dVx, dVy, x, y);
                end
                
                tol = (norm(x-x0)+norm(y-y0))/o.n1;
                if tol <= o.tol1; break; end;
            end
            
        end
        
        function [x, y] = reparametrize(o, xi, yi)
            g1 = linspace(0,1,o.n1);
            dx = xi-circshift(xi,[0 1]);
            dy = yi-circshift(yi,[0 1]);
            dx(1) = 0;
            dy(1) = 0;
            lxy = cumsum(sqrt(dx.^2+dy.^2));
            lxy = lxy/lxy(o.n1);
            
            x = interp1(lxy,xi,g1);
            y = interp1(lxy,yi,g1);
        end
        
    end
    
end

