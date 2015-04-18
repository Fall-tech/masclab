function mu = viscosity(T);

%mks units for dynamic viscosity;

T0 = 273.15;
mu0 = 1.74e-5; %Pa.s at 0 C
mu = mu0.*sqrt(T/T0);
