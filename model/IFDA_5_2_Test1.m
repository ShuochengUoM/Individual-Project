%cost coefficients
fa = [0.0100; 0.0250; 0.0200; 0.0090; 0.0180; 0.0340];
fa_range = [0.0024,0.0679];

fb = [10.5;   12.0;   15.0;   11.5;   13.0;   9.5];
fb_range = [8.3391,37.6968];

fc = [20; 25; 30; 22; 28; 18];
fc_range = [6.78;74.33];

% supply power bounds
Pmin_range = [5,150];
Pmin = [20; 25; 15; 30; 18; 12];
Pmax_range = [150,400];
Pmax = [180; 200; 160; 220; 170; 150];

% local demand
Pd_range = [0,300];
Pd = [90; 80; 70; 85; 60; 55];

% initial conditions
%Pg0 = [25; 30; 20; 35; 20; 15];
Pg0 = [0;0;0;0;0;0];
lambda0 = zeros(6,1);
z0 = zeros(6,1);

% ring communication graph Laplacian
Lg = [ 2 -1  0  0  0 -1;
     -1  3 -1  0  -1  0;
      0 -1  3 -1  0  -1;
      0  0 -1  2 -1  0;
      0  -1  0 -1  3 -1;
     -1  0  -1  0 -1  3];








