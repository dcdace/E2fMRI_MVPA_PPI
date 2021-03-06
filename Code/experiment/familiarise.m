function familiarise(fs)
% perform all (6) sequences, each 2x

Screen('Preference', 'SkipSyncTests', 1);

% change dir to the dir where this .m file is
[folder] = fileparts(which(mfilename));
cd(folder);

% sequences
Sequences = [
    5,3,4,2,1;      %1
    5,2,1,3,4 ;     %2
    4,5,1,3,2 ;     %3
    4,1,3,5,2 ;     %4
    3,1,4,2,5 ;     %5
    2,3,5,4,1 ;     %6
    2,5,3,1,4 ;     %7
    1,4,2,5,3 ;     %8
    1,2,4,3,5 ;     %9
    1,5,4,2,3 ;     %10
    3,5,2,1,4 ;     %11
    3,2,5,1,4 ;     %12
    ];
% familiarization sequence
sNR = fs; % sequence numbers from the 12 sequence list

% key names
% if Mac then getKeyboard
if regexp(computer,'PCW\w*')
    theKb = 0;
else
    theKb = GetKeyboard(0);
end
KbName('UnifyKeyNames');
spacebar = KbName('m');
k1 = KbName('y');
k2 = KbName('5%');
k3 = KbName('4$');
k4 = KbName('3#');
k5 = KbName('q');

keys = [k1,k2,k3,k4,k5]; % response keys

keylist = ones(1,256); % create a list of 256 zeros
%keylist(keys) = 1; % set keys you interested in to 1

KbQueueCreate(theKb,keylist); %Make kb queue
%% =====================================================
% SCREEN & TEXT
% =====================================================

HideCursor;
%     ListenChar(2); % suppresses any output of keypresses to Matlab
% create Screen
grey = [240 240 240];
black = [0 0 0];

ScreenColor = grey;
ScreenID = max(Screen('Screens'));

[win, rect]= Screen('OpenWindow',ScreenID, ScreenColor); % full screen
%[win, rect]= Screen('OpenWindow',ScreenID, ScreenColor, [0 0 1000 500]); % 1000x750 screen

% define text style
Screen('TextFont',win, 'Calibri');
Screen('TextSize',win, 42);
Screen('TextStyle', win, 0); % 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend
TextColor = black;
Screen('TextColor', win, TextColor);

%% =====================================================
% Instructions
% =====================================================
DrawFormattedText(win, ['This is a familiarisation task. \n\n'...
    'Memorise the sequence and then tap it FIVE times \n with the 5 fingers of your LEFT hand. \n\n'...
    '5-pinky; 1-thumb. \n\n'...
    'Press M to start'], 'center', 'center');
Screen('Flip', win);
% waits for spacebar
while KbCheck(-1); end % Wait until all keys are released
[keyIsDown, seconds, keyCode ] = KbCheck(-1);
while ~keyCode(spacebar)
    [keyIsDown, seconds, keyCode ] = KbCheck(-1);
end

%% =====================================================
% 5 SQUARE POSITIONS
% =====================================================
% square size
sw = 40; % square width in px
sh = 40; % square height
sg = 0; % gap between squares
sn = 5; %

[x,y] = RectCenter(rect);
% left and right border position for the first square
l = x - (sn/3+1)*(90/3) - (sn/3)*sw;
r = l + sw;
b = rect(1,4) - 10;
t = b - sh;

Squares=zeros(4,sn);
for i = 1 : sn
    Squares(:,i) = [l;t;r;b];
    l = l + sw + sg;
    r = r + sw + sg;
end
%border = [Squares(1,1), Squares(2,1), Squares(3,5), Squares(4,5)];

%% START
% five sequences
p = 0; % each press
tr = 0; % trial = one completed sequence
totalErrors = 0;
Errors=[];
MT=[];
OUTPUT = [];
allSeqSummary = [];
allSeqAvgs = [];
medianMT = 0;

