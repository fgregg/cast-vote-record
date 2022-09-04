# Chicago Cast Vote Records, June 2022 Primaries.

This repo contains 

* the raw CVR data (encrypted)
* the [precincts used in the June 2022 Primaries](./raw)
* scripts for turning that into a normalized sqlite db and [suppressing some data to protect privacy](./scripts/suppress.sql)
* [the sqlite db (password protected)](https://github.com/fgregg/cast-vote-record/releases/download/v1/cvr_geo_suppress.db.zip)

**NOTE: the votes in this database will not quite equal to the precinct level tallies reported on the Chicago Board of Election because of suppression of some ballot to protect privacy**

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
/* 
2: JB Pritzker and Juliana Stratton
8: Anna Valencia
39: Toni Preckwinkle
51: Fritz Kaegi
38: Chakena D. Perry
26: Mariyana T. Spyropoulos
32: Precious W. Brady-Davis
34: Sharon Waller
*/
SELECT
    count(*)
FROM
    mask;
WITH mask AS (
    SELECT
        ballot_id
    FROM
        vote
    GROUP BY
        ballot_id
    HAVING
        sum(option_id IN (2, 8, 39, 51, 38, 26, 32, 34)) = 8
)
SELECT
    count(*)
FROM
    mask;    
```

About 17K Ballots is the answer to that one!

Here's a similar query for the [Cook County Democratic slate](https://www.cookcountydems.com/cook-county-democrats-endorse-slate-for-2022-primary/):

```sql
/*
2: JB Pritzker and Juliana Stratton
6: Alexi Giannoulias
39: Toni Preckwinkle
51: Fritz Kaegi
27: Yumeka Brown
26: Mariyana T. Spyropoulos
28: Patricia Theresa Flynn
36: Daniel Pogorzelski
*/ 
WITH mask AS (
    SELECT
        ballot_id
    FROM
        vote
    GROUP BY
        ballot_id
    HAVING
        sum(option_id IN (2, 6, 39, 51, 27, 26, 28, 36)) >= 7
)
SELECT
    count(*)
FROM    
```

only around 14K!
