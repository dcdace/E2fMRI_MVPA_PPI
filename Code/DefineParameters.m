% contact: dace@dcdace.net

function parameters = DefineParameters

% == Main Directories
parameters.dir_base        = '/Users/soba_lab/Documents/MATLAB/Dace/SR0046'; % data directory
parameters.dir_functional  = 'functional'; % directory of functional data (NIfTI files)
parameters.dir_anatomical  = 'anatomical'; % directory including the T1 3D high resoluation anatomical data set
parameters.sess_prfx       = 'run';
parameters.name_subj       = {'SR0046_P02','SR0046_P03','SR0046_P05','SR0046_P06','SR0046_P07','SR0046_P08',...
    'SR0046_P09','SR0046_P10','SR0046_P11','SR0046_P13','SR0046_P14','SR0046_P15','SR0046_P17','SR0046_P18',...
    'SR0046_P20'
};

% == scanning parameters
parameters.n_sess          = 10;     % number of runs
parameters.n_scans         = 136;
parameters.TR              = 2.6;    % repetition time in s
parameters.num_slices      = 41;     % number of slices
parameters.ref_slice       = 20;     % reference slice for slice timing (e.g. first slice or middle slice)
parameters.TA = parameters.TR-parameters.TR/parameters.num_slices;
parameters.slice_order     = 1:1:parameters.num_slices;	% Syntax: [first_slice:increment/decrement:last_slice]
% Examples:
% descending acquisition [parameters.num_slices:-1:1]
% ascending acquisition [1:1:parameters.num_slices]
% interleaved acquisition (ascending - even slices first): [2:2:parameters.num_slices 1:2:parameters.num_slices-1]

% == preprocessing parameters
parameters.smooth_fwhm     = 8;  % smoothing after normalization in mm

% == Analysis parameters
parameters.dir_analysis    = 'univarDay1avgCondNoRP';   % directory where SPM.mat, beta images, con images etc. are stored for each subject
parameters.analysis_prefix = 'swar'; % normally 'ar' for mvpa and 'swar' for univariate 
                                     % s-smoothened; w-normalised; a-time corrected; r-realigned

parameters.rp              = 0;  % include realignment parameters in design matrix? 1=yes, 0=no
parameters.cutoff_highpass = 52; %128;% for bloc des. 4xblock_length / cutoff for high pass filter in s [Inf = no filtering]

% definition of conditions
parameters.cond_names      = {'OA','UN','Err','Q', 'OACues','UNCues'};
parameters.cond_param      = [0 0 0 0 0 0 0 0 0 0 0 0];    % number of parameters per condition
parameters.cond_shift      = 0; % set this to 0 unless you know what you are doing!

% % definition of contrasts
parameters.c_name          = {'OAvsUN','UNvsOA','OAvsRest','UNvsRest','OAUNvsRest',...
                              'OACuesvsUNCues','UNCuesvsOACues','CuesvsRest',...
                              'QvsRest','ErrvsOAUN'};
parameters.c_con           = [
                             
                              1 -1 0 0 0 0;         %02 OAvsUN
                              -1 1 0 0 0 0;         %03 UNvsOA
                              1 0 0 0 0 0;          %04 OAvsRest
                              0 1 0 0 0 0;          %05 UNvsRest
                              1 1 0 0 0 0;          %06 OAUNvsRest
                              0 0 0 0 1 -1;         %07 OACuesvsUNCues
                              0 0 0 0 -1 1;         %08 UNCuesvsOACues
                              0 0 0 0 1 1;          %09 CuesvsRest
                              0 0 0 1 0 0;          %10 QvsRest
                              -1 -1 1 0 0 0;        %11 ErrvsOAUN
                              ];
                          
parameters.c_type          = {'T','T','T','T','T','T','T','T','T','T'};


%% save parameters
% Get date and time
time                       = clock;
datetime                   = [datestr(now,'ddmmyyyy') '_' int2str(time(1,4)) int2str(time(1,5))];

savefile                   = [parameters.dir_base filesep 'parameters_' datetime];
save(savefile,'parameters');
