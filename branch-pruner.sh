#!/bin/bash
set -e

git checkout master > /dev/null
git pull > /dev/null

blacklist='HEAD|master|develop'

branches=$(git branch -r --merged | sed s/origin\\/// | grep -v -E "$blacklist") # | grep -E "$pattern")
branches_count=$(echo -n "$branches" | grep -c '^')

if [ $branches_count -gt 0 ]
then
    echo ---------------
    echo "$branches"
    echo ---------------
fi

echo Found $branches_count merged branches on remote.

if [ $branches_count -gt 0 ]
then
    read -p "Proceed with deletion? " -n 1 -r
    echo  
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # do dangerous stuff
        git push origin --delete $branches
    fi
fi


get_old_branches() {
    git for-each-ref --sort=committerdate refs/remotes/ --format='%(committerdate:raw) %(refname:short)' | \
    while read entry
    do
        commit_date=$(echo -n $entry | awk '{print $1}')
        branch_name=$(echo -n $entry | awk '{print $3}')
        today=$(date +'%s')
        answer=$(echo $(( today - commit_date )))

        if [[ $answer -gt 15778800 ]]; then
            echo $branch_name
        fi
    done
}

old_branches="$(get_old_branches | sed s/origin\\/// | grep -v -E "$blacklist")"
old_branches_count=$(echo -n "$old_branches" | grep -c '^')

if [ $old_branches_count -gt 0 ]
then
    echo ---------------
    echo "$old_branches"
    echo ---------------
fi

echo Found $old_branches_count branches older than 6 months on remote.

if [ $old_branches_count -gt 0 ]
then
    read -p "Proceed with deletion? " -n 1 -r
    echo  
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # do dangerous stuff
        git push origin --delete $old_branches
    fi
fi