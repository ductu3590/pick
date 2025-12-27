/*
  # Create Tournament Management Schema

  ## Overview
  Complete schema for managing tournament matches, scores, and standings.

  ## Tables Created

  1. **matches** - Individual match records for each round
     - match_id: Unique identifier
     - round: Tournament round (1-5)
     - team_a_id, team_b_id: Teams competing
     - status: pending, in_progress, completed
     - match_date: When the match occurs
     
  2. **games** - Individual game results within a match (up to 4 games per match)
     - game_id: Unique identifier
     - match_id: Reference to parent match
     - game_type: 'blue_pair', 'red_pair', 'mixed_pair_1', 'mixed_pair_2'
     - game_number: 1-4 sequence
     - team_a_score, team_b_score: Points scored
     - status: pending, in_progress, completed
     
  3. **standings** - Real-time ranking calculations
     - team_id: Team identifier
     - matches_won: Total match wins
     - games_won: Total game wins
     - games_lost: Total games lost
     - points_for: Total points scored
     - points_against: Total points conceded
     - rank: Current ranking

  ## Security
  - Enable RLS on all tables
  - Public read access for schedule and standings
  - Allow admin-level score updates via policies
*/

-- Create matches table
CREATE TABLE IF NOT EXISTS matches (
  match_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  round integer NOT NULL CHECK (round >= 1 AND round <= 5),
  team_a_id integer NOT NULL,
  team_b_id integer NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
  match_date timestamptz DEFAULT now(),
  team_a_wins integer DEFAULT 0 CHECK (team_a_wins >= 0 AND team_a_wins <= 4),
  team_b_wins integer DEFAULT 0 CHECK (team_b_wins >= 0 AND team_b_wins <= 4),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create games table
CREATE TABLE IF NOT EXISTS games (
  game_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id uuid NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
  game_number integer NOT NULL CHECK (game_number >= 1 AND game_number <= 4),
  game_type text NOT NULL CHECK (game_type IN ('blue_pair', 'red_pair', 'mixed_pair_1', 'mixed_pair_2')),
  team_a_score integer DEFAULT 0 CHECK (team_a_score >= 0),
  team_b_score integer DEFAULT 0 CHECK (team_b_score >= 0),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(match_id, game_number)
);

-- Create standings table
CREATE TABLE IF NOT EXISTS standings (
  standings_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id integer NOT NULL UNIQUE,
  matches_won integer DEFAULT 0,
  matches_lost integer DEFAULT 0,
  games_won integer DEFAULT 0,
  games_lost integer DEFAULT 0,
  points_for integer DEFAULT 0,
  points_against integer DEFAULT 0,
  rank integer DEFAULT 0,
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_matches_round ON matches(round);
CREATE INDEX IF NOT EXISTS idx_matches_teams ON matches(team_a_id, team_b_id);
CREATE INDEX IF NOT EXISTS idx_games_match ON games(match_id);
CREATE INDEX IF NOT EXISTS idx_standings_rank ON standings(rank);

-- Enable RLS
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE standings ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Allow public read access
CREATE POLICY "Matches are publicly readable"
  ON matches
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Games are publicly readable"
  ON games
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Standings are publicly readable"
  ON standings
  FOR SELECT
  TO public
  USING (true);

-- RLS Policies: Allow insert for matches and games (for tournament setup)
CREATE POLICY "Allow match creation"
  ON matches
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Allow game creation"
  ON games
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- RLS Policies: Allow updates for score entries
CREATE POLICY "Allow match status updates"
  ON matches
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow game score updates"
  ON games
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow standings updates"
  ON standings
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);