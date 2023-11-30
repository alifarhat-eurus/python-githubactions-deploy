#!/bin/bash
cd helm/helmfile.d
wget https://github.com/helmfile/helmfile/releases/download/v0.159.0/helmfile_0.159.0_linux_amd64.tar.gz
tar -xzvf helmfile_0.159.0_linux_amd64.tar.gz
./helmfile -h

./helmfile init --force

set +e ./helmfile diff --environment lower -f $1 --detailed-exitcode
exit_code=2
#$(echo $?)
echo "----exit_code-----"
echo $exit_code
set -e 
if [[ $exit_code -eq 2 || $exit_code -eq 130 ]]; then
    echo "helm_apply_required=true" >> "$GITHUB_OUTPUT"
    echo "Changes dectected in helm diff"
    exit 0
elif [[ $exit_code -eq 1 ]]; then
    echo "Helm diff resulted in error with exit code 1"
    exit 1
else
    echo "No changes detected in helm diff"
    exit 0
fi

./helmfile diff --environment lower -f $1 --detailed-exitcode &>> loki_helm_diff_summary
echo "$(cat loki_helm_diff_summary)" >> $GITHUB_STEP_SUMMARY