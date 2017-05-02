function [header,data] = readtable_fallback(filename)
% this is used if the version of matlab being used doesn't support
% the table variable type. Eventually I'd like to not use tables,
% and instead use low-level file IO for speed and compatibility
% with Octave.

fid = fopen(filename,'r');

% read headers
tline = fgetl(fid);
header = regexp(tline,',','split');

% from headers, get data format
dataFormat = '';
for i = 1:length(header)
    featureFormat = getFeatureFormat(header{i});
    dataFormat = [dataFormat,featureFormat];
end

data = textscan(fid,dataFormat,'Delimiter',',');

fclose(fid)
end
