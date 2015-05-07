cd ../data/artificial/
artificial = dir;
artificial = artificial(3:length(artificial)); % exclude the current dir and parent dir
datasets = cell(12,1);
for i=1:length(artificial)
    datasets{i} = load(artificial(i).name);
end
cd ../realworld
realworld = dir;
realworld = realworld(3:length(realworld));
for i=1:length(realworld)
   datasets{i+6} = load(realworld(i).name);
end
cd ../../src

K = cell(9,1);

% boat : 3, m range from 6 - 15
D = size(datasets{1},2);
Ks = zeros(10,3);
for i=1:10
    Ks(i,1) = heuristic(datasets{1}(:,2:D),13, i+5);
    Ks(i,2) = randomWalk(datasets{1}(:,2:D), 13, i+5, false);
    Ks(i,3) = guido(datasets{1}(:,2:D), 13, i+5);
end
K{1} = Ks;
disp('boat');

% easy_doughnut : 2, m from 5-12
D = size(datasets{2},2);
Ks = zeros(8,3);
for i=1:8
    Ks(i,1) = heuristic(datasets{2}(:,2:D),12, i+4);
    Ks(i,2) = randomWalk(datasets{2}(:,2:D), 12, i+4, false);
    Ks(i,3) = guido(datasets{2}(:,2:D), 12, i+4);
end
K{2} = Ks;
disp('easy');

% four_gauss : 4 m from 10 - 28
D = size(datasets{3},2);
Ks = zeros(10,3);
for i=1:10
    Ks(i,1) = heuristic(datasets{3}(:,2:D),14, 2*i+8);
    Ks(i,2) = randomWalk(datasets{3}(:,2:D), 14, 2*i+8, false);
    Ks(i,3) = guido(datasets{3}(:,2:D), 14, 2*i+8);
end
K{3} = Ks;
disp('4gauss');

% moon : 2 m from 39-42
D = size(datasets{4},2);
Ks = zeros(4,3);
for i=1:4
    Ks(i,1) = heuristic(datasets{4}(:,2:D),12, i+38);
    Ks(i,2) = randomWalk(datasets{4}(:,2:D), 12, i+38, false);
    Ks(i,3) = guido(datasets{4}(:,2:D), 12, i+38);
end
K{4} = Ks;
disp('moon');

% noisy_lines : 2 , m from 7-15
D = size(datasets{5},2);
Ks = zeros(9,3);
for i=1:9
    Ks(i,1) = heuristic(datasets{5}(:,2:D),12, i+6);
    Ks(i,2) = randomWalk(datasets{5}(:,2:D), 12, i+6, false);
    Ks(i,3) = guido(datasets{5}(:,2:D), 12, i+6);
end
K{5} = Ks;
disp('noisy');

% regular : 16, m from 5-10
D = size(datasets{6},2);
Ks = zeros(6,3);
for i=1:6
    Ks(i,1) = heuristic(datasets{6}(:,2:D),25, i+4);
    Ks(i,2) = randomWalk(datasets{6}(:,2:D), 25, i+4, false);
    Ks(i,3) = guido(datasets{6}(:,2:D), 25, i+4);
end
K{6} = Ks;
disp('regular');

% glass : 7 m from 5-12
D = size(datasets{7},2);
Ks = zeros(8,3);
for i=1:8
    Ks(i,1) = heuristic(datasets{7}(:,2:D),17, i+4);
    Ks(i,2) = randomWalk(datasets{7}(:,2:D), 17, i+4, true);
    Ks(i,3) = guido(datasets{7}(:,2:D), 17, i+4);
end
K{7} = Ks;
disp('glass');

% iris : 3 m from 11 - 29
D = size(datasets{8},2);
Ks = zeros(10,3);
for i=1:10
    Ks(i,1) = heuristic(datasets{8}(:,2:D),13, 2*i+9);
    Ks(i,2) = randomWalk(datasets{8}(:,2:D), 13, 2*i+9, false);
    Ks(i,3) = guido(datasets{8}(:,2:D), 13, 2*i+9);
end
K{8} = Ks;
disp('iris');

% wine : 3 m from 20-30
D = size(datasets{9},2);
Ks = zeros(6,3);
for i=1:6
    Ks(i,1) = heuristic(datasets{9}(:,2:D),13, 2*i+18);
    Ks(i,2) = randomWalk(datasets{9}(:,2:D), 13, 2*i+18, false);
    Ks(i,3) = guido(datasets{9}(:,2:D), 13, 2*i+18);
end
K{9} = Ks;
disp('wine');