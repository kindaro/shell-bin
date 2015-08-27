#!/bin/sh -e

# Make a github repo via API curl.
# --------------------------------

# Functions
# ---------

_help () {
    cat <<EOF
    create a github repo in a glimpse

arguments:
        (help)        -- print this message.
        (user)        -- set the github account name to use.
        (name)        -- set the project/repo name desired.
        (description) -- set an one-line description of the project.
EOF
}


# UI
# --

while test "${1:0:2}" == '--'
do
    opt="${1:2}"
    if not test "$opt"
    then
        break
    fi

    case "$opt" in
        (help)
            _help
            exit 0 ;;
        (user)    
            user="$2" &&
                shift ;;
        (name)
            name="$2" &&
                shift ;;
        (description)
            description="$2" &&
                shift ;;
    esac
    shift
done

if not test "${user}"
then
    user="${USER}"
fi


# Execution
# ---------

curl                                                                         \
    -u "${user}"                                                             \
    'https://api.github.com/user/repos'                                      \
    -d ' { "name" : "'"${name}"'" , "description" : "'"${description}"'" } ' \
    > /dev/null

git clone "git@github.com:${user}/${name}"
cd "${name}"

echo > 'README.md'

echo "${name}"                             >> 'README.md'
head -c "${#name}" /dev/zero | tr '\0' '=' >> 'README.md'
echo                                       >> 'README.md'
echo                                       >> 'README.md'
echo "${description}"                      >> 'README.md'
echo                                       >> 'README.md'

git add 'README.md'
git commit -m 'Automatic initial commit.'
git push --set-upstream origin master

exit 0
