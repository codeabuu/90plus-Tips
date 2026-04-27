# alltips_scraper/unified_scraper.py
from concurrent.futures import ThreadPoolExecutor, as_completed
from .fast_scraper import get_fast_scraper
from .utils import (
    BetOfTheDayScraper,
    DailyAccumulatorScraper,
    BTTSWinAccumulatorScraper,
    Over25GoalsAccumulatorScraper,
    BothTeamsToScoreScraper,
    AnytimeGoalscorerScraper,
)


class UnifiedScraper:
    """
    Scrapes all accumulator types in parallel for maximum speed.
    """
    
    def __init__(self, max_workers: int = 6):
        self.max_workers = max_workers
        self.scrapers = {
            'bet_of_the_day': BetOfTheDayScraper(),
            'daily_accumulator': DailyAccumulatorScraper(),
            'btts_win': BTTSWinAccumulatorScraper(),
            'over_25': Over25GoalsAccumulatorScraper(),
            'btts': BothTeamsToScoreScraper(),
            'anytime_goalscorer': AnytimeGoalscorerScraper(),
        }
    
    def scrape_all(self) -> Dict:
        """
        Scrape ALL accumulator types in parallel.
        Returns dictionary with all results.
        """
        results = {}
        
        # Define scrape methods for each type
        scrape_methods = {
            'bet_of_the_day': lambda: self.scrapers['bet_of_the_day'].scrape_bet_of_the_day(),
            'daily_accumulator': lambda: self.scrapers['daily_accumulator'].scrape_daily_accumulator(),
            'btts_win': lambda: self.scrapers['btts_win'].scrape_btts_win_accumulator(),
            'over_25': lambda: self.scrapers['over_25'].scrape_over_25_goals_accumulator(),
            'btts': lambda: self.scrapers['btts'].scrape_both_teams_to_score(),
            'anytime_goalscorer': lambda: self.scrapers['anytime_goalscorer'].scrape_anytime_goalscorer(),
        }
        
        # Execute all scrapers in parallel
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {
                executor.submit(method): name 
                for name, method in scrape_methods.items()
            }
            
            for future in as_completed(futures):
                name = futures[future]
                try:
                    results[name] = future.result(timeout=30)
                    print(f"✅ Scraped {name}")
                except Exception as e:
                    print(f"❌ Failed to scrape {name}: {e}")
                    results[name] = {'error': str(e)}
        
        return results
    
    def scrape_single(self, scraper_name: str) -> Dict:
        """Scrape a single accumulator type"""
        if scraper_name not in self.scrapers:
            return {'error': f'Unknown scraper: {scraper_name}'}
        
        scraper = self.scrapers[scraper_name]
        method_name = f'scrape_{scraper_name}'
        
        if hasattr(scraper, method_name):
            return getattr(scraper, method_name)()
        else:
            return {'error': f'Method {method_name} not found'}


# Optimized versions of your scrapers (add to your existing utils.py or create new)

class OptimizedBetOfTheDayScraper(BetOfTheDayScraper):
    """Optimized version with session reuse"""
    
    def __init__(self):
        super().__init__()
        self.scraper = get_fast_scraper().session  # Reuse session
    
    def scrape_bet_of_the_day_fast(self):
        """Faster version using cached session"""
        # Same logic but with shared session
        return self.scrape_bet_of_the_day()


class OptimizedDailyAccumulatorScraper(DailyAccumulatorScraper):
    def __init__(self):
        super().__init__()
        self.scraper = get_fast_scraper().session