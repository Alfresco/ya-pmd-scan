# Yet Another PMD Scan GitHub Action

This repository contains the PMD GitHub Action and default configuration. Although primarily intended for Alfresco repositories, it is a generic Github Action and could be used by anybody.

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
      pmd-version: "7.0.0" # The version of PMD to use (only 7.x versions are supported).
      pmd-sha256-digest: "24be4bde2846cabea84e75e790ede1b86183f85f386cb120a41372f2b4844a54" # The expected SHA-256 digest of the PMD distribution binaries zip file (64 digit hexidecimal value).
      create-github-annotations: "true" # Whether to create annotations using the GitHub Advanced Security (nb. this is not free for private repositories)
      fail-on-new-issues: "true" # Whether the introduction of new issues should cause the build to fail.
      pmd-ruleset-repo: "Alfresco/pmd-ruleset" # The GitHub repository containing the PMD ruleset (by default https://github.com/Alfresco/pmd-ruleset/).
      pmd-ruleset-ref: "master" # The git reference (e.g. branch name, tag name or commit id) for the ruleset project.
      pmd-ruleset-path: "pmd-ruleset.xml" # The path to the PMD ruleset file from the root of the ruleset project. Optionally other paths to local rulesets can be appended to this separated by commas.
      classpath-enable: "true" # Whether to set the classpath before the scan (used by certain rules - for example MissingOverride). This assumes the project uses maven.
      classpath-build-command: "mvn -ntp test-compile" # Command to build the class files so that the classpath can be used.
      classpath-directory-list: "**/target/classes" # A colon-separated list of directories containing class files. Using wildcards (*) or globstar (**) is also supported in order to select items at one or many levels deep.
```

All parameters have default values and can be skipped.

A human readable summary of the report is created as an artifact called `PMD Summary (Human Readable)`.
