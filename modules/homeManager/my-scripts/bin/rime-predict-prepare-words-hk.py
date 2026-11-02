#!/usr/bin/env python3

import csv
import sys


# This program converts the CSV https://words.hk/faiman/analysis/existingwordcount.csv
# into a TSV accepted by https://github.com/rime/librime-predict/blob/data-1.0/tools/build_predict.cc
# A sample TSV is available at https://github.com/rime/librime-predict/blob/data-1.0/data/sample.txt
# The TSV has 3 columns.
# The first column is the head, which must be a string of a single code point.
# The second column is the tail, which must be a string of at least one code point.
# The third column is the weight, and it IS NOT actually used.
# The input TSV to build_predict is expected to be sorted, from most frequent to least frequent.
# The source order of the TSV is used as is when displaying the list of prediction candidates.
def main():
    reader = csv.reader(sys.stdin)
    writer = csv.writer(sys.stdout, delimiter="\t")
    sorted_tuples: list[tuple[str, str, int]] = []
    for row in reader:
        word = row[0]
        weight: int = int(row[1])
        head: str = word[0:1]
        tail: str = word[1:]
        # The tail must be non-empty.
        # The words in the source CSV does contain words that is only 1 code point long.
        if len(tail) <= 0:
            continue
        sorted_tuples.append((head, tail, weight))
    # Sort order is
    # 1. By head, lexicographically increasing order
    # 2. By weight, numerically decreasing order
    # 3. By tail, lexicographically increasing order
    sorted_tuples = sorted(sorted_tuples, key=lambda row: (row[0], -row[2], row[1]))
    for t in sorted_tuples:
        writer.writerow([t[0], t[1], t[2]])


main()
