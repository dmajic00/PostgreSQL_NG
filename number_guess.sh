#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
N=$(( RANDOM % 1000 + 1 ))
echo -e "\nEnter your username:"
read USERNAME_INPUT
USER_ID=$($PSQL "select user_id from users where username='$USERNAME_INPUT'")
if [[ -z $USER_ID ]]; then
    echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
    USERNAME_INPUT_RESULT=$($PSQL "insert into users(username) values ('$USERNAME_INPUT')")
else 
    GAMES_PLAYED=$($PSQL "select count(user_id) from games where user_id='$USER_ID'")
    BEST_GAME=$($PSQL "select min(guesses) from games where user_id='$USER_ID'")
    echo "Welcome back, $USERNAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

GAME(){
    local GUESS_COUNT=0
    read GUESS_INPUT
    while [[ ! $GUESS_INPUT =~ ^[0-9]+$ ]]
     do
        echo "That is not an integer, guess again:"
        read GUESS_INPUT
    done

    while true
     do
        ((GUESS_COUNT++))
        if [[ ! $GUESS_INPUT =~ ^[0-9]+$ ]]
         then
        echo "That is not an integer, guess again:"
        elif [[ $GUESS_INPUT -lt $N ]]
         then
            echo "It's higher than that, guess again:"
        elif [[ $GUESS_INPUT -gt $N ]]
         then
            echo "It's lower than that, guess again:"
        else 
            echo "You guessed it in $GUESS_COUNT tries. The secret number was $N. Nice job!"
            USER_ID=$($PSQL "select user_id from users where username='$USERNAME_INPUT'")
            GUESES=$($PSQL "insert into games(user_id,guesses) values ('$USER_ID','$GUESS_COUNT') ")
            break
        fi
        read GUESS_INPUT
    done
}

GAME
