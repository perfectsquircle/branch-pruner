#!/bin/bash
# set -x

git checkout master
git pull

merged='--merged'
# pattern='feature|release|bugfix'
blacklist='HEAD|master|develop'

branches=$(git branch -r $merged | sed s/origin\\/// | grep -v -E "$blacklist") # | grep -E "$pattern")
branches_count=$(echo -n "$branches" | wc -l)

echo Found $branches_count merged branches on remote.
echo "$branches"

read -p "Proceed with deletion? " -n 1 -r
echo  
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # do dangerous stuff
    git push origin --delete $branches
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
branches_count=$(echo -n "$old_branches" | wc -l)

echo Found $branches_count branches older than 6 months on remote.
echo "$old_branches"

read -p "Proceed with deletion? " -n 1 -r
echo  
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # do dangerous stuff
    git push origin --delete $old_branches
fi