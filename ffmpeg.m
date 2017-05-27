function [outfile,metadata] = ffmpeg(infile,outfile)
% wrapper for commanline function ffmpeg
% if no outfile given, assumed same dir and wav file (if infile is wav, then mp3)
% if successfully converts, returns the path/filename to a wav file
% otherwise returns the empty string
% also outputs a boolean whether the conversion was successful

% defaults
command = '/usr/bin/ffmpeg';
defaultOutext = '.wav';
backupOutext = '.mp3'; % if infile is of type defaultOutext
metadataLabels = {'artist','album','title','track','genre','date'};

% parse input and output filenames
[inpath,inname,inext] = fileparts(infile);
if nargin > 1
    [outpath,outname,outext] = fileparts(outfile);
else
    outpath = '';
    outname = '';
    outext = '';
end
if isempty(outpath)
    outpath = inpath; end
if ~exist(outpath,'dir') && ~isempty(outpath)
    mkdir(outpath); end
if isempty(outname)
    outname = inname; end
if isempty(outext)
    outext = defaultOutext;
    if strcmp(outext,inext)
        outext = backupOutext; end
end
outfile = fullfile(outpath,[outname,outext]);

% escape spaces for the system call 
outfileX = addEscapes(outfile);
infileX = addEscapes(infile);

% get metadata and read into struct
tempfile = 'temp.txt';
metadata = [];
[status,result] = system([command,' -i ',infileX,' -f ffmetadata ',tempfile]);
if status
    warning('Failed metadata extraction with ffmpeg')
    disp(result)
end
%[~,result] = system('cat temp.txt')
fid = fopen(tempfile,'rt');
tline = fgetl(fid);
while ischar(tline)
    data = regexp(tline,'=','split');
    if length(data) == 2 && ismember(data{1},metadataLabels)
        metadata.(data{1}) = data{2}; end
    tline = fgetl(fid);
end

% convert file
if strcmp(infile,outfile)
    disp('In and out files have the same name. Returning same filename and aborting ffmpeg.m')
    outfile = infile;
    return
end

if exist(outfile,'file')
    disp('Outfile already exists. Aborting ffmpeg')
    return
end 

[status,result] = system([command,' -i ',infileX,' ',outfileX]);
if status
    outfile = '';
    warning('Failed conversion with ffmpeg')
    disp(result)
end
end

function file = addEscapes(file)
file = strrep(file,' ','\ ');
file = strrep(file,'-','\-');
file = strrep(file,'(','\(');
file = strrep(file,')','\)');
file = strrep(file,']','\]');
file = strrep(file,'[','\[');
file = strrep(file,'{','\{');
file = strrep(file,'}','\}');
file = strrep(file,'&','\&');
file = strrep(file,'''','\''');
file = strrep(file,'"','\"');
file = strrep(file,'.','\.');
file = strrep(file,'*','\*');
file = strrep(file,'?','\?');
file = strrep(file,';','\;');
file = strrep(file,'<','\<');
file = strrep(file,'>','\>');
file = strrep(file,'#','\#');
file = strrep(file,'!','\!');
end

