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


-- UPDATE
--     ballot
-- SET
--     ballot_race_id = ballot_race_mask.race_mask_id
-- FROM
--     ballot_race_mask
-- WHERE
--     ballot_race_mask.CvrNumber = ballot.CvrNumber;

-- CREATE TABLE race_option_mask as 
-- WITH ballot_race AS (
--     SELECT DISTINCT
--         CvrNumber,
--         race_id
--     FROM
--         ballot
--         INNER JOIN vote USING (CvrNumber)
--         INNER JOIN option ON option_id = option.id
-- )
--     SELECT DISTINCT
--         CvrNumber,
--         group_concat (race_id) OVER (PARTITION BY 
--             CvrNumber ORDER BY race_id ROWS between UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) mask
--     FROM ballot_race




-- CREATE TABLE ballot_race AS
-- WITH RECURSIVE split(id, race_id, str) AS (
--     SELECT id, '', mask||',' FROM race_msk
--     UNION ALL SELECT
--     id,
--     substr(str, 0, instr(str, ',')),
--     substr(str, instr(str, ',')+1)
--     FROM split WHERE str!=''
-- ) 
-- SELECT id, race_id
-- FROM split
-- WHERE race_id != ''
-- order by id;

