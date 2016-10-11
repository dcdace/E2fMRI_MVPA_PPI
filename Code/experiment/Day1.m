function [sID seqCond] = Day1(sID)
Screen('Preference', 'SkipSyncTests', 1);
% change dir to the dir where this .m file is
[folder] = fileparts(which(mfilename));
cd(folder);

% PARTICIPANT DATA
sIDDir = getParticipant(sID);
if sID < 10
    sIDtxt = ['0' num2str(sID)];
else
    sIDtxt = num2str(sID);
end

% Get date and time
time = clock;
datetime = [datestr(now,'ddmmyyyy') '_' int2str(time(1,4)) int2str(time(1,5))];

%% =====================================================
% SCREEN & TEXT
% =====================================================
HideCursor;
expparam.white = [255 255 255];
expparam.grey = [240 240 240];
expparam.black = [0 0 0];

expparam.ScreenColor = expparam.grey;
expparam.ScreenID = max(Screen('Screens'));

[expparam.win, expparam.rect]= Screen('OpenWindow',expparam.ScreenID, expparam.ScreenColor); % full screen
%[win, rect]= Screen('OpenWindow',ScreenID, ScreenColor, [0 0 1000 500]); % 1000x750 screen

% define text style
Screen('TextFont', expparam.win, 'Calibri');
Screen('TextSize', expparam.win, 42);
Screen('TextStyle', expparam.win, 0); % 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend
expparam.TextColor = expparam.black;
Screen('TextColor', expparam.win, expparam.TextColor);

% =====================================================
% PARAMETERS
% =====================================================
X = Shuffle(1:12);
seqCond = X(1,1:8);
% sequences 11 and 12 can't be in the same condition 
while (sum(ismember([11,12],seqCond (1:4)))==2 || (sum(ismember([11,12],seqCond (5:8)))==2))
    X = Shuffle(1:12);
    seqCond = X(1,1:8);
end
% =====================================================
% PROCEDURE
% =====================================================

% familiarisation
% finds familiarisation sequece
fs=randi(12);
while any(seqCond==fs)
    fs=randi(12);
end
familiarise(fs);

% pre Training
preTraining(sID, seqCond);
% save parameters
filename = [sIDDir sIDtxt 'parameters.mat'];
save(filename);

% Instructions of what will happen in the scanner
familiariseOA(fs);

% participants enters the scanner

% =====================================================
% EXIT
% =====================================================
clear Screen;
ShowCursor;
