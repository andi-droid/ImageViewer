function furz3=odfit2(Param,X,Y,Bild)
A = Param(1);
b = Param(2);
sigx = Param(3);
sigy = Param(4);
mx = Param(5);
my = Param(6);
xc  = Param(7);
yc = Param(8);
fug  = Param(9);

furz3 = A.*dilog2(-fug.*exp(-((X-xc).^2)./(2.*sigx.^2)).*exp(-((Y-yc).^2)./(2.*sigy.^2)))./dilog2(-fug)+b+mx.*X+my.*Y - Bild;