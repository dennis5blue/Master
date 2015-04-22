clc;
clear;

time = [0.2 0.4 0.6 0.8 1.0 1.2 1.4]; % sec
trellis = [28.9598 29.5429 29.9164 30.2003 30.6299 31.3172 31.6835];
greedySNR = [28.9432 29.4944 29.9860 30.4781 30.8502 31.1287 31.4953];
greedySNRNoCorr = [28.5421 28.9907 29.2754 29.5148 30.0543 30.4931 30.9749];
crossEntropy = [28.9432 29.4865 30.0490 30.4728 30.9104 31.3103 31.6953];

trellisSupNum = [1 2 4 5 6 7 8];
greedySNRSupNum = [1 2 3 4 5 7 8];
crossEntropySupNum = [1 3 4 5 6 7 8];

% Plot PSNR
figure(1);
plot(time,trellis,'*-','LineWidth',2,'DisplayName','Trellis based algorithm','Color','b','MarkerSize',10); hold on;
plot(time,greedySNR,'^-','LineWidth',2,'DisplayName','Greedy with correlation','Color','r','MarkerSize',10); hold on;
plot(time,crossEntropy,'^-','LineWidth',2,'DisplayName','Cross entropy algorithm','Color','c','MarkerSize',10); hold on;
plot(time,greedySNRNoCorr,'^-','LineWidth',2,'DisplayName','Greedy without correlation','Color','g','MarkerSize',10);
legend('show','location','NorthWest');
axis([-inf inf -inf inf]);
ylabel('Average PSNR');
xlabel('Available transmission time (sec)');
grid on;

% Plot number of supported cameras
figure(2);
plot(time,trellisSupNum,'*-','LineWidth',2,'DisplayName','Trellis based algorithm','Color','b','MarkerSize',10); hold on;
plot(time,crossEntropySupNum,'*-','LineWidth',2,'DisplayName','Cross entropy algorithm','Color','c','MarkerSize',10); hold on;
plot(time,greedySNRSupNum,'^-','LineWidth',2,'DisplayName','Greedy algorithm','Color','r','MarkerSize',10);
legend('show','location','NorthWest');
axis([-inf inf -inf inf]);
ylabel('Number of supported cameras');
xlabel('Available transmission time (sec)');
grid on;