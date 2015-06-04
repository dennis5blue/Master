clc;
clear;

indep = [6752720 0 0 0]./(8*1024);
greedy = [0 5975694 0 0]./(8*1024);
CE = [0 0 5248250 0]./(8*1024);
BB = [0 0 0 5219335]./(8*1024);
x = [1 2 3 4];

figure(1);
bar(x, indep, 'FaceColor', [1 0 0], 'DisplayName','Independent transmission'); hold on;
bar(x, greedy, 'FaceColor', 'g', 'DisplayName','Greedy scheduling'); hold on;
bar(x, CE, 'FaceColor', 'b', 'DisplayName','Cross entropy scheduling'); hold on;
bar(x, BB, 'FaceColor', 'm', 'DisplayName','Branch-and-bound scheduling');

leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf 400 860]);
ylabel('Transmission bytes (kB)');
xlabel('');
grid on;