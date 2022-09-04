import sys
import csv
import re

reader = csv.DictReader(sys.stdin)
read_fieldnames = reader.fieldnames

write_fieldnames = [
    "CvrNumber",
    "TabulatorNum",
    "BatchId",
    "RecordId",
    "CountingGroup",
    "Ward",
    "Precinct",
    "Portion",
    "Ballot",
] + read_fieldnames[8:]

writer = csv.DictWriter(sys.stdout, fieldnames=write_fieldnames)
writer.writeheader()

for row in reader:
    ward, precinct, portion = re.match(
        "Ward (\d+) Precinct (\d+)-(\d+) .*", row.pop("PrecinctPortion")
    ).groups()
    row["Ward"] = ward
    row["Precinct"] = precinct
    row["Portion"] = portion

    ballot, ballot_type = re.match(
        "Ballot (\d+) - Type (\d+) .*", row.pop("BallotType")
        ).groups()
    row["Ballot"] = ballot

    del row["ImprintedId"]
    
    writer.writerow(row)
