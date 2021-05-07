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

[[ ! -z $(which tmux 2>/dev/null) ]] && {
  function tmuxns() {
    # creates a tmux session
    # $1: optional string to represent name of the tmux session
    # If $1 not given, then use the base name of the path as the session name
    if [ -z "$1" ]; then
      session_name=$(basename $(pwd));
      tmux new -s "$session_name";
      history;
    else
      tmux new -s "$1";
    fi
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

# SET OPERATIONS BEGIN
# Referenced https://catonmat.net/set-operations-in-unix-shell

# set operations
function set_elem() {
  # membership check. ex: grep -xs 'element' set
  # returns 1 if set contains element, 0 if not
  local ele=$1;
  local set=$2;
  grep -xq "$ele" $set;
}

function set_eq() {
  # check if sets are equal
  # $ diff -q <(sort A | uniq) <(sort B | uniq)
  # return code 1 -- sets A and B are not equal
  # $ diff -q <(sort Aequal | uniq) <(sort Bequal | uniq)
  # return code 0 -- sets A and B are equal
  local set1=$1;
  local set2=$2;
  diff -q <(sort $set1 | uniq) <(sort $set2 | uniq);
}

function set_cardinality() {
  # the number of elements in the set
  local set=$1;
  sort -u $set | wc -l;
}

function set_subset() {
  # test if $1 is a subset of $2
  local subset=$1;
  local superset=$2;
  # comm returns no output if $subset is a subset of $superset
  # comm outputs something if $subset is not a subset of $superset
  [[ -z $(comm -23 <(sort $1 | uniq) <(sort $2 | uniq) | head -1) ]]
}

function set_union () {
  # returns elements that occur in either sets or both sets
  local set1=$1;
  local set2=$2;
  sort -u $set1 $set2;
}

function set_intersection() {
  # returns elements that occur in both sets
  local set1=$1;
  local set2=$2;
  comm -12 <(sort $set1) <(sort $set2);
}

function set_complement() {
  # returns elements that occur in $1 and not in $2
  # $1 - $2
  local set1=$1;
  local set2=$2;
  comm -23 <(sort $set1) <(sort $set2);
}

function set_symmetric_difference() {
  # returns elements that occur in either set, but not both sets
  local set1=$1;
  local set2=$2;
  sort $set1 $set2 | uniq -u;
}

function set_power_set_experimental() {
  # EXPERIMENTAL!
  # returns a set that contains all subsets of the set
  local set=$1;
  perl -le '
  sub powset {
   return [[]] unless @_;
   my $head = shift;
   my $list = &powset;
   [@$list, map { [$head, @$_] } @$list]
  }
  chomp(my @e = <>);
  for $p (@{powset(@e)}) {
   print @$p;
  }' $set
}

function set_cardesian_product_experimental() {
  # EXPERIMENTAL!
  # returns a set that contains all possible pairs of elements from one set and the other
  # $1 x $2
  local set1=$1;
  local set2=$2;
  while read a; do while read b; do echo "$a, $b"; done < $set1; done < $set2;
}

function set_disjoint_experimental() {
  # EXPERIMENTAL!
  # The disjoint set test operation finds if two sets are disjoint, i.e., they do not contain common elements.
  local set1=$1;
  local set2=$2;
  # returns 0 if sets are disjoint
  # returns 1 if sets are not disjoint
  awk '{ if (++seen[$0]==2) exit 1 }' $set1 $set2;
}

function set_minimum() {
  local set=$1;
  head -1 <(sort $set);
}

function set_minimum_num() {
  local set=$1;
  head -1 <(sort -n $set);
}

function set_maximum() {
  local set=$1;
  tail -1 <(sort $se1);
}

function set_maximum_num() {
  local set=$1;
  tail -1 <(sort -n $set);
}

# SET OPERATIONS END

function prefix_file() {
  # add a line to the beginning of a file
  # $1: string to add
  # $2: file
  local text=$1;
  local file=$2;
  sed -i "1s/^/$text/" "$file";
}

function col {
  # Extract the nths column from a tabular output
  # $1: pos num
  local n=$1;
  awk -v col=$n '{print $col}';
}

function skip {
  # Skip first n words in line
  # $1: pos num
  local n=$(($1 + 1));
  cut -d' ' -f$n-;
}

function first {
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

function num_lines {
  local content="$1";
  perl -nle 'print "$. $_"' "$content";
}

function refresh_settings {
  local project_root_path="$HOME/projects/home-settings";
  cd "$project_root_path" &&
  git checkout master &&
  git pull &&
  "$project_root_path"/setup/OS_PLACEHOLDER/scripts/copy.sh &&
  source ~/.bash_profile &&
  echo 'Refreshed settings!' &&
  echo '' &&
  echo 'Current commit information:' &&
  echo "$(git show --summary)";
  echo '';
  cd ~-;
  show_env_notes;
}

function refresh_pwsh {
  echo "Refreshing powershell modules..."
  echo ''
  pwsh -file $HOME/Tasks/pwsh_update_modules.ps1
  echo ''
  echo "Refresh completed."
}

function find_items_rename_experimental_helper {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specifiy a file pattern!"; return 1; }
  local by="$2";
  [[ -z "$by" ]] && { echo "Must specifiy a by substitution!"; return 1; }
  local preview=$3;
  [[ -z "$preview" ]] && { echo "Must specifiy the preview flag!"; return 1; }
  find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -print0  | while read -d $'\0' item
  do
    local new_name="$(echo "$item" | sed -E "$by")";
    [[ $f != $new_name ]] && {
      [[ -d "$item" ]] && {
        [[ $preview == false ]] && {
          mkdir -p "$new_name";
        } || {
          echo mkdir -p "$new_name" ";";
        }
      }
    }
  done;
  find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -print0 | while read -d $'\0' item
  do
    local new_name="$(echo "$item" | sed -E "$by")";
    [[ $f != $new_name ]] && {
      [[ $preview == false ]] && {
        mv "$item" "$new_name";
      } || {
        echo mv "$item" "$new_name" ";";
      }
    }
  done;
}

function find_items_rename_preview_experimental {
  local file_pattern="$1";
  local by="$2";
  local preview=true
  find_items_rename_experimental_helper "$file_pattern" "$by" $preview;
}

function find_items {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specifiy a file pattern!"; return 1; }
  local separator="$2";
  [[ -z "$separator" ]] && { separator='\n'; }
  find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -print0 | tr '\0' "$separator";
}

function find_items_fuzz {
  local file_pattern="$(echo "$1" | to_fuzz)";
  find_items "$file_pattern";
}

function find_items0 {
  local file_pattern="$1";
  local separator='\0';
  find_items "$file_pattern" "$separator";
}

function find_items_fuzz0 {
  local file_pattern="$(echo "$1" | to_fuzz)";
  find_items0 "$file_pattern";
}

function find_files_delete_preview {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specifiy a file pattern!"; return 1; }
  local with_content="$2";
  [[ -z "$with_content" ]] && {
    find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -exec echo rm "{}" \;
  } || {
    find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -exec egrep -in "$with_content" "{}" \; -exec echo rm "{}" \; | egrep "^rm"
  }
}

function find_files_delete {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specifiy a file pattern!"; return 1; }
  local with_content="$2";
  [[ -z "$with_content" ]] && {
    find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -exec rm "{}" \;
  } || {
    find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -exec egrep -in "$with_content" "{}" \; -exec rm "{}" \; > /dev/null
  }
}

function find_files_rename_helper {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specifiy a file pattern!"; return 1; }
  local by="$2";
  [[ -z "$by" ]] && { echo "Must specifiy a by substitution!"; return 1; }
  local with_content="$3";
  local preview=$4
  [[ -z "$preview" ]] && { echo "Must specifiy the preview flag!"; return 1; }

  find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -print0  | while read -d $'\0' file
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
  local preview=true;
  find_files_rename_helper "$file_pattern" "$by" "$with_content" "$preview";
}

function find_files_rename {
  local file_pattern="$1";
  local by="$2";
  local with_content="$3";
  local preview=false;
  find_files_rename_helper "$file_pattern" "$by" "$with_content" "$preview";
}

function find_files {
  local file_pattern="$1";
  [[ -z "$file_pattern" ]] && { echo "Must specifiy a file pattern!"; return 1; }
  local with_content="$2";
  [[ -z "$with_content" ]] && {
    find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*';
  } || {
    find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -exec egrep -in "$with_content" "{}" \; -exec echo "{}" \; | egrep -v "\s*^[[:digit:]]+:"
  }
}

function find_files_fuzz {
  local file_pattern="$(echo "$1" | to_fuzz)";
  local with_content="$2";
  find_files "$file_pattern" "$with_content";
}

function find_in_files {
  local grep_pattern="$1";
  [[ -z "$grep_pattern" ]] && { echo "Must specifiy a grep pattern!"; return 1; }
  local file_pattern="$2";
  [[ -z "$file_pattern" ]] && { file_pattern=".*"; }
  find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -exec egrep --color -in "$grep_pattern" "{}" +;
}

function find_in_files_fuzz {
  local grep_pattern="$(echo "$1" | to_fuzz)";
  local file_pattern="$2";
  [[ -z "$file_pattern" ]] && { file_pattern=".*"; }
  find_in_files "$grep_pattern" "$file_pattern";
}

function find_in_files_replace {
  local by="$1"
  [[ -z "$by" ]] && { echo "Must specifiy a by substitution!"; return 1; }
  local file_pattern="$2";
  [[ -z "$file_pattern" ]] && { file_pattern=".*"; }
  find . -maxdepth 9 -regextype egrep -iregex "$file_pattern" -type f -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/.git/*' -not -path '*/.svn/*' -not -path '*/node_modules/*' -not -path '*/.ionide/*' -exec sed -E -i'' "$by" "{}" \;
}

function git_checkout_branch_in_path {
  local branch="$1";
  local path="$2";
  [[ -z "$branch" ]] && { echo "Must specifiy a branch!"; return 1; }
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

function show_cmds_like {
  local pattern="$1";
  [[ -z "$pattern" ]] && { echo "Must specifiy a command pattern!"; return 1; }
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

function bash_snip_for_loop {
  echo '
IFS= ;
l=(1 2 3 "4");
for ele in ${l[@]};
  do echo $ele hi;
done;
unset IFS;
  '
}

function sql_snip_search_column {
  echo "
/* SQL column search */
SELECT 
c.name  AS 'ColumnName'
,t.name AS 'TableName'
,TYPE_NAME(c.user_type_id) AS 'ColumnType'
,c.max_length AS 'ColumnTypeLength'
,c.is_nullable AS 'ColumnIsNullable'
FROM sys.columns c
JOIN sys.tables  t ON c.object_id = t.object_id
WHERE c.name LIKE '%ColumnPattern%'
ORDER BY TableName, ColumnName;
  "
}

function sql_snip_general_search {
  echo "
/* SQL general search, NOT FOR COLUMNS */
SELECT
name AS [Name], 
SCHEMA_NAME(schema_id) AS schema_name, 
type_desc, 
create_date, 
modify_date
FROM sys.objects
WHERE name LIKE '%Pattern%'
AND type ='u';
  "
}

function pwsh_snip_init_module {
  echo "
pwsh -Command '& {Set-StrictMode -Version 3; Import-Module powershell_scaffolder; Initialize-Module -Path ./ -ModuleName \"test\" -Author \"Manyu Lakhotia\" -Description \"Test powershell module\" -ModuleVersion \"5.1\" -CompanyName \"N/A\" -CopyRight \"N/A\";}'
  "
}

function pwsh_snip_init_script {
  echo "
pwsh -Command '& {Set-StrictMode -Version 3; Import-Module powershell_scaffolder; Initialize-Script -Path ./ -ScriptName \"test\" -ShouldUseAdvLogging $false}'
  "
}

