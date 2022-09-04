# Chicago Cast Vote Records, June 2022 Primaries.

This repo contains 

* the raw CVR data (encrypted)
* the precincts used in the June 2022 Primaries (raw dir)
* scripts for turning that into a normalized sqlite db and [suppressing some data to protect privacy](./scripts/suppress.sql)
* [the sqlite db (password protected)](https://github.com/fgregg/cast-vote-record/releases/download/v1/cvr_geo_suppress.db.zip)

### Provenance
This data ultimately proceeds from a [FOIA request](https://www.muckrock.com/foi/chicago-169/cast-vote-record-120119/). I got these records on July 18, 2022.

### ERD for the sqlite db

![This is an image](/erd.png)

### Working with the data.

This sqlite data is highly normalized. You may want to pivot the vote table wider to get something easier to work with, but you can do interesting things 
with the table as it is.

For example here's a query that gives the counts for the number of ballots
that were aligned with the [Girl, I Guess](https://docs.google.com/document/d/11diBlRiahHsCkHHpV1lt2fHHxgRwQpz-G0t9iGeBCtI/edit#heading=h.3jcg60s3d56u) voter guide for the races that covered the whole city

```sql
WITH mask AS (
    SELECT
        ballot_id
    FROM
        vote
    GROUP BY
        ballot_id
    HAVING
        sum(option_id = 2) -- JB Pritzker and Juliana Stratton
        AND sum(option_id = 8) -- Anna Valencia
        AND sum(option_id = 39) -- Toni Preckwinkle
        AND sum(option_id = 51)  -- Fritz Kaegi
        AND sum(option_id = 38) -- Chakena D. Perry
        AND sum(option_id = 26) -- Mariyana T. Spyropoulos
        AND sum(option_id = 32) -- Precious W. Brady-Davis
        AND sum(option_id = 34)) -- Sharon Waller
SELECT
    count(*)
FROM
    mask;
```

About 17K Ballots is the answer to that one!
