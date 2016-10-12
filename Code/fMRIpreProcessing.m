% fMRI preprocessing using SPM
% contact: dace@dcdace.net

parameters = DefineParameters;

%% SPM
spm fmri;
spm('defaults','fmri');
spm_jobman('initcfg'); % Initialise jobs configuration and set MATLAB path accordingly.

for subjNr = 1 : size(parameters.name_subj,2); % for each participant
    
    fprintf(1,'==================================\n');
    fprintf(1,'Pre-processing participant %s\n', parameters.name_subj{subjNr});
    fprintf(1,'==================================\n');
    
    %% FILES
    dir_subj = [parameters.dir_base filesep parameters.name_subj{subjNr}];
    cd (dir_subj);
    
    for sess    = 1:parameters.n_sess
        
        if sess < 10
            dir_scans{sess} = [dir_subj filesep parameters.dir_functional filesep parameters.sess_prfx '0' num2str(sess)]; % scan directory
        else
            dir_scans{sess} = [dir_subj filesep parameters.dir_functional filesep parameters.sess_prfx num2str(sess)];
        end
        
        for scan_nr = 1 : parameters.n_scans
            niifile = dir([dir_scans{sess} filesep '*.nii']); % find the nii file in the functiona/runx directory
            niifilenames{scan_nr,1} = [dir_scans{sess} filesep niifile(1).name ',' num2str(scan_nr)]; % if there are more then one nii file, will take the first one
        end
        datafiles{sess} = niifilenames; % will be used in Preprocesing batches
        name_scans{sess} = niifile(1).name; % will be used in Analysis
        
    end
    
    %% REALIGNMENT
    clear job
    
    job{1}.spm.spatial.realign.estwrite.data = datafiles;
    job{1}.spm.spatial.realign.estwrite.eoptions.quality = 1;
    job{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    job{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    job{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1; % 0 - register to first; 1 - register to mean
    job{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    job{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    job{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    job{1}.spm.spatial.realign.estwrite.roptions.which = [2 1]; % resliced images
    job{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    job{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    job{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    job{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    
    % save batch file for review
    savefile = [dir_subj filesep 'realign_', parameters.name_subj{subjNr}];
    save(savefile,'job')
    
    % run batch
    spm_jobman('run', job);
    
    %% SLICE TIMING CORRECTION
    clear job
    
    % use realigned files (prefix r)
    for sess    = 1:parameters.n_sess
        for scan_nr = 1 : parameters.n_scans
            niifile_r = dir([dir_scans{sess} filesep 'r*.nii']); % find the nii file in the functiona/runx directory
            
            niifile_r_names{scan_nr,1} = [dir_scans{sess} filesep niifile_r(1).name ',' num2str(scan_nr)]; % if there are more then one nii file, will take the first one
        end
        datafiles_r{sess} = niifile_r_names;
    end
    
    job{1}.spm.temporal.st.scans = datafiles_r;
    
    job{1}.spm.temporal.st.nslices = parameters.num_slices;
    job{1}.spm.temporal.st.tr = parameters.TR;
    job{1}.spm.temporal.st.ta = parameters.TA;
    job{1}.spm.temporal.st.so = parameters.slice_order;
    job{1}.spm.temporal.st.refslice = parameters.ref_slice;
    job{1}.spm.temporal.st.prefix = 'a';
    
    % save batch file for review
    savefile = [dir_subj filesep 'slicetimingcorr_', parameters.name_subj{subjNr}];
    save(savefile,'job')
    
    % run batch
    spm_jobman('run', job);
    
    %% COREGISTRATION (anatomical to functional)
    clear job
    
    % reference file
    mean_niifile = dir([dir_scans{1} filesep 'mean*.nii']); % usually saved in the first session (run01) folder
    mean_niifile = {[dir_scans{1} filesep mean_niifile.name ',1']};
    % source file
    T1_file = dir([dir_subj filesep parameters.dir_anatomical filesep '*.nii']);
    T1_file = {[dir_subj filesep parameters.dir_anatomical filesep T1_file(1).name ',1']}; % i there is more then one, use first file (nopeel)
    
    job{1}.spm.spatial.coreg.estimate.ref = mean_niifile;  % mean realigned functional image
    job{1}.spm.spatial.coreg.estimate.source = T1_file;
    job{1}.spm.spatial.coreg.estimate.other = {''};
    job{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    job{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    job{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    job{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    
    % save batch file for review
    savefile = [dir_subj filesep 'coregistration_', parameters.name_subj{subjNr}];
    save(savefile,'job')
    
    % run batch
    spm_jobman('run', job);
    
    %% SEGMENTATION
    clear job
    
    job{1}.spm.spatial.preproc.channel.vols = T1_file;
    job{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    job{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    job{1}.spm.spatial.preproc.channel.write = [0 1];
    job{1}.spm.spatial.preproc.tissue(1).tpm = {[spm('Dir') filesep 'tpm/TPM.nii,1']};
    job{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    job{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    job{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    job{1}.spm.spatial.preproc.tissue(2).tpm = {[spm('Dir') filesep 'tpm/TPM.nii,2']};
    job{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    job{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    job{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    job{1}.spm.spatial.preproc.tissue(3).tpm = {[spm('Dir') filesep 'tpm/TPM.nii,3']};
    job{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    job{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    job{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    job{1}.spm.spatial.preproc.tissue(4).tpm = {[spm('Dir') filesep 'tpm/TPM.nii,4']};
    job{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    job{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    job{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    job{1}.spm.spatial.preproc.tissue(5).tpm = {[spm('Dir') filesep 'tpm/TPM.nii,5']};
    job{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    job{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    job{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    job{1}.spm.spatial.preproc.tissue(6).tpm = {[spm('Dir') filesep 'tpm/TPM.nii,6']};
    job{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    job{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    job{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    job{1}.spm.spatial.preproc.warp.mrf = 1;
    job{1}.spm.spatial.preproc.warp.cleanup = 1;
    job{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    job{1}.spm.spatial.preproc.warp.affreg = 'mni';
    job{1}.spm.spatial.preproc.warp.fwhm = 0;
    job{1}.spm.spatial.preproc.warp.samp = 3;
    job{1}.spm.spatial.preproc.warp.write = [0 1];
    
    % save batch file for review
    savefile = [dir_subj filesep 'segmentation_', parameters.name_subj{subjNr}];
    save(savefile,'job')
    
    % run batch
    spm_jobman('run', job);
    
    %% NORMALISATION
    clear job
    
    % use realigned and slice timing corrected files (prefix ar)
    datafiles_ar = [];
    for sess    = 1:parameters.n_sess
        for scan_nr = 1 : parameters.n_scans
            niifile_ar = dir([dir_scans{sess} filesep 'ar*.nii']); % find the nii file in the functiona/runx directory
            
            niifile_ar_names{scan_nr,1} = [dir_scans{sess} filesep niifile_ar(1).name ',' num2str(scan_nr)]; % if there are more then one nii file, will take the first one
        end
        datafiles_ar = [datafiles_ar; niifile_ar_names];
    end
    T1_yfile = dir([dir_subj filesep parameters.dir_anatomical filesep 'y*.nii']);  % deformation field file created in Segmentation
    T1_yfile = {[dir_subj filesep parameters.dir_anatomical filesep T1_yfile(1).name]};
    
    job{1}.spm.spatial.normalise.write.subj.def = T1_yfile;
    
    job{1}.spm.spatial.normalise.write.subj.resample = datafiles_ar;
    
    job{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -50
        78 76 85];
    job{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    job{1}.spm.spatial.normalise.write.woptions.inteparameters.rp = 4;
    
    % save batch file for review
    savefile = [dir_subj filesep 'normalisation_', parameters.name_subj{subjNr}];
    save(savefile,'job')
    
    % run batch
    spm_jobman('run', job);
    
    %% SMOOTHING
    clear job
    
    % use realigned, slice timing corrected and normalised files (prefix war)
    datafiles_war = [];
    for sess    = 1:parameters.n_sess
        for scan_nr = 1 : parameters.n_scans
            niifile_war = dir([dir_scans{sess} filesep 'war*.nii']); % find the nii file in the functiona/runx directory
            
            niifile_war_names{scan_nr,1} = [dir_scans{sess} filesep niifile_war(1).name ',' num2str(scan_nr)]; % if there are more then one nii file, will take the first one
        end
        datafiles_war = [datafiles_war; niifile_war_names];
    end
    
    job{1}.spm.spatial.smooth.data = datafiles_war;
    %%
    job{1}.spm.spatial.smooth.fwhm(1:1:3)= parameters.smooth_fwhm;
    job{1}.spm.spatial.smooth.dtype = 0;
    job{1}.spm.spatial.smooth.im = 0;
    job{1}.spm.spatial.smooth.prefix = 's';
    
    % save batch file for review
    savefile = [dir_subj filesep 'smoothing_', parameters.name_subj{subjNr}];
    save(savefile,'job')
    
    % run batch
    spm_jobman('run', job);
    
    %% NEXT PARTICIPANT
end
fprintf(1,'==================================\n');
fprintf(1,'All done.');
fprintf(1,'==================================\n');
