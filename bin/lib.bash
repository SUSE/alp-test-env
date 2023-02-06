#!/bin/bash -eu

cmd_name="$(basename "${BASH_SOURCE[1]}")"
cmd_dir="$(dirname "$(readlink -e "${BASH_SOURCE[1]}")")"

base_dir="$(dirname "${cmd_dir}")"

venv_name="ansible-venv"
venv_dir="${base_dir}/.${venv_name}"
venv_reqs="${venv_dir}-requirements.txt"
venv_bin="${venv_dir}/bin"

[[ "${DEBUG:+true}" != "true" ]] || echo 1>&2 "DBG: cmd_name='${cmd_name}' cmd_dir='${cmd_dir}'"

# vim:shiftwidth=4:tabstop=4:expandtab
