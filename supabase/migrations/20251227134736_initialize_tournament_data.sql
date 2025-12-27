/*
  # Initialize Tournament Data

  - Insert all matches based on the 5-team round-robin schedule
  - Create game records for each match (4 games per match)
  - Initialize standings for all 5 teams
*/

-- Insert matches for all 5 rounds
INSERT INTO matches (round, team_a_id, team_b_id, status) VALUES
-- Round 1: Team 1 rests
(1, 2, 5, 'pending'),
(1, 3, 4, 'pending'),

-- Round 2: Team 4 rests
(2, 1, 5, 'pending'),
(2, 2, 3, 'pending'),

-- Round 3: Team 2 rests
(3, 1, 4, 'pending'),
(3, 3, 5, 'pending'),

-- Round 4: Team 5 rests
(4, 1, 3, 'pending'),
(4, 2, 4, 'pending'),

-- Round 5: Team 3 rests
(5, 4, 5, 'pending'),
(5, 1, 2, 'pending')
ON CONFLICT DO NOTHING;

-- Create games for each match
DO $$
DECLARE
  match_record matches%ROWTYPE;
  game_types text[] := ARRAY['blue_pair', 'red_pair', 'mixed_pair_1', 'mixed_pair_2'];
  game_idx integer;
BEGIN
  FOR match_record IN SELECT * FROM matches
  LOOP
    FOR game_idx IN 1..4
    LOOP
      INSERT INTO games (match_id, game_number, game_type, status)
      VALUES (match_record.match_id, game_idx, game_types[game_idx], 'pending')
      ON CONFLICT DO NOTHING;
    END LOOP;
  END LOOP;
END $$;

-- Initialize standings for all 5 teams
INSERT INTO standings (team_id, matches_won, matches_lost, games_won, games_lost, points_for, points_against, rank)
VALUES
(1, 0, 0, 0, 0, 0, 0, 0),
(2, 0, 0, 0, 0, 0, 0, 0),
(3, 0, 0, 0, 0, 0, 0, 0),
(4, 0, 0, 0, 0, 0, 0, 0),
(5, 0, 0, 0, 0, 0, 0, 0)
ON CONFLICT (team_id) DO NOTHING;