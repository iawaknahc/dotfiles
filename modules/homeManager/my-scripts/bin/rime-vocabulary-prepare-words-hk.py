#!/usr/bin/env python3

import csv
import sys


# This program converts the CSV https://words.hk/faiman/analysis/existingwordcount.csv
# into a .txt file accepted by `vocabulary: ` in .dict.yaml in Rime.
# Each line in the file is a phrase and a weight separated by a tab.
# So effectively, it is a TSV file.
def main():
    reader = csv.reader(sys.stdin)
    writer = csv.writer(sys.stdout, delimiter="\t")
    for row in reader:
        writer.writerow(row)


main()
