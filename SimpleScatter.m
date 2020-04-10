function SimpleScatter(X,Y,fig_title,plot_titles,gradient_span)
warning('off','all')

X_range=X:X+size(Y,2)-1;
Fig_Size=[0 0 1500 1000];

%% Daily increase
Graphs=struct([]);
for count=1:size(Y,1)
    if numel(nonzeros(Y(count,:)))>5
        Graphs(count).Subplot=[ceil(size(Y,1)/4),4,count];
        start = find(Y(count,:)>0,1);
        x=X_range(start:end);
        y=Y(count,start:end);
        Graphs(count).cumulative=y;
        y=[y(1),(y(2:end)-y(1:end-1))];
        Graphs(count).x_DailyInc=x;
        Graphs(count).y_DailyInc=y;
        
        [f_p1]= fit(Graphs(count).cumulative',Graphs(count).y_DailyInc','poly1');
        Graphs(count).FitP1=f_p1(Graphs(count).cumulative);
        [f_p2]= fit(Graphs(count).cumulative',Graphs(count).y_DailyInc','poly2');
        Graphs(count).FitP2=f_p2(Graphs(count).cumulative);
        
        x_fit=day(x-(x(1)));
        Grad=[];
                
        parfor epoch_idx=1:size(x_fit,2)-gradient_span+1
            warning('off','all')
            f= fit(x_fit(epoch_idx:epoch_idx+gradient_span-1)',y(epoch_idx:epoch_idx+gradient_span-1)','poly1');
            Grad(epoch_idx)=f.p1;
        end
        
        upper_lim=length(x_fit);
        if upper_lim>29+gradient_span-1
            lower_lim=upper_lim-(29+gradient_span-1);
        else
            lower_lim=1;
        end
        
        Grad_DailyCumm_epoch=NaN(1,upper_lim-gradient_span+1);
        Grad_DailyCumm_cont=NaN(1,upper_lim-gradient_span+1);
        Final_CummVal=NaN(1,upper_lim-gradient_span+1);
        End_Date_parabola=NaT(1,upper_lim-gradient_span+1);
        First_Date=x(1);
        Cumm_temp=Graphs(count).cumulative;
        
        parfor epoch_idx=lower_lim:upper_lim-gradient_span+1
            f= fit(Cumm_temp(epoch_idx:epoch_idx+gradient_span-1)',y(epoch_idx:epoch_idx+gradient_span-1)','poly1');
            Grad_DailyCumm_epoch(epoch_idx)=f.p1;
            
            f= fit(Cumm_temp(1:epoch_idx+gradient_span-1)',y(1:epoch_idx+gradient_span-1)','poly1');
            Grad_DailyCumm_cont(epoch_idx)=f.p1;
                        
            f= fit(Cumm_temp(1:epoch_idx+gradient_span-1)',y(1:epoch_idx+gradient_span-1)','poly2');
            if f.p1<0
            FinalNum=max(roots ([f.p1 f.p2 f.p3]));
            Final_CummVal(epoch_idx)=FinalNum;
            
            f= fit(Cumm_temp(epoch_idx:epoch_idx+gradient_span-1)',x_fit(epoch_idx:epoch_idx+gradient_span-1)','poly1');
            End_Date_parabola(epoch_idx)=First_Date+f(FinalNum);               
            end
        end
        
        Graphs(count).x_Grad=x(gradient_span:end);
        Graphs(count).y_Grad=Grad;
        Graphs(count).Grad_DailyCumm_epoch=Grad_DailyCumm_epoch;
        Graphs(count).Grad_DailyCumm_cont=Grad_DailyCumm_cont;
        Graphs(count).Final_CummVal=Final_CummVal;
        Graphs(count).End_Date_parabola=End_Date_parabola;
        Graphs(count).title=plot_titles(count);
        
        idx=~isnan(Grad_DailyCumm_cont);
        x_temp=Graphs(count).x_Grad(idx);
        x_fit_temp=day(x_temp-x_temp(1));
        y_temp=Grad_DailyCumm_cont(idx);
        First_Date_temp=x_temp(1);
        End_Date_grad=NaT(1,length(x_temp)-gradient_span+1);
        parfor epoch_idx=1:length(x_temp)-gradient_span+1
            f= fit(x_fit_temp(epoch_idx:epoch_idx+gradient_span-1)',y_temp(epoch_idx:epoch_idx+gradient_span-1)','poly1');
            if f.p1<0
            End_Date_grad(epoch_idx)=First_Date_temp+(-f.p2/f.p1);
            end
        end
        Graphs(count).End_Date_grad=End_Date_grad;
        Graphs(count).End_Date_grad_x=x_temp(gradient_span:end);
    end
