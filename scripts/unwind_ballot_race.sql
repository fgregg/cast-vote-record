CREATE TABLE ballot_race AS
WITH RECURSIVE split(id, race_id, str) AS (
    SELECT id, '', mask||',' FROM ballot_race_mask_normal
    UNION ALL SELECT
    id,
    substr(str, 0, instr(str, ',')),
    substr(str, instr(str, ',')+1)
    FROM split WHERE str!=''
) 
SELECT id, race_id
FROM split
WHERE race_id != ''
order by id;

ALTER TABLE ballot
ADD COLUMN ballot_race_id INTEGER;


UPDATE
    ballot
SET
    ballot_race_id = ballot_race_mask.race_mask_id
FROM
    ballot_race_mask
WHERE
    ballot_race_mask.ballot_id = ballot.id;

