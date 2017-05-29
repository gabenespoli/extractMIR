function metadata = getMetadata(filename)

% make sure exiftool exists on the system
if system('which exiftool')
    error('The command line program exiftool does not exist on the system.')
end

% make system call to command line utility exiftool
[status,result] = system(['exiftool',' ',addEscapes(filename)]);

% use regex to split the output by colons-surrounded-by-whitespace and newlines
% this essentially parses the stdout into a 1-by-n cell array of key/value pairs
temp = regexp(result,'(\s+:\s)|(\n)','split');

% often there is a trailing newline messing up key/value pair structure; get rid of it
if mod(length(temp),2), temp(end) = []; end

% convert the key/value cell array to a struct
% all fields are of type string since this is what stdout is
metadata = struct;
for i = 1:2:length(temp)
    metadata.(matlab.lang.makeValidName(temp{i})) = temp{i+1};
end

end
