# Replacing starship with this
function fish_prompt
    set -l last $status
    set -l lambda green
    test $last -ne 0; and set lambda red

    # fish_transient_prompt: past prompts collapse to the λ
    if contains -- --final-rendering $argv
        set_color -o $lambda
        echo -n 'λ '
        set_color normal
        return
    end

    echo

    # Path from the repo root inside a repo, else from ~; last 3 parts
    set -l git (command git rev-parse --git-dir --show-toplevel 2>/dev/null)
    set -l dir (prompt_pwd -d 0)
    if set -q git[2]; and string match -q -- "$git[2]*" $PWD
        set dir (path basename -- $git[2])(string replace -- $git[2] '' $PWD)
    end
    set_color blue
    echo -n (string match -r '(?:[^/]*/){0,2}[^/]*$' -- $dir)' '

    if set -q git[2]
        set -l st (command git status --porcelain=v2 --branch --show-stash 2>/dev/null)
        set -l head (string replace -rf '^# branch.head ' '' -- $st)
        if test "$head" = '(detached)'
            set_color -o green
            echo -n '('(string sub -l 7 -- (string replace -rf '^# branch.oid ' '' -- $st))')'
        else
            set_color brblack
            echo -n $head
        end
        set_color ffafd7
        string match -qv '#*' -- $st; and echo -n '*'
        echo -n ' '

        set -l ab (string match -rg '^# branch.ab \+(\d+) -(\d+)' -- $st)
        set -l up
        if set -q ab[1]
            if test $ab[1] -gt 0 -a $ab[2] -gt 0
                set up ⇕
            else if test $ab[1] -gt 0
                set up ⇡
            else if test $ab[2] -gt 0
                set up ⇣
            end
        end
        string match -q '# stash *' -- $st; and set up "$up≡"
        set_color cyan
        test -n "$up"; and echo -n "$up "

        set -l gd $git[1]
        set -l state
        if test -d $gd/rebase-merge
            set state "REBASING "(cat $gd/rebase-merge/msgnum)/(cat $gd/rebase-merge/end)
        else if test -d $gd/rebase-apply
            set state "REBASING "(cat $gd/rebase-apply/next)/(cat $gd/rebase-apply/last)
        else if test -f $gd/MERGE_HEAD
            set state MERGING
        else if test -f $gd/CHERRY_PICK_HEAD
            set state CHERRY-PICKING
        else if test -f $gd/REVERT_HEAD
            set state REVERTING
        else if test -f $gd/BISECT_LOG
            set state BISECTING
        end
        if test -n "$state"
            set_color brblack
            echo -n "($state) "
        end
    end

    # Last command's duration, from 2s, like 1h5s
    if test $CMD_DURATION -ge 2000
        set -l s (math -s0 $CMD_DURATION / 1000)
        set -l h (math -s0 $s / 3600)
        set -l m (math -s0 $s % 3600 / 60)
        set s (math $s % 60)
        set -l d ''
        test $h -gt 0; and set d {$h}h
        test $m -gt 0; and set d "$d$m"m
        test $s -gt 0; and set d "$d$s"s
        set_color yellow
        echo -n "$d "
    end

    echo
    set -l jobs (count (jobs -p 2>/dev/null))
    if test $jobs -gt 0
        set_color -o blue
        test $jobs -ge 2; and echo -n "✦$jobs "; or echo -n '✦ '
    end
    set_color -o $lambda
    echo -n 'λ '
    set_color normal
end