end


h=figure ('Name',['Daily v/s Cummu_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).cumulative,Graphs(graph_count).y_DailyInc,[],hsv(length(Graphs(graph_count).cumulative)),'.')
        hold on
        plot(Graphs(graph_count).cumulative,Graphs(graph_count).FitP1,'r')
        plot(Graphs(graph_count).cumulative,Graphs(graph_count).FitP2,'g')
        hold off
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Daily increase as a funct. of total')


h=figure ('Name',['Grad of Daily v/s Cummu_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        idx=~isnan(Graphs(graph_count).Grad_DailyCumm_epoch);
        scatter(Graphs(graph_count).x_Grad(idx),Graphs(graph_count).Grad_DailyCumm_epoch(idx),[],hsv(sum(idx)),'.')
        hold on
        idx=~isnan(Graphs(graph_count).Grad_DailyCumm_cont);
        plot(Graphs(graph_count).x_Grad(idx),Graphs(graph_count).Grad_DailyCumm_cont(idx),'.-')
        hold off
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Gradient of Daily increase v/s Total')

h=figure ('Name',['Predicted No. of cases_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        idx=~isnan(Graphs(graph_count).Final_CummVal);
        scatter(Graphs(graph_count).x_Grad(idx),Graphs(graph_count).Final_CummVal(idx),[],hsv(sum(idx)),'.')
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Eventual No. of cases (predicted by parabola)')


h=figure ('Name',['Predicted End Date_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        idx=~isnat(Graphs(graph_count).End_Date_parabola);
        x_pts=Graphs(graph_count).x_Grad(idx);
        y_pts=Graphs(graph_count).End_Date_parabola(idx);
        plot(x_pts,y_pts,'.-m')
        hold on
                
        x_pts=x_pts(end-gradient_span+1:end);
        y_pts=y_pts(end-gradient_span+1:end);
        f=fit(day(x_pts-x_pts(1))',day(y_pts-y_pts(1))','poly1');
        plot(x_pts(1):x_pts(1)+19,y_pts(1)+f(0:19),'--r')
        
        idx=~isnat(Graphs(graph_count).End_Date_grad);
        x_pts=Graphs(graph_count).End_Date_grad_x(idx);
        y_pts=Graphs(graph_count).End_Date_grad(idx);
        plot(x_pts,y_pts,'.-c')
        x_pts=x_pts(end-gradient_span+1:end);
        y_pts=y_pts(end-gradient_span+1:end);
        f=fit(day(x_pts-x_pts(1))',day(y_pts-y_pts(1))','poly1');
        plot(x_pts(1):x_pts(1)+19,y_pts(1)+f(0:19),'--b')
        
        plot(x_pts(1):x_pts(1)+24,x_pts(1):x_pts(1)+24,'-k')
                
        hold off
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Predicted End Date_')


h=figure ('Name',['DailyIncrease_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x_DailyInc,Graphs(graph_count).y_DailyInc,[],hsv(length(Graphs(graph_count).x_DailyInc)),'.')
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Daily Increase')


h=figure ('Name',['Grad of DailyIncrease_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x_Grad,Graphs(graph_count).y_Grad,[],hsv(length(Graphs(graph_count).x_Grad)),'.')
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Gradient of Daily Increase')


%% Fitting exponential and sigmoid and plotting on log
Graphs=struct([]);
parfor count=1:size(Y,1)
    warning('off','all')
    if numel(nonzeros(Y(count,:)))>2
        start = find(Y(count,:)>0,1);
        Graphs(count).Subplot=[ceil(size(Y,1)/4),4,count];
        x=X_range(start:end);
        y=Y(count,start:end);
        Graphs(count).x=x;
        Graphs(count).y1=y;
        x_fit=day(x-(x(1)));
        [f_exp]= fit(x_fit',y','exp1'); %'linearinterp'
        Graphs(count).y2=f_exp(x_fit);
        [f_sig]= SigmoidFit(x_fit,y);
        Graphs(count).y3=f_sig(x_fit);
        Graphs(count).title=plot_titles(count);
    end
end


h=figure ('Name',fig_title);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x,Graphs(graph_count).y1)
        hold on
        plot(Graphs(graph_count).x,Graphs(graph_count).y2,'r')
        plot(Graphs(graph_count).x,Graphs(graph_count).y3,'g')
        hold off
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Total No. of cases')



h=figure ('Name',['Log_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x,log(Graphs(graph_count).y1))
        hold on
        plot(Graphs(graph_count).x,log(Graphs(graph_count).y2),'r')
        plot(Graphs(graph_count).x,log(Graphs(graph_count).y3),'g')
        hold off
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Log of total number of cases (exponent v/s time)')


%% Gradient
Graphs=struct([]);
for count=1:size(Y,1)
    if numel(nonzeros(Y(count,:)))>gradient_span
        start = find(Y(count,:)>0,1);
        x=X_range(start:end);
        y=Y(count,start:end);
        x_fit=day(x-(x(1)));
        Grad=[];
        parfor epoch_idx=1:size(x_fit,2)-gradient_span+1
            f= fit(x_fit(epoch_idx:epoch_idx+gradient_span-1)',y(epoch_idx:epoch_idx+gradient_span-1)','poly1');
            Grad(epoch_idx)=f.p1;
        end
        Graphs(count).Subplot=[ceil(size(Y,1)/4),4,count];
        Graphs(count).x=x(gradient_span:end);
        Graphs(count).y=Grad;
        Graphs(count).title=plot_titles(count);
    end
end


h=figure ('Name',['Gradient_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x,Graphs(graph_count).y,[],hsv(length(Graphs(graph_count).x)),'.')
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end
sgtitle('Gradient of total number of cases')


%% Goodness of fit of exp vs sigmoid
Graphs=struct([]);
for count=1:size(Y,1)
    if numel(nonzeros(Y(count,:)))>5
        start = find(Y(count,:)>0,1);
        x=X_range(start:end);
        y=Y(count,start:end);
        x_fit=day(x-(x(1)));
        GoF=[];
        parfor epoch_idx=3:size(x_fit,2)
            [~,GoF_exp]= fit(x_fit(1:epoch_idx)',y(1:epoch_idx)','exp1');
            [~,GoF_sig]= SigmoidFit(x_fit(1:epoch_idx),y(1:epoch_idx));
            GoF=[GoF;[GoF_exp.adjrsquare,GoF_sig.adjrsquare]];
        end
        Graphs(count).Subplot=[ceil(size(Y,1)/4),4,count];
        Graphs(count).x=x(3:end);
        Graphs(count).y1=GoF(:,1);
        Graphs(count).y2=GoF(:,2);
        Graphs(count).y3=GoF(:,2)-GoF(:,1);
        Graphs(count).title=plot_titles(count);
    end
end


h=figure ('Name',['Goodness of Fit_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x,Graphs(graph_count).y1,'.r')
        hold on
        scatter(Graphs(graph_count).x,Graphs(graph_count).y2,'.g')
        scatter(Graphs(graph_count).x,Graphs(graph_count).y3,'.k')
        hold off
        title(Graphs(graph_count).title,'Interpreter', 'none')
        ylim([-0.1 1.1])
        grid on
        grid minor
    end
end
sgtitle('Goodness of Fit - Exponential and Sigmoid')


end

