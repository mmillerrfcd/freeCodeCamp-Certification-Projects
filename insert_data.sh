#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo Working...

# Empty tables
TRUNCATE_RESULT=$($PSQL "TRUNCATE teams, games;")

# Read all games
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Find winner id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    if [[ -z $WINNER_ID ]]
    then
      # Insert new team
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    fi

    # Find opponent id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert new team
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    fi

    # Insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
  fi
done

echo Done.