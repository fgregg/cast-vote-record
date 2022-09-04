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
	csvs-to-sqlite $^ $@
	sqlite-utils extract $@ vote CvrNumber TabulatorNum BatchId RecordId CountingGroup Ward Precinct Portion Ballot --table ballot --fk-column ballot_id
	sqlite-utils extract $@ vote race option party --table option --fk-column option_id
	sqlite-utils extract $@ option race --table race --fk-column race_id
	sqlite3 $@ < scripts/ballot_race_mask.sql
	sqlite-utils extract $@ ballot_race_mask mask --table ballot_race_mask_normal --fk-column race_mask_id
	sqlite3 $@ < scripts/unwind_ballot_race.sql
	sqlite-utils add-foreign-key $@ ballot ballot_race_id ballot_race id
	sqlite-utils add-foreign-key $@ ballot_race race_id race id
	sqlite3 $@ < scripts/cleanup.sql


.INTERMEDIATE : ballot.csv vote.csv cvr_wide.csv

vote.csv : cvr_wide.csv
	cat $< | python scripts/to_long.py > $@

cvr_wide.csv : CVR_Export_20220718163851.csv
	cat $< | \
            python scripts/flatten_header.py | \
            python scripts/expand_cols.py > $@

CVR_Export_20220718163851.csv : raw/CVR_Export_20220718163851.7z
	7zz e $< $@
	touch $@


raw/CVR_Export_20220718163851.7z : raw/CVR_Export_20220718163851.7z.gpg
	gpg --decrypt $< > $@


