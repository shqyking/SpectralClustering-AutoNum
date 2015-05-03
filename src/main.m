% load the datasets
cd ../data/
listing = dir;
listing = listing(3:length(listing));
datasets = cell(length(listing),1);
for i=1:length(listing)
    datasets{i} = load(listing(i).name);
end
cd ../src/

W = getKnnGraph(datasets{1}, 10, false);
D = getDegree(W);
L = getLaplacian('rw', W, D);
[eigVec, eigVal] = eig(L);
