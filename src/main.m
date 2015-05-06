% load the datasets
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


% W = getKnnGraph(datasets{1}, 10, false);
% D = getDegree(W);
% L = getLaplacian('rw', W, D);

% Total 12 datasets, first 6 are artifical data, last 6 are real world data
% first column is the tree # of classes
% 2nd column = heuristic, 3rd column = random walk, 4th column = guido
% the name of dataset and corresponding clusters are
% boat:3  easy_doughnut:2 four_gauss:4  moon : 2 noisy_lines:2  regular:16 
% abalone:29  faults:7  glass:6  iris:3  voice:9  wine:3 
K = zeros(12,3);
K = [[3;2;4;2;2;16;29;7;7;3;9;3], K];

% boat : 3
D = size(datasets{1},2);
K(1,2) = heuristic(datasets{1}(:,2:D),13, 15);
K(1,3) = randomWalk(datasets{1}(:,2:D), 13, 10, false);
K(1,4) = guido(datasets{1}(:,2:D), 13, 10);

% easy_doughnut : 2
D = size(datasets{2},2);
K(2,2) = heuristic(datasets{2}(:,2:D),12,10);
K(2,3) = randomWalk(datasets{2}(:,2:D), 12, 6, false);
K(2,4) = guido(datasets{2}(:,2:D), 12, 10);

% four_gauss : 4
D = size(datasets{3},2);
K(3,2) = heuristic(datasets{3}(:,2:D),14,10);
K(3,3) = randomWalk(datasets{3}(:,2:D), 14,22, false);
K(3,4) = guido(datasets{3}(:,2:D), 14, 10);

% moon : 2
D = size(datasets{4},2);
K(4,2) = heuristic(datasets{4}(:,2:D),12,40);
K(4,3) = randomWalk(datasets{4}(:,2:D), 12, 40, false);
K(4,4) = guido(datasets{4}(:,2:D), 12, 40);

% noisy_lines : 2
D = size(datasets{5},2);
K(5,2) = heuristic(datasets{5}(:,2:D),12,14);
K(5,3) = randomWalk(datasets{5}(:,2:D), 12, 8, false);
K(5,4) = guido(datasets{5}(:,2:D), 12, 14);

% regular : 16
D = size(datasets{6},2);
K(6,2) = heuristic(datasets{6}(:,2:D),26,5);
K(6,3) = randomWalk(datasets{6}(:,2:D), 26, 5, false);
K(6,4) = guido(datasets{6}(:,2:D), 26, 5);

%
D = size(datasets{7}, 2);
K(7,2) = heuristic(datasets{7}(:,2:D),27,40);
K(7,3) = randomWalk(datasets{7}(:,2:D), 27, 40, false);
K(7,4) = guido(datasets{7}(:,2:D), 27, 40);

% faults : 7
D = size(datasets{8}, 2);
K(8,2) = heuristic(datasets{8}(:,2:D),27,40);
K(8,3) = randomWalk(datasets{8}(:,2:D), 27, 40, false);
K(8,4) = guido(datasets{8}(:,2:D), 27, 40);

% glass : 7
D = size(datasets{9}, 2);
K(9,2) = heuristic(datasets{9}(:,2:D),27,12);
K(9,3) = randomWalk(datasets{9}(:,2:D), 27, 12, false);
K(9,4) = guido(datasets{9}(:,2:D), 27, 12);
