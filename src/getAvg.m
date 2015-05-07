load res1.mat
best1 = best(1:3,:);
best2 = best(4:6,:);
best3 = best(7:9,:);
l = cell(7,1);
l{1} = 'target';
l{2} = 'heuristic';
l{3} = 'randomWalk';
l{4} = 'guido';
l{5} = 'selfTuning';
l{6} = 'robust';
l{7} = 'dip-means';

h1 = bar(best1);
set(gca,'XTickLabel',{'boat', 'doughnut', '4gauss'})
set(gca,'fontsize',14);
l1 = legend(h1,l);
set(l1,'position',[0 0 0.2 0.2],'FontSize', 14)
ylim([0 6]);

h2 = bar(best2);
set(gca,'XTickLabel',{'half_ring','noisy','regular'})
set(gca,'fontsize',14);
l2 = legend(h2,l,'location','northwest');
set(l2,'position',[0 0 0.2 0.2],'FontSize', 14);

h3 = bar(best3);
set(gca,'XTickLabel',{'glass','iris','wine'})
set(gca,'fontsize',14);
l3 = legend(h3,l);
set(l3,'position',[0 0 0.2 0.2],'FontSize', 14)
ylim([0 15]);


load res2.mat;
average = zeros(9,4);
stddev = zeros(9,4);

for i=1:9
    for j=1:4
       average(i,j) = mean(avg{i}(:,j)); 
       stddev(i,j) = std(avg{i}(:,j));
    end
end
average = [[3;2;4;2;2;16;7;3;3], average];
