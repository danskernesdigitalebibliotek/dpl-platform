echo "** Danish Public Libraries Platform Shell **"
export DNSIMPLE_ACCOUNT="61014"

export DPLPLAT_ENV="dplplat01"

# Get bash completion and set the alias and set completion for the alias
source <(kubectl completion bash)
alias kc=kubectl
complete -o default -F __start_kubectl kc

# Give PS1 some color so it's eaiser to find
export PS1='\[$(printf "\x1b[38;2;255;100;250m\]$(hostname):$(pwd)$ \[\x1b[0m")\]'

echo
echo "Environment is assumed to be 'dplplat01'"
echo "If you want to operate another environment, run 'export DPLPLAT_ENV=<environment>'"
echo "Consult https://github.com/danskernesdigitalebibliotek/dpl-platform/blob/main/docs/platform-environments.md"
echo
echo "Now run "task" to continue your work."
echo
