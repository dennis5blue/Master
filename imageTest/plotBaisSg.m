clc;
clear;

figure(1);
indep = 57766;
%fullsearch256 = [(indep-68727)/indep 0 0 0 0];
%fullsearch128 = [0 (indep-73762)/indep 0 0 0];
bais0 = [(indep-57030)/indep 0 0 0 0];
bais100 = [0 (indep-37068)/indep 0 0 0];
%bais96 = [(70148-indep)/indep]
bais200 = [0 0 (indep-35008)/indep 0 0];
%bais160 = [(84515-indep)/indep]
bais300 = [0 0 0 (indep-34348)/indep 0];
bais400 = [0 0 0 0 (indep-56874)/indep];

x = [1:length(bais0)];
bar(x, 100.*bais0, 'FaceColor', [1 0.5 0], 'DisplayName','Conventional motion estimation'); hold on;
bar(x, 100.*bais100, 'FaceColor', [0 0.5 0.2], 'DisplayName','Biased pixels = 100'); hold on;
bar(x, 100.*bais200, 'FaceColor', [0 0.5 0.4], 'DisplayName','Biased pixels = 200'); hold on;
bar(x, 100.*bais300, 'FaceColor', [0 0.5 0.6], 'DisplayName','Biased pixels = 300'); hold on;
bar(x, 100.*bais400, 'FaceColor', [0 0.5 0.8], 'DisplayName','Biased pixels = 400');

leg = legend('show','location','NorthWest');
set(leg,'FontSize',11);
axis([-inf inf 0 60]);
set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
ylabel('Reduced encoded bits (%)','FontSize',11);
xlabel('');
grid on;

%{
figure(2);
fullsearch256Time = [49*60+51 0 0 0 0];
fullsearch128Time = [0 14*60+44 0 0 0];
%bais32Time = [4*60+10]
bais64Time = [0 0 4*60+5 0 0];
%bais96Time = [4*60+5]
bais128Time = [0 0 0 4*60+9 0];
%bais160Time = [4*60+17]
bais192Time = [0 0 0 0 4*60+9];

x = [1:length(fullsearch128Time)];
bar(x, fullsearch256Time, 'FaceColor', [1 0.5 0], 'DisplayName','Full search (range = 256)'); hold on;
bar(x, fullsearch128Time, 'FaceColor', [0 0.5 0.2], 'DisplayName','Full search (range = 128)'); hold on;
bar(x, bais64Time, 'FaceColor', [0 0.5 0.4], 'DisplayName','Baised full search (range = 128, baised pixels = 64)'); hold on;
bar(x, bais128Time, 'FaceColor', [0 0.5 0.6], 'DisplayName','Baised full search (range = 128, baised pixels = 128)'); hold on;
bar(x, bais192Time, 'FaceColor', [0 0.5 0.8], 'DisplayName','Baised full search (range = 128, baised pixels = 192)');

leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf 0 inf]);
set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
ylabel('Encoded time (sec)');
xlabel('');
grid on;
%}
