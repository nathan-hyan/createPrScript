#!/usr/bin/env bash

# Asking which kind of PR is it

# This is highly modifiable, but be aware that
# the result='' of each case has to be
# the exact text thats in the
# pr.txt file, otherwise it wont find the
# text match and nothing will happen.

# Link to the article I used as reference: https://www.putorius.net/create-multiple-choice-menu-bash.html

function askForPRType() {
    PS3=$(printBold 'Which type of change your PR introduces? (Choose a number):')
    select type in "${PR_TYPES[@]}"; do
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

        BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//--BUGFIX-NOTES--/\n\n## What is the current behavior?:\n\n${bugBehavior}\n\n\n## What is the new behavior?:\n\n${bugFix}}")

    else

        # User choose something else, no need
        # for the placeholders then!

        BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//--BUGFIX-NOTES--/}")

    fi

    # Now let's talk about the Other section:
    # It's pretty straight forward, if the
    # user seleted this option, it will ask
    # what's the appropiate type, and we will
    # append that text to the end of the option.

    if [ "$result" = "Other (please describe)" ]; then
        BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//Other (please describe):/Other (please describe): $description}")
    fi

    # And we got everything from this section!
    # Let's save the changes and move on!

    BASE_PR_TEXT=$(echo -e "${BASE_PR_TEXT//\- \[ \] ${result}/- [x] ${result}}")
}
