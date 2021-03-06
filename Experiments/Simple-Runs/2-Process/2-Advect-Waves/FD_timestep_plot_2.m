%% FD_timestep_plot
% Plotting routing for simple-thermo-advect run

if mod(FSTD.i,1) == 0
    
    cols = [228,26,28
        55,126,184
        77,175,74
        152,78,163
        255,127,0]/256;
    
    
    subplot(211)
    
    if FSTD.i == 1
        
        hold on
        
        tauadvect = OPTS.Domainwidth / ADVECT.v1;
        
        V_in = integrate_FSTD(ADVECT.FSTD_in,FSTD.Hmid,FSTD.dA,0); % The total ice volume (area-weighted) in the pack ice
        
        V_init = DIAG.FSTD.Vtot(1);
        
        % Compute the advective-only solution
        V_adv = V_in + exp(1).^(-FSTD.time/tauadvect)*(V_init - V_in);
        
        % Compute the full solution
        tauadvect = OPTS.Domainwidth / ADVECT.v1;
        
        plot(FSTD.time/86400,V_adv,'--','color',cols(1,:),'linewidth',2)
        OPTS.h1 = plot(DIAG.FSTD.time(1:FSTD.i)/86400,DIAG.FSTD.Vtot(1:FSTD.i),'--','color',cols(5,:),'linewidth',2);
        OPTS.h2 = scatter(DIAG.FSTD.time(FSTD.i)/86400,DIAG.FSTD.Vtot(FSTD.i),200,'filled','markerfacecolor',cols(5,:));
        
        grid on
        box on
        xlabel('Time (days)')
        title('Ice Volume')
        ylabel('m^3/m^2')
        set(gca,'ydir','normal','layer','top','fontname','helvetica','fontsize',14)
        legend('Predicted','Calculated')
        pos = [16 8];
        set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches');
        set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches');
        xlim([0 FSTD.time(end)/86400]);
        a = get(gca,'ylim');
        a(1) = 0;
        set(gca,'ylim',a);
    else
        
        delete(OPTS.h1)
        delete(OPTS.h2)
        OPTS.h1 = plot(DIAG.FSTD.time(1:FSTD.i)/86400,DIAG.FSTD.Vtot(1:FSTD.i),'--','color',cols(5,:),'linewidth',2);
        OPTS.h2 = scatter(DIAG.FSTD.time(FSTD.i)/86400,DIAG.FSTD.Vtot(FSTD.i),200,'filled','markerfacecolor',cols(5,:));
        
    end
    
    
    
    subplot(234)
    
    if FSTD.i == 1
        OPTS.h3 = plot(DIAG.FSTD.time(1:FSTD.i)/86400,DIAG.FSTD.conc(1:FSTD.i),'-','color',cols(3,:),'linewidth',2);
        grid on
        box on
        xlabel('Time (days)')
        title('Ice Concentration')
        ylabel('m^2/m^2')
        set(gca,'ydir','normal','layer','top','fontname','helvetica','fontsize',14)
        hold on
        c0 = integrate_FSTD(ADVECT.FSTD_in,1,FSTD.dA,1);
        plot(FSTD.time/86400,0*FSTD.time + c0,'--k')
        xlim([0 FSTD.time(end)/86400]);
        ylim([0 1])
        
    else
        
        delete(OPTS.h3)
        OPTS.h3 = plot(DIAG.FSTD.time(1:FSTD.i)/86400,DIAG.FSTD.conc(1:FSTD.i),'-','color',cols(3,:),'linewidth',2);
        
    end
    
    subplot(235)
    
    if FSTD.i == 1
        OPTS.h4 = plot(DIAG.FSTD.time(1:FSTD.i)/86400,DIAG.FSTD.Hmean(1:FSTD.i),'-','color',cols(3,:),'linewidth',2);
        hold on
        
        grid on
        box on
        xlabel('Time (days)')
        title('Mean Ice Thickness')
        ylabel('m')
        set(gca,'ydir','normal','layer','top','fontname','helvetica','fontsize',14)
        h0 = integrate_FSTD(ADVECT.FSTD_in,FSTD.Hmid,FSTD.dA,1);
        plot(FSTD.time/86400,0*FSTD.time + h0,'--k')
        xlim([0 FSTD.time(end)/86400]);
        a = get(gca,'ylim');
        a(1) = 0;
        set(gca,'ylim',a);
        
    else
        
        delete(OPTS.h4)
        OPTS.h4 = plot(DIAG.FSTD.time(1:FSTD.i)/86400,DIAG.FSTD.Hmean(1:FSTD.i),'-','color',cols(3,:),'linewidth',2);
        
    end
    
    subplot(236)
    
    if FSTD.i == 1
        
        OPTS.h5 = plot(DIAG.FSTD.time(1:FSTD.i)/86400,DIAG.FSTD.Rmeannum(1:FSTD.i),'-','color',cols(3,:),'linewidth',2);
        hold on
        
        grid on
        box on
        xlabel('Time (days)')
        title('Mean Floe Size')
        ylabel('m')
        set(gca,'ydir','normal','layer','top','fontname','helvetica','fontsize',14)
        
        r0 = ADVECT.FSTD_in ./ (pi * FSTD.meshRmid.^2);
        
        r0 = integrate_FSTD(r0,FSTD.Rmid',FSTD.dA,1);
        
        % Calculating peak wavelength
%        r1 = sum(WAVES.spec.*[WAVES.Lambda(1) diff(WAVES.Lambda)].*WAVES.Lambda)./sum(WAVES.spec.*[WAVES.Lambda(1) diff(WAVES.Lambda)]);
        % This is R which is half the wavelength of the peak period
%        R_longterm = r1/2;
        % This is the initial mean floe size
        R_init = FSTD.psi ./ (pi * FSTD.meshRmid.^2);
        R_init = integrate_FSTD(R_init,FSTD.Rmid',FSTD.dA,1);
        
 %       R_pred = R_longterm + exp(1).^(-FSTD.time/WAVES.tau)*(R_init - R_longterm);
        
 %       plot(FSTD.time/86400,R_pred,'--','color',cols(3,:));
        
%        plot(FSTD.time/86400,0*FSTD.time + R_longterm,'--k');
        
        
        plot(FSTD.time/86400,0*FSTD.time + r0,'--k')
        xlim([0 FSTD.time(end)/86400]);
        a = get(gca,'ylim');
        a(1) = 0;
        set(gca,'ylim',a);
        
    else
        
        delete(OPTS.h5)
        OPTS.h5 = plot(DIAG.FSTD.time(1:FSTD.i)/86400,DIAG.FSTD.Rmeannum(1:FSTD.i),'-','color',cols(3,:),'linewidth',2);
        
    end
    
    
    
end

drawnow


if FSTD.i == OPTS.nt
    
    pos = [16 8];
    set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches');
    set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches');
    saveas(gcf,'~/Dropbox/FSTD/Manuscripts/FSTD-Code-Feedbacks/Figures/Waves-Advect/Waves-Advect.fig')
    saveas(gcf,'~/Dropbox/FSTD/Manuscripts/FSTD-Code-Feedbacks/Figures/Waves-Advect/Waves-Advect.pdf')
    
end


