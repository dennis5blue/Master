clc;
clear;

% Trellis
trellisSchedule = [8 10 1 5 4 9 2 3 6 7];
trellisPsnr = [28.7706 29.4412 29.7815 30.0648 30.4968 30.8828 31.2503 31.6410 31.8458 32.2934];
trellisReqSlots = [176 332 504 618 843 1009 1201 1406 1502 1718];

% Scheduling metric
metricSchedule = [8 6 5 10 9 1 2 3 7 4];
metricPsnr = [28.7706 29.0417 29.3132 29.9323 30.3778 30.6719 31.0385 31.4603 31.9141 32.2934];
metricReqSlots = [176 272 386 542 708 880 1072 1277 1493 1718];

time = [100:50:2000]; % ms
plotTrellis = [];
plotMetric = [];
for i = 1:length(time)
    avaSlots = time(i);
    psnr = 0;
    for t = 1:length(trellisReqSlots)
        if trellisReqSlots(t) > avaSlots
            break;
        end
        psnr = trellisPsnr(t);
    end
    plotTrellis = [plotTrellis psnr];
    
    psnr = 0;
    for t = 1:length(metricReqSlots)
        if metricReqSlots(t) > avaSlots
            break;
        end
        psnr = metricPsnr(t);
    end
    plotMetric = [plotMetric psnr];
end

figure(1);
stairs(time,plotTrellis,'-','LineWidth',2,'DisplayName','Trellis based algorithm','Color','r','MarkerSize',10); hold on;
%stairs(time,plotMetric,'-','LineWidth',2,'DisplayName','Scheduling metric','Color','g','MarkerSize',10); hold on;
legend('show','location','NorthWest');
axis([-inf inf 28.5 32.5]);
ylabel('Average PSNR');
xlabel('Time (ms)');
grid on;
