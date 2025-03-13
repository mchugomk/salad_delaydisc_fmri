function delaydisc_firstlevel_any_session(subject_id, session_id, run_list)
%% function delaydisc_firstlevel_any_session(subject_id, session_id, run_list)
%
% subject_id: BIDS-format subject ID, e.g., sub-204
% session_id: BIDS-format session ID, e.g., ses-01
% run_list: array containing list of runs to process
%   to process both runs: [1 2]
%   to process only run 1: [1]
%   to process only run 2: [2]

if nargin ~= 3 
    error('Must specify subject_id, session_id and run_list');
end

%% Study specific variables to specify data folders and SPM settings
study_id='salad';
task_id='delaydisc';
study_dir=fullfile('/home/data/images', study_id);                          % main study directory
onset_dir=fullfile(study_dir, 'data', 'sourcedata', 'task_data');           % directory with SPM onsets
bids_dir=fullfile(study_dir,'data','bids_data');                            % bids data directory
preproc_dir=fullfile(bids_dir, 'derivatives','fmriprep_ses01t1_nofmap');    % directory with preprocessed data, uses t1 from ses-01 and no fieldmap correction
output_dir=fullfile(bids_dir,'derivatives',[study_id '_' task_id]);         % analysis output directory for SPM data

n_vols='378';                           % each run should contain 378 volumes
tr='1';                                 % repetition time = 1s
fwhm='6';                               % FWHM kernel size for smoothing
hpf='128';                              % High pass filter cutoff
output_space='MNI152NLin6Asym_res-02';  % Use fmriprep output in MNI152NLin6Asym template space with 2mm resolution

disp(['Processing subject: ' subject_id ' session: ' session_id]);
disp(['n_vols: ' n_vols]);
disp(['tr: ' tr]);
disp(['fwhm: ' fwhm]);
disp(['hpf: ' hpf]);
disp(['output_space: ' output_space]);

%% Make output folder if it doesn't exist
out_dir=fullfile(output_dir, subject_id, session_id, [task_id '_firstlevel']);
if not(isfolder(out_dir))
    [status, msg] = mkdir(out_dir);
    if status == 1 
        error(msg);
    end
end

%% Loop over all runs

for r = 1:length(run_list)
    % Set file paths
    run_number = num2str(run_list(r));

%     multi_conds=fullfile(onset_dir, subject_id, session_id, ['DelayDiscount_' subject_id '_' session_id, '_Run' run_number '.mat']);    % onsets for delaydisc run
    multi_conds=fullfile(onset_dir, subject_id, session_id, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'onsets.mat']);    % onsets for delaydisc run

    fmri=fullfile(preproc_dir,subject_id,session_id,'func', [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'space-' output_space '_' 'desc-preproc_bold.nii.gz']);
    confounds=fullfile(preproc_dir,subject_id,session_id,'func', [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'desc-confounds_timeseries.tsv']);    

    % Copy input files to out_dir
    [status, msg] = copyfile(fmri, out_dir);
    if status == 1 
        error(msg);
    end
    [status, msg] = copyfile(confounds, out_dir);
    if status == 1 
        error(msg);
    end
    [status, msg] = copyfile(multi_conds, out_dir);
    if status == 1 
        error(msg);
    end

end

%% Unzip nifti files for SPM
gunzip(fullfile(out_dir,'*.gz'))


%% Call firstlevel function
%         'multi_conds1', fullfile(out_dir, ['DelayDiscount_' subject_id '_' session_id, '_Run1.mat']), ...
%         'multi_conds2', fullfile(out_dir, ['DelayDiscount_' subject_id '_' session_id, '_Run2.mat']), ...

if length(run_list) == 2
    delaydisc_firstlevel('fmri1_nii', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-01' '_' 'space-' output_space '_' 'desc-preproc_bold.nii']), ...
        'fmri2_nii', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-02' '_' 'space-' output_space '_' 'desc-preproc_bold.nii']), ...
        'confounds1', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-01' '_' 'desc-confounds_timeseries.tsv']), ...
        'confounds2', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-02' '_' 'desc-confounds_timeseries.tsv']), ...
        'multi_conds1', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-01'  '_' 'onsets.mat']), ...
        'multi_conds2', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-02'  '_' 'onsets.mat']), ...
        'tr', tr, ...
        'n_vols', n_vols, ...
        'fwhm', fwhm, ...
        'hpf', hpf, ...
        'out_dir', out_dir)
else 
    delaydisc_firstlevel('fmri1_nii', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'space-' output_space '_' 'desc-preproc_bold.nii']), ...
        'confounds1', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'desc-confounds_timeseries.tsv']), ...
        'multi_conds1', fullfile(out_dir, [subject_id '_' session_id '_' 'task-' task_id '_' 'run-0' run_number '_' 'onsets.mat']), ...
        'tr', tr, ...
        'n_vols', n_vols, ...
        'fwhm', fwhm, ...
        'hpf', hpf, ...
        'out_dir', out_dir)

end