for b = 1 : 3 %3 how many blocks
    thisSeqSummary = [];
    % fixation cross
    Screen('Flip', win);
    WaitSecs(0.2);
    %Screen('FrameRect', win, black, border );
    DrawFormattedText(win, ' * ', Squares(1,3), Squares(2,3), TextColor);
    Screen('Flip', win);
    WaitSecs(1);
    % sequence
    %Screen('FrameRect', win, black, border );
    for i = 1:5
        DrawFormattedText(win, [' ' num2str(Sequences(sNR,i))], Squares(1,i), Squares(2,i)-7, TextColor);
    end
    Screen('Flip', win);
    WaitSecs(2.7);
    % produce each sequence 5 times
    for r = 1:5 % 5 repetitions
        E = 0;
        % 5 asterix
        for i = 1:5
            DrawFormattedText(win, ' * ', Squares(1,i), Squares(2,i)-40, TextColor);
        end
        % Screen('FrameRect', win, black, border );
        DrawFormattedText(win, ' * ', Squares(1,3), Squares(2,3));
        ssTime = Screen('Flip', win); % sequence start time
        % sets asterix colors to default (black)
        
        % 5 keys in each sequence
        acolor(1:3,1:5)=0;
        TimeSequenceStarted = GetSecs;
        KbQueueStart(); %start listening
        KbQueueFlush(); %removes all keyboard presses
        for k = 1:5 % 5 keys
            e = 0; % error yes or no
            % the correct key = Sequences(s,k)
            % WAITS RESPONSE
            
            [pressed, firstPress] = KbQueueCheck(); %check response
            % if pressed
            while ~pressed
                [pressed, firstPress] = KbQueueCheck(); %check response
            end
            tp = GetSecs;
            tpSinceSeqStart = tp - TimeSequenceStarted;
            p = p + 1;
            if k == 1
                tfp = tp; % time first key pressed
                gap = tpSinceSeqStart;
            end
            if any(find(firstPress) ~= keys(Sequences(sNR,k)))
                e = 1;
                E = 1;
                totalErrors = totalErrors + 1;
            end
            % sequence execution time
            % if sequence was not executed correctly the asteriks is red
            if e
                acolor(:,k) = [255 0 0]; % red
                % Screen('FrameRect', win, black, border );
                DrawFormattedText(win, ' * ', Squares(1,3), Squares(2,3));
                % redraw all 5 asteriks
                for i = 1:5
                    DrawFormattedText(win, ' * ', Squares(1,i), Squares(2,i)-40, acolor(:,i));
                end
                Screen('Flip', win);
            else % if correct the asteriks ir green
                acolor(:,k) = [0 255 0]; % green
                %  Screen('FrameRect', win, black, border );
                DrawFormattedText(win, ' * ', Squares(1,3), Squares(2,3));
                % redraw all 5 asteriks
                for i = 1:5
                    DrawFormattedText(win, ' * ', Squares(1,i), Squares(2,i)-40, acolor(:,i));
                end
                Screen('Flip', win);
                
            end
        end
        KbQueueStop();
        lastMT = tp - tfp;
        percMTdiff = (lastMT/medianMT-1)*100; % difference in % between the lastMT and median MT
        % asterix for 800ms
        % if there was an error then red, if not - green or blue
        %Screen('FrameRect', win, black, border );
        if E
            DrawFormattedText(win, ' * ', Squares(1,3), Squares(2,3), [255 0 0]);
        else
            % if faster than median MT, then 3 green asteriks
            if percMTdiff < -20
                DrawFormattedText(win, '  * * * ', Squares(1,2), Squares(2,2), [0 255 0]);
            else
                % if faster than median MT, then 3 blue asteriks
                if percMTdiff > 20
                    DrawFormattedText(win, '  * * * ', Squares(1,2), Squares(2,2), [0 0 255]);
                else
                    % if within 20% difference then just one green asteriks
                    DrawFormattedText(win, ' * ', Squares(1,3), Squares(2,3), [0 255 0]);
                end
            end
        end
        Screen('Flip', win); %sequence end time
        WaitSecs(0.8);
    end
end
DrawFormattedText(win, 'OK, hope you are familiar with the task now. \n\n Press M to start the task', 'center', 'center', TextColor);
Screen('Flip', win);
% waits for spacebar
while KbCheck(-1); end % Wait until all keys are released
[keyIsDown, seconds, keyCode ] = KbCheck(-1);
while ~keyCode(spacebar)
    [keyIsDown, seconds, keyCode ] = KbCheck(-1);
end

% get back to Matlab
clear Screen;
ShowCursor;
