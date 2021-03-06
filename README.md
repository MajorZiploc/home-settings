# home-settings

## Purpose
For automating the setup of a developer machine
NOTE: mac is least tested!

## Tools

All:
- vim (text editor)
- bash (shell)
- tmux (terminal multiplexier)
- pwsh (cross platform powershell)
- just (a command runner for Justfiles)
- asdf (a general programming language version manager)
- npm (node package manager)
- rg (ripgrep)
- dotnet (cross platform dotnet cli tooling)

Windows:
- chocolatey package manager

Ubuntu:
- apt package manager

WSL Ubuntu:
- apt package manager

## Installs

All:
- bash configs
- vim configs
- vscode configs

Windows:
- chocolatey packages

Ubuntu:
- apt packages


## Install scripts - ALWAYS read scripts you are going to execute!!!!

### Warning - The following script will override any files in the destination. It copies to locations such as the home directory!!
### It is highly recommended to back up your current settings!!!!
### The copy process makes use of sed substitutions that can affect the configs and the currently running copy scripts. See the substitutions for your os in ./setup/\<os\>/scripts/substitution.sh

Use the copy.sh scripts found in ./setup/[windows10|wsl\_ubuntu20.04|ubuntu20.04|mac]/scripts/copy.sh "$flags" to copy over vscode keybindings and settings, vim, bash settings, tasks, and clipboard files. It will also clone a vim plugin manager, Vundle.

copy.sh : binary\_flags? -> unit

Paths with content that will be affected include but are not limited to:
- "$HOME/.vim/bundle"
- "$HOME/.vim/swap"
- "$HOME/vimfiles/plugin-settings"
- "$HOME/clipboard" when flags contain "10"
- "$HOME/bin"
- "$HOME/Tasks"
- "$HOME/vscodevim" when flags contain "01"
- "$HOME/AppData/Roaming/Code/User/" (windows) else "$HOME/.config/Code/User/" when flags contain "01"

### Windows
To install chocolatey and clone this repo:
- ./setup/windows/scripts/bootstrap.ps1
To install windows software with chocolatey:
- ./setup/windows/scripts/install.ps1
To setup ssh keys for git:
- ./setup/windows/scripts/create\_ssh\_keys/1\_admin.ps1
- ./setup/windows/scripts/create\_ssh\_keys/2\_std\_usr.ps1

## Bash tooling
### Notable bash functions/aliases
- whence <cmd> # gives the details of a bash command
- search\_env\_for(\_fuzz)? "egrep|string|here" # searches the bash env for the given string (a fuzzy variant is available
- show\_cmds\_like "egrep|string|here" # sends impls of aliases and bash fns that match the regex to stdout (useful when
  piped to clip)
- grepn\_files(\_freq|\_uniq)? # useful chained after find\_in\_files(\_fuzz)?
- find\_files(\_fuzz)?
- find\_files\_rename(\_preview)?
- find\_in\_files(\_fuzz)?
- find\_in\_files\_replace
- find\_items
- tmuxcs <optional\_session\_name> # Creates a tmux session based on the current path if the session name is not given
- tmuxps # Creates a tmux session based the selected fzf/fzy folders specified by tmuxps\_get\_project\_dirs
- tmuxds # Creates a tmux session based the selected fzf/fzy folder from the users current path
- tmuxks -t <session\_name> # kill a tmux session
- tmuxas -t <session\_name> # attach to a tmux session
- tmuxksvr # kills the tmux server
- refresh\_settings(\_help|\_all|\_with\_flags)?
### Note on Notable bash functions/aliases
All of the find\_ are wrappers around find to make certain common operations easy to perform.

Use whence to view the implementations of any of them to get an understanding of how they work

For more bash aliases and functions, use search\_env\_for(\_fuzz)?, or look at ~/.bash\_aliases and ~/.bash\_functions

## Extending and Staying Up to date with these settings

### Staying up to date (Important notes for extending aswell)
If you want to stay up to date with this repo, then use the refresh\_settings bash function.

refresh\_settings will pull master on this repo (~/projects/home-settings) and call the copy script.

### Remember that the copy script will copy over any files that exist in the destination path that have the same name as files being copied from the source. See the Install Scripts section for more detail on this!!!

This means that if you edit the files in the destination and then call copy, it will overwrite them.

Example: you edit ~/.bash\_aliases to add an alias, then call refresh\_settings. This will replace ~/.bash\_aliases and you will lose your local edits

### Extending
The ~/.bashrc from this repo sources a file ~/.bash\_ext if it exists

The copy script does not have a .bash\_ext that it copies down, so the ~/.bash\_ext file is a safe place to add your own customizations of these bash settings.

The ~/.bash\_ext is sourced after all other bash files. So you can change the implementation of aliases and functions and shopt flags that you do not like with your own flavor.

Example: you do not like the fact that cdspell is turned on (shopt -s cdspell)

In ~/.bash\_ext, you can add the following line:

> shopt -u cdspell

This will turn that feature off!

This way you can have all the other great features you love from this repo, keep up to date with the repo, and make any changes that make these settings more you!

## Development tools for contribution
- docker v20.10.7
- bash v5.0.17
- vim v8.1

## Developing in the docker container
To contribute without mudding up your own environment from the copy scripts. The copy scripts can be used within a docker container and all testing can happen there.

- Running docker container
> docker-compose -f .devcontainer/docker-compose.yaml up -d

- Attaching to the docker container (Run the rest of the development commands in the docker container)
> docker exec -it devcontainer_app_1 /bin/bash

The container is a based on a ubuntu image. So when you make changes to the shared content or ubuntu specific content and want to test them manually, then you need to run the copy down WITHIN the docker container
> ./setup/ubuntu20.04/scripts/copy.sh && source ~/.bash_profile

### Unit tests in the docker container

- Run the ubuntu setup script after making any changes to the content you want to test WITHIN the docker container.
> ./tests/setup_ubuntu20.04.sh

- Run all the tests
> ./tests/run_tests.sh

NOTE: you can also run a specific test file instead of all tests

## TODO
- consider switching find_ commands to use `rg --no-heading`

