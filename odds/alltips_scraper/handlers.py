# alltips_scraper/handlers.py
from .utils import (
    AnytimeGoalscorerScraper,
    BTTSWinAccumulatorScraper,
    BetOfTheDayScraper,
    BothTeamsToScoreScraper,
    DailyAccumulatorScraper,
    Over25GoalsAccumulatorScraper,
)
from .soccerbase import get_bulk_results
from .prediction_adjuster import verify_predictions
import os


# Environment variable to toggle verification (default: False)
ENABLE_VERIFICATION = True
print(f"[DEBUG] ENABLE_PREDICTION_VERIFICATION = {ENABLE_VERIFICATION}")  


def get_bet_of_the_day():
    """Get today's Bet of the Day"""
    scraper = BetOfTheDayScraper()
    data = scraper.scrape_bet_of_the_day()
    
    # Apply verification if enabled
    if ENABLE_VERIFICATION and data.get('matches') and not data.get('error'):
        data = _verify_predictions(data, 'bet_of_day')
    
    return data


def get_daily_accumulator():
    """Get today's Daily Accumulator Tips"""
    scraper = DailyAccumulatorScraper()
    data = scraper.scrape_daily_accumulator()
    
    # Apply verification if enabled
    if ENABLE_VERIFICATION and data.get('matches') and not data.get('error'):
        data = _verify_predictions(data, 'daily')
    
    return data


def get_btts_win_accumulator():
    """Get today's BTTS and Win Accumulator Tips"""
    scraper = BTTSWinAccumulatorScraper()
    data = scraper.scrape_btts_win_accumulator()
    
    # Apply verification if enabled
    if ENABLE_VERIFICATION and data.get('matches') and not data.get('error'):
        data = _verify_predictions(data, 'btts_win')
    
    return data


def get_over_25_goals_accumulator():
    """Get today's Over 2.5 Goals Accumulator Tips"""
    print(f"[DEBUG] get_over_25_goals_accumulator called, ENABLE_VERIFICATION={ENABLE_VERIFICATION}")
    scraper = Over25GoalsAccumulatorScraper()
    data = scraper.scrape_over_25_goals_accumulator()
    
    # Apply verification if enabled
    if ENABLE_VERIFICATION and data.get('matches') and not data.get('error'):
        print(f"[DEBUG] Verification is ENABLED for {len(data['matches'])} matches")
        data = _verify_predictions(data, 'over_25')
    else:
        print(f"[DEBUG] Verification is DISABLED or no matches")
    
    return data

def get_both_teams_to_score():
    """Get today's Both Teams to Score Tips"""
    scraper = BothTeamsToScoreScraper()
    data = scraper.scrape_both_teams_to_score()
    
    # Apply verification if enabled
    if ENABLE_VERIFICATION and data.get('matches') and not data.get('error'):
        data = _verify_predictions(data, 'btts')
    
    return data


def get_anytime_goalscorer():
    """Get today's Anytime Goalscorer Tips"""
    scraper = AnytimeGoalscorerScraper()
    data = scraper.scrape_anytime_goalscorer()
    
    # Apply verification if enabled (just add scores, no adjustment)
    if ENABLE_VERIFICATION and data.get('matches') and not data.get('error'):
        data = _add_scores_to_goalscorer(data)
    
    return data


def _verify_predictions(data, accumulator_type):
    """Helper function to verify predictions with actual scores"""
    # Extract team pairs
    team_pairs = []
    for match in data.get('matches', []):
        teams = match.get('teams', [])
        if len(teams) >= 2:
            team_pairs.append((teams[0], teams[1]))
    
    if not team_pairs:
        return data
    
    # Get actual scores from Soccerbase
    match_results = get_bulk_results(team_pairs)
    
    # Verify and adjust predictions
    verified_data = verify_predictions(data, match_results, accumulator_type)
    
    return verified_data


def _add_scores_to_goalscorer(data):
    """Helper function to add actual scores to anytime goalscorer predictions"""
    # Extract team pairs
    team_pairs = []
    for match in data.get('matches', []):
        teams = match.get('teams', [])
        if len(teams) >= 2:
            team_pairs.append((teams[0], teams[1]))
    
    if not team_pairs:
        return data
    
    # Get actual scores from Soccerbase
    match_results = get_bulk_results(team_pairs)
    
    # Add scores to each match
    for match in data.get('matches', []):
        teams = match.get('teams', [])
        if len(teams) >= 2:
            match_key = f"{teams[0]}|{teams[1]}"
            match_result = match_results.get(match_key)
            
            if match_result and match_result.get('found'):
                match['actual_score'] = match_result['score']
                match['actual_home_score'] = match_result['home_score']
                match['actual_away_score'] = match_result['away_score']
                match['total_goals'] = match_result['total_goals']
                match['verified'] = True
            else:
                match['verified'] = False
                match['verification_error'] = 'Match not found'
    
    data['verified'] = True
    data['processed_at'] = __import__('datetime').datetime.now().isoformat()
    
    return data