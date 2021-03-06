%% FD_timestep_advect
% We think of the advective velocities as being u(x) + dudx * L
% Therefore we consider an advective flux at each end of the domain
% If there is convergence, this means there is an additional flux at the
% left side
% If there is divergence, the same is true at the right side

% Shear does not lead to advective changes in the ice concentration, though
% it will do so when there is mechanical forcing.

% This code is very simple. It requires v2, the velocity of the ice at the
% eastern boundary, and v1, the velocity of the ice at the western
% boundary. Additionally, the FSTD of ice at the western boundary is
% required. It is assumed that the eastern boundary.

% The outgoing advective flux is equal to the velocity of the ice,
% multiplied by the FSTD divided by the domain width (to get units of per
% unit time)


%% Need to re-adjust ADVECT.FSTD_in

% ADVECT.FSTD_in is written in reference to this initial floe size
% discretization. It has an initial concentration and volume. 

% I.e. at FSTD.i = 1, integrate_FSTD(ADVECT.FSTD_in,1,FSTD.dA,1) = in_conc; 
% And integrate_FSTD(ADVECT.FSTD_in,FSTD.Hmid,FSTD.dA,1) = in_vol;

% However FSTD.dA will change over time. This means that so will in_vol and
% in_conc, if we evaluate them at each timestep. Therefore we need to
% re-adjust the incoming FSTD to account for the shifting discretization. 

FSTD_input = ADVECT.FSTD_in .* FSTD.dA_i ./ FSTD.dA; 

% if MECH is on, ADVECT.v2 is zero. 
ADVECT.out = ADVECT.v2 * FSTD.psi; 

% If it is off, we have no way to stop advecting things in, so we have an
% advective velocity out that depends on the local conc
ADVECT.in = ADVECT.v1 * FSTD_input; 

ADVECT.diff = ADVECT.in - ADVECT.out; 

ADVECT.diff = ADVECT.diff / OPTS.Domainwidth; 

% Really just V_max_delta


ADVECT.V_max_in = FSTD.H_max_i*sum(ADVECT.v1*ADVECT.FSTD_in(:,end).*FSTD.dA_i(:,end)); 

ADVECT.V_max_in = ADVECT.V_max_in / OPTS.Domainwidth;

ADVECT.V_max_out = FSTD.H_max*sum(ADVECT.out(:,end).*FSTD.dA(:,end));
ADVECT.V_max_out = ADVECT.V_max_out / OPTS.Domainwidth; 

% Pretty simple
ADVECT.opening = -sum(ADVECT.diff(:).*FSTD.dA(:));

