%MYWAITBAR  Waitbar to display in the command window.
%
% USAGE
%   Initialize the waitbar: w = mywaitbar(title,[progress],[message])
%   Update the waitbar:     w = mywaitbar(w,progress,[message])
%   Close the waitbar:      mywaitbar(w,-1)
%
% INPUT
%   w = The output from a previous call to mywaitbar represents the 
%       length of the previous output, so that it can be erased
%       from the command window before printing the new 
%       progress and message.
%   title = [string]
%   progress = [number between 0 and 1]
%   message = [string]
%
% OUTPUT
%   Title [-----               ] message
%   Title [-------------       ] updated message
%   Title [--------------------] Done.
%
% EXAMPLES
%
% Written by Gabriel A. Nespoli 2016-05-12. Revised 2017-05-02.

function w = mywaitbar(w,progress,message)

% parse input
if nargin == 0, w = ''; end
if ischar(w)
    command = 'init';
    title = [w,' '];
    progress = 0;
elseif isnumeric(w)
    if nargin < 2
        warning('Invalid progress given to mywaitbar.')
        return
    end
    if progress < 0
        command = 'close';
    else
        command = 'update';
        title = '';
    end
end
if nargin < 3, message = ''; end

% get progress string (e.g., [----      ])
steps = 20;
done = floor(progress * steps);
togo = steps - done;
progressStr = ['[',repmat('-',1,done),repmat(' ',1,togo),'] '];
progressPct = ['(',getProgressPctStr(progress),'%%) '];
progressStr = [progressStr,progressPct];

% create full waitbar string
switch command
    case 'init'
        waitbarStr = [title,progressStr,message,''];
        
    case 'update'
        fprintf(1,repmat('\b',1,w)); % print backspaces to remove previous progress
        waitbarStr = [progressStr,message,''];
        
    case 'close'
        w = w - steps - length(progressPct) + 1;
        fprintf(1,repmat('\b',1,w)); % print backspaces to remove previous message
        fprintf(1,' Done.\n');
        return
end

fprintf(1,waitbarStr); % 1 means to print to stdout
w = length(waitbarStr) - length(title) - 1; % length to delete for updating
% -1 for the escaped percent sign
end

function str = getProgressPctStr(progress)
% get a string of a percentage that is 3 characters long
pct = floor(progress * 100);
str = num2str(pct);
if pct < 10
    str = ['  ',str];
elseif pct < 100
    str = [' ',str];
elseif pct > 100
    warning('Progress is greater than 100%')
end
end

