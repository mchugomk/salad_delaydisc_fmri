#!/bin/bash


## Study specific variables to specify data folders and license files
task_id=foodpics
study_dir=/data/images/adak										# main study directory
bids_dir=$study_dir/data/bids_data								# bids data directory
preproc_dir=$bids_dir/derivatives/fmriprep_3mm					# directory with preprocessed data
output_dir=$bids_dir/derivatives/adak_${task_id}				# analysis output directory for fmriprep 3mm data
log_dir=$bids_dir/derivatives/logs								# directory to save log file 
firstlevel_script=$study_dir/code/adak_${task_id}/src/wrapper.sh						# main script to run preprocessing
multi_conds1=$study_dir/code/adak_${task_id}/matlab/src/onsets_${task_id}_run-01.mat	# onsets for foodpics run 1
multi_conds2=$study_dir/code/adak_${task_id}/matlab/src/onsets_${task_id}_run-02.mat	# onsets for foodpics run 2
n_vols=172
tr=2
fwhm=6
output_space=MNI152NLin6Asym_res-07	#MNI152NLin6Asym3mm_res-01 # MNI152NLin6Asym_res-2

## List of subjects
subject_id_list=(sub-204
sub-207
sub-209
sub-212
sub-216
sub-223
sub-225
sub-226
sub-227
sub-235
sub-236
sub-237
sub-238
sub-242
sub-244
sub-245
sub-246
sub-247
sub-248
sub-249
sub-250
sub-252
sub-254
sub-256
sub-258
sub-260
sub-261
sub-266
sub-267
)
nsub=${#subject_id_list[@]}

## List of sessions
session_id_list=(ses-01
ses-02
ses-03
ses-04) 
nses=${#session_id_list[@]}



for (( sub=0; sub<$nsub; sub++ )); do
	
	for (( ses=0; ses<$nses; ses++ )); do
		
		subject_id=${subject_id_list[$sub]}
		session_id=${session_id_list[$ses]}
		echo $subject_id $session_id
		
		now=`date +"%Y%m%d%H%M%S"` 

		## Save output from command line to log file
		logfile=$log_dir/${task_id}_output_${subject_id}_${session_id}_${now}.log

		## Set file paths
		fmrifile1=${preproc_dir}/${subject_id}/${session_id}/func/${subject_id}_${session_id}_task-${task_id}_run-01_space-${output_space}_desc-preproc_bold.nii.gz
		fmrifile2=${preproc_dir}/${subject_id}/${session_id}/func/${subject_id}_${session_id}_task-${task_id}_run-02_space-${output_space}_desc-preproc_bold.nii.gz
		confounds1=${preproc_dir}/${subject_id}/${session_id}/func/${subject_id}_${session_id}_task-${task_id}_run-01_desc-confounds_timeseries.tsv
		confounds2=${preproc_dir}/${subject_id}/${session_id}/func/${subject_id}_${session_id}_task-${task_id}_run-02_desc-confounds_timeseries.tsv
		out_dir=${output_dir}/${subject_id}/${session_id}/${task_id}_firstlevel


		## Check for files
		if [ ! -e $fmrifile1 ]; then
			echo "Func file does not exist: $fmrifile1"
			exit 1
		fi
		if [ ! -e $fmrifile2 ]; then
			echo "Func file does not exist: $fmrifile2"
			exit 1
		fi
		if [ ! -e $confounds1 ]; then
			echo "Confounds file does not exist: $confounds1"
			exit 1
		fi
		if [ ! -e $confounds2 ]; then
			echo "Confounds file does not exist: $confounds2"
			exit 1
		fi


		## Standard first level analysis for task with 2 runs
		date > $logfile # Overwrite existing log file
		echo "Running $firstlevel_script for $subject_id $session_id $task_id" >> $logfile


		echo "$firstlevel_script --fmri1_niigz $fmrifile1 \
--fmri2_niigz $fmrifile2 \
--confounds1 $confounds1 \
--confounds2 $confounds2 \
--multi_conds1 $multi_conds1 \
--multi_conds2 $multi_conds2 \
--tr $tr \
--n_vols $n_vols \
--fwhm $fwhm \
--out_dir $out_dir 2>&1 | tee -a $logfile
" >> $logfile


		$firstlevel_script --fmri1_niigz $fmrifile1 \
			--fmri2_niigz $fmrifile2 \
			--confounds1 $confounds1 \
			--confounds2 $confounds2 \
			--multi_conds1 $multi_conds1 \
			--multi_conds2 $multi_conds2 \
			--tr $tr \
			--n_vols $n_vols \
			--fwhm $fwhm \
			--out_dir $out_dir | tee -a $logfile
			date >> $logfile
	
	done

done