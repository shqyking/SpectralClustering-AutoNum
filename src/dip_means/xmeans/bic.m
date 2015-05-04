%% Bayesian Inference Criterion
% calculates the BIC score for a model given:
% Inputs
% - x the input dataset
% - idx the cluster index each datapoint belongs to
% - mu the cluster centroids
% - K the number of clusters
% Outputs
% - score the BIC score for the given model
function score = bic(X, idx, mu)
% calculate the model and data parameters from the input vectors
[N, d] = size(X);
k = size(mu,1);
% MLE of the variance
variance = (1/(N-k)) * sum(sum(((X - mu(idx,:)).^2), 2));
% calculate the number of free parameters, p
p = k-1 + d*k + 1;
% calculate the log-likelhood for each cluster
likelihood = NaN(k, 1);
for i = 1:k
    Ni = length(idx(idx == i));
    likelihood(i) = (-Ni*log10(2*pi) - Ni*d*log10(variance) - (Ni-k))/2 + Ni*(log10(Ni) - log10(N));
end
% the total log likelihood is simply the linear sum of the individual log likelihoods
likelihood = sum(likelihood);

% calculate the BIC score
score = likelihood - (p*log10(N)) / 2;
