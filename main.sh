#!/usr/bin/env bash

# So first, I want this script to be functional
# independently from where it's executed

# This line takes care of that, and wherever the
# script is executed it does not matter
# since SCRIPT_DIR is always going to be
# where the script is

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "${SCRIPT_DIR}"/print.sh           # The functions needed to print the questions
source "${SCRIPT_DIR}"/config.sh          # Where all the vars are stored
source "${SCRIPT_DIR}"/prTypeSelection.sh # See step 2!

# Clear the screen and let's get started!!!

clear

# Step 1. Reading the title for the PR

printBold "Please enter a name for the PR: "
read -r title
printf "\n"

# Step 2. Asking for the PR Type, see file: prTypeSelection.sh

askForPRType

# Step 3. Asking if there's more info to be added

# In the Pull Request message, there's
# an option to add more context to the
# reviewer. So let's add the option

printBold "\nIs there any additional notes? (Press ENTER if not):"
read -r extraNotes

# If the user entered text, let's
# add the notes with the corresponding
# title to the file:

if [ "$extraNotes" != '' ]; then

  BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//--ADDITIONAL-NOTES--/\n\n## Other information:\n\n${extraNotes}}")

else

  # The user just pressed enter? OK then,
  # lets delete the placeholder and
  # pretend that nothing happened

  BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//--ADDITIONAL-NOTES--/}")

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
    BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//--PREVIEW--/\n\n## Preview:\n\n[Paste here your screenshots! :)]}")
    break
    ;;

  [nN])

    # No worries, let's just delete
    # the placeholder included in the
    # base file

    BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//--PREVIEW--/}")
    break
    ;;

  *)

    printError "\n=== Invalid choice, try again. ===\n"
    ;;

  esac

done

# Finally, apply it to the text

BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//--ISSUE-LINK--/$issueLink}")

# And thats everything for the PR message!
# Show the result to the user and move on

printSuccess "PR Ready to be open! This is the result\n"
echo -e "${BASE_PR_TEXT}\n\n"

URL=$(curl -s -L -I -o /dev/null -w '%{url_effective}' --get \
  --data-urlencode "expand=1" \
  --data-urlencode "title=[HP-${ISSUE_NUMBER}] ${title}" \
  --data-urlencode "body=${BASE_PR_TEXT}" \
  "${GIT_REPO_URL}/compare/$(git symbolic-ref --quiet --short HEAD)")

while true; do

  printBold "\nYou'll be redirected to: $URL. Do you want to continue? (y/n): "
  read -r yn

  case $yn in

  [yY])

    printSuccess "\n\nRedirecting to the url! Thanks for using the script! -- Hy-An\n\n"

    # And off we g... wait, what is
    # Curl doing here? WHAT
    # ARE YOU DOING CUUUURRRLLL?

    open "$URL"

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
