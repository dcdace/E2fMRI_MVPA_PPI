function sIDDir = getParticipant(sID)
% change dir to the dir where this .m file is
[folder] = fileparts(which(mfilename));
cd(folder);
% get Data directory name
dataDir = [folder filesep 'Data' filesep];
% if Data dir doesn't exist, creat it
if ~exist(dataDir, 'dir')
    mkdir(dataDir);
    fprintf('Created ''Data'' folder %s \n', dataDir);
end

% Get date and time
time = clock;
if time(1,5) < 10
    sec = ['0' num2str(time(1,5))];
else
    sec = num2str(time(1,5));
end
datetime = [datestr(now,'yyyymmdd') '_' int2str(time(1,4)) sec];

% create the participant folder
if sID < 10
    sIDtxt = ['0' num2str(sID)];
else
    sIDtxt = num2str(sID);
end
sIDDir = [dataDir sIDtxt filesep];
if ~exist(sIDDir, 'dir')
    mkdir(sIDDir);
end

% DIALOG BOX
title = 'Enter participant details';
prompt={'sID',...           % 1
    'Date', ...             % 2
    'Initials',...          % 3
    'Age',...               % 4
    'Gender ( f / m / other )',...      % 5
    'Are you right handed? ( yes / no / other )',...      % 6
    'Your e-mail (optional)'};              % 7
numlines        = [1,60];
defaultanswer   = {num2str(sID) datetime '' '' '' '' '' ''};
answer          = inputdlg(prompt, title, numlines, defaultanswer);
%
p.sID           = answer{1};
p.datetime      = answer{2};
p.initials      = answer{3};
p.age           = answer{4};
p.gender        = answer{5};
p.righthanded   = answer{6};
p.email         = answer{7};

participant  = p;

% save
filename = [sIDDir sIDtxt '_' datetime '_demographics.mat'];
save(filename, 'participant');

