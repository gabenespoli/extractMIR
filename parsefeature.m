function [feature,f] = parseFeature(feature,Fs)
% parse a feature name that has filter cutoffs included
% this is specified in the form "feature_locut_hicut"

if nargin > 1, nyquist = floor(Fs / 2); end
f = [];
% check for length of string first to avoid error if feature is < 4 chars long
% make sure more than 4 chars so that 'flux' on its own will pass through
if length(feature) > 4
    % split feature string at underscores, make each a separate var
    % this means flux features must be in this format: flux_lowfreq_highfreq
    % e.g., flux_100_200 for flux between 100 and 200 Hz
    temp = regexp(feature,'_','split');
    feature = temp{1}; % convert from cell to whatever
    if nargin > 1 && length(temp) == 3
        lo = eval(temp{2}); % convert from string to numeric
        hi = eval(temp{3});

        % convert 0 and nyquist to -Inf and Inf (required for mirfilterbank)
        if lo <= 0,         lo = -Inf; end
        if hi >= nyquist;   hi = Inf; end
    
        f = [lo hi];
    end
end
% else just return the feature string as is
end

