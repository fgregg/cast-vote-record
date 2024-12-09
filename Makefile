cvr_geo_suppress.db.zip : cvr_geo_suppress.db
	zip -e $@ $<

cvr_geo_suppress.db : cvr.db
	sqlite3 $@ < scripts/suppress.sql
	sqlite-utils transform $@ ballot \
            --drop CvrNumber \
            --drop BatchId \
            --drop RecordId \
            --drop CountingGroup \
            --drop Portion \
            --drop Ballot \
            --drop TabulatorNum

cvr.db : vote.csv
	cat scripts/create_vote_table.sql | sqlite3 $@
	tail -n +2 $< | sqlite3 $@ ".mode csv" ".import /dev/stdin vote"
	sqlite-utils extract $@ vote CvrNumber TabulatorNum BatchId RecordId CountingGroup Ward Precinct Portion Ballot --table ballot --fk-column ballot_id
	sqlite-utils extract $@ vote race option party --table option --fk-column option_id
	sqlite-utils extract $@ option race --table race --fk-column race_id
	sqlite3 $@ < scripts/ballot_race_mask.sql
	sqlite-utils extract $@ ballot_race_mask mask --table ballot_race_mask_normal --fk-column race_mask_id
	sqlite3 $@ < scripts/unwind_ballot_race.sql
	sqlite3 $@ < scripts/add_race_to_vote.sql
	sqlite-utils transform $@ ballot_race --type race_id integer 
	sqlite-utils add-foreign-key $@ ballot ballot_race_id ballot_race id
	sqlite-utils add-foreign-key $@ ballot_race race_id race id
	sqlite-utils add-foreign-keys $@ vote race_id race id \
            vote option_id option id \
            vote ballot_id ballot id
	sqlite-utils create-index $@ vote ballot_id
	sqlite-utils create-index $@ vote race_id ballot_id
	sqlite-utils create-index $@ ballot_race id

	sqlite3 $@ < scripts/cleanup.sql


.INTERMEDIATE : ballot.csv vote.csv cvr_wide.csv

vote.csv : cvr_wide.csv
	cat $< | python scripts/to_long.py > $@

cvr_wide.csv : CVR_Export_20241126151047.csv
	cat $< | \
            python scripts/flatten_header.py | \
            python scripts/expand_cols.py > $@

CVR_Export_20241126151047.csv : raw/CVR_Export_20241126151047.7z
	7zz e $< $@
	touch $@



