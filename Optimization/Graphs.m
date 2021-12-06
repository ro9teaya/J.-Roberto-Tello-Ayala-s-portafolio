[x,y] = meshgrid(0:.1:6);

z = -cos(x).*cos(y).*exp(-(x-pi).^2. - (y-pi).^2.);


surf(x,y,z)

