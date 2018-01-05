B = [0,1,2,3,0,1,2,3,0,1];
C = [1,4,5,2,3,1,6,1,4,2,3,1];
[Bc,ia,ib] =unique(B,'stable');

            for i=1:numel(ia)
                match = ib==i;
                % careful here xxx
                sel = C(match);
                Cneu(i) = mean(sel);
            end