#!/bin/bash
echo "Returning back unwanted Characters"
sed -i 's/"None_escaped"/"None"/g' $1*.json
sed -i 's/escaped_38/\\"38\\"/g' $1*.json
sed -i 's/escaped_3/\\"3\\"/g' $1*.json
sed -i 's/"escaped_yes"/"yes"/g' $1*.json
sed -i 's/"escaped_no"/"no"/g' $1*.json
sed -i 's/"escaped_3_no_slash"/"3"/g' $1*.json
sed -i 's/"escaped_1_no_slash"/"1"/g' $1*.json
sed -i 's/"escaped_2_no_slash"/"2"/g' $1*.json
sed -i 's/escaped_none_with_slash/\\"None\\"/g' $1*.json
sed -i 's/escaped_done_earlier/\\"done_earlier\\"/g' $1*.json
sed -i 's/\\u00c2\\u00ba/º/g' $1*.json
sed -i 's/escaped_inconclusive/\\"inconclusive\\"/g' $1*.json

echo "Done returning back unwanted Characters"
