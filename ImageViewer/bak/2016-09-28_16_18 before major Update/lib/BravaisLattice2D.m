classdef BravaisLattice2D <handle
    properties
        b1
        b2
        center
    end
    
    methods
        function ret = V(o)
            ret = (o.b1(1)*o.b2(2)-o.b1(2)*o.b2(1))/(2*pi);
        end
        function ret = a1(o)
            ret = [o.b2(2) -o.b2(1)]/o.V();
        end
        function ret = a2(o)
            ret = [-o.b1(2) o.b1(1)]/o.V();
        end
        function ret = M(o)
            % M b1 = e1
            ret = 1/(2*pi)*[o.a1; o.a2];
        end
        function ret = alpha(o)
            ret = -0.5*o.V()/(2*pi)*dot(o.a1()+o.a2(), o.a1());
        end
        function ret = beta(o)
            ret = 0.5*o.V()/(2*pi)*dot(o.a1()+o.a2(), o.a2());
        end
        
        function p  = getGPoint(o)
            p = o.center;
        end
        
        function ret = BZ1(o)
         %   ret = o.cellPoly([0 0]');
            ret = zeros(7,2);           
            ret(1,:) =  o.b1/2 - o.alpha*o.V*o.a2;
            ret(2,:) =  o.b2/2 - o.beta* o.V*o.a1;
            ret(3,:) = -o.b1/2 - o.alpha*o.V*o.a2;
            ret(4,:) = -o.b2/2 - o.beta* o.V*o.a1;
            ret(5,:) = -o.b2/2 + o.beta* o.V*o.a1;
            ret(6,:) =  o.b1/2 + o.alpha*o.V*o.a2;
            ret(7,:) =  o.b1/2 - o.alpha*o.V*o.a2;
            ret(:,1) = ret(:,1)+o.center(1);
            ret(:,2) = ret(:,2)+o.center(2);
        end
        
        function points = reciprocalPoints(o, nK)
            % lattice points in circle of nk radius
            % in mn lattice basis
            angle = linspace(1,360, 30)';
            circle = nK*[sind(angle) cosd(angle)];
            n_m = mtimes(o.M, circle')';
            top_right   = ceil(max(n_m));
            bottom_left = floor(min(n_m));
            [Yb Xb] = ndgrid(bottom_left(2):top_right(2),bottom_left(1):top_right(1));
            [INb ONb] = inpolygon(Xb,Yb,n_m(:,1),n_m(:,2));
            points = [Yb(INb==1|ONb==1) Xb(INb==1|ONb==1)];
        end
        
        function [points, arragement] = L(o, nK)
            % lattice points in circle of nk radius
            % in kx ky Basis
            % sorted by their distance to zero
            % giving their arragnement
            lattice_points = o.reciprocalPoints(nK);
            L = lattice_points(:,1)*o.b1 + lattice_points(:,2)*o.b2;
            dists = L(:,1).^2 + L(:,2).^2;
            [dists, ind] = sort(dists);
            L = L(ind,:);
            L(:,1) = L(:,1) + o.center(1);
            L(:,2) = L(:,2) + o.center(2);
            points = L;
            [~, m, ~] = unique(round(dists*100000)/100000,'first');
            % check noutargs
            arragement = NaN(numel(m),2);
            for iCircle = 1:(numel(m)-1)
                arragement(iCircle,:) =  [m(iCircle); m(iCircle+1)-1];
            end
            arragement(numel(m),:) =  [m(end); size(points,1)];            
        end
        
        function p  = getKPoint(o, n)
            switch(n)
                case 1, d = o.b1/2 - o.alpha*o.V*o.a2;
                case 2, d =-o.b1/2 - o.alpha*o.V*o.a2;
                case 3, d =-o.b2/2 + o.beta* o.V*o.a1;
                otherwise, error('n has to be in [1,2,3]');
            end
            p = o.center +  d';
        end
        
        function p  = getKPrimePoint(o, n)
            switch(n)
                case 1, d = o.b2/2 - o.beta* o.V*o.a1;
                case 2, d =-o.b2/2 - o.beta* o.V*o.a1;
                case 3, d = o.b1/2 + o.alpha*o.V*o.a2;
                otherwise, error('n has to be in [1,2,3]');
            end
            p = o.center +  d';
        end
        
        function [b, v, a] = braggPlanes(o, nK)
            [L, a] = o.L(nK);
            Lp(:,1) = L(:,1) - o.center(1);
            Lp(:,2) = L(:,2) - o.center(2);
            b(:,1) = 0.5*Lp(:,1)+o.center(1);
            b(:,2) = 0.5*Lp(:,2)+o.center(2);
            v(:,1) = Lp(:,2);
            v(:,2) = -Lp(:,1);
        end
        
        function [ls, le] = braggPlaneLines(o, nK, length)
            [b, v, ~] = o.braggPlanes(nK);
            nLines = size(b,1);
            ls = NaN(nLines,2);
            le = NaN(nLines,2);
            for i=1:nLines
                ls(i,:) = b(i,:)+length*v(i,:);
                le(i,:) = b(i,:)-length*v(i,:);
            end
        end
        
        function poly = cellPoly(o, mn)
            poly = zeros(7,2);           
            poly(1,:) =  o.b1/2 - o.alpha*o.V*o.a2;
            poly(2,:) =  o.b2/2 - o.beta* o.V*o.a1;
            poly(3,:) = -o.b1/2 - o.alpha*o.V*o.a2;
            poly(4,:) = -o.b2/2 - o.beta* o.V*o.a1;
            poly(5,:) = -o.b2/2 + o.beta* o.V*o.a1;
            poly(6,:) =  o.b1/2 + o.alpha*o.V*o.a2;
            poly(7,:) =  o.b1/2 - o.alpha*o.V*o.a2;
            poly(:,1) = poly(:,1)+mn(1)*o.b1 + o.center(1);
            poly(:,2) = poly(:,2)+mn(2)*o.b2 + o.center(2);
        end
        
        function [X Y] = cellPolies(o, nK)
            L = o.L(nK);
            nCells = size(L,1);
            poly = zeros(7,2);           
            poly(1,:) =  o.b1/2 - o.alpha*o.V*o.a2;
            poly(2,:) =  o.b2/2 - o.beta* o.V*o.a1;
            poly(3,:) = -o.b1/2 - o.alpha*o.V*o.a2;
            poly(4,:) = -o.b2/2 - o.beta* o.V*o.a1;
            poly(5,:) = -o.b2/2 + o.beta* o.V*o.a1;
            poly(6,:) =  o.b1/2 + o.alpha*o.V*o.a2;
            poly(7,:) =  o.b1/2 - o.alpha*o.V*o.a2;
            X = zeros(7, nCells);
            Y = zeros(7, nCells);
            for iCell = 1:nCells
                X(:,iCell) = poly(:,1) + L(iCell,1);
                Y(:,iCell) = poly(:,2) + L(iCell,2);
            end
        end
    end
    
end

