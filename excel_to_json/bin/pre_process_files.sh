#!/bin/bash
echo "Stripping out unwanted Characters"

sed -i 's/"None"/"None_escaped"/g' $1*.json
sed -i 's/\\"38\\"/escaped_38/g' $1*.json
sed -i 's/\\"3\\"/escaped_3/g' $1*.json
sed -i 's/"yes"/"escaped_yes"/g' $1*.json
sed -i 's/"no"/"escaped_no"/g' $1*.json
sed -i 's/"3"/"escaped_3_no_slash"/g' $1*.json
sed -i 's/"1"/"escaped_1_no_slash"/g' $1*.json
sed -i 's/"2"/"escaped_2_no_slash"/g' $1*.json
sed -i 's/\\"None\\"/escaped_none_with_slash/g' $1*.json
sed -i 's/\\"done_earlier\\"/escaped_done_earlier/g' $1*.json
sed -i 's/\\"inconclusive\\"/escaped_inconclusive/g' $1*.json

echo "Done Stripping the unwanted Characters"
