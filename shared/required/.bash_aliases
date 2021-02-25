shopt -s expand_aliases
# tmux aliases
alias tmuxas="tmux attach-session"
alias tmuxks="tmux kill-session"
alias tmuxksvr="tmux kill-server"
alias tmuxls="tmux ls"

# copy / paste aliases
alias pbcopy="clip.exe"
alias pbpaste="powershell.exe -command 'Get-Clipboard' | head -n -1"

# View path directories alias
alias show_path='echo $PATH | tr ":" "\n"'

# text manipulation aliaes
alias rev_chars='perl -F"" -anle "print reverse @F" | perl -ple "s/^\r//"'
alias rev_lines='tac'
alias toggle_case='tr "[a-zA-Z]" "[A-Za-z]"'
alias camel_to_snake="sed -E 's/([A-Z])/_\L\1/g' | sed 's/^_//'"
alias snake_to_camel="sed -E 's/_([a-zA-Z])/\U\1/gi' | sed -E 's/^([A-Z])/\l\1/'"
alias snake_to_space="sed 's/_/ /g'"
alias camel_to_space="sed -E 's/([A-Z])/ \1/g' | sed 's/^ //'"
alias space_to_snake="sed -E 's/ ([a-zA-Z])/_\L\1/g' | sed -E 's/^_//' | sed -E 's/^([A-Z])/\L\1/'"
alias space_to_camel="sed -E 's/ ([a-zA-Z])/\U\1/g' | sed -E 's/^([A-Z])/\L\1/'"
alias rtrim="sed -E 's/[ '$'\t'']+$//'"
alias ltrim="sed -E 's/\s*(.*)/\1/g'"
alias trim="sed -E 's/[ '$'\t'']+$//' | sed -E 's/\s*(.*)/\1/g'"
alias keep_last='tac | awk "!x[\$0]++" | tac'
alias keep_first='cat | awk "!x[\$0]++" | cat'

# Viewing directory information aliases
alias dir='ls --format=vertical'
alias vdir='ls --format=long'
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='ls --color=auto --format=vertical'
  alias vdir='ls --color=auto --format=long'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi
alias ls_c='ls -hF --color=tty'                 # classify files in colour
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lst='ls --human-readable --size -1 -S --classify'
alias less_r='less -r'                          # raw control characters
alias whence='type -a'                        # where, of a sort

# Default to human readable figures
alias df_h='df -h'
alias du_h='du -h'

alias uniq_files_from_grep="sed -E 's/(.\S*?):[0-9]+:(.*?)/\1/g' | sort | uniq"
alias show_hidden_items_from_find="sed -e 's/\.\///g' | egrep \"\/\.\""

# reexecutes last command that beings with a pattern. ex: fc -s egrep
alias reexe='fc -s'

alias vimi='/usr/bin/vim -u NONE'
alias vimc='/usr/bin/vim -u ~/_commonvimrc'
alias vimt='/usr/bin/vim -u ~/_vimrcterm'
alias vimnp='/usr/bin/vim --noplugin'

alias curl_follow_redirects='curl -Lks'
alias curl_follow_redirects_ignore_security_exceptions='curl -0Lks'

alias show_fn_names='declare -F'
alias show_fn_impls='declare -f'


if [ -d ~/AppData/Roaming/npm ]; then
  # requires <npm i gnomon -g> for the current user
  alias time_js='gnomon'
fi
