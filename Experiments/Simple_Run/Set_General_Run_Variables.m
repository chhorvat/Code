function [FSTD,OPTS,THERMO,MECH,WAVES,DIAG,EXFORC,OCEAN,ADVECT]  = Set_General_Run_Variables(OPTS)
% This creates general run variables to use.
% Updated 12/8/2015 - Chris Horvat


% Create the structures
FSTD = struct(); 
THERMO = struct(); 
MECH = struct(); 
WAVES = struct(); 
OCEAN = struct(); 
DIAG = struct(); 
EXFORC = struct(); 
ADVECT = struct();


% Set General options
OPTS.nt = 30*12; % Number of timesteps
OPTS.dt = 86400; % Timestep duration
OPTS.nh = 13; % No. of thickness categories 

DH = .2; % Thickness increment (m)

% Linearly spaced time vector
OPTS.time = linspace(OPTS.dt,OPTS.nt*OPTS.dt,OPTS.nt); 

% Initial discretization. Spaced at spacing to guarantee conservation of
% volume using mechanics. 

FSTD.R(1) = .5;
for i = 2:65
    FSTD.R(i) = sqrt(2*FSTD.R(i-1)^2 - (4/5) * FSTD.R(i-1)^2);
end

OPTS.nr = length(FSTD.R); % Number of size categories
FSTD.H = .1:DH:2.5; % Thickness Vector

OPTS.r_p = .5; % Minimum floe size category
OPTS.h_p = .1; % Minimum thickness category

%% First Run Initialization to get all the default fields we will use 

% Initialize the FSTD Main Parts

%% Set General Thermodynamic Options
THERMO.SHLambda = 0; 


%% Set Swell Fracture Options
OPTS.Domainwidth = 5e4;
WAVES.epscrit = .01;

%% Set Ocean Options
OCEAN.no_oi_hf = 0; 
OCEAN.H = 50; 

OPTS.ociccoeff = 1; 

%% Set Advection Options
ADVECT.in_ice = 0;
ADVECT.out_ice = 0; 