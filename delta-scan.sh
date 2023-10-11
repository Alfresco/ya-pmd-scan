#!/usr/bin/env bash
echo "=========================== Starting PMD Script ==========================="
set -e

# The location of the PMD ruleset.
ruleset_location=$1
# The git reference for the branch to merge the PR into.
target_ref=$2
# The git reference for the branch containing the PR changes.
head_ref=$3
# Whether to generate a sarif report for GitHub annotations.
generate_sarif=$4

# Requires PMD to have already been downloaded to this location.
run_pmd="/opt/hostedtoolcache/pmd/${PMD_VERSION}/x64/pmd-bin-${PMD_VERSION}/bin/pmd"

# Create a temporary directory for storing files.
tmp_dir=$(mktemp -d)

# Create a list of the files changed by this PR.
baseline_ref=$(git merge-base "${target_ref}" "${head_ref}")
git diff --name-only ${baseline_ref} ${head_ref} > ${tmp_dir}/file-list.txt
git diff --name-only ${head_ref} ${baseline_ref} >> ${tmp_dir}/file-list.txt
sort -u ${tmp_dir}/file-list.txt -o ${tmp_dir}/file-list.txt
git diff ${baseline_ref} ${head_ref} > ${tmp_dir}/full-diff.txt

# Run PMD against the baseline commit.
git checkout ${baseline_ref}
old_file_count=0
touch ${tmp_dir}/old-files.txt
for file in $(cat ${tmp_dir}/file-list.txt)
do
    if [[ -f ${file} ]]
    then
        echo ${file} >> ${tmp_dir}/old-files.txt
        old_file_count=$((old_file_count+1))
    fi
done
${run_pmd} check --cache ${tmp_dir}/pmd.cache --file-list ${tmp_dir}/old-files.txt -R ${ruleset_location} -r ${tmp_dir}/old_report.txt --no-fail-on-violation
old_issue_count=$(cat ${tmp_dir}/old_report.txt | wc -l)
echo "${old_issue_count} issue(s) found in ${old_file_count} old file(s) on ${baseline_ref}"

# Rerun PMD against the PR head commit.
git checkout ${head_ref}
new_file_count=0
touch ${tmp_dir}/new-files.txt
for file in $(cat ${tmp_dir}/file-list.txt)
do
    if [[ -f ${file} ]]
    then
        echo ${file} >> ${tmp_dir}/new-files.txt
        new_file_count=$((new_file_count+1))
    fi
done
if [[ "${generate_sarif}" == "true" ]]
then
    echo "Generating sarif.json for GitHub annotations."
    ${run_pmd} check --cache ${tmp_dir}/pmd.cache --file-list ${tmp_dir}/new-files.txt -R ${ruleset_location} --format=sarif -r ${tmp_dir}/sarif.json --no-fail-on-violation
fi
${run_pmd} check --cache ${tmp_dir}/pmd.cache --file-list ${tmp_dir}/new-files.txt -R ${ruleset_location} -r ${tmp_dir}/new_report.txt --no-fail-on-violation
new_issue_count=$(cat ${tmp_dir}/new_report.txt | wc -l)
echo "${new_issue_count} issue(s) found in ${new_file_count} updated file(s) on ${head_ref}"

# Display the differences between the two files in the log.
diff ${tmp_dir}/old_report.txt ${tmp_dir}/new_report.txt || true

# Store references to the files created.
echo "OLD_ISSUE_COUNT=${old_issue_count}" >> "${GITHUB_ENV}"
echo "NEW_ISSUE_COUNT=${new_issue_count}" >> "${GITHUB_ENV}"
echo "OLD_REPORT_FILE=${tmp_dir}/old_report.txt" >> "${GITHUB_ENV}"
echo "NEW_REPORT_FILE=${tmp_dir}/new_report.txt" >> "${GITHUB_ENV}"
if [[ "${generate_sarif}" == "true" ]]
then
    echo "SARIF_REPORT_FILE=${tmp_dir}/sarif.json" >> "${GITHUB_ENV}"
fi
echo "FULL_DIFF_FILE=${tmp_dir}/full-diff.txt" >> "${GITHUB_ENV}"
echo "HEAD_REF=$(git rev-parse ${head_ref})" >> "${GITHUB_ENV}"
echo "BASELINE_REF=${baseline_ref}" >> "${GITHUB_ENV}"

set +e
echo "=========================== Finishing PMD Script =========================="
