% Uses SPM Marsbar toolbox
% Creates a ROI around subject's peak of the sepcified contrast within group ROI
% Uses SPM Marsbar toolbox
% contact: dace@dcdace.net

clear

fs           = filesep;
dirStudy     = 'G:\SR0046_ProcessedFinal\';
dirROIs      = 'G:\SR0046_ProcessedFinal\ROIs_PostDiffRegression\';
dirContrast  = 'G:\SR0046_ProcessedFinal\PrePostRegression\subjects\';

nameContrast = '_PrePostRegressionBeta.nii';

subjects     = {'02','03','05','06','07','08','09','10','11','13','14','15','17','18','19','20'};

mm = 10; % size of the new ROI in mm

for subj = 1 : length(subjects)
    
    % get all ROI file names
    ROIdir = dirROIs;
    ROIfiles = dir([ROIdir '15mm*.nii']);
    
    for i = 1 : length(ROIfiles) % for each ROI
        
        fileContrast = fullfile(dirContrast, [subjects{subj} nameContrast]);
        
        fileROI = [ROIdir ROIfiles(i).name];
        
        % get all ROI coordinates. use marsbar
        fileROI_matfname = [fileROI(1:(length(fileROI)-4)) '.mat'];
        
        %% export nii rois no marsbar mat rois
        if ~exist(fileROI_matfname,'file')
            display('creating .mat file');
            mars_img2rois(fileROI, dirROIs, ROIfiles(i).name(1:(length(ROIfiles(i).name)-4)), 'i');
        end
        V = spm_vol(fileROI);
        my_space = mars_space(V);
        
        R = maroi(fileROI_matfname);
        [pts vals] = voxpts(R,my_space);
        %---
        
        dataContrast  = spm_vol(fileContrast);
        y = spm_get_data(dataContrast,pts); % all values within the ROI
        
        % max absolute value and position
        [maxVal pos] = max(abs(y));
        
        % convert the position to MNI coord
        MNI = vox2mni(my_space.mat,pts(:,pos));
        
        % create a ROI around these coordinates
        
        if ~exist([dirROIs subjects{subj}], 'dir')
            mkdir([dirROIs subjects{subj}]);
        end
        
        roi_name = fullfile(dirROIs, subjects{subj}, [num2str(mm) 'mmPeak' ROIfiles(i).name(5:(length(ROIfiles(i).name)-4)) '.nii']);
        marsbarCreateROI(MNI', mm, fileContrast, roi_name);
 
    end % ROI
    
end % subject

