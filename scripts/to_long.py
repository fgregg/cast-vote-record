import sys
import csv

reader = csv.DictReader(sys.stdin)

in_fieldnames = reader.fieldnames

ballot_header = in_fieldnames[:9]
vote_header = ["race", "option", "party", "choice"]
races = in_fieldnames[9:]


writer = csv.DictWriter(sys.stdout, fieldnames=ballot_header + vote_header)

writer.writeheader()

for row in reader:
    common_row = {k: row[k] for k in ballot_header}
    for race_str in races:
        choice = row[race_str]
        if choice:
            out_row = {"choice": choice}
            out_row["race"], out_row["option"], out_row["party"] = race_str.split(" | ")
            out_row.update(common_row)

            writer.writerow(out_row)
