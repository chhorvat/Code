%% Update_local_variables

% This script updates all of the variables that change on the order of
% one internal timestep but are not reset, mostly counting variables



% Marginal Distributions
FSTD.FSD = sum(bsxfun(@times,FSTD.psi,FSTD.dH),2);
FSTD.ITD = sum(bsxfun(@times,FSTD.psi,FSTD.dR'),1);

% How much time left to go in the timestep
OPTS.dt_sub = OPTS.dt_sub - OPTS.dt_temp;

% Counter of sub-cycles, both per global timestep and in totality
OPTS.numSC = OPTS.numSC + 1;
OPTS.totnum = OPTS.totnum + 1;

%%

% How much volume is in the largest floe class.
FSTD.V_max = FSTD.V_max + OPTS.dt_temp*FSTD.dV_max;

% To ensure the code converges, if this value is too small, we just set it
% to zero. If it is that small, then the maximum thickness is just equal to
% the initial value we set for the maximum thickness. 
if abs(FSTD.V_max) < 1e-8 % && sum(FSTD.ITD(1:end-1).*FSTD.H) < eps
    FSTD.V_max = 0; 
    FSTD.H_max = FSTD.H_max_i;
    FSTD.A_max = 0; 
    if integrate_FSTD(FSTD.ITD,FSTD.H,FSTD.dH,0) < eps
    FSTD.psi = 0*FSTD.psi; 
    end
else
    FSTD.A_max = integrate_FSTD(FSTD.psi(:,end),1,FSTD.dA(:,end),0);
end

% if FSTD.H_max > 10 && FSTD.A_max < 1e-6
%     disp('H_max is too huge. This is likely just an I.C. issue. Deleting the ice area there.')
%     disp('If this message re-appears a bunch, need to examine the code.')
%     disp(['Timestep ' num2str(FSTD.i)])    
%     FSTD.psi(:,end) = 0; 
%     FSTD.A_max = 0; 
%     FSTD.V_max = 0; 
% end


% The mean thickness is equal to the sum of the 
FSTD.Hmean = integrate_FSTD(FSTD.psi,FSTD.Hmid,FSTD.dA,1);

if FSTD.Hmean == 0
    FSTD.Hmean = OPTS.h_p;
end

Ameps = 0;

if FSTD.A_max == 0
    
    Ameps = eps;
    FSTD.V_max = 0; 
    
end

% The top category thickness is simply the ratio of the volume to the
% concentration

% if FSTD.i == 42
%     disp('ok')
% end

FSTD.H_max = FSTD.V_max / (Ameps + FSTD.A_max);

if FSTD.H_max == 0
    FSTD.H_max = FSTD.H_max_i; 
end

FSTD.Hmid(end) = FSTD.H_max; 
%% We need to correct for changes to the thickest class of ice. 

% If the thickest ice category decreases in thickness so that it becomes
% thinner than the right-most boundary of the thickest non-variable ice
% thickness category, we have to adjust where the ice is. 

if size(FSTD.H,2) > 1 && FSTD.H_max < FSTD.H(end)
 %%   
    % This is the total volume in the thickest ice class (variable) and in
    % the maximum ice thickness category
    V_i = integrate_FSTD(FSTD.psi,[FSTD.Hmid(1:end-1) FSTD.H_max],FSTD.dA,0); 
    c_i = integrate_FSTD(FSTD.psi,1,FSTD.dA,0); 
    % For V_max = A * H_max = A' * H_end, this becomes an area A' = A * H_max / H_end
    % Now we add this volume to the smaller thickness category, adjusting
    % it appropriately
    % Here is the total amount of ice concentration belonging to this
    % category
    
    % The initial concentration in the thickest category


    
    H0 = FSTD.H_max; 
    
    % Now we find the thickness category to which all the ice will go. 
    [a,b] = find(FSTD.Hmid < H0);
    ind = b(end); 
    
    psi0 =  FSTD.psi(:,end);
    dA0 = FSTD.dA(:,end);
    dA1 = FSTD.dA(:,ind); 
    dA2 = FSTD.dA_i(:,end); 
    
    H1 = FSTD.Hmid(ind); 
    H2 = FSTD.H_mid_max_i; 
    

    % This area must be transformed in order to conserve volume into ice
    % of a lower thickness. 
    
    % This is done according to the following:
    % c_i = c(end-1) + c(end)
    % v_i = c(end-1) * H(end-1) + c(end) * H_i
    
    % Where c(end-1) = psi(end-1) * dA(end-1)    
    % and H_i is the initial maximum sea ice thickness
    
    % The solution to this set of equations is
    % c_1 = (v_i + H_i c_i) / (H(end-1) + H_i)
    % c_2 = c_i - c_1
    
    psi_1 = (psi0 .* dA0 ./ dA1) * (H0 - H2) / (H1 - H2); 
    psi_2 = (psi0 .* dA0 - psi_1 .* dA1)./dA2; 
    
    FSTD.psi(:,ind) = FSTD.psi(:,ind) + psi_1; 
    FSTD.psi(:,end) = psi_2; 
    
    FSTD.H_max = FSTD.H_max_i;
    FSTD.Hmid(end) = FSTD.H_mid_max_i; 
    
    V_f = integrate_FSTD(FSTD.psi,FSTD.Hmid,FSTD.dA_i,0); 
    c_f = integrate_FSTD(FSTD.psi,1,FSTD.dA_i,0); 

    if abs(V_i - V_f)/V_i > 1e-4
        FSTD.eflag = 1;
        disp('Exchange of Volume at Thickest Size is a Problem')
    end
    
    if abs(c_i - c_f)/c_i > 1e-4
        FSTD.eflag = 1;
        disp('Exchange of Concentration at Thickest Size is a Problem')
    end
    
    FSTD.dA = FSTD.dA_i; 
    
end



% now update the time!

FSTD.time_now = FSTD.time_now + OPTS.dt_temp;
