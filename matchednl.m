function ynon=matchednl(x,u)
% Nonlinear matched filter
% SYNTAX: ynon=matchednl(x,u) 
MM=length(x);         
hh=fliplr(x)/norm(x); % flipped and normalized, |h|=1
y=filter(hh,1,u);
z=filter(ones(1,MM),1,u.^2); % z_n=u_n^2+..+u_{n-M}^2
ynon=y./sqrt(eps+z);  % added eps to avoid /0
  
