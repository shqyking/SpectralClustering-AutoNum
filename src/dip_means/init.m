%------------
% Initialization for Dip-means package. Run bistest.m for a demonstration.
%------------
% Copyright (C) 2012-2013, Argyris Kalogeratos.
%------------

fclose('all');
clc;

% copyright/copyleft info
fprintf('Dip-means package v.0.1. Copyright (C) 2012-2013 Argyris Kalogeratos.\n'); 
fprintf('This is free software distributed under the GNU General Public License; for details see LICENSE.txt.\n');

% prepare paths
addpath('./xmeans');
addpath('./gmeans');
addpath('./hartigans');
addpath('./bisecting');
addpath('./var');
addpath('./bisecting');
              
% open important files [optional]
edit('bistest.m');
edit('./bisecting/bisect_kmeans.m');
edit('bisect.m');
edit('test_unimodal_cluster.m');
edit('HartigansDipSignifTest.m');

