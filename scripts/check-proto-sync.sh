#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
schema_path="proto/slouching/v1/handshake.proto"
temp_dir="$(mktemp -d)"
trap 'rm -rf -- "${temp_dir}"' EXIT

cd "${project_root}"
status=0
while read -r key submodule_path; do
  name="${key#submodule.}"
  name="${name%.path}"
  url="$(git config --file .gitmodules --get "submodule.${name}.url")"
  commit="$(git ls-files --stage -- "${submodule_path}" | cut -d' ' -f2)"
  copy="${temp_dir}/${name//\//-}.proto"
  # An initialized submodule already has the pinned commit; otherwise fetch only
  # that commit's trees and the one schema blob.
  if git -C "${submodule_path}" cat-file -e "${commit}:${schema_path}" 2>/dev/null; then
    git -C "${submodule_path}" cat-file blob "${commit}:${schema_path}" >"${copy}"
  else
    fetch_dir="${temp_dir}/${name//\//-}.git"
    git init --quiet --bare "${fetch_dir}"
    git -C "${fetch_dir}" remote add origin "${url}"
    git -C "${fetch_dir}" fetch --quiet --depth 1 --filter=blob:none origin "${commit}"
    git -C "${fetch_dir}" cat-file blob "FETCH_HEAD:${schema_path}" >"${copy}"
  fi
  if cmp -s "${schema_path}" "${copy}"; then
    printf '%s at %s matches the canonical schema.\n' "${submodule_path}" "${commit:0:7}"
  else
    printf '%s at %s carries a different %s.\n' "${submodule_path}" "${commit:0:7}" "${schema_path}" >&2
    status=1
  fi
done < <(git config --file .gitmodules --get-regexp '^submodule\..*\.path$')
exit "${status}"
