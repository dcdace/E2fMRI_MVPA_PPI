function OATraining(sID, day)
Screen('Preference', 'SkipSyncTests', 1);
runs = 4; % 4
% change dir to the dir where this .m file is
[folder] = fileparts(which(mfilename));
cd(folder);
% get Data directory name
dataDir = [folder filesep 'Data' filesep];
% get Stimuli directory name
stimuliDir = [folder filesep 'stimuliSmall' filesep];

if sID < 10
    sIDtxt = ['0' num2str(sID)];
else
    sIDtxt = num2str(sID);
end
sIDDir = [dataDir sIDtxt filesep];
if ~exist(sIDDir, 'dir')
    fprintf('Folder %s doesn not exist\n', sIDDir);
else
    filename = [sIDDir sIDtxt 'parameters.mat'];
    load(filename)
    sIDDir = [dataDir sIDtxt filesep];
    % first 4 are OA sequences
    seqOA = seqCond(1,1:4);
    % Get date and time
    time = clock;
    datetime = [datestr(now,'ddmmyyyy') '_' int2str(time(1,4)) int2str(time(1,5))];
    
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
    
    % key names
    % theKb = GetKeyboard(0);
    % key names
    % if Mac then getKeyboard
    if regexp(computer,'PCW\w*')
        theKb = 0;
    else
        theKb = GetKeyboard(0);
    end
    KbName('UnifyKeyNames');
    keyUpper = KbName('b'); % yes
    keyLower = KbName('m'); % no
    keyT = KbName('t');
    keylist = ones(1,256); % create a list of 256 zeros
    
    KbQueueCreate(theKb,keylist); %Make kb queue
    %% =====================================================
    % SCREEN & TEXT
    % =====================================================
    HideCursor;
    grey = [240 240 240];
    black = [0 0 0];
    
    ScreenColor = grey;
    TextColor = black;
    ScreenID = max(Screen('Screens'));
    
    [win, rect]= Screen('OpenWindow',ScreenID, ScreenColor); % full screen
    %[win, rect]= Screen('OpenWindow',ScreenID, ScreenColor, [0 0 1000 500]); % 1000x750 screen
    
    % define text style
    Screen('TextFont',win, 'Calibri');
    Screen('TextSize',win, 42);
    Screen('TextStyle', win, 0); % 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend
    Screen('TextColor', win, TextColor);
    
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
    
    %% =====================================================
    % Instructions
    % =====================================================
    DrawFormattedText(win, ['You will watch videos of somebody tapping sequences. \n\n'...
        'Pay close attention whether the sequences are performed correctly. \n\n'...
        'Occasionally you will be asked whether the performer in the video made an error \n in any of the 5 repetitions.\n\n'...
        'Press the Red key for Yes or Blue for No \n\n'...
        'Now press any key to start the experiment.'], 'center', 'center');
    Screen('Flip', win);
    KbQueueStart(); %start listening
    KbQueueFlush(); %removes all keyboard presses
    [pressed, firstPress] = KbQueueCheck();
    while ~pressed
        [pressed, firstPress] = KbQueueCheck();
    end
    KbQueueStop();
    %% =====================================================
    % START
    % =====================================================
    k = 0;
    % == 10 runs ==========================================
    for run = 1:runs %4
        errors = 0;
        % for each run
        % trial type vector
        % trials: 16 (4*4) seq., 4 error video
        
        % example seqOA = [5,7,3,1;]
        trialType = Shuffle([seqOA seqOA seqOA seqOA seqOA+1000]);
        % example trialType = [1,5,1007,1,1003,7,1,3,5,1,3,1005,7,5,7,3,1001,5,3,7;]
        % will ask the question 5 - 7 times
        numOfQ = randi([5 7]);
        askQ = Shuffle([zeros(length(trialType)-numOfQ,1); ones(numOfQ,1)]);
        % == 20 trials ==========================================
        for trNr = 1:length(trialType) % 20 trials length(trialType)
            e = 0;
            k = k+1;
            
            s = num2str(trialType(trNr));
            % error trial
            if trialType(trNr) > 1000
                e = 1;
                sequence = Sequences(str2double(s)-1000,:);
                fileStruct = dir([stimuliDir s '*']);
                
            else % task trial
                sequence = Sequences(str2num(s),:);
                fileStruct = dir([stimuliDir s num2str(randi(5)) '*']); % (randomly one of the 5)
            end
            
            DrawFormattedText(win, '+', 'center', 'center');
            Screen('Flip', win);
            WaitSecs(0.4);
            
            % show the sequence for 2.6s
            DrawFormattedText(win, num2str(sequence), 'center', 'center', TextColor);
            Screen('Flip', win);
            WaitSecs(2.6);
            
            % show the video 13s
            fileName{k,1} = fileStruct.name; % saves the list of videos shown
            [movie movieduration] = Screen('OpenMovie', win, [stimuliDir fileName{k,1}]);
            Screen('Flip', win);
            Show_Video(win, rect, movie, movieduration);
            
            %----------------------
            % Attention check
            if askQ(trNr,1) % ask the question
                correct = 0;
                DrawFormattedText(win, ['Was there an error in any of the last 5 repetitions? \n\n' ...
                    'Yes    No'], 'center', 'center', TextColor);
                Screen('Flip', win);
                % waits for the answer
                %% start the keyboard check
                KbQueueStart(); %start listening
                KbQueueFlush(); %removes all keyboard presses
                % waits for a key press
                
                %2.6s to answer
                WaitSecs(2.6);
                
                [pressed, firstPress] = KbQueueCheck(); %check response
                KbQueueStop();
                Yes_pressed = (any(find(firstPress) == keyUpper));
                No_pressed = (any(find(firstPress) == keyLower));
                % correct if e and Yes or e and No
                if (e && Yes_pressed) || (~e && No_pressed)
                    correct = 1;
                else
                    errors = errors + 1;
                end
                Results(k,1:3) = [e pressed correct];
            end
        end
        
        Errors(run) = errors;
        Accuracy(run) = (sum(askQ)-errors)/sum(askQ);
%         filename = [sIDDir sIDtxt  '_' datetime 'run' num2str(run) 'OAtraining.mat'];
%         save(filename);
        if run < runs
            DrawFormattedText(win, [num2str(run) '/' num2str(runs) ' done \n\n ' ...
                'Your answered correctly ' num2str(sum(askQ)-errors) ' out of ' num2str(sum(askQ)) ' times.\n\n' ...
                'Press any key when you are ready to continue.'], 'center', 'center', TextColor);
            Screen('Flip', win);
            KbQueueStart(); %start listening
            KbQueueFlush(); %removes all keyboard presses
            [pressed, firstPress] = KbQueueCheck();
            while ~pressed
                [pressed, firstPress] = KbQueueCheck();
            end
            KbQueueStop();
            DrawFormattedText(win, '+', 'center', 'center', TextColor);
            Screen('Flip', win);
        end 
    end
    DrawFormattedText(win, [num2str(run) '/' num2str(runs) ' done \n\n ' ...
        'Your answered correctly ' num2str(sum(askQ)-errors) ' out of ' num2str(sum(askQ)) ' times.'], 'center', 'center', TextColor);
    Screen('Flip', win);
    WaitSecs(3);
    filename = [sIDDir sIDtxt  '_' num2str(day) '_' datetime 'OAtraining.mat'];
    save(filename);
    
    % get back to Matlab
    clear Screen;
    ShowCursor;
end
