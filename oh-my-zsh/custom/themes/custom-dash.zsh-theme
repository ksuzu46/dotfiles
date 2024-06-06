# This requires zsh shell with Oh My Zsh installed https://github.com/ohmyzsh/ohmyzsh/
# based on af-magic.zsh-theme https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/af-magic.zsh-theme

# color settings https://robotmoon.com/256-colors/
typeset +H my_blue="$FG[117]"
typeset +H my_light_blue="$FG[153]"
typeset +H my_gray="$FG[237]"
typeset +H my_green="$FG[115]"
typeset +H my_pink="$FG[218]"
typeset +H my_purple="$FG[147]"
typeset +H my_red="$FG[160]"
typeset +H my_yellow="$FG[186]"

# git settings
ZSH_THEME_GIT_PROMPT_STAGED="$my_yellow*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="$my_pink*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="$my_red!%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STASHED="$my_pink✓%{$reset_color%}"

# virtualenv settings
ZSH_THEME_VIRTUALENV_PREFIX=" $FG[075]["
ZSH_THEME_VIRTUALENV_SUFFIX="]%{$reset_color%}"

# dashed separator size
function afmagic_dashes {
    # check either virtualenv or condaenv variables
    local python_env="${VIRTUAL_ENV:-$CONDA_DEFAULT_ENV}"

    # if there is a python virtual environment and it is displayed in
    # the prompt, account for it when returning the number of dashes
    if [[ -n "$python_env" && "$PS1" = \(* ]]; then
        echo $(( COLUMNS - ${#python_env} - 3 ))
    else
        echo $COLUMNS
    fi
}

function __git_prompt_status() {
    [[ "$(__git_prompt_git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]] && return

    # Maps a git status prefix to an internal constant
    # This cannot use the prompt constants, as they may be empty
    local -A prefix_constant_map
    prefix_constant_map=(
        '\?\? '     'UNSTAGED'
        'A  '       'STAGED'
        'M  '       'STAGED'
        'MM '       'STAGED'
        ' M '       'UNSTAGED'
        'AM '       'STAGED'
        ' T '       'UNSTAGED'
        'R  '       'STAGED'
        ' D '       'UNSTAGED'
        'D  '       'STAGED'
        'UU '       'UNMERGED'
        'ahead'     'AHEAD'
        'behind'    'BEHIND'
        'diverged'  'DIVERGED'
        'stashed'   'STASHED'
    )

    # Maps the internal constant to the prompt theme
    local -A constant_prompt_map
    constant_prompt_map=(
        'STAGED'    "$ZSH_THEME_GIT_PROMPT_STAGED"
        'UNSTAGED'  "$ZSH_THEME_GIT_PROMPT_UNSTAGED"
        'UNTRACKED' "$ZSH_THEME_GIT_PROMPT_UNTRACKED"
        'ADDED'     "$ZSH_THEME_GIT_PROMPT_ADDED"
        'MODIFIED'  "$ZSH_THEME_GIT_PROMPT_MODIFIED"
        'RENAMED'   "$ZSH_THEME_GIT_PROMPT_RENAMED"
        'DELETED'   "$ZSH_THEME_GIT_PROMPT_DELETED"
        'UNMERGED'  "$ZSH_THEME_GIT_PROMPT_UNMERGED"
        'AHEAD'     "$ZSH_THEME_GIT_PROMPT_AHEAD"
        'BEHIND'    "$ZSH_THEME_GIT_PROMPT_BEHIND"
        'DIVERGED'  "$ZSH_THEME_GIT_PROMPT_DIVERGED"
        'STASHED'   "$ZSH_THEME_GIT_PROMPT_STASHED"
    )

    # The order that the prompt displays should be added to the prompt
    local status_constants
    status_constants=(
        STAGED UNSTAGED UNTRACKED ADDED MODIFIED RENAMED DELETED
        STASHED UNMERGED AHEAD BEHIND DIVERGED
    )

    local status_text
    status_text="$(__git_prompt_git status --porcelain -b 2> /dev/null)"

    # Don't continue on a catastrophic failure
    if [[ $? -eq 128 ]]; then
        return 1
    fi

    # A lookup table of each git status encountered
    local -A statuses_seen

    if __git_prompt_git rev-parse --verify refs/stash &>/dev/null; then
        statuses_seen[STASHED]=1
    fi

    local status_lines
    status_lines=("${(@f)${status_text}}")

    # If the tracking line exists, get and parse it
    if [[ "$status_lines[1]" =~ "^## [^ ]+ \[(.*)\]" ]]; then
        local branch_statuses
        branch_statuses=("${(@s/,/)match}")
        for branch_status in $branch_statuses; do
            if [[ ! $branch_status =~ "(behind|diverged|ahead) ([0-9]+)?" ]]; then
                continue
            fi
            local last_parsed_status=$prefix_constant_map[$match[1]]
            statuses_seen[$last_parsed_status]=$match[2]
        done
    fi

    # For each status prefix, do a regex comparison
    for status_prefix in ${(k)prefix_constant_map}; do
        local status_constant="${prefix_constant_map[$status_prefix]}"
        local status_regex=$'(^|\n)'"$status_prefix"

        if [[ "$status_text" =~ $status_regex ]]; then
            statuses_seen[$status_constant]=1
        fi
    done

    # Display the seen statuses in the order specified
    local status_prompt
    for status_constant in $status_constants; do
        if (( ${+statuses_seen[$status_constant]} )); then
            local next_display=$constant_prompt_map[$status_constant]
            status_prompt="$next_display$status_prompt"
        fi
    done

    echo $status_prompt
}

function __git_info {
    if ! __git_prompt_git rev-parse --git-dir &> /dev/null \
        || [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
            return 0
    fi

    git_status=$(__git_prompt_status)
    if [ -z "$git_status" ]; then
        git_status="$my_green✓"
    fi
    echo "$my_light_blue($my_purple$(git_current_branch)$my_light_blue|$git_status$my_light_blue%)"
}

function __current_path {
    pwd_result=$(pwd)
    if [[ $(expr length "$pwd_result") -gt $(( COLUMNS - 30 )) ]]; then
        echo "%~"
    else
        echo "$pwd_result"
    fi
}

function __remote_connection_status {
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        echo "$my_pink(ssh%) "
    elif [ "$ZSH_THEME_REMOTE_CONNECTION_STATUS" -eq 0 ]; then
        return 0
    else
        echo "$my_pink(remote%) "
    fi
}

# primary prompt
PS1='$my_gray${(l.$(afmagic_dashes)..-.)}%{$reset_color%}
$my_light_blue╭─ $my_blue$(__current_path) $(__git_info) $(hg_prompt_info)
$my_light_blue╰─%(?.$my_yellow(*'\''一'\''%).$my_pink(╯°◻°%)╯︵┴─┴) %(!.#.<) %{$reset_color%}'
PS2='%{$fg[red]%}\ %{$reset_color%}'

# right prompt: return code, virtualenv and context (user@host)
# and show proxy connection status
if (( $+functions[virtualenv_prompt_info] )); then
    RPS1+='$(virtualenv_prompt_info)'
fi
RPS1+='$(__remote_connection_status)$my_blue%*%{$reset_color%}%'
