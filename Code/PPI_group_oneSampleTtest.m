% Runs One-Sample T-test of PPI results using SPM
%
% FILE STRUCTURE
% -dirStudy
%   -subject1
%       -dirSPM(day) -- first level analysis betas and SPM.mat file
%           -[PPI_PostDiff ROIfname(s)] -- PPI analysis results
%               -[contrasts{c} subject '.nii']
%   ...
%   -subjectN
%       -dirSPM(day) -- first level analysis betas and SPM.mat file
%           -[PPI_PostDiff ROIfname(s)] -- PPI analysis results
%               -[contrasts{c} subject '.nii']
%
%   -dirPPIGroupResults -- group results dir
%       -ROIfname(s)
%           -condition(s)
%
%
% contact: dace@dcdace.net

clear
spm fmri;
spm('defaults','fmri');
spm_jobman('initcfg');

dirStudy = 'G:\SR0046_ProcessedFinal\'; % base directory
dirPPIGroupResults = 'PPI_GroupResults_PostDiffRegrPeak';

contrasts  = {'con_PPI_OA_Rest_' 'con_PPI_UN_Rest_' 'con_PPI_OA_UN_' 'con_PPI_UN_OA_'}; % for PPI

subjects    = {'02','03','05','06','07','08','09','10','11','13','14','15','17','18','19','20'};

ROIfname    =  {
    '10mmPeakC1_RSPL'
    '10mmPeakC2_RdPM'
    '10mmPeakC3_LvPM'
    '10mmPeakC4_LdPM'
    };
fs = filesep;

for day = 1 : 2 % analyse each scan day separately
    for r = 1 : length(ROIfname) % for each PPI region
        for c = 1 : length(contrasts)
            display(['ttest for ' contrasts{c}]);
            
            clear matlabbatch
            
            dirRes  = fullfile(dirStudy, dirPPIGroupResults, ['Day' num2str(day)], ROIfname{r}, contrasts{c});
            if ~exist(dirRes, 'dir')
                mkdir(dirRes);
            end
            cd(dirRes);
            matlabbatch{1}.spm.stats.factorial_design.dir = {dirRes};
            
            for subj = 1 : length(subjects)
                subject = ['SR0046_P' subjects{subj}];
                matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{subj,1} = fullfile(dirStudy, subject, ['univarDay' num2str(day)], ['PPI_PostDiff' ROIfname{r}], [contrasts{c} subject '.nii,1']);
            end
            matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
            
            % run batch
            spm_jobman('run', matlabbatch);
            
            %% ESTIMATE
            display(['Estimate ' analysis_names{a}]);
            
            clear matlabbatch
            
            matlabbatch{1}.spm.stats.fmri_est.spmmat = {[dirRes filesep 'SPM.mat']};
            matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
            matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
            
            % run batch
            spm_jobman('run', matlabbatch);
            
            %% CONTRASTS
            display(['Contrasts ' analysis_names{a}]);
            
            clear matlabbatch
            
            matlabbatch{1}.spm.stats.con.spmmat = {[dirRes filesep 'SPM.mat']};
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = analysis_names{a};
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = 1;
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
            matlabbatch{1}.spm.stats.con.delete = 0;
            
            % run batch
            spm_jobman('run', matlabbatch);
            
            %% REPORT
            display(['Report ' analysis_names{a}]);
            
            clear matlabbatch
            
            matlabbatch{1}.spm.stats.results.spmmat = {[dirRes filesep 'SPM.mat']};
            matlabbatch{1}.spm.stats.results.conspec(1).titlestr = '';
            matlabbatch{1}.spm.stats.results.conspec(1).contrasts = 1;
            matlabbatch{1}.spm.stats.results.conspec(1).threshdesc = 'none';
            matlabbatch{1}.spm.stats.results.conspec(1).thresh = 0.001;
            matlabbatch{1}.spm.stats.results.conspec(1).extent = 10;
            matlabbatch{1}.spm.stats.results.conspec(1).mask.none = 1;
            matlabbatch{1}.spm.stats.results.units = 1;
            matlabbatch{1}.spm.stats.results.print = 'jpg';
            matlabbatch{1}.spm.stats.results.write.none = 1;
            
            % run batch
            spm_jobman('run', matlabbatch);
        end % condition
    end % ROI
end % day
