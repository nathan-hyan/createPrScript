#!/bin/bash

# I want to format my text
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
