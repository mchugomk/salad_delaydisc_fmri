
addpath '/data/images/adak/code/adak_foodpics/matlab/src/'
foodpics_data_dir='/data/images/adak/data/bids_data/derivatives/adak_foodpics'

% list of 'subjects to process
slist={'sub-204'
'sub-207'
'sub-209'
'sub-212'
'sub-213'
'sub-215'
'sub-216'
'sub-223'
'sub-225'
'sub-226'
'sub-227'
'sub-228'
'sub-229'
'sub-235'
'sub-236'
'sub-237'
'sub-238'
'sub-242'
'sub-244'
'sub-245'
'sub-246'
'sub-247'
'sub-248'
'sub-249'
'sub-250'
'sub-252'
'sub-254'
'sub-255'
'sub-256'
'sub-257'
'sub-258'
'sub-259'
'sub-260'
'sub-261'
'sub-262'
'sub-263'
'sub-266'
'sub-267'
'sub-268'
};

conlist={'con_0001'
'con_0002'
'con_0003'
};

%% loop over subjects 
for s=1:length(slist)
    subject_id=slist{s}

    for c=1:length(conlist)
        con_name=conlist{c}
        foodpics_subtract_cons(con_name, 'foodpics_firstlevel', fullfile(foodpics_data_dir, subject_id))
    end

end
