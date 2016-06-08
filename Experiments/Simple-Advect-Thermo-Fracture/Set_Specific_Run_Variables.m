function [FSTD,OPTS,THERMO,MECH,WAVES,DIAG,EXFORC,OCEAN,ADVECT]  = Set_Specific_Run_Variables(FSTD,OPTS,THERMO,MECH,WAVES,DIAG,EXFORC,OCEAN,ADVECT) 
%% Which Processes Will Be Used?
% In order to validate a process, it must be added to this call here

FSTD.DO = 1; % Do the main model stuff
OCEAN.DO = 0; % Whether or not to use the ocean model. 
MECH.DO = 0;
THERMO.DO = 1;
WAVES.DO = 1; % Wave Fracture
ADVECT.DO = 1; % Advection Package
DIAG.DO = 1; % Diagnostics Package

%% Diagnostics Options
DIAG.DOPLOT = 0; % Plot Diagnostics?

%% Set Waves Options and External Forcing
EXFORC.wavespec = zeros(OPTS.nt,length(FSTD.Rmid));

% Pick a swell wave with a peak wavelength near 100 meters
ind = find(FSTD.Rmid > 100,1); 

EXFORC.wavespec(:,ind) = 1; 

%% Set Thermo Options and External Forcing
THERMO.fixQ = 1; % Fix the heat flux

Qin = 300; 

THERMO.fixed_Q = Qin + zeros(1,OPTS.nt); % To be Q_fixed


%% Set Advection Options

var = [5^2 .125^2];

psi = FSTD.meshR.^(1); 
psi = psi./ FSTD.dA;

ADVECT.FSTD_in = psi/sum(psi(:).*FSTD.dA(:)); 

ADVECT.prescribe_ice_vels = 1; 

OCEAN.UVEL = zeros(2,OPTS.nt); 

% UVEL(2) needs to be equal to UVEL(1) unless mechanics is turned on. 
OCEAN.UVEL(1,:) = .4;
OCEAN.UVEL(2,:) = .4; 

%% Initial Conditions

psi = FSTD.meshR.^(-1); 
psi = psi./ FSTD.dA;

FSTD.psi = .5*psi/sum(psi(:).*FSTD.dA(:)); 