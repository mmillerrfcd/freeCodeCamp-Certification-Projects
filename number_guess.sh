#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(($RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")

  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE user_id = $USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE user_id = $USER_ID;")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
CORRECT=false
GUESSES=0

while [[ $CORRECT == false ]]
do
  read GUESS
  GUESSES=$(($GUESSES + 1))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
    CORRECT=true
  fi
done

INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES);")