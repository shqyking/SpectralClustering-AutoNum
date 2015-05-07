load res1.mat
h = bar(best);
set(gca,'XTickLabel',{'boat', 'doughnut', '4gauss', 'moon','noisy','regular','glass','iris','wine'})
l = cell(4,1);
l{1} = 'target';
l{2} = 'heuristic';
l{3} = 'randomWalk';
l{4} = 'guido';
legend(h,l)

load res2.mat;
average = zeros(9,3);
stddev = zeros(9,3);

for i=1:9
    for j=1:3
       average(i,j) = mean(avg{i}(:,j)); 
       stddev(i,j) = std(avg{i}(:,j));
    end
end

