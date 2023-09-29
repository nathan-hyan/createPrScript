#!/bin/bash

# Hello! I've created this script
# so I can learn a bit of Bash and also
# because I wanted to automate this SO MUCH
# that it kinda forced me to...

# So first, I want this script to be functional
# independently from where it's executed
# I'm thinking to ship the script with a
# pr.txt file where the actual PR message is.

# This line takes care of that, and wherever the
# script is executed it does not matter
# since SCRIPT_DIR is always going to be
# where the script is

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
baseFile=${SCRIPT_DIR}/pr.txt

# Read the text file into a variable for manipulation

basePrMessage=$(<"$baseFile")

# Now, I want to format my text
# and i've found that using tput
# is the most reliable way to
# format it. So let's create a
# couple of functions so i wont repeat
# much of the code.

# Link to the article i've used: https://linuxcommand.org/lc3_adv_tput.php

function printBold() {
  tput bold
  echo -e "$1"
  tput sgr0
}

function printError() {
  tput bold
  tput setaf 1
  echo -e "$1"
  tput sgr0
}

function printSuccess() {
  tput bold
  tput setaf 2
  echo -e "$1"
  tput sgr0
}

# Clear the screen and let's get started!!!

clear

# Reading the title for the PR

printBold "Please enter a name for the PR: "
read -r title
printf "\n"

# Asking which kind of PR is it
# Link to the article I used as reference: https://www.putorius.net/create-multiple-choice-menu-bash.html

PS3=$(printBold 'Which type of change your PR introduces? (Choose a number):')
types=("Bugfix" "Feature" "Code style update" "Refactoring" "Build related changes" "Documentation" "Other" "Cancel")
select type in "${types[@]}"; do
  case $type in
  "Bugfix")
    result="Bugfix"

    # If this option is selected, we
    # need to add some details about the
    # bug we encountered and how we fixed
    # it :)

    printBold "\nWhat was the bug?:"
    read -r bugBehavior

    printBold "\nHow was it fixed?"
    read -r bugFix
    break
    ;;

  "Feature")
    result="Feature"
    break
    ;;

  "Code style update")
    result="Code style update (formatting, renaming)"
    break
    ;;

  "Refactoring")
    result="Refactoring (no functional changes, no api changes)"
    break
    ;;

  "Build related changes")
    result="Build related changes"
    break
    ;;

  "Documentation")
    result="Documentation content changes"
    break
    ;;

  "Other")
    # For this option to work the way we want,
    # we need to ask the user for type and save
    # it to a variable, in this case 'description'

    printBold "\nEnter a custom PR type:"
    read -r description

    result="Other (please describe)"
    break
    ;;

  "Cancel")
    printSuccess "\n\n=== Goodbye! Have a great day! ===\n\n"
    exit
    ;;

  *)
    printError "\n=== Invalid choice: $REPLY, try again. ===\n"
    ;;
  esac
done

# Before continuing, let's check for the vars
# assigned to the Bugfix and the Other
# sections. First, the Bugfix:

if [ "$result" = "Bugfix" ]; then

  # The user selected Bugfix and it
  # gets asked what whas the behavior of the bug
  # and how did it got fixed. Let's add
  # those user comments with the corresponding
  # titles to the file

  basePrMessage=$(echo -e "${basePrMessage//--BUGFIX-NOTES--/\n\n## What is the current behavior?:\n\n${bugBehavior}\n\n\n## What is the new behavior?:\n\n${bugFix}}")

else

  # User choose something else, no need
  # for the placeholders then!

  basePrMessage=$(echo -e "${basePrMessage//--BUGFIX-NOTES--/}")

fi

# Now let's talk about the Other section:
# It's pretty straight forward, if the
# user seleted this option, it will ask
# what's the appropiate type, and we will
# append that text to the end of the option.

if [ "$result" = "Other (please describe)" ]; then

  basePrMessage=$(echo -e "${basePrMessage//Other (please describe):/Other (please describe): $description}")

fi

# And we got everything from this section!
# Let's save the changes and move on!

basePrMessage=$(echo -e "${basePrMessage//\- \[ \] ${result}/- [x] ${result}}")

