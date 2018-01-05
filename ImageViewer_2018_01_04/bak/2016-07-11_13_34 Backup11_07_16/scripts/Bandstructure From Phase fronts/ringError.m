function e = ringError(val, x)
xy = v.discreteCircle(x(1:2),x(3));
s = 0;
for i = 1:size(xy,2)
    if xy(2,i) < size(val,1) && xy(1,i) < size(val,2)
        s = s + log(1+val(xy(2,i),xy(1,i)));
    end
    %o.val(xy(2,i),xy(1,i)) = x(3)/33;;
end
e = 1/s*size(xy,2);
end