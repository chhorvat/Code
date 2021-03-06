%% Plot FSD

set(gcf,'currentaxes',PLOTS.ax_FSD);


if FSTD.i == 1
    
    PLOTS.p1 = pcolor([0 FSTD.time/86400],FSTD.Rint,log10(squeeze(sum(bsxfun(@times,DIAG.FSTD.psi,DIAG.FSTD.dA),2)+eps)));
    
else
    
    if isfield(PLOTS,'p1')
        
        delete(PLOTS.p1)
        
    end
    
    % determine interpolation grid: from min to max in equal steps
    ax1 = [0 FSTD.time/86400];
    ax1 = ax1(1:skip_contour:end);
    ax2 = FSTD.Rint;
    
    Ax1v = linspace(ax1(1),ax1(end),numel(ax1));
    Ax2v = linspace(ax2(1),ax2(end),numel(ax2));
    
    [ax1,ax2] = meshgrid(ax1,ax2);
    [Ax1,Ax2] = meshgrid(Ax1v,Ax2v);
    
    
    plotter = log10(squeeze(sum(bsxfun(@times,DIAG.FSTD.psi(:,:,1:skip_contour:end),DIAG.FSTD.dA(:,:,1:skip_contour:end)),2)+eps));
    
    int = interp2(ax1,ax2,plotter,Ax1,Ax2);
    
    PLOTS.p1 = pcolor(Ax1v,Ax2v,int);
    hold on
    
    %  PLOTS.p1 = pcolor([0 FSTD.time/86400],FSTD.Rint,log10(squeeze(sum(bsxfun(@times,DIAG.FSTD.psi,DIAG.FSTD.dA),2)+eps)));
    %  shading interp
    set(gca,'clim',[-4 0])
    set(gca,'yscale','log')
    
    if FSTD.i == OPTS.nt && WAVES.DO
        
        
        [a,b] = max(WAVES.spec);
        
        % This is R which is half the wavelength of the peak period
        R_longterm = FSTD.Rmid(b);
        plot(FSTD.time/86400,0*FSTD.time + R_longterm,'-k','linewidth',2)
        
    end
    
    
    if FSTD.i == OPTS.nt
        
        hold on
        
        imcontour(ax1,FSTD.Rint,log10(squeeze(sum(bsxfun(@times,DIAG.FSTD.psi(:,:,1:skip_contour:end),DIAG.FSTD.dA(:,:,1:skip_contour:end)),2)+eps)),[-4:1:0],'--k','showtext','on');
        
        
        hold off
        
    end
    
    
end

shading interp
axis xy
grid on
box on
ylabel('Floe Size')
title('log_{10} of FSD(r)dr')
xlabel('Time')
set(gca,'ydir','normal','layer','top','fontname','helvetica','fontsize',14)
ylim([FSTD.Rint(1) FSTD.Rint(end)]);
set(gca,'clim',[-2 0])
shading interp
colorbar

%% Plot ITD

set(gcf,'currentaxes',PLOTS.ax_ITD);


if length(FSTD.Hmid) > 1
    if FSTD.i == 1
        
        PLOTS.p2 = pcolor([0 FSTD.time/86400],FSTD.Hmid,log10(squeeze(sum(bsxfun(@times,DIAG.FSTD.psi,DIAG.FSTD.dA),1)+eps)));
        
        hold on
        
        
    else
        
        if isfield(PLOTS,'p2')
            delete(PLOTS.p2)
        end
        
        % determine interpolation grid: from min to max in equal steps
        ax1 = [0 FSTD.time/86400];
        ax1 = ax1(1:skip_contour:end);
        
        ax2 = FSTD.Hmid_i;
        
        Ax1v = linspace(ax1(1),ax1(end),numel(ax1));
        Ax2v = linspace(ax2(1),ax2(end),numel(ax2));
        
        [ax1,ax2] = meshgrid(ax1,ax2);
        [Ax1,Ax2] = meshgrid(Ax1v,Ax2v);
        
        
        
        plotter = log10(squeeze(sum(bsxfun(@times,DIAG.FSTD.psi(:,:,1:skip_contour:end),DIAG.FSTD.dA(:,:,1:skip_contour:end)),1)+eps));
        
        int = interp2(ax1,ax2,plotter,Ax1,Ax2);
        
        PLOTS.p2 = pcolor(Ax1v,Ax2v,int);
        
        
        if FSTD.i == OPTS.nt
            hold on
            imcontour(ax1,ax2,log10(squeeze(sum(bsxfun(@times,DIAG.FSTD.psi(:,:,1:skip_contour:end),DIAG.FSTD.dA(:,:,1:skip_contour:end)),1)+eps)),[-4:1:0],'--k','showtext','on');
            hold off
            
            
        end
    end
end

grid on
box on
ylabel('Floe Size')
title('log_{10} of ITD(h)dh')
xlabel('Time')
set(gca,'ydir','normal','layer','top','fontname','helvetica','fontsize',14)

if length(FSTD.Hmid > 1)
    % ylim([FSTD.Hmid(1) FSTD.Hmid_i(end)]);
end

set(gca,'clim',[-4 0])
shading interp
axis xy
colorbar
