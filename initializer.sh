#!/bin/sh -e

# Sharply branch new project.
# ---------------------------

# Initialize defaults.
# --------------------

initial_user="kindaro"
initial_branch="master"
username="$USER"

# Advanced initialization.
# ------------------------

if test $# -eq 0
then # Interactive.

    initial_user_o="$initial_user"
    echo "Where are we supposed to clone from ? (Default: ${initial_user})"
    read initial_user
    if not test "$initial_user"
    then
        initial_user="$initial_user_o"
    fi

    initial_branch_o="$initial_branch"
    echo "What branch are we supposed to clone from ? (Default: ${initial_branch})"
    read initial_branch
    if not test "$initial_branch"
    then
        initial_branch="$initial_branch_o"
    fi

    echo "How would you like to name your new project ?"
    read name
    echo "How would you like to describe your new project ?"
    read description

    echo "How would you like to present yourself? (Default: ${USER})"
    read username
    if not test "$username"
    then
        username="$USER"
    fi
else # Batch.

    while test "${1:0:2}" == '--'
    do
        opt="${1:2}"
        if not test "$opt"; then break; fi
        case "$opt" in
            (iuser | su)
                initial_user="$2" && shift ;;
            (ibranch | sb)
                initial_branch="$2" && shift ;;
            (name | tn)
                name="$2" && shift ;;
            (description | td)
                description="$2" && shift ;;
            (username | user | tu)
                username="$2" && shift ;;
            (help)
                cat <<EOF
            Sharply branch new project.
    USAGE:
        (iuser | su) -- What user's initial repository are we branching ?
        (ibranch | sb) -- Which branch of that repo we need ?
        (name | tn) -- What's our project's new name ?
        (description | td) -- What's our project's description ?
        (username | user | tu) -- Which GitHub user should own the project ?
        (help) -- Read this memo.
EOF
                exit 0
                ;;
                
        esac
        shift
    done
fi

# Execution.
# ----------

initial_repo=git@github.com:$initial_user/initial.git
git clone --single-branch --branch "$initial_branch" "$initial_repo" "$name"
cd "$name"
./initialize.sh "$name" "$description" "$username"

