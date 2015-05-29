clc;
clear;

addpath('../Utility');
N = 10;
res.X = 1280;
res.Y = 720;
reg.X = 16;
reg.Y = 9;
schedule = [10 4 5 1 3 2 8 9 6 7];
bits = 8.*dlmread(['../../SourceData/test4_png/test_phase_0.txt']);
rate = bits./(res.X*res.Y); % in bpp
tmp = ceil(bits./(reg.X*reg.Y));
% rate and size for each regions (an approximated approach)
for i = 1:N
    eval(['matsBits.cam' num2str(i) '=tmp(' num2str(i) ')*ones(reg.Y,reg.X);']);
end

% Initial txRegions
for i = 1:N
    eval(['txRegs.cam' num2str(i) '=ones(reg.Y,reg.X);']);
end

indepTxBits = [];
overTxBits = [];
temp = [];

for i = 1:N
    cam = schedule(i);
    temp = [temp cam];
    if length(indepTxBits) > 0
        bb = indepTxBits(length(indepTxBits)) + bits(cam);
    else
        bb = bits(cam);
    end
    indepTxBits = [indepTxBits bb];
    overTxBits = [overTxBits CalTxBits('../../SourceData/test4_png/', temp, matsBits, reg)
];  
end
indepTxBits = indepTxBits./(8*1024);
overTxBits = overTxBits./(8*1024);

figure(1);
num = [1:10];
plot(num,indepTxBits,'*-','LineWidth',2,'DisplayName', ...
    'Independent source coding','Color','b','MarkerSize',10); hold on;
plot(num,overTxBits,'*-','LineWidth',2,'DisplayName', ...
    'Overhearing source coding','Color','r','MarkerSize',10);

leg = legend('show','location','NorthWest');
set(leg,'FontSize',16);
axis([-inf inf -inf inf]);
ylabel('Amount of useful data (kB)','FontSize',12);
xlabel('Number of cameras','FontSize',12);
grid on;