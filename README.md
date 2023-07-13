# Alfresco PMD GitHub Action

This repository contains the PMD GitHub Action and default configuration. Although primarily intended for Alfresco repositories, it is a generic Action and could be used by anybody.

## Action

Runs the [PMD](https://pmd.github.io/) static analysis tool to check for common programming flaws.

The action looks for issues in files modified by PRs and should only be run against the pull-request target:

```yml
name: "PMD Scan"
runs-on: ubuntu-latest
if: >
  github.event_name == 'pull_request'
steps:
  - uses: Alfresco/alfresco-build-tools/.github/actions/pmd@ref
    with:
      pmd-version: "6.55.0" # The version of PMD to use
      create-github-annotations: "true" # Whether to create annotations using the GitHub Advanced Security (nb. this is not free for private repositories)
      fail-on-new-issues: "true" # Whether the introduction of new issues should cause the build to fail.
      pmd-ruleset-ref: "master" # The git reference (e.g. branch name or commit id) for the [pmd-ruleset](https://github.com/AlfrescoLabs/pmd-ruleset/) project.
```

All parameters have default values and can be skipped.

The PMD [SARIF](https://sarifweb.azurewebsites.net/) report is created as an artifact called `PMD Report` and a human readable summary of the report is created as an artifact called `PMD Summary (Human Readable)`.