# In the Pull Request message, there's
# an option to add more context to the
# reviewer. So let's add the option

printBold "\nIs there any additional notes? (Press ENTER if not):"
read -r extraNotes

# If the user entered text, let's
# add the notes with the corresponding
# title to the file:

if [ "$extraNotes" != '' ]; then

  basePrMessage=$(echo -e "${basePrMessage//--ADDITIONAL-NOTES--/\n\n## Other information:\n\n${extraNotes}}")

else

  # The user just pressed enter? OK then,
  # lets delete the placeholder and
  # pretend that nothing happened

  basePrMessage=$(echo -e "${basePrMessage//--ADDITIONAL-NOTES--/}")

fi

# Sometimes, since the
# change is purely graphical we
# have to provide screenshots to
# make it easier on the reviewer

# Link to the article that I
# used as reference for this YN prompt:
# https://linuxconfig.org/bash-script-yes-no-prompt-example

while true; do

  printBold "\nDo you want to include screenshots? (y/n): "
  read -r yn

  case $yn in

  [yY])

    # Ok! Let's inform the user that the Preview
    # section in the message will be added
    # and modify the base PR message to include it

    printSuccess "\n\n=== You'll find a Preview section in the PR description for image uploading! ===\n\n"
    basePrMessage=$(echo -e "${basePrMessage//--PREVIEW--/\n\n## Preview:\n\n[Paste here your screenshots! :)]}")
    break
    ;;

  [nN])

    # No worries, let's just delete
    # the placeholder included in the
    # base file

    basePrMessage=$(echo -e "${basePrMessage//--PREVIEW--/}")
    break
    ;;

  *)

    printError "\n=== Invalid choice, try again. ===\n"
    ;;

  esac

done

# Now that we have everything we need from the user
# we can start making the final gatherings and
# changes to get to the finish line!

# Grab the ticket number from the branch name
# this will work suggesting we follow a certain
# standard for branch naming. With this number
# we can build the final link.

issueNumber=$(git symbolic-ref HEAD | grep -oE '\d+' | head -1)
issueLink=https://rootstrap.atlassian.net/browse/HP-$issueNumber

# Finally, apply it to the text

basePrMessage=$(echo -e "${basePrMessage//--ISSUE-LINK--/$issueLink}")

# And thats everything for the PR message!
# lets build the github link for the PR creation
# and open it in the browser

repo_url=$(git config remote.origin.url | sed 's|https://\(.*\).git|https://\1|')

printSuccess "PR Ready to be open! This is the result\n"
echo -e "${basePrMessage}\n\n"

while true; do

  printBold "\nYou'll be redirected to: $repo_url. Do you want to continue? (y/n): "
  read -r yn

  case $yn in

  [yY])

    printSuccess "\n\nRedirecting to the url! Thanks for using the script! -- Hy-An\n\n"

    # And off we g... wait, what is
    # Curl doing here? WHAT
    # ARE YOU DOING CUUUURRRLLL?

    open "$(curl -s -L -I -o /dev/null -w '%{url_effective}' --get \
      --data-urlencode "expand=1" \
      --data-urlencode "title=[HP-${issueNumber}] ${title}" \
      --data-urlencode "body=${basePrMessage}" \
      "${repo_url}/compare/$(git symbolic-ref --quiet --short HEAD)")"

    # The thing is that i run into a lot of issues regarding
    # URL Parsing, the hash sign used for MarkDown was causing
    # issues whenever the URL was being loaded in the browser.
    # Searching thru StackOverflow i've found the curl solution,
    # and later I had to search how to get the final URL without
    # anything else. Links to those two posts:

    # How to URLEncode data: https://stackoverflow.com/questions/296536/how-to-urlencode-data-for-curl-command
    # Get the final URL after curl is redirected: https://stackoverflow.com/questions/3074288/get-final-url-after-curl-is-redirected

    exit

    ;;

  [nN])

    # Thank you for using the script! :)

    printError "\n\nNo worries, thank you for using the script! -- Hy-An\n\n"
    exit
    ;;

  *)

    printError "\n=== Invalid choice, try again. ===\n"
    ;;

  esac

done
