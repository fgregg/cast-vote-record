
DROP TABLE ballot_race_mask;
DROP TABLE ballot_race_mask_normal;

DELETE FROM vote WHERE choice != 1;

ALTER TABLE VOTE DROP COLUMN choice;

VACUUM;
