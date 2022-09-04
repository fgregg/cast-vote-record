/* set precinct to null, if there are too few ballots in the
geography. it would be better to instead merge sparse precincts
with neighboring precincts until the mimimum count was reached, but
that's more complicated to implement */

WITH low_count_precinct AS (
    SELECT
        ballot_race_id,
        Ward,
        Precinct,
        count(*)
    FROM
        ballot
    GROUP BY
        ballot_race_id,
        Ward,
        Precinct
    HAVING
        count(*) < 10)
UPDATE
    ballot
SET
    Precinct = NULL
FROM
    low_count_precinct
WHERE
    ballot.ballot_race_id = low_count_precinct.ballot_race_id
    AND ballot.Ward = low_count_precinct.Ward
    AND ballot.Precinct = low_count_precinct.Precinct;

/* if only one precinct in a ward got suppressed in the previous
stage it would still be identifiable. so, we then suppress all precincts
in ward. the geography merging method would obviate this. */
WITH low_count_precinct AS (
    SELECT
        ballot_race_id,
        Ward,
        Precinct,
        count(*)
    FROM
        ballot
    GROUP BY
        ballot_race_id,
        Ward,
        Precinct
    HAVING
        count(*) < 10)
UPDATE
    ballot
SET
    Precinct = NULL
FROM
    low_count_precinct
WHERE
    ballot.ballot_race_id = low_count_precinct.ballot_race_id
    AND ballot.Ward = low_count_precinct.Ward;

WITH low_count_ward AS (
    SELECT
        ballot_race_id,
        Ward,
        count(*)
    FROM
        ballot
    GROUP BY
        ballot_race_id,
        Ward
    HAVING
        count(*) < 10)
UPDATE
    ballot
SET
    Ward = NULL,
    Precinct = NULL
FROM
    low_count_ward
WHERE
    ballot.ballot_race_id = low_count_ward.ballot_race_id;

/* there are some ballots that are so rare they are also identifying */
WITH low_ballot_count AS (
    SELECT
        ballot_race_id,
        Ward,
        Precinct,
        count(*)
    FROM
        ballot
    GROUP BY
        ballot_race_id,
        Ward,
        Precinct
    HAVING
        count(*) < 10
),
low_ballot_count_ballots AS (
    SELECT
        *
    FROM
        ballot
    INNER JOIN low_ballot_count
    USING (ballot_race_id)
    WHERE ballot.Ward is low_ballot_count.Ward
    AND ballot.Precinct is low_ballot_count.Precinct
)
DELETE FROM vote
WHERE ballot_id IN (
        SELECT
            id
        FROM
            low_ballot_count_ballots);


/* there are some ballots that are so rare they are also identifying */
WITH low_ballot_count AS (
    SELECT
        ballot_race_id,
        Ward,
        Precinct,
        count(*)
    FROM
        ballot
    GROUP BY
        ballot_race_id,
        Ward,
        Precinct
    HAVING
        count(*) < 10
),
low_ballot_count_ballots AS (
    SELECT
        *
    FROM
        ballot
    INNER JOIN low_ballot_count
    USING (ballot_race_id)
    WHERE ballot.Ward is low_ballot_count.Ward
    AND ballot.Precinct is low_ballot_count.Precinct
)
UPDATE ballot
SET ballot_race_id = NULL
FROM low_ballot_count_ballots
WHERE ballot.id = low_ballot_count_ballots.id;


