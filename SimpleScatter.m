function SimpleScatter(X,Y,fig_title,plot_titles,gradient_span)
X_range=X:X+size(Y,2)-1;
Fig_Size=[0 0 1500 1000];

%% Daily increase
Graphs=struct([]);
for count=1:size(Y,1)
    if numel(nonzeros(Y(count,:)))>5
        Graphs(count).Subplot=[ceil(size(Y,1)/4),4,count];
        start = find(Y(count,:)>0,1);
        x=X_range(start+1:end);
        y=Y(count,start:end);
        y=y(2:end)-y(1:end-1);
        Graphs(count).x_DailyInc=x;
        Graphs(count).y_DailyInc=y;
        
        x_fit=day(x-(x(1)));
        Grad=[];
        parfor epoch_idx=1:size(x_fit,2)-gradient_span+1
            f= fit(x_fit(epoch_idx:epoch_idx+gradient_span-1)',y(epoch_idx:epoch_idx+gradient_span-1)','poly1');
            Grad(epoch_idx)=f.p1;
        end
        
        Graphs(count).x_Grad=x(gradient_span:end);
        Graphs(count).y_Grad=Grad;
        Graphs(count).title=plot_titles(count);
    end
end

disp(['DailyIncrease_',fig_title])
h=figure ('Name',['DailyIncrease_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x_DailyInc,Graphs(graph_count).y_DailyInc,'.')
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end

disp(['Grad of DailyIncrease_',fig_title])
h=figure ('Name',['Grad of DailyIncrease_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x_Grad,Graphs(graph_count).y_Grad,'.')
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end



%% Fitting exponential and sigmoid and plotting on log
Graphs=struct([]);
parfor count=1:size(Y,1)
    if numel(nonzeros(Y(count,:)))>2
        start = find(Y(count,:)>0,1);
        Graphs(count).Subplot=[ceil(size(Y,1)/4),4,count];
        x=X_range(start:end);
        y=Y(count,start:end);
        Graphs(count).x=x;
        Graphs(count).y1=y;
        x_fit=day(x-(x(1)));
        [f_exp]= fit(x_fit',y','exp1');
        Graphs(count).y2=f_exp(x_fit);
        [f_sig]= SigmoidFit(x_fit,y);
        Graphs(count).y3=f_sig(x_fit);
        Graphs(count).title=plot_titles(count);
    end
end

disp(['',fig_title])
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

disp(['Log_',fig_title])
h=figure ('Name',['Log_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x,log(Graphs(graph_count).y1),'.')
        hold on
        plot(Graphs(graph_count).x,log(Graphs(graph_count).y2),'r')
        plot(Graphs(graph_count).x,log(Graphs(graph_count).y3),'g')
        hold off
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end



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

disp(['Gradient_',fig_title])
h=figure ('Name',['Gradient_',fig_title]);
set(h, 'Position', Fig_Size);
for graph_count=1:size(Graphs,2)
    if ~isempty(Graphs(graph_count).Subplot)
        subplot(Graphs(graph_count).Subplot(1),Graphs(graph_count).Subplot(2),Graphs(graph_count).Subplot(3))
        scatter(Graphs(graph_count).x,Graphs(graph_count).y,'.')
        title(Graphs(graph_count).title,'Interpreter', 'none')
        grid on
        grid minor
    end
end



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

disp(['Goodness of Fit_',fig_title])
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

end

