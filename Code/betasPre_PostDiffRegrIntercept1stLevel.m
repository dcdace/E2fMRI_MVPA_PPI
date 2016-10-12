% calculate pre-scan diff (x-value) between 2 condition and post-scan diff (y-value) regression intercept at the 1st Level
% intercept gives the predicted post-diff if pre-diff is zero

clear

spm fmri;
spm('defaults','fmri');

fs = filesep;

dirStudy = '/Users/soba_lab/Documents/MATLAB/Dace/SR0046/';

conditionLabels = {'OA','UN'}; % condition names how you named them when defining the SPM design

subjects = {'02','03','05','06','07','08','09','10','11','13','14','15','17','18','19','20'};

spm_progress_bar('Init',100);

for subj = 1 : length(subjects)
    
    display(['analysing subject ' subjects{subj}]);
    
    for day = 1 : 2
        
        % get all beta file names for each scan day
        betaFiles(day).betas = dir([dirStudy 'SR0046_P' subjects{subj} fs 'univarDay' num2str(day) 'avgCondNoRP' fs 'beta*.nii']);
        
        % get the SPM structure
        SPM(day) = load(fullfile(dirStudy, ['SR0046_P' subjects{subj}], ['univarDay' num2str(day) 'avgCondNoRP'],'SPM.mat'));
        
        % get condition vector to know which beta files belong to which
        % condition and which run
        
        % function from RSAToolbox
        % http://www.mrc-cbu.cam.ac.uk/methods-and-resources/toolboxes/license/
        [cond(day).cond, run(day).run] = rsa_getSPMconditionVec(SPM(day).SPM,conditionLabels);
        
    end
    clear SPM
    
    % number of runs per day may differ. Get the smallest number of
    % runs
    numRuns = min([max(run(1).run) max(run(2).run)]);
    
    % for each run within each day substract the two condition beta values
    for day = 1 : 2
        
        for runNr = 1 : numRuns
            
            OAbeta{day} = fullfile(dirStudy, ['SR0046_P' subjects{subj}], ['univarDay' num2str(day) 'avgCondNoRP'], betaFiles(day).betas(cond(day).cond==1&run(day).run==runNr).name);
            UNbeta{day} = fullfile(dirStudy, ['SR0046_P' subjects{subj}], ['univarDay' num2str(day) 'avgCondNoRP'], betaFiles(day).betas(cond(day).cond==2&run(day).run==runNr).name);
                        
            OAbetaVol{day} = spm_vol(OAbeta{day});
            UNbetaVol{day} = spm_vol(UNbeta{day});
            
            OAbetaData{day} = spm_read_vols(OAbetaVol{day});
            UNbetaData{day} = spm_read_vols(UNbetaVol{day});
                        
            Diff{runNr,day} = OAbetaData{day} - UNbetaData{day}; % substracts OA from UN
            
        end
    end
    
    clear betaFiles preDiffVol postDiffVol
    
    [nx, ny, nz] = size(Diff{1,1}); % assumption is that all scans have the same volum size.
    
    % will create 3 image files. Set all initial values to NaN
    [tvalue, beta, pvalue]  = deal(zeros(nx,ny,nz));
    
    tvalue(:,:,:)   = NaN;
    beta(:,:,:)     = NaN;
    pvalue(:,:,:)   = NaN;
      
    % for each voxel in the volume, get the voxel's preDiff and postDiff values within
    % each run and do the linear regression
    for z = 1 : nz
        for x = 1 : nx
            for y = 1 : ny
                for runNr = 1 : numRuns
                    
                    preDiff(runNr,1)   = Diff{runNr,1}(x,y,z);
                    postDiff(runNr,1)  = Diff{runNr,2}(x,y,z);
                    
                end
                
                if ~any(isnan([preDiff; postDiff])) % only if in all runs this voxel had any value, not NaN
                    
                    % do the linear regression on postDiff (y) on
                    % preDiff (x)
                    [B,DEV,STATS]   = glmfit(preDiff,postDiff);
                    
                    % store t-value, intercept-value (beta), p-value
                    tvalue(x,y,z)   = STATS.t(1,1);     % intercept t-value
                    beta(x,y,z)     = STATS.beta(1,1);  % intercept B-value
                    pvalue(x,y,z)   = STATS.p(1,1);     % intercept p-value, if interested to look at them
                end
                clear preDiff postDiff B DEV STATS
            end
        end
        
        spm_progress_bar('set',(z/nz)*100);
        
    end % voxels
    
        % save files
        
        % create volume templates. Same as the original beta files
        TimgFileVol(1)      = spm_vol(OAbeta{1});
        BetaimgFileVol(1)   = spm_vol(OAbeta{1});
        PvalimgFileVol(1)   = spm_vol(OAbeta{1});
        
        % directory where to save
        dirRes = [dirStudy 'PrePostRegressionXX/subjects/'];
        % create the directory if it does not exist       
        if ~exist(dirRes, 'dir')
            mkdir(dirRes);
        end
        
        % specify nii file names
        TimgFileVol(1).fname    = fullfile(dirRes, [subjects{subj} '_PrePostRegressionTvalue.nii']); % t-values. Same as spmT_0001.nii files
        BetaimgFileVol(1).fname = fullfile(dirRes, [subjects{subj} '_PrePostRegressionIntercept.nii']); % intercept values, similar to con_0001.nii files. These are used for group analysis
        PvalimgFileVol(1).fname = fullfile(dirRes, [subjects{subj} '_PrePostRegressionPvalue.nii']); % p-values. Not necessary to create them. 
        
        % write nii files
        spm_write_vol(TimgFileVol(1),tvalue);
        spm_write_vol(BetaimgFileVol(1),beta);
        spm_write_vol(PvalimgFileVol(1),pvalue);
        
        clear OAbetaVol UNbetaVol OAbetaData UNbetaData tvalue beta
        
end % subject

display(['all done and saved in ' dirRes]);

close all
