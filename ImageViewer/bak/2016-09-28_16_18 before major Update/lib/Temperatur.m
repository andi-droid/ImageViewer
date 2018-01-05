function tempintf = Temperatur(z)
y=@(x) dilog2(x)./x;
tempintf = (nthroot(6*quad(y,-z,0),3)).^(-1);