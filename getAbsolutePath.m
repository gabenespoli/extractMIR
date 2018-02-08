function folder = getAbsolutePath(folder)
currentDir = pwd;
if ~isempty(folder), cd(folder), end
absolutePath = pwd;
if ~isempty(folder), cd(currentDir), end
folder = absolutePath;
end
