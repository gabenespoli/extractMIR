function extractMIR(varargin)
%extractMIR  Extract features from wav files.
% usage
%   extractMIR('key1',val1,'key2',val2,...)
%
% input
%   'csvfile' = [string] Path and name of csv file to write data to.
%       Default is to prompt the user for a filename.
%
%   'folder' = [string|cell of strings] Folder(s) to search
%       for files. All subfolders are searched. Default 'Music'.
%       If the folder doesn't exist, the user is prompted to enter one.
%
%   'filetypes' = [string|cell of strings] File extensions to search for
%       in all folders specified in locs. Default {'mp3','m4a','wav','aiff'}.
%
%   'features' = [cell of strings|string] List of features to extract.
%       Filter settings can be added to features like so:
%       'feature_lowfreq_highfreq'. For e.g., 'flux_100_200' for spectral
%       flux between 100 and 200 Hz. See subfunction parsefeature.
%
%   'mirtoolboxpath' = [cell of strings|string] Paths to search for 
%       MIR Toolbox and add it to the MATLAB path. The first match is added.
%       Default '{'~/Documents/MATLAB/MIRtoolbox1.6.1', 
%       '~/bin/matlab/MIRtoolbox1.6.1'}.
%
% output
%   A csv file with 'filename' as the first column, and each column
%   thereafter is the value of the one of the features specified.
%
% Written by Gabriel A. Nespoli 2017-04-04. Revised 2017-04-07.

% TODO add parameter 'addfeatures' that adds certain features to an existing csv file

%% defaults
folder = 'Music';
outputfile = ''; % enter '' to not write to file
filetypes = {'mp3','m4a','wav','aiff'};
MIRtoolboxPath = {'~/Documents/MATLAB/MIRtoolbox1.6.1', '~/bin/matlab/MIRtoolbox1.6.1'};
saveFrequency = 1; % save every x number of files
features = {...
    'filetype',...
    'artist',...
    'album',...
    'title',...
    'track',...
    'genre',...
    'date',...
    'rms',...
    'rmsStd',...
    'flux',...
    'flux_0_50',...
    'flux_50_100',...
    'flux_100_200',...
    'flux_200_400',...
    'flux_400_800',...
    'flux_800_1600',...
    'flux_1600_3200',...
    'flux_3200_6400',...
    'flux_6400_12800',...
    'flux_12800_22050',...
    'fluctuation',...
    'lowenergy',...
    };

%% user-defined
for i = 1:2:length(varargin)
    switch lower(varargin{i})
    case {'csvfile','outputfile'},  outputfile = varargin{i+1};
    case 'folder',                  folder = varargin{i+1};
    case {'filetypes','exts'},      filetypes  = varargin{i+1};
    case 'mirtoolboxpath',          MIRtoolboxPath = varargin{i+1};
    case 'features',                features = varargin{i+1};
    end
end

