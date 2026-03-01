from .utils import (
    AnytimeGoalscorerScraper,
    BTTSWinAccumulatorScraper,
    BetOfTheDayScraper,
    BothTeamsToScoreScraper,
    DailyAccumulatorScraper,
    Over25GoalsAccumulatorScraper,
)


def get_bet_of_the_day():
    """Get today's Bet of the Day"""
    scraper = BetOfTheDayScraper()
    return scraper.scrape_bet_of_the_day()

def get_daily_accumulator():
    """Get today's Daily Accumulator Tips"""
    scraper = DailyAccumulatorScraper()
    return scraper.scrape_daily_accumulator()

def get_btts_win_accumulator():
    """Get today's BTTS and Win Accumulator Tips"""
    scraper = BTTSWinAccumulatorScraper()
    return scraper.scrape_btts_win_accumulator()

def get_over_25_goals_accumulator():
    """Get today's Over 2.5 Goals Accumulator Tips"""
    scraper = Over25GoalsAccumulatorScraper()
    return scraper.scrape_over_25_goals_accumulator()

def get_both_teams_to_score():
    """Get today's Both Teams to Score Tips"""
    scraper = BothTeamsToScoreScraper()
    return scraper.scrape_both_teams_to_score()

def get_anytime_goalscorer():
    """Get today's Anytime Goalscorer Tips"""
    scraper = AnytimeGoalscorerScraper()
    return scraper.scrape_anytime_goalscorer()