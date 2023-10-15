#!/bin/bash

# Hello! I've created this script
# so I can learn a bit of Bash and also
# because I wanted to automate this SO MUCH
# that it kinda forced me to...

BASE_FILE=${SCRIPT_DIR}/pr.txt

# This only works with HTTPS at the moment
# I will add SSH support in a later commit

GIT_REPO_URL=$(git config remote.origin.url | sed 's|https://\(.*\).git|https://\1|')

# Read the text file into a variable for manipulation

BASE_PR_TEXT=$(<"$BASE_FILE")

export PR_TYPES=("Bugfix" "Feature" "Code style update" "Refactoring" "Build related changes" "Documentation" "Other" "Cancel")
export JIRA_URL="https://rootstrap.atlassian.net/browse/HP-"

# Now that we have everything we need from the user
# we can start making the final gatherings and
# changes to get to the finish line!

# Grab the ticket number from the branch name
# this will work suggesting we follow a certain
# standard for branch naming. With this number
# we can build the final link.

ISSUE_NUMBER=$(git symbolic-ref HEAD | grep -oE '\d+' | head -1)

export issueLink=$JIRA_URL$ISSUE_NUMBER

export BASE_PR_TEXT
export ISSUE_NUMBER
export GIT_REPO_URL