%% prepare some things
addMIRtoolboxPath(MIRtoolboxPath)
mirwaitbar(0); % turn off mir toolbox's waitbar
mirverbose(1); % stop mir toolbox from printing to the command window
features = cellstr(features); % make sure input is a cell array
while ~exist(folder,'dir'), 
    disp(['The folder ''',folder,''' doesn''t exist.'])
    folder = input('Folder (e.g., ~/Music): ','s');
end
filenames = getFilenames(folder,filetypes,'relative');

if isempty(outputfile)
    outputfile = input('Output filename (e.g., mir.csv): ','s');
end

if exist(outputfile,'file')
    resp = input(['File ''',outputfile,''' already exists. [a]ppend, [o]verwrite, or [c]ancel: '],'s');

    if ismember(lower(resp), {'a','o'}) % backup file before modifying it
        disp(['Backing up ''',outputfile,''' to ''',outputfile,'.bak','''...'])
        [status,result] = system(['cp ',outputfile,' ',outputfile,'.bak']);
    end

    switch lower(resp)
    case 'a'
        makeNewFile = false;
        try
            completed = readtable(outputfile);
            header = completed.Properties.VariableNames;
            completedFilenames = completed.filename;
        catch
            [header,data] = readtable_fallback(outputfile);
            completedFilenames = data{ismember(header,'filename')};
        end

         % must extract same features as file
         features = header(3:end);
        
        % remove filenames that have already been completed
        if ~isempty(completedFilenames)
            filenames = filenames(~ismember(filenames,completedFilenames));
        end
        
        % open file for appending text
        % open as text file ('t') to deal with newlines on different systems
        fid = fopen(outputfile,'at');

    case 'o'
        makeNewFile = true;

    otherwise
        disp('Invalid entry. Aborting...')
        return

    end

else 
    makeNewFile = true;

end
    
if makeNewFile
    disp(['Creating output file ''',outputfile,'''...'])
    % open new file and write header row
    fid = fopen(outputfile,'wt');
    header = {'filename','dateExtracted',features{:}};
    headerFormat = [repmat('%s,',1,length(header)-1), '%s\n'];
    fprintf(fid,headerFormat,header{:});
end

%% big try catch block because this is going to take a while
% this lets us exit gracefully (bascially to properly close the csv file)
try

%% loop files
for filename = filenames
    tic
    
    filenameInd = find(ismember(filenames,filename)); % get loop iteration
    filename = filename{1}; % make current filename a string instead of a cell
    disp(['Processing file ',num2str(filenameInd),'/',num2str(length(filenames)),': ''',filename,''''])
    
    data = {filename,datestr(now,'yyyy-mm-dd HH:MM:SS')};
    dataFormat = [getFeatureFormat('filename'),',',getFeatureFormat('dateExtracted')];

    % get file extension
    [~,~,ext] = fileparts(filename);
    ext = strrep(ext,'.','');
        
    % now that relative filename has been stored in the data variable and
    % the metadata has been pulled from the relative path, convert it to an
    % absolute path so we can actually find the file for loading
    filename = fullfile(folder,filename);
    
    %% get acoustic features
    % pass filename to ffmpeg.m
    % it will convert to wav if it's not wav, and extract metadata
    if ~strcmpi(ext,'wav')
        disp(['Converting from ',ext,' to wav and extracting metdata with ffmpeg...'])
        haveTempFile = true;
    else
        disp('Extracting metadata with ffmpeg...')
        haveTempFile = false;
    end
    % if file is already wav, ffmpeg.m returns the same filename
    [filename,metadata] = ffmpeg(filename,'.wav'); 

    disp('Loading file into MIR Toolbox...')
    a = miraudio(filename); % load current file
    Fs = get(a,'Sampling'); % get sampling rate
    Fs = Fs{1}; % convert from cell to numeric
    
    if haveTempFile % remove temp wavfile if original file was not wav
        status = system(['rm ',strrep(filename,' ','\ ')]);
    end
        
    w = mywaitbar('    Extracting features...');
    for feature = features
        
        featureInd = find(ismember(features,feature));
        feature = feature{1}; % make string instead of cell
        [featureName,f] = parseFeature(feature,Fs); % get feature settings from name
        if ~isempty(f) % filter
            if mirverbose
                w = mywaitbar(w,featureInd/length(features),'filtering\n');
            else w = mywaitbar(w,featureInd/length(features),'filtering');
            end
            a = mirfilterbank(a,'Manual',f);
        end
        
        if mirverbose
            w = mywaitbar(w,featureInd/length(features),[feature,'\n']);
        else w = mywaitbar(w,featureInd/length(features),feature);
        end
        switch lower(featureName)

            % mir features
            case 'rms',         val = mirgetdata(mirrms(a));
            case 'rmsstd',      val = std(mirgetdata(mirrms(a,'Frame'))); % Stupacher2016
            case 'flux',        val = mean(mirgetdata(mirflux(a)));
            case 'pulseclarity',val = mirgetdata(mirpulseclarity(a,'MaxAutocor','Attack')); % Stupacher2016
            case 'eventdensity',val = mirgetdata(mireventdensity(a));
            case 'fluctuation', val = mean(mean(mirgetdata(mirfluctuation(a))));
            case 'lowenergy',   val = mirgetdata(mirlowenergy(a));
            case 'filetype',    val = ext;

                % metadata
            case {'artist','album','title','track','genre','date'}
                if isfield(metadata,featureName)
                    val = {metadata.(featureName)};
                else val = {''};
                end
                
            otherwise, error(['Unknown feature ''',feature,'''.'])
        end
        
        data = [data,val];
        dataFormat = [dataFormat,',',getFeatureFormat(featureName)];
        
    end
    mywaitbar(w,-1);
    
    % print data to file
    fprintf(fid,[dataFormat,'\n'],data{:});
    
    % save progress every so often
    if mod(featureInd,saveFrequency) == 0
        progress = featureInd / length(filenames);
        w = mywaitbar('    Saving progress...',progress,'Closing file...');
        fclose(fid);
        clear a
        
        w = mywaitbar(w,progress,'Reopening file...');
        fid = fopen(outputfile,'at');
        
        mywaitbar(w,-1);
    end
    
    toc
end

catch errorMsg % exit gracefully (close file)
    disp('*** Error in extractMIR ***')
    fprintf('Closing csv file before exiting...')
    fclose(fid);
    fprintf(' Done.\n')
    rethrow(errorMsg)
end

%% close output file
fclose(fid);
disp(['Extracted features from ',num2str(length(files)),' file(s).'])

end

function addMIRtoolboxPath(MIRtoolboxPath)
MIRtoolboxPath = cellstr(MIRtoolboxPath);
for i = 1:length(MIRtoolboxPath)
    if exist(MIRtoolboxPath{i}, 'dir')
        addpath(genpath(MIRtoolboxPath{i}))
        return
    end
end
end
