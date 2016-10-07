% calculate pretetst-posttest regression intercept at the 1st Level

clear

spm fmri;
spm('defaults','fmri');

fs = filesep;

dirStudy = '/Users/soba_lab/Documents/MATLAB/Dace/SR0046/';

conditionLabels = {'PPI_OA','PPI_UN'}; % condition names how you named them when defining the SPM design

ROIfname =  {
    '10mmPeakC1_RSPL'
    '10mmPeakC2_RdPM'
    '10mmPeakC3_LvPM'
    '10mmPeakC4_LdPM'
    };

subjects = {'02','03','05','06','07','08','09','10','11','13','14','15','17','18','19','20'};

spm_progress_bar('Init',100);

% load all files
for roi = 1 : 1%length(ROIfname)
    % will only use voxels that fall into the group mask
    mask = fullfile(dirStudy, 'PPI_GroupResults_PostDiffRegrPeak', ROIfname{roi}, 'Day2OA_UN', 'mask.nii');
    VolMask = spm_vol(mask);
    VDatMask = spm_read_vols(VolMask);
    
    for subj = 1 : length(subjects)
        % for each run substract UN from OA
        for day = 1 : 2
            
            % get all betas
            betaFiles(day).betas = dir([dirStudy 'SR0046_P' subjects{subj} fs 'univarDay' num2str(day) 'avgCondNoRP' fs 'PPI_PostDiff'  ROIfname{roi} fs 'beta*.nii']);
            
            % get the SPM structure
            SPM(day) = load(fullfile(dirStudy, ['SR0046_P' subjects{subj}], ['univarDay' num2str(day) 'avgCondNoRP'], ['PPI_PostDiff'  ROIfname{roi}], 'SPM.mat'));
            
            % get condition vector to know which beta files belong to which
            % condition and which run
            [cond(day).cond,run(day).run] = getPPIconditionVec(SPM(day).SPM,conditionLabels);
            
        end
        clear SPM
        
        % number of runs per day may differ. Get the smallest number of
        % runs
        numRuns = min([max(run(1).run) max(run(2).run)]);
        
        for day = 1 : 2
            for runNr = 1 : numRuns % for each run within the day
                
                OAbeta{day} = fullfile(dirStudy, ['SR0046_P' subjects{subj}], ['univarDay' num2str(day) 'avgCondNoRP'], ['PPI_PostDiff'  ROIfname{roi}], betaFiles(day).betas(cond(day).cond==1&run(day).run==runNr).name);
                UNbeta{day} = fullfile(dirStudy, ['SR0046_P' subjects{subj}], ['univarDay' num2str(day) 'avgCondNoRP'], ['PPI_PostDiff'  ROIfname{roi}], betaFiles(day).betas(cond(day).cond==2&run(day).run==runNr).name);
                
                
                OAbetaVol{day} = spm_vol(OAbeta{day});
                UNbetaVol{day} = spm_vol(UNbeta{day});
                
                OAbetaData{day} = spm_read_vols(OAbetaVol{day});
                UNbetaData{day} = spm_read_vols(UNbetaVol{day});
                
                
                Diff{runNr,day} = OAbetaData{day} - UNbetaData{day}; % expecting OA > UN
                
            end
        end
        clear betaFiles
        
        clear preDiffVol postDiffVol
        
        [nx, ny, nz] = size(Diff{1,1});
        [tvalue, beta, pvalue] = deal(zeros(nx,ny,nz));
           
        tvalue(:,:,:) = NaN;
        beta(:,:,:) = NaN;
        pvalue(:,:,:) = NaN;
        
        for z = 1 : nz
            for x = 1 : nx
                for y = 1 : ny
                    for runNr = 1 : numRuns
                        
                        preDiff(runNr,1)   = [Diff{runNr,1}(x,y,z)];
                        postDiff(runNr,1)  = [Diff{runNr,2}(x,y,z)];
                        
                    end
                    
                    if (VDatMask(x,y,z) && ~any(isnan([preDiff; postDiff])))
                        [B,DEV,STATS]   = glmfit(preDiff,postDiff);
                        tvalue(x,y,z)   = STATS.t(1,1);     % intercept t
                        beta(x,y,z)     = STATS.beta(1,1);  % intercept B0
                        pvalue(x,y,z)     = STATS.p(1,1);     % intercept p
                    end
                    clear preDiff postDiff B DEV STATS
                end
            end
            spm_progress_bar('set',(z/nz)*100);
        end % voxels
        
        %
        % save files
        TimgFileVol(1)      = spm_vol(OAbeta{1});
        BetaimgFileVol(1)   = spm_vol(OAbeta{1});
        PvalimgFileVol(1)   = spm_vol(OAbeta{1});
        
        % save each ROI each subject T Beta Pval files
        dirRes = [dirStudy 'PPI_GroupResults_PostDiffRegrPeak' fs 'PostDiffRegr' fs ROIfname{roi}];
        
        if ~exist(dirRes, 'dir')
            mkdir(dirRes);
        end
        
        TimgFileVol(1).fname    = fullfile(dirRes, [subjects{subj} '_PrePostRegressionT.nii']);
        BetaimgFileVol(1).fname = fullfile(dirRes, [subjects{subj} '_PrePostRegressionBeta.nii']);
        PvalimgFileVol(1).fname = fullfile(dirRes, [subjects{subj} '_PrePostRegressionPval.nii']);
        
        spm_write_vol(TimgFileVol(1),tvalue);
        spm_write_vol(BetaimgFileVol(1),beta);
        spm_write_vol(PvalimgFileVol(1),pvalue);
        
        clear OAbetaVol UNbetaVol OAbetaData UNbetaData tvalue beta
    end % subject
end % ROI

close all
