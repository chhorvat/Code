function [THERMO] = setmner_1D_thermo_petty(FSTD,OPTS,THERMO,OCEAN,EXFORC)
%% function [dhdt,T] = semtner_1D_thermo(Q,h)
% In this function we will calculate
% THERMO.dhdt_surf - the surface melt rate of ice of thickness h
% THERMO.dhdt_bas - the basal melt rate
% THERMO.Q_cond - the conductive heat flux through the ice
% THERMO.Q_vert - the net heating at the surface of the ice - zero if not
% melting. 
% THERMO.T_ice - The surface temperature of the ice

%% These fluxes are created in a region in which there is only ice
% aka a 1-column sea ice model. The heat flux from the ocean, which is
% given as OCEAN.Q_bas, is expressed as the total such heating in the
% entire grid. It therefore has to be divided by the sea ice concentration
% to get the flux to each individual square meter of sea ice. 
Q_bas = THERMO.Q_bas / FSTD.conc;

% dhdt is the total time rate of change of ice thickness in each thickness
% category
% THERMO.Q_cond is the conductive flux per thickness category (positive = melting)
% THERMO.Q_vert is the surface heat budget (0 if not melting). 
% T is the temperature of the ice per thickness category

rho_0 = 917; %kg/m^3 density of ice
L_0 = 334000; %J/kg latent heat of freezing of ice
kappa_I = 2.034; %J/(s deg C m)
sigma = 5.67e-8; % Boltzmann constant
T_B = OCEAN.Tfrz; % Degrees C (temp of bottom)

THERMO.Q_vert = zeros(1,length(FSTD.Hmid)); 
THERMO.Q_cond = THERMO.Q_vert; 
THERMO.dhdt_surf = THERMO.Q_vert; 

q_s = rho_0 * L_0 ; % Enthalpy of freezing/melting of surface ice
qbase = q_s * .9; 

%% For each thickness 
for i = 1:length(FSTD.Hmid)
  
    %%
    H = FSTD.Hmid(i);
    T_ice = THERMO.T_ice(i);
    
    % The conductive heat flux from the upper surface to the lower
    % > 0 implies cooling of surface (rare, or when near melting)
    % < 0 implies warming of surface (otherwise)
    cond_HF = @(T_i) kappa_I * (T_i - T_B)./H;
    
    % The surface heat flux from the balance of fluxes - conductive
    LW_out = @(T_i) sigma*(T_i+273.14).^4;
    
    if OCEAN.DO
        
        SH_out = @(T) OCEAN.do_SH * OCEAN.rho_a * OCEAN.c_a * OCEAN.CD_i * OCEAN.U_a * (T - OCEAN.T_a);
        LH_out = @(T) OCEAN.do_LH * OCEAN.rho_a * OCEAN.L_s * OCEAN.CD_i * OCEAN.U_a * (OCEAN.qsat(T) - OCEAN.q_a);
        LW_out = @(T) OCEAN.epsilon_i * OPTS.sigma * (T + 273.14).^4;
        LW_in = OCEAN.epsilon_i * OCEAN.LW;
        SW_in = (1 - OCEAN.alpha_i) * OCEAN.SW;
        
        surf_HF = @(T) ...
            LW_in + ... % Longwave absorption at ice surface
            SW_in - ... % Shortwave absorption at ice surface
            LH_out(T) - ... % Latent heat flux from ice surface
            SH_out(T) - ... % Sensible heat flux out of ice surface
            LW_out(T) - ...    % Longwave heat flux out of ice surface
            cond_HF(T); % Conductive heat flux out of ice surface
    else
    
    surf_HF = @(T_i) EXFORC.Q_ic_noLW - cond_HF(T_i) - LW_out(T_i);
    
    end
    
    % Find the temperature which equalizes the conductive flux and the
    % surface heat balance, near T_0.     
    THERMO.T_ice(i) = fzero(surf_HF,T_ice); % New ice temperature
 %%  Now fix if the temperature would allow for melting
    if THERMO.T_ice(i) > 0 % melting point of fresh sea ice
        % Set the temperature to 0
        THERMO.T_ice(i) = 0;
        % Calculate the budget at 0 temperature
        THERMO.Q_vert(i) = surf_HF(THERMO.T_ice(i)); % >0 when not balanced (THERMO.T_ice = 0).
        % Includes the conductive heat flux
        THERMO.Q_cond(i) = cond_HF(THERMO.T_ice(i)); % < 0 almost always.
        
        % The melting is now done so as to balance the heat budget
        % The total heat input is the residual THERMO.Q_vert
        THERMO.dhdt_surf(i) = -THERMO.Q_vert(i)/q_s; %
        
    else
        
        THERMO.dhdt_surf(i) = 0;
        
        % THERMO.Q_cond is the conductive heat flux 
        THERMO.Q_cond(i) = cond_HF(THERMO.T_ice(i));
        
    end
    
end
    
% Want to calculate the mean heat exchange fields. Since these are per
% thickness category, we take the average field across the thickness
% categories
dum = sum(FSTD.psi.*FSTD.dA,1); 
dum = dum / sum(dum); 
if isnan(dum)
    dum = 0; 
end

% Outgoing latent heat flux
THERMO.Q_LH_ice = sum(dum.*LH_out(THERMO.T_ice));
% Outgoing sensible heat flux
THERMO.Q_SH_ice = sum(dum.*SH_out(THERMO.T_ice)); 
% Outgoing longwave
THERMO.LW_out_ice = sum(dum.*LW_out(THERMO.T_ice)); 
% Incoming SW
THERMO.Q_SW_in_ice = sum(dum.*SW_in); 
% Incoming LW
THERMO.Q_LW_in_ice = sum(dum.*LW_in);

%Qbase is positive for melting
% Lose thickness due to input from water to ice
% Lose thickess due to heat flux from ice surface to ice base
THERMO.dhdt_base = -(Q_bas/qbase + THERMO.Q_cond / qbase); 
    
THERMO.surf_HF = surf_HF(FSTD.Hmid); 
    
