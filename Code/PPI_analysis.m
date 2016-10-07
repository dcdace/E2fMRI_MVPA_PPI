% Runs PPI analysis using gPPI Toolbox https://www.nitrc.org/projects/gppi
%
% FILE STRUCTURE
% -dirStudy
%   -dirROIs
%       -subject1
%           -ROIfname(s)
%       ...
%       -subjectN
%           -ROIfname(s)
%   -subject1
%       -dirSPM(day) -- first level analysis betas and SPM.mat file
%   ...       
%   -subjectN
%       -dirSPM(day) -- first level analysis betas and SPM.mat file

% contact: dace@dcdace.net

clear

fs           = filesep;
dirStudy     = 'G:\SR0046_ProcessedFinal\'; % base directory
dirROIs      = 'ROIs_PostDiffRegression';   % roi directory
dirSPM       = 'univarDay';                 % analysis directory. univarDay1 and univarDay2

subjects     = {'02','03','05','06','07','08','09','10','11','13','14','15','17','18','19','20'};

ROIfname =  {
    '10mmPeakC1_RSPL'
    '10mmPeakC2_RdPM'
    '10mmPeakC3_LvPM'
    '10mmPeakC4_LdPM'
    };

for day = 1 : 2 % analyse each scan day separately
    
    for subj = 1 : length(subjects)
        
        for r = 1 : length(ROIfname)
            
            subject         = ['SR0046_P' subjects{subj}];
            
            clear P
            
            P.subject       = subject;
            P.directory     = fullfile(dirStudy, subject, [dirSPM num2str(day)]);
            P.VOI           = fullfile(dirStudy, dirROIs, subject, [ROIfname{r} '.nii']);
            P.Region        = ROIfname{r};
            P.analysis      = 'psy';
            P.method        = 'cond';
            
            P.Estimate      = 1;
            P.contrast      = 0;
            P.extract       = 'mean';
            P.Tasks         = {'1' 'OA' 'UN'};
            P.Weights       = [];
            P.equalroi      = 0;
            P.FLmask        = 1;
            P.CompContrasts = 1;
            P.Weighted      = 0;
            
            P.Contrasts(1).left       = {'OA'};
            P.Contrasts(1).right      = {'none'};
            P.Contrasts(1).STAT       = 'T';
            P.Contrasts(1).name       = 'OA_Rest';
            P.Contrasts(1).MinEvents  = 20;
            
            P.Contrasts(2).left       = {'UN'};
            P.Contrasts(2).right      = {'none'};
            P.Contrasts(2).STAT       = 'T';
            P.Contrasts(2).name       = 'UN_Rest';
            P.Contrasts(2).MinEvents  = 20;
            
            P.Contrasts(3).left       = {'OA'};
            P.Contrasts(3).right      = {'UN'};
            P.Contrasts(3).STAT       = 'T';
            P.Contrasts(3).name       = 'OA_UN';
            P.Contrasts(3).MinEvents  = 20;
            
            P.Contrasts(4).left       = {'UN'};
            P.Contrasts(4).right      = {'OA'};
            P.Contrasts(4).STAT       = 'T';
            P.Contrasts(4).name       = 'UN_OA';
            P.Contrasts(4).MinEvents  = 20;
            
            PPPI(P);
            
        end % region
    end % subject
end % day
