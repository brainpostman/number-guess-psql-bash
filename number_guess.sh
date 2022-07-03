#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

# echo "$($PSQL "truncate users")"
# echo "$($PSQL "alter sequence users_user_id_seq restart with 1")"

USER_LOGIN() {
  USER_QUERY=$($PSQL "select games_played, best_game from users where username='$1'")
  if [[ ! -z $USER_QUERY ]]
    then
      echo "$USER_QUERY" | while read GAMES_PLAYED BAR BEST_GAME
        do
          echo "Welcome back, $1! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
          GAMES_PLAYED_INSERT=$($PSQL "update users set games_played=$(( $GAMES_PLAYED + 1 )) where username='$1'")
        done
    else
      USER_INSERT=$($PSQL "insert into users(username) values('$1')")
      echo "Welcome, $1! It looks like this is your first time here."
  fi
  echo Guess the secret number between 1 and 1000:
  GUESSING_GAME $1    
}

GUESSING_GAME() {
  COUNTER=0;
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  while [[ $USER_GUESS -ne $SECRET_NUMBER ]]
    do
      USER_GUESS_PREV=$USER_GUESS
      read USER_GUESS
      if [[ ! "$USER_GUESS" =~ ^[0-9]+$ ]]
        then
          echo "That is not an integer, guess again:"
          USER_GUESS=$USER_GUESS_PREV
          continue
      fi
      COUNTER=$(( $COUNTER + 1 )) # no increments in this shell :(
      if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          continue
      fi
      if [[ $USER_GUESS -gt $SECRET_NUMBER ]]
        then
          echo "It's lower than that, guess again:"
      fi 
    done
  BEST_GAME=$($PSQL "select best_game from users where username='$1'")
  if [[ ! $BEST_GAME='          ' ]]
    then
      if [[ $COUNTER -lt $BEST_GAME ]]
        then
          BEST_GAME_INSERT=$($PSQL "update users set best_game=$COUNTER where username='$1'")
      fi    
    else
      BEST_GAME_INSERT=$($PSQL "update users set best_game=$COUNTER where username='$1'")
  fi    
  echo "You guessed it in $COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
}

echo Enter your username:
read USERNAME
USER_LOGIN $USERNAME
