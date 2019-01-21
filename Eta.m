function contradiction = Eta(tabu, allow, colnum)
 contradiction = zeros(size(allow));
 m = 1;
 for i = allow
     row = floor((i-1)/colnum)+1;
     col = mod(i-1,colnum)+1;
     
     
     leftslash = row + col - 2;
     rightslash = colnum - 1 + col - row;
     taburow = floor((tabu-1)/colnum)+1;
     tabucol = mod((tabu-1),colnum)+1;
     tabuleftslash = taburow + tabucol - 2;
     taburightslash = colnum - 1 + tabucol - taburow;
     
     colcontra = sum(row == taburow);
     rowcontra = sum(col == tabucol);
     slashcontra = sum(leftslash == tabuleftslash) + sum(rightslash == taburightslash);
     contradiction(m) = colcontra + rowcontra + slashcontra;
     m=m+1;
 end
 
     
     
 