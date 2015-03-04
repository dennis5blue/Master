delay = [0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]; % sec
plotTrellis = [1394976 2046696 2675456 3332104 3801560 4412992 4632200 5117848]./(8*1024);
plotGreedy = [1332840 1992480 1992480 2649128 3134776 3584128 4383920 4994056]./(8*1024);
plotClusGreedy = [3314728 4395616 4395616 5413824 6325032 8410368 9209528 9209528]./(8*1024);

% Create a stacked bar chart using the bar function
figure(1);

plot(delay,plotGreedy,'*-','LineWidth',2,'DisplayName','Max reduction first','Color','b','MarkerSize',10); hold on;
plot(delay,plotTrellis,'^-','LineWidth',2,'DisplayName','Trellis based algorithm','Color','g','MarkerSize',10); hold on;
plot(delay,plotClusGreedy,'o-','LineWidth',2,'DisplayName','Cluster based greedy algorithm','Color','r','MarkerSize',10);
legend('show','location','best');
axis([-inf inf -inf inf]);
%set(gca,'XDir','reverse');

%title('Gathered Information');
ylabel('Gathered inforamtion (kB)');
xlabel('Tolerable delay (sec)');
grid on;