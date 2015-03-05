clc;
clear;

name = { '1280*720' };
cam1 = [52118 0 0]./1024;
cam1refcam2 = [0 52413 0]./1024;
cam1refcam3 = [0 0 45214]./1024;

myBar1 = bar(cam1,'r','barwidth',0.6,'Facecolor',[1 0 0]); hold on;
myBar2 = bar(cam1refcam2,'g','barwidth',0.6,'Facecolor',[0 1 0]); hold on;
myBar3 = bar(cam1refcam3,'b','barwidth',0.6,'Facecolor',[0 0 1]);

set(gca,'xticklabel',' ');
ylim([40 52]);
ylabel(gca,'Frame size (kB)','FontSize',13);
legend('Independent encoding','Reference from cam1','Reference from cam2');
grid on;