#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables
$PSQL "TRUNCATE TABLE games, teams;"

# 1. Insert teams (handling duplicates)
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  if [[ "$winner" != "winner" ]]; then # Skip header row
    # Insert winner (if not already exists)
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z "$TEAM_ID" ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$winner')"
    fi

    # Insert opponent (if not already exists)
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z "$TEAM_ID" ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$opponent')"
    fi
  fi
done

# 2. Insert games
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  if [[ "$winner" != "winner" ]]; then # Skip header row
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)"
  fi
done

echo "Data imported successfully!"
