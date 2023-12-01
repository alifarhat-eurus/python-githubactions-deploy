#!/bin/bash
app=$1
echo "app is" $app
cd helm/helmfile.d
wget https://github.com/helmfile/helmfile/releases/download/v0.159.0/helmfile_0.159.0_linux_amd64.tar.gz
tar -xzvf helmfile_0.159.0_linux_amd64.tar.gz
./helmfile -h

./helmfile init --force

set +e ./helmfile diff --environment lower -f $app --detailed-exitcode
exit_code=#$(echo $?)
echo "----exit_code-----"
echo $exit_code
set -e 
if [[ $exit_code -eq 2 || $exit_code -eq 130 ]]; then
    echo "helm_apply_required=true" >> "$GITHUB_OUTPUT"
    echo "Changes dectected in helm diff"

    ./helmfile diff --environment lower -f $app --detailed-exitcode &>> loki_helm_diff_summary
    echo "diff-summary=$(cat loki_helm_diff_summary)" >> $GITHUB_STEP_SUMMARY

    echo "Building helm .... "
    ./helmfile build --environment lower -f $app

    echo "Apply helm .... "
    ./helmfile apply --environment lower -f $app
    
    exit 0
elif [[ $exit_code -eq 1 ]]; then
    echo "Helm diff resulted in error with exit code 1"

    ./helmfile diff --environment lower -f $app --detailed-exitcode &>> loki_helm_diff_summary
    echo "diff-summary=$(cat loki_helm_diff_summary)" >> $GITHUB_STEP_SUMMARY

    exit 1
else
    echo "No changes detected in helm diff"

    ./helmfile diff --environment lower -f $app --detailed-exitcode &>> loki_helm_diff_summary
    echo "diff-summary=$(cat loki_helm_diff_summary)" >> $GITHUB_STEP_SUMMARY

    exit 0
fi
