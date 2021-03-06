. ~/.bash_functions_sets

function h() {
  # show history
  # $1: optional pos num to show last n entries in the history
  local n="$1";
  [[ -z "$n" ]] && { n=25; }
  history | tail -n "$n";
}

function hf() {
  # show most commonly used commands based on frequency
  # $1: optional pos num to show last n entries
  local n="$1";
  [[ -z "$n" ]] && { n=25; }
  history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -n | tail -n "$n";
}

function show_env_notes() {
  export ENV_NOTES="";
  # Dependency checks
  [[ -z $(which npm 2>/dev/null) ]] && { ENV_NOTES="$ENV_NOTES:Missing npm (node package manager)"; }
  [[ -z $(which tmux 2>/dev/null) ]] && { ENV_NOTES="$ENV_NOTES:Missing tmux (terminal multiplexier)"; }
  [[ -z $(which pwsh 2>/dev/null) ]] && { ENV_NOTES="$ENV_NOTES:Missing pwsh (cross platform powershell)"; }
  [[ -z $(which gnomon 2>/dev/null) ]] && { ENV_NOTES="$ENV_NOTES:Missing gnomon (npm package)"; }
  [[ -z $(which rg 2>/dev/null) ]] && { ENV_NOTES="$ENV_NOTES:Missing rg (ripgrep) Important for the ripgrep plugin in vim"; }
  [[ -z $(dotnet --version 2>/dev/null | egrep "^5") ]] && { ENV_NOTES="$ENV_NOTES:Missing dotnet v5 (cross platform dotnet cli tooling)"; }
  [[ -z $(which just 2>/dev/null) ]] && { ENV_NOTES="$ENV_NOTES:Missing just (a command runner for Justfiles)"; }
  [[ -z $(which asdf 2>/dev/null) ]] && { ENV_NOTES="$ENV_NOTES:Missing asdf (a general programming language version manager)"; }
  EXTRA_ENV_CHECKS_PLACEHOLDER
  # final check on environment
  [[ -z "$ENV_NOTES" ]] && { ENV_NOTES="No missing dependencies! Setup is complete!"; }
  echo $ENV_NOTES | tr ":" "\n" | egrep -v "^\\s*$"
}

function tmuxcs() {
  # tmux create session
  # creates a tmux session
  # $1: optional string to represent name of the tmux session
  # If $1 not given, then use the base name of the path as the session name
  if [ -z "$1" ]; then
    local session_name="$(basename $(pwd))";
  else
    local session_name="$1";
  fi
  local session_name="$(echo "$session_name" | tr '.' '-')";
  tmux new -s "$session_name" 2>/dev/null || tmux new -d -s "$session_name" && tmux switch-client -t "$session_name";
}

function tmuxps_get_project_dirs(){
  export TMUXPS_PROJECT_DIRS=TMUXPS_PATHS_ARRAY_PLACEHOLDER;
}

