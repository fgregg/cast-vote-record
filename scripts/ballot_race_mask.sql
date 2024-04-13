CREATE TABLE ballot_race_mask AS
WITH ballot_race AS (
    SELECT DISTINCT
        ballot_id,
        race_id
    FROM
        ballot
        INNER JOIN vote ON ballot_id = ballot.id
        INNER JOIN option ON option_id = option.id
)
SELECT DISTINCT
    ballot_id,
    group_concat (race_id) OVER (PARTITION BY ballot_id ORDER BY race_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) mask
    FROM
        ballot_race
