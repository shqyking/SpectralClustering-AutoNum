function [pad, ad] = anderson_darling( data, cv, smallest_cluster )

%%
% Goodness-of-fit test with the Anderson-Darling statistic,
% compares how well the data fits a model with a normal distribution.
% The data should be reduced to 1 dimension (principal component or some
% such).
%
% Input 
%  data : The data matrix [NxD] with N the samples and D dimension
%  cv   : Critical value to be used for the AD-statistic
%  smallest_cluster: the size of cluster lower to which no statistic
%  analysis will be conducted
%
% Output
%  pad  : one or zero, depending on whether the test passed or not
%  ad   : the ad value OR when pad = 0: -1 if the std of the data was 0
%                                       -2 if the cdf returned 1 (log(0) error)
%                                       -3 if there were too few samples
%
% Copyright 2005-2006 Laboratori d'Aplicacions Bioacustiques
% For more information, errors, comments please contact codas@lab.upc.edu
%
% Changes to original release:
%  smallest_cluster has been defined as a parameter insted of an internal
%  variable. Other minor changes might have done. 
%  Argyris Kalogeratos 2012-2013.

if ( nargin < 2 )
    error( 'Syntax: [test, ad] = anderson_darling( data, critical_value )' );
    return;
end

% number of points
n = length(data); % one-dimensional vector

% no point in calculating this for very small values
if ( n < smallest_cluster )
    pad = 0; ad = -3;
    return;
end

% calculate the sample mean and variance
dmean = sum(data) / n; % mean(data); 
dstd  = std(data);

% this function should only be called for data sets larger than 6, 
% in that case a zero standard deviation (all values identical) is
% not likely to have a normal distribution. In order to send back
% the 0 std value for the data to the caller function, ad is set 
% to -1
if ( dstd == 0 )
    pad = 0; ad  = -1;
    return;
end

% normalize the data
Z  = (sort(data) - dmean) / dstd;

% get the cumulative chances on Z
pZ = cdf( 'norm', Z, 0, 1 );

% NOTE : log(0) happens when values attain a cdf of 1, if this happens
% we assume it is not a N(0,1) distribution and we can abort
if ( pZ(n) == 1 )
    pad = 0;
    ad = -2;
    return;
end

% calculate the ad statistic
k  = [1:n];
ad = sum((2*k - 1) .* (log(pZ(k)) + log(1-pZ(n+1-k))));
ad = -(1/n) * ad - n;

% adjust for using sample mean and variance
ad = ad * (1 + 0.75/n + 2.25/n^2);

pad = (ad < cv);
