import asyncio
import aiohttp
import cloudscraper
from bs4 import BeautifulSoup
from datetime import datetime
from decouple import config
from concurrent.futures import ThreadPoolExecutor
from functools import partial

API_BASE_URL = config('API_BASE_URL')


# ---------------------------------------------------------------------------
# Shared HTML parsing helpers (stateless, reused by every scraper)
# ---------------------------------------------------------------------------

def _parse_tip_box(tip_box, date_text: str) -> dict | None:
    """Extract match data from a single tip-box div. Used by all scrapers."""
    try:
        icons_section = tip_box.find('div', class_='icons')
        teams = []
        if icons_section:
            seen = set()
            for img in icons_section.find_all('img'):
                alt = img.get('alt', '').strip()
                if alt and alt != 'goto-fix' and alt not in seen:
                    teams.append(alt)
                    seen.add(alt)

        h2 = tip_box.find('h2')
        p  = tip_box.find('p')
        title_link      = h2.find('a') if h2 else None
        prediction_link = p.find('a')  if p  else None

        match_title = title_link.get_text(strip=True)      if title_link      else ""
        prediction  = (prediction_link.find('b').get_text(strip=True)
                       if prediction_link and prediction_link.find('b') else "")
        match_url   = title_link.get('href', '')           if title_link      else ""

        # Prefer teams from title for consistency
        if match_title and ' vs ' in match_title:
            teams = match_title.split(' vs ')

        return {
            'date':        date_text,
            'match_title': match_title,
            'teams':       teams,
            'prediction':  prediction,
            'match_url':   match_url,
        }
    except Exception as e:
        print(f"Error extracting match from tip-box: {e}")
        return None


def _parse_page(html: bytes, multi_box: bool) -> dict:
    """
    Parse a scraped page into an accumulator dict.

    multi_box=True  → tip boxes are inside a 'tip-box-wrap' (accumulator-style pages)
    multi_box=False → one tip box directly inside 'tip-wrap' (bet-of-the-day style)
    """
    soup = BeautifulSoup(html, 'html.parser')

    result = {'total_odds': None, 'matches': []}

    for tip_wrap in soup.find_all('div', class_='tip-wrap'):
        date_bar  = tip_wrap.find('div', class_='date-bar')
        date_text = date_bar.get_text(strip=True) if date_bar else ""

        if multi_box:
            wrap = tip_wrap.find('div', class_='tip-box-wrap')
            if wrap:
                for tip_box in wrap.find_all('div', class_='tip-box'):
                    m = _parse_tip_box(tip_box, date_text)
                    if m:
                        result['matches'].append(m)
        else:
            tip_box = tip_wrap.find('div', class_='tip-box')
            if tip_box:
                m = _parse_tip_box(tip_box, date_text)
                if m:
                    result['matches'].append(m)

        # Total odds (first occurrence wins)
        if result['total_odds'] is None:
            bet_box = tip_wrap.find('div', class_='bet-box')
            if bet_box:
                span = bet_box.find('span', class_='oddsvalue1')
                if span:
                    result['total_odds'] = span.get_text(strip=True)
                    raw = span.get('data-odd')
                    if raw:
                        result['total_odds_raw'] = raw

    result['count'] = len(result['matches'])
    return result


# ---------------------------------------------------------------------------
# Scraper configuration table
# ---------------------------------------------------------------------------

SCRAPER_CONFIGS = {
    'bet_of_the_day':          ('/bet-of-the-day/',                     False),
    'daily_accumulator':       ('/daily-football-accumulator-tips/',    True),
    'btts_win':                ('/btts-and-win-acca/',                  True),
    'over_25_goals':           ('/over-2-5-goals-accumulator/',         True),
    'both_teams_to_score':     ('/both-teams-to-score-tips/',           True),
    'anytime_goalscorer':      ('/anytime-goalscorer-tip/',             True),
}


# ---------------------------------------------------------------------------
# Fast concurrent fetcher
# ---------------------------------------------------------------------------

def _fetch_one(path: str, multi_box: bool) -> dict:
    """Fetch + parse a single URL synchronously (runs in thread pool)."""
    scraper = cloudscraper.create_scraper()
    url = f"{API_BASE_URL}{path}"
    resp = scraper.get(url, timeout=15)
    if not resp or not resp.ok:
        return {'error': f'Failed to fetch {url}'}
    return _parse_page(resp.content, multi_box)


def scrape_all(keys: list[str] | None = None) -> dict[str, dict]:
    """
    Scrape all (or a subset of) pages concurrently using a thread pool.

    Returns a dict keyed by scraper name.

    Example:
        results = scrape_all()
        results = scrape_all(['bet_of_the_day', 'over_25_goals'])
    """
    configs = {k: SCRAPER_CONFIGS[k] for k in (keys or SCRAPER_CONFIGS)}

    with ThreadPoolExecutor(max_workers=len(configs)) as pool:
        futures = {
            name: pool.submit(_fetch_one, path, multi_box)
            for name, (path, multi_box) in configs.items()
        }
        return {name: fut.result() for name, fut in futures.items()}


def scrape_one(key: str) -> dict:
    """Scrape a single page by config key."""
    path, multi_box = SCRAPER_CONFIGS[key]
    return _fetch_one(path, multi_box)


# ---------------------------------------------------------------------------
# Legacy class wrappers (drop-in replacements for the original classes)
# ---------------------------------------------------------------------------

class BetOfTheDayScraper:
    def scrape_bet_of_the_day(self):
        return scrape_one('bet_of_the_day')

class DailyAccumulatorScraper:
    def scrape_daily_accumulator(self):
        return scrape_one('daily_accumulator')

class BTTSWinAccumulatorScraper:
    def scrape_btts_win_accumulator(self):
        return scrape_one('btts_win')

class Over25GoalsAccumulatorScraper:
    def scrape_over_25_goals_accumulator(self):
        return scrape_one('over_25_goals')

class BothTeamsToScoreScraper:
    def scrape_both_teams_to_score(self):
        return scrape_one('both_teams_to_score')

class AnytimeGoalscorerScraper:
    def scrape_anytime_goalscorer(self):
        return scrape_one('anytime_goalscorer')