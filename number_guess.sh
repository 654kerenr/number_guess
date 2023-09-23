#!/bin/bash

echo "Enter your username:" 
read USERNAME

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

USER_EXISTS=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_EXISTS ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$(echo $USER_EXISTS | cut -f 2 -d "|")
  BEST_GAME=$(echo $USER_EXISTS | cut -f 3 -d "|")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUM=$(( $RANDOM % 1000 + 1 ))
TRIES=1

echo "Guess the secret number between 1 and 1000:"
read NUM

while [[ $NUM != $SECRET_NUM ]]
do
  if [[ $NUM =~ ^[0-9]+$ ]]
  then
    if [[ $NUM -gt $SECRET_NUM ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi 
  else
    echo "That is not an integer, guess again:"
  fi
  read NUM
  TRIES=$(( $TRIES + 1 ))
done

if [[ -z $GAMES_PLAYED ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users VALUES ('$USERNAME', 1, $TRIES)")
else
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
  if [[ $BEST_GAME -gt $TRIES ]]
  then
    UPDATE_USER_RESULT=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username = '$USERNAME'")
  fi
fi

echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUM. Nice job!"
