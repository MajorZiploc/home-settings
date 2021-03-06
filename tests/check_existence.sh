#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source ~/.bashrc || true;

function typea_check(){
  type -a "$1";
}

@test "check that all user defined bash functions exist" {
  IFS= ;
  l=(
  "find_files"
  "h"
  "hf"
  "show_env_notes"
  "tmuxcs"
  "tmuxps"
  "tmuxds"
  "ide1"
  "ide2"
  "ide3"
  "show_find_full_paths"
  "show_machine_details"
  "show_folder_details"
  "prefix_file"
  "col_n"
  "skip_n"
  "take_n"
  "sample"
  "show_file_content"
  "sample_csv"
  "search_env_for"
  "search_env_for_fuzz"
  "show_block"
  "show_line_nums"
  "refresh_settings"
  "refresh_pwsh"
  "find_items_rename_experimental_helper"
  "find_items_rename_preview_experimental"
  "find_items_rename_experimental"
  "find_items"
  "find_items_fuzz"
  "find_files_delete_preview"
  "find_files_delete"
  "find_files_rename_helper"
  "find_files_rename_preview"
  "find_files_rename"
  "find_files"
  "find_files_fuzz"
  "find_in_files"
  "find_in_files_fuzz"
  "find_in_files_replace"
  "git_checkout_branch_in_path"
  "git_log_follow"
  "git_diff_range"
  "git_log_show_last_n"
  "show_cmds_like"
  "show_cmds_like_fuzz"
  "snip_bash_for_loop"
  "snip_sql_search_column"
  "snip_sql_general_search"
  "snip_pwsh_init_module"
  "snip_pwsh_init_script"
  )
  for funct in ${l[@]};
    do
      run typea_check "$funct"
      assert_success
      assert_output --partial "$funct"
    done;
  unset IFS;
}

@test "check that all user defined bash aliases exist" {
  IFS= ;
  l=(
  "tmuxas"
  "tmuxks"
  "tmuxksvr"
  "tmuxls"
  #"clip"
  #"clipp"
  "show_path"
  "rev_chars"
  "rev_lines"
  "toggle_case"
  "camel_to_snake"
  "snake_to_camel"
  "snake_to_space"
  "camel_to_space"
  "space_to_snake"
  "space_to_camel"
  "to_lower"
  "to_upper"
  "rtrim"
  "ltrim"
  "trim"
  "keep_last"
  "keep_first"
  "to_fuzz"
  "to_newlines"
  "bash_surround_expression"
  "bash_surround_stream"
  "bash_line_join"
  "bash_line_split"
  "bse"
  "bss"
  "blj"
  "bls"
  "bln"
  "dir"
  "vdir"
  "ls"
  "dir"
  "vdir"
  "grep"
  "fgrep"
  "egrep"
  "ll"
  "la"
  "ld"
  "l"
  "less_r"
  "less_f"
  "whence"
  "df_h"
  "du_h"
  "grepn_files"
  "grepn_files_freq"
  "grepn_files_uniq"
  "find_items_hidden"
  "find_items_nonhidden"
  "reexe"
  "vimi"
  "vimc"
  "vimt"
  "vimnp"
  "curl_follow_redirects"
  "curl_follow_redirects_ignore_security_exceptions"
  "show_fn_names"
  "show_fn_impls"
  "back"
  #"time_js"
  "git_merge_keep_theirs"
  "git_deploy"
  "to_winpath"
  "to_unixpath"
  "kill_port"
  )
  for funct in ${l[@]};
    do
      run typea_check "$funct"
      assert_success
      assert_output --partial "$funct"
    done;
  unset IFS;
}

