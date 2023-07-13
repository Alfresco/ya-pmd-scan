#!/usr/bin/env bash
echo "=========================== Starting PMD Evaluation Script ==========================="
set -e

# The number of issues found in the old code.
old_issue_count=$1
# The number of issues found in the new code.
new_issue_count=$2
# Set to "true" if an increase in PMD violations should cause the build to fail.
fail_on_new_issues=$3

# Fail the build if there are more issues now than before.
if [[ ${new_issue_count} > ${old_issue_count} ]]
then
    echo "ERROR: Number of PMD issues in edited files increased from ${old_issue_count} to ${new_issue_count}"
    if [[ ${fail_on_new_issues} == "true" ]]
    then
        exit 1
    else
        echo "Increase in errors ignored as fail_on_new_issues set to ${fail_on_new_issues}"
    fi
else
    echo "Number of PMD issues in edited files went from ${old_issue_count} to ${new_issue_count}"
fi

set +e
echo "=========================== Finishing PMD Evaluation Script =========================="
