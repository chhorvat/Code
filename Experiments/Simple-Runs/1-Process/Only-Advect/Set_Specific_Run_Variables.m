function [FSTD,OPTS,THERMO,MECH,WAVES,DIAG,EXFORC,OCEAN,ADVECT]  = Set_Specific_Run_Variables(FSTD,OPTS,THERMO,MECH,WAVES,DIAG,EXFORC,OCEAN,ADVECT) 
%% Which Processes Will Be Used?
% In order to validate a process, it must be added to this call here

FSTD.DO = 1; % Do the main model stuff
OCEAN.DO = 0; % Whether or not to use the ocean model. 
MECH.DO = 0;
THERMO.DO = 0;
WAVES.DO = 0; % Wave Fracture
ADVECT.DO = 1; % Advection Package
DIAG.DO = 1; % Diagnostics Package

%% Diagnostics Options
DIAG.DOPLOT = 1; % Plot Diagnostics?

%% Set Advection Options
OPTS.Domainwidth = 1e4; 

EXFORC = load_forcing_fields(EXFORC,OPTS,FSTD.time);

var = [5^2 .125^2];
% Make a Gaussian at thickness 1.5 m and size 25 m with variance var.

psi = 0*mvnpdf([0*FSTD.meshR(:) FSTD.meshH(:)],[150 2],var);
psi = reshape(psi,length(FSTD.Rint),length(FSTD.H));
psi(63,10) = 1; 

ADVECT.FSTD_in = psi/ sum(psi(:).*FSTD.dA(:));  

ADVECT.prescribe_ice_vels = 1; 

%% Initial Conditions

psi = 0*mvnpdf([0*FSTD.meshR(:) FSTD.meshH(:)],[150 2],var);
psi = reshape(psi,length(FSTD.Rint),length(FSTD.H));
psi(25,5) = 1; 


% Initial concentration is 50%
FSTD.psi = .25*psi/ sum(psi(:).*FSTD.dA(:)); 