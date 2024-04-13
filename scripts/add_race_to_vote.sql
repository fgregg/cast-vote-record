BEGIN;

CREATE TABLE vote_race AS
SELECT
    vote.*,
    option.race_id
FROM
    vote
    INNER JOIN option ON vote.option_id = option.id;

DROP TABLE vote;

ALTER TABLE vote_race RENAME TO vote;

END;
