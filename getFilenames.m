function filenames = getFilenames(locs,exts,pathtype,ignoredotfiles)
% getfilenames  Recursively search dirs for files of a certain type.
%
% USAGE
%   filenames = getFilenames(locs,exts,[pathtype],[ignoredotfiles])
%
% INPUT
%   locs = [cell of strings|string] A list of filenames or folders.
%       Folders are recursively searched.
%
%   exts = [cell of strings|string] A list of file extensions
%       to search for if something in locs is a folder, not 
%       including the dot.
%
%   pathtype = ['relative'|'absolute'] The type of path to 
%       put in the filename column of the output csv file.
%
%   ignoredotfiles = [bool] Whether or not to exclude filenames
%       that begin with a period from the results. Default true.
%
% OUTPUT
%   filenames = [cell of strings] Full file paths to files.
%

% TODO ignore dotfiles without a loop

locs = cellstr(locs); % make sure it's a cell of strings
exts = cellstr(exts);
if nargin < 3 || isempty(pathtype), pathtype = 'absolute'; end
if nargin < 4 || isempty(ignoredotfiles), ignoredotfiles = true; end
filenames = {};

for iLoc = 1:length(locs)
    loc = locs{iLoc};

    if isdir(loc)
        loc = getAbsolutePath(loc);
        subfolders = genpath(loc);
        subfolders = regexp(subfolders,pathsep,'split');

        for iSub = 1:length(subfolders)
            subfolder = subfolders{iSub};
            
            for iExt = 1:length(exts)
                ext = exts{iExt};
                temp = dir(fullfile(subfolder,['*.',ext])); % get filenames in folder
                if size(temp,1) == 0, continue, end % abort if no files found
                temp = {temp.name};
                if ignoredotfiles
                    rmind = zeros(size(temp));
                    for i = 1:length(temp)
                        if strcmp(temp{i}(1),'.'), rmind(i) = 1; end
                    end
                    temp(logical(rmind)) = [];
                end
                temp = cellfun(@(x) fullfile(subfolder,x),temp,'UniformOutput',false); % make full path
                
                % remove loc if relative path is desired
                if strcmp(pathtype,'relative')
                    temp = cellfun(@(x) strrep(x,[loc,'/'],''),temp,'UniformOutput',false);
                    temp = cellfun(@(x) strrep(x,loc,''),temp,'UniformOutput',false);
                elseif ~strcmp(pathtype,'absolute')
                    error('Invalid pathtype for getfilenames.m.')
                end
                
                filenames = [filenames temp];
            end
        end
    else
        filenames = [filenames loc];
    end
end
end

