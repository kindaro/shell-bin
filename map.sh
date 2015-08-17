#!/bin/sh

# Option parser. Pure.
# --------------

while test "${1:0:2}" == '--'
do
    opt="${1:2}"
    if not test "$opt"; then break; fi
    case "$opt" in
        (stdout | pipe)
            opt_stdout='True'
            ;;
        (from | source | in)
            opt_from="$2" && shift
            ;;
        (to | target | out)
            opt_to="$2" && shift
            ;;
        (ext)
            opt_ext="$2" && shift
            ;;
        (cmd)
            opt_cmd="$2" && shift
            ;;
        (dry-run | test)
            opt_dry="True"
            ;;
        (find-args)
            opt_find_args+=" $2" && shift
            ;;
    esac
    shift
done

if not test "$opt_from"
then
    cat <<'EOF'
Apply a command to each of a set S of files, transposing
    each to a file in set T with the same name.

Options: 
    (stdout | pipe)
        -- The processing program would process stdin to stdout,
            and map will care to supply it with stdin from a file
            in S and put stdout to a corresponding file in T.
    (from | source | in)
        -- Naturally, this designates a file mask for S.
            All should reside in the same directory tree, but filename
            globbing is supported.
    (to | target | out)
        -- This designates the directory to put processed files,
            i.e. those in T.
    (ext)
        -- This designates the extension we'd like to append to
            each file in T.
    (cmd)
        -- The command we'd like to process each of our files.
    (dry-run | test)
        -- Do nothing but output files from S and their
            corresponding projections in T.
    (find-args)
        -- Supply a string of custom "find" command arguments.

Exampli gratia:

    ~/bin/map.sh --from '/media/Sounds/*.m4a' \
                --ext wav --to /tmp/audio --cmd 'yes | ffmpeg -i '
        -- Convert all mp4 files to plain wave with ffmpeg
            for further editing.
    ~/bin/map.sh --from ~/'*.json' --cmd 'rev' \
                --find-args '-maxdepth 1' --target /tmp/json-rev --pipe
        -- Convert all json files immediately in home directory
            (not descending into the tree) with "rev".
EOF
exit 1
fi

# Execution.
# ------------------

o_path="${opt_from%/*}"
o_name="${opt_from##**/}"
find "$o_path" $opt_find_args -name "$o_name" |
    while read s
    do 
        # Pure computations.
        # ------------------

        s_path="${s%/*}"
        s_name="${s##**/}"

        if test "$opt_to"
        then
            t_path="$opt_to"
        else
            t_path="$s_path"
        fi

        if test "$opt_ext"
        then
            t_name="$s_name"."$opt_ext"
        else
            t_name="$s_name"
        fi

        t="$t_path"/"$t_name"

        # Effectful execution.
        # --------------------

        if test "$opt_dry"
        then
            echo "$s"' -> '"$t"
        else

            if test "$opt_stdout"
            then
                cat "$s" | eval "$opt_cmd" > "$t"
            else
                eval "$opt_cmd" '"$s"' '"$t"'
            fi
        fi
    done

