function OAscanning(sID)
Screen('Preference', 'SkipSyncTests', 1);
runs = 10; % 10
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
    keyUpper = KbName('r'); % yes
    keyLower = KbName('b'); % no
    keyT = KbName('t');
    keylist = ones(1,256); % create a list of 256 zeros
    
    KbQueueCreate(theKb,keylist); %Make kb queue
    %% =====================================================
    % SCREEN & TEXT
    % =====================================================
    HideCursor;
    grey = [240 240 240];
    black = [0 0 0];
    
    ScreenColor = black;
    TextColor = grey;
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
        'Press the Upper key (red) for Yes or Lower key (blue) for No \n\n'], 'center', 'center');
    Screen('Flip', win);
    
    %% =====================================================
    % START
    % =====================================================
    k = 0;
    ErrorsRun = [];
    TrialTimes = [];
    CueTimes = [];
    QuestionTimes = [];
    % == 10 runs ==========================================
    for run = 1:runs %10
        errors = 0;
        % for each of the 10 runs
        % 136 TRs (5.76 min)
        % trial type vector
        % runStart(run) trials: 5 rest, 16 seq., 1 error video
        
        trialType = ones(1,22);
        restTrial = Shuffle(3:2:21);
        % 5 rest trials; 1 at the start and 4 randomly
        trialType(1,[1 restTrial(1,1:4)]) = 0;
        % error trial
        x = find(trialType==1);
        es = Shuffle(seqCond); es = es(1); % error sequence
        trialType(x(randi(length(x)))) = 1000 + es;
        % example seqCond = [5,7,3,1,8,12,4,9;]
        trialType(trialType==1) = [Shuffle(seqCond) Shuffle(seqCond)];
        % example trialType = [0,4,0,9,12,7,3,8,1007,1,5,7,0,1,0,9,0,3,4,12,5,8;]
        
        % one question trial
        % a question follows one non-error video and one error video
        question = Shuffle([zeros(1,15) 1]);
        % example question = [0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0;]
        q = 0;
        taskTrNr = 0;
        % == waits for scanner (t)
        while KbCheck(-1); end % Wait until all keys are released
        [keyIsDown, seconds, keyCode ] = KbCheck(-1);
        while ~keyCode(keyT)
            [keyIsDown, seconds, keyCode ] = KbCheck(-1);
        end
        runStart = GetSecs;
        % =========================
        
        % == 22 trials ==========================================
        for trNr = 1:22 % 22 trials
            e = 0;
            k = k+1;
            % REST 13s
            if trialType(trNr) == 0
                DrawFormattedText(win, '+', 'center', 'center');
                Screen('Flip', win);
                trialStart(trNr,1:3) = [run trialType(trNr) GetSecs-runStart];
                WaitSecs(13);
                trialEnd(trNr,1) = GetSecs-runStart;
            else
                % SHOW VIDEO
                s = num2str(trialType(trNr));
                % error trial (1 per run)
                if trialType(trNr) > 1000
                    e = 1;
                    sequence = Sequences(str2double(s)-1000,:);
                    fileStruct = dir([stimuliDir s '*']);
                    % task trial (16 per run)
                else
                    taskTrNr = taskTrNr + 1;
                    sequence = Sequences(str2num(s),:);
                    fileStruct = dir([stimuliDir s num2str(randi(5)) '*']); % (randomly one of the 5)
                end
                
                DrawFormattedText(win, '+', 'center', 'center');
                Screen('Flip', win);
                WaitSecs(0.4);
                
                % show the sequence for 2.6s
                DrawFormattedText(win, num2str(sequence), 'center', 'center', TextColor);
                Screen('Flip', win);
                cueStart(taskTrNr,1:3) = [run trialType(trNr)  GetSecs-runStart];
                WaitSecs(2.6);
                cueEnd(taskTrNr,1) = GetSecs-runStart;
                
                % show the video 13s
                fileName{k,1} = fileStruct.name; % saves the list of videos shown
                [movie movieduration] = Screen('OpenMovie', win, [stimuliDir fileName{k,1}]);
                Screen('Flip', win);
                trialStart(trNr,1:3) = [run trialType(trNr) GetSecs-runStart];
                Show_Video(win, rect, movie, movieduration);
                trialEnd(trNr,1) = GetSecs-runStart;
                
                %----------------------
                % Attention check, twice per run
                if e || question(taskTrNr)
                    correct = 0;
                    q = q + 1;
                    DrawFormattedText(win, ['Was there an error in any of the last 5 repetitions? \n\n' ...
                        'Yes \n\nNo'], 'center', 'center', TextColor);
                    Screen('Flip', win);
                    questionStart(q, 1:2) = [run GetSecs-runStart];
                    % waits for the answer
                    %% start the keyboard check
                    KbQueueStart(); %start listening
                    KbQueueFlush(); %removes all keyboard presses
                    % waits for a key press
                    
                    %2.6s to answer
                    WaitSecs(2.6);
                    questionEnd(q,1) = GetSecs-runStart;
                    
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
            end % show video
        end % trial
        runEnd = GetSecs;
        filename = [sIDDir sIDtxt  '_' datetime 'run' num2str(run) 'OAscanning.mat'];
        save(filename);
        if run < runs
            DrawFormattedText(win, [num2str(run) '/' num2str(runs) ' done \n\n Press any key when you are ready to continue.'], 'center', 'center', TextColor);
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
        TrialTimes = [TrialTimes; trialStart trialEnd];
        CueTimes = [CueTimes; cueStart cueEnd];
        QuestionTimes = [QuestionTimes; questionStart questionEnd];
        RunsStart(run) = runStart;
        RunsEnd(run) = runEnd;
        Errors(run) = errors;
        
    end
    DrawFormattedText(win, [num2str(run) '/' num2str(runs) ' Well done! .'], 'center', 'center', TextColor);
    Screen('Flip', win);
    WaitSecs(3);
    filename = [sIDDir sIDtxt  '_' datetime '_OAscanning.mat'];
    save(filename);
    
    % get back to Matlab
    clear Screen;
    ShowCursor;
end
