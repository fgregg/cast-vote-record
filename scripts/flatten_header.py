import sys
import csv
import re

reader = csv.reader(sys.stdin)
writer = csv.writer(sys.stdout)

next(reader)
races = next(reader)[8:]
options = next(reader)[8:]
mixed = next(reader)
parties = mixed[8:]

combo = [' | '.join((race, option, party)) for race, option, party in zip(races, options, parties)]

header = mixed[:8] + combo

writer.writerow(header)

for row in reader:
    clean_row = [field.strip('"=') for field in row[:8]] + row[8:]

    writer.writerow(clean_row)
