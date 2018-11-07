#!/bin/bash
#
# Filter an existing DNS zone into static and dynamic entries.
#
# Assumes that current directory has three files:
#   - existing - current zone w/ dynamic entries
#   - new - new zone (compiled by bind)
#   - new_zone - new zone (raw)

# No need for the old SOA.
sed -i -e '/IN SOA/ d' existing

# For each RR the new zone, remove it from the existing zone.
for RR in $(grep -v "IN SOA" new | awk '{ print $1 }' | sort -fu); do
  sed -i -e "/^${RR//\./\\.}\s/ d" existing
done

# If we still have bits left, add them to the new zone.
if [[ -s existing ]]; then
  echo "; Dynamic entries follow" >> new_zone
  cat existing >> new_zone
fi