function tmuxps() {
  # tmux project session
  # creates a tmux session
  # $1: optional relative dir to start the tmux session in
  # If $1 not given, then display a fuzzy finder of various project dirs to select a project for creation of a session
  if [[ $# -eq 1 ]]; then
    local selected=$1;
  else
    local items="";
    tmuxps_get_project_dirs;
    for path in ${TMUXPS_PROJECT_DIRS[@]};
      do
        [[ -d $path ]] && {
          items+=`find $path -maxdepth 1 -mindepth 1 -type d`;
          items+="\n";
        }
    done;
    local selected=`printf "$items" | FUZZY_FINDER_PLACEHOLDER`;
  fi
  [[ -z "$selected" ]] || {
    local dirname=`basename $selected | tr '.' '-'`;
    tmux switch-client -t $dirname;
    if [[ $? -eq 0 ]]; then
      exit 0;
    fi
    tmux new-session -c $selected -d -s $dirname && tmux switch-client -t $dirname || tmux new -c $selected -A -s $dirname;
  }
}

function tmuxds() {
  # tmux directory session
  # displays a fuzzy finder listing of directories at the current directory to choose from for a tmux session
  tmuxps "$(find . -maxdepth 1 -mindepth 1 -type d | FUZZY_FINDER_PLACEHOLDER)";
}

function ide1() {
  # splits the window into 2 panes
  tmux split-window -v -p 30;
}

function ide2() {
  # splits the window into 3 panes
  tmux split-window -v -p 30;
  tmux split-window -h -p 55;
}

function ide3() {
  # splits the window into 4 panes
  tmux split-window -v -p 30;
  tmux split-window -h -p 66;
  tmux split-window -h -p 50;
}

function show_find_full_paths() {
  # displays the full path names of $1 (the directory)
  # $1: optional directory. Defaults to .
  find $1 -exec readlink -f "{}" \;
}

function show_machine_details() {
  local user=$(whoami);
  local machine_name=$(uname -n);
  long_info=$(uname -a);
  echo "user: $user";
  echo "machine_name: $machine_name";
  echo "long_info: $long_info";
}

function show_folder_details() {
  local total_items=$(ls -A | wc -l);
  local total_dirs=$(ls -Al | egrep "^d" | wc -l);
  local total_files=$(ls -Al | egrep "^-" | wc -l);
  local nonhidden_items=$(ls | wc -l);
  local nonhidden_dirs=$(ls -l | egrep "^d" | wc -l);
  local nonhidden_files=$(ls -l | egrep "^-" | wc -l);
  local hidden_items=$(($total_items - $nonhidden_items));
  local hidden_dirs=$(($total_dirs - $nonhidden_dirs));
  local hidden_files=$(($total_files - $nonhidden_files));
  local git_branch=$(__git_ps1);
  echo "$PWD";
  echo "format: nonhidden/hidden/total";
  echo "items: $nonhidden_items/$hidden_items/$total_items";
  echo "dirs: $nonhidden_dirs/$hidden_dirs/$total_dirs";
  echo "files: $nonhidden_files/$hidden_files/$total_files";
  echo "git_branch:$git_branch";
}

function prefix_file() {
  # add a line to the beginning of a file
  # $1: string to add
  # $2: file
  local text=$1;
  local file=$2;
  sed -i "1s/^/$text/" "$file";
}

function col_n {
  # Extract the nths column from a tabular output
  # $1: pos num
  local n=$1;
  awk -v col=$n '{print $col}';
}

function skip_n {
  # Skip first n words in line
  # $1: pos num
  local n=$(($1 + 1));
  cut -d' ' -f$n-;
}

function take_n {
  # Keep first n words in line
  # $1: pos num
  local n=$1;
  cut -d' ' -f1-$n;
}

function sample {
  # get a random sample of lines from a file or std out
  # Note: the lines retain order relative to each other
  # $1: pos num
  # $2: file/stdout
  local n="$1";
  local content="$2";
  shuf -n "$n" $content;
}

function show_file_content {
  # displays file contents lead by the name of the file
  # files=$@
  echo "Files: $@";
  echo "";
  tail -n +1 $@;
}

function sample_csv {
  # grab a random sample of n size from a csv
  local n=$1;
  local file="$2";
  cat <(head -n 1 "$file") <(sample $n <(tail -n +2 "$file"));
}

function search_env_for {
  # searches through bash env and user defined bash tools
  local search_regex="";
  [[ -z "$1" ]] && { search_regex=".*"; } || { search_regex="$1"; }
  cat <(ls -A ~/bin 2> /dev/null) <(ls -A /usr/local/bin 2> /dev/null) <(alias) <(env) <(declare -F) <(shopt) | egrep -i "$search_regex";
}

function search_env_for_fuzz {
  # fuzzy searches through bash env and user defined bash tools
  local search_regex="";
  [[ -z "$1" ]] && { search_regex=".*"; } || { search_regex="$(echo "$1" | to_fuzz)"; }
  search_env_for "$search_regex";
}

function show_block {
  # $1: regex string
  # $2: regex string
  # $3: file | stdin
  local from_pattern="$1";
  local to_pattern="$2";
  local content="$3";
  sed -n "/$from_pattern/,/$to_pattern/p; /$to_pattern/q;" "$content";
}

function show_line_nums {
  local content="$1";
  perl -nle 'print "$. $_"' "$content";
}

function refresh_settings_help {
local docs="$(cat << EOF
Purpose:
Refresh your bash, vim, clipboard, Tasks, and/or vscode settings
Can toggle some refreshes on and off with use of binary flag system

Assumption:
the ~/projects/home-settings repo has no working changes

refresh_settings() = refresh_settings_with_flags "00"
refresh_settings_all() = refresh_settings_with_flags "11"

Togglable Copies:
- vscode
- clipboard

Binary Flags to pass to refresh_settings_with_flags: (leading zeros can be omitted)
Use to copy the given settings
"01" -- vscode
"10" -- clipboard
These flags are stackable:
Ex:
refresh_settings_with_flags "11" -- copy vscode and clipboard aswell

How:
type -a refresh_settings to see implementation
This process tries to retain working changes in the git repo for home-settings for the copy down process
EOF
)"
  echo "$docs";
}

function refresh_settings_all {
  refresh_settings "11";
}

function refresh_settings_with_flags {
  local flags="$1";
  [[ -z "$flags" ]] && { echo "flags must be specified" >&2; return 1; }
  refresh_settings "$flags";
}

function refresh_settings {
  local flags="$1";
  [[ -z "$flags" ]] && { flags="00"; }
  local project_root_path="$HOME/projects/home-settings";
  cd "$project_root_path" &&
  git checkout master &&
  echo 'Previous commit information:' &&
  echo "$(git show --summary)" &&
  git pull &&
  "$project_root_path"/setup/OS_PLACEHOLDER/scripts/copy.sh "$flags" &&
  . ~/.bash_profile &&
  echo 'Refreshed settings!' &&
  echo '' &&
  echo 'Current commit information:' &&
  echo "$(git show --summary)";
  echo '';
  cd ~-;
  show_env_notes;
}

function refresh_pwsh {
  echo "Refreshing powershell modules...";
  echo '';
  pwsh -Command '& {@("powershell_scaffolder", "PSLogFileReporter") | ForEach-Object { Install-Module -Name "$_" -Scope CurrentUser -Force;}}';
  echo '';
  echo "Refresh completed.";
}

function find_items_rename_experimental_helper {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specify a file pattern!" >&2; return 1; }
  local by="$2";
  [[ -z "$by" ]] && { echo "Must specify a by substitution!" >&2; return 1; }
  local preview=$3;
  [[ -z "$preview" ]] && { echo "Must specify the preview flag!" >&2; return 1; }
  local maxdepth="$4";
  [[ -z "$maxdepth" ]] && { echo "Must specify a maxdepth!" >&2; return 1; }
  find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -print0 | while read -d $'\0' item
  do
    local new_name="$(echo "$item" | sed -E "$by")";
    [[ $f != $new_name ]] && {
      [[ $preview == false ]] && {
        mv "$item" "$new_name";
        true;
      } || {
        echo mv "$item" "$new_name" ";";
      }
    }
  done;
}

function find_items_rename_preview_experimental {
  local file_pattern="$1";
  local by="$2";
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  local preview=true;
  find_items_rename_experimental_helper "$file_pattern" "$by" $preview "$maxdepth";
}

function find_items_rename_experimental {
  local file_pattern="$1";
  local by="$2";
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  local preview=false;
  find_items_rename_experimental_helper "$file_pattern" "$by" $preview "$maxdepth";
}

function find_items {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specify a file pattern!" >&2; return 1; }
  local maxdepth="$2";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*';
}

function find_items_fuzz {
  local file_pattern="$(echo "$1" | to_fuzz)";
  local maxdepth="$2";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  find_items "$file_pattern" "$maxdepth";
}

function find_files_delete_preview {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specify a file pattern!" >&2; return 1; }
  local with_content="$2";
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  [[ -z "$with_content" ]] && {
    find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -exec echo rm "{}" \;
    true;
  } || {
    find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -exec egrep -in "$with_content" "{}" \; -exec echo rm "{}" \; | egrep "^rm"
  }
}

function find_files_delete {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specify a file pattern!" >&2; return 1; }
  local with_content="$2";
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  [[ -z "$with_content" ]] && {
    find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -exec rm "{}" \;
    true;
  } || {
    find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -exec egrep -in "$with_content" "{}" \; -exec rm "{}" \; > /dev/null
  }
}

function find_files_rename_helper {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specify a file pattern!" >&2; return 1; }
  local by="$2";
  [[ -z "$by" ]] && { echo "Must specify a by substitution!" >&2; return 1; }
  local with_content="$3";
  local preview=$4
  [[ -z "$preview" ]] && { echo "Must specify the preview flag!" >&2; return 1; }
  local maxdepth="$5";
  [[ -z "$maxdepth" ]] && { echo "Must specify a maxdepth!" >&2; return 1; }

  find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -print0  | while read -d $'\0' file
  do
    local should_rename=false;
    [[ -z "$with_content" ]] && {
      should_rename=true;
    } || {
      file_content_matches="$(egrep -in "$with_content" "$file")"
      [[ -z "$file_content_matches" ]] || { should_rename=true; }
    }
    [[ $should_rename == true ]] && {
      local b=$(basename "$file");
      local nb="$(echo "$b" | sed -E "$by")";
      local new_name="$(dirname "$file")/$nb"
      [[ $f != $new_name ]] && {
        [[ $preview == false ]] && {
          mv "$file" "$new_name";
          true;
        } || {
          echo mv "$file" "$new_name" ";";
        }
      }
    }
  done;
}

function find_files_rename_preview {
  local file_pattern="$1";
  local by="$2";
  local with_content="$3";
  local maxdepth="$4";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  local preview=true;
  find_files_rename_helper "$file_pattern" "$by" "$with_content" "$preview" "$maxdepth";
}

function find_files_rename {
  local file_pattern="$1";
  local by="$2";
  local with_content="$3";
  local maxdepth="$4";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  local preview=false;
  find_files_rename_helper "$file_pattern" "$by" "$with_content" "$preview" "$maxdepth";
}

function find_files {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specify a file pattern!" >&2; return 1; }
  local with_content="$2";
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  [[ -z "$with_content" ]] && {
    find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*';
    true;
  } || {
    find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -exec egrep -in "$with_content" "{}" \; -exec echo "{}" \; | egrep -v "\s*^[[:digit:]]+:"
  }
}

function find_files_fuzz {
  local file_pattern="$(echo "$1" | to_fuzz)";
  local with_content="$2";
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  find_files "$file_pattern" "$with_content" "$maxdepth";
}

function find_in_files {
  local grep_pattern="$1";
  [[ -z "$grep_pattern" ]] && { echo "Must specify a grep pattern!" >&2; return 1; }
  local file_pattern="$2";
  [[ -z "$file_pattern" ]] && { file_pattern=".*"; }
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -exec egrep --color -in "$grep_pattern" "{}" +;
}

function find_in_files_fuzz {
  local grep_pattern="$(echo "$1" | to_fuzz)";
  local file_pattern="$2";
  [[ -z "$file_pattern" ]] && { file_pattern=".*"; }
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  find_in_files "$grep_pattern" "$file_pattern" "$maxdepth";
}

function find_in_files_replace {
  local by="$1";
  [[ -z "$by" ]] && { echo "Must specify a by substitution!" >&2; return 1; }
  local file_pattern="$2";
  [[ -z "$file_pattern" ]] && { file_pattern=".*"; }
  local maxdepth="$3";
  [[ -z "$maxdepth" ]] && { maxdepth=9; }
  find . -maxdepth "$maxdepth" -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -not -path '*/.venv/*' -exec sed -E -i'' "$by" "{}" \;
}

function git_checkout_branch_in_path {
  local branch="$1";
  local path="$2";
  [[ -z "$branch" ]] && { echo "Must specify a branch!" >&2; return 1; }
  [[ -z "$path" ]] && { path='*'; }
  IFS= ;
  for ele in $path;
    do
      echo "$ele";
      cd $ele;
      # the first git pull to to ensure that if there is working dir changes
      #  that it will not continue to switching the branch
      git pull && git fetch origin && git checkout "$branch" && git pull;
      cd ..;
  done;
  unset IFS;
}

function git_log_follow {
  # search current branch git commits for commits that change a file
  local item_name="$1";
  git log --date-order --follow -- "$item_name";
}

function git_diff_range {
  # assumption from commit is older than to commit
  local from=$(($1 + 1));
  local to=$(($2 + 1));
  local commits="$(git --no-pager log --oneline -n "$from" | col_n 1 | xargs )";
  local from_commit="$(echo "$commits" | col_n "$from")";
  local to_commit="$(echo "$commits" | col_n "$to")";
  git diff --ignore-space-change "$from_commit" "$to_commit";
}

function git_log_show_last_n {
  local n="$1";
  git --no-pager log --oneline -n "$n" | perl -nle '$i=$.-1; print "$i $_"';
}

function git_diff_of_commit {
  local commit="$1";
  [[ -z "$commit" ]] && { echo "Must specify a commit!" >&2; return 1; }
  git diff "$commit"^!;
}

function git_graph {
  git log --oneline --decorate --all --graph;
}

function show_cmds_like {
  local pattern="$1";
  [[ -z "$pattern" ]] && { echo "Must specify a command pattern!" >&2; return 1; }
  local search_res=$(search_env_for "$pattern");
  local alias=$(echo "$search_res" | egrep -i "\s*alias");
  [[ -z "$alias" ]] || { echo "$alias"; }
  local fn_names=$(echo "$search_res" | egrep -i "\s*declare -f" | sed -E "s/declare -f (.*)/\1/" | xargs);
  for fn_name in ${fn_names[@]};
    do
      echo "$(declare -f $fn_name)";
  done;
}

function show_cmds_like_fuzz {
  local pattern="$(echo "$1" | to_fuzz)";
  show_cmds_like "$pattern";
}

function show_script_path {
  local scriptpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )";
  echo "$scriptpath";
}

