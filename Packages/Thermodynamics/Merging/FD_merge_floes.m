% function FD_merge_floes.m
% This script is performed in the case of thermodynamic freezing
% When this is occuring, we merge floes together
% This is done at a rate approximately equal to dot(r)/(1-c)^2
if THERMO.DO
    %%
    if THERMO.mergefloes && THERMO.drdt > 0 && FSTD.conc < 1
        %%
        % This is a flag, and we must be freezing in order to merge floes.
        % If the concentration is equal to 1, we must also quit
        
        % get the mean reciprocal size (int r f(r) dr)
        Mn1 = sum_FSTD(FSTD.psi,1./FSTD.meshRmid,0);
        
        
        % This is the total consolidated area, divided by the ice
        % concentration.
        THERMO.alphamerge = 2 * THERMO.drdt * Mn1 / (1 - sum(FSTD.psi(:)));
        
        % If the ice concentration is very close to 1, this becomes a
        % problem. To get around this the most ice that can merge is simply
        % equal to 50% of what exists. This will happen rarely
        
        if THERMO.alphamerge >= 1
            
            THERMO.alphamerge = .5; 
        
        end
        
        THERMO.loss_merge = THERMO.alphamerge * FSTD.psi;
        THERMO.loss_merge = THERMO.loss_merge;
        THERMO.gain_merge = 0*THERMO.loss_merge;
        
        for i = 1:length(FSTD.Rmid)-1
            
            % Largest floe size does not experience merging
            % For each floe size
            
            % This gets the largest multiple (a factor of deltamerge)
            maxR = FSTD.Rmid(i) * THERMO.deltamerge;
            
            % These are all the indices for which we merge into a larger
            % category
            
            isbigg = sum((maxR - FSTD.Rmid(i+1:end) > 0));
            
            
            
            THERMO.gain_merge(i+1:i+isbigg,:) = ...
                bsxfun(@plus,THERMO.gain_merge(i+1:i+isbigg,:),1/isbigg * THERMO.loss_merge(i,:));
            
        end
        
        THERMO.gain_merge(end,:) = THERMO.gain_merge(end,:) + THERMO.loss_merge(end,:);
        
        THERMO.diff_merge = THERMO.gain_merge - THERMO.loss_merge;
        
        
        % This is the volume flux to the largest thickness class
        THERMO.V_max_in_merge = sum(THERMO.diff_merge(:,end)*FSTD.H_max);
        
        
        
        
    else
        
        THERMO.diff_merge = 0*THERMO.diff;
        THERMO.V_max_in_merge = 0*THERMO.V_max_in;
        
    end
else
    
    error('Thermodynamics is not on, cannot merge floes')
    
end

if abs(sum(THERMO.diff_merge(:))) >= eps
   
    error('diff_merge is nonzero')
end
    