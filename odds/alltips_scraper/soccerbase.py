# alltips_scraper/soccerbase.py
import requests
from bs4 import BeautifulSoup
import re
from concurrent.futures import ThreadPoolExecutor
from typing import Optional, Dict, List, Tuple
import logging

logger = logging.getLogger(__name__)


class SoccerbaseScraper:
    """
    Fast Soccerbase scraper.
    - Pages are fetched in parallel (3 at once)
    - Results are cached at CLASS level so re-instantiation doesn't re-fetch
    - bulk_lookup does a single in-memory scan (no threads needed)
    """

    # ── Class-level cache shared across ALL instances ────────────────────────
    _cached_matches: Optional[List[Dict]] = None

    RESULT_URLS = [
        "https://www.soccerbase.com/results/home.sd",
        "https://www.soccerbase.com/results/home.sd?type=2",
        "https://www.soccerbase.com/results/home.sd?type=3",
    ]

    IGNORED_PREFIXES = {'la', 'le', 'les', 'los', 'las', 'el', 'il', 'fc', 'afc',
                        'ac', 'ssc', 'as', 'us', 'sco', '1', 'rc', 'cf', 'vfb', 'stade'}
    IGNORED_SUFFIXES = {'united', 'city', 'fc', 'afc', 'sc', 'cf', 'club', 'is'}

    def __init__(self, max_workers: int = 3):
        self.max_workers = max_workers
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })

    # ── Page fetching ────────────────────────────────────────────────────────

    def _fetch_page(self, url: str) -> List[Dict]:
        """Fetch and parse a single results page."""
        matches = []
        try:
            resp = self.session.get(url, timeout=5)
            soup = BeautifulSoup(resp.content, 'html.parser')
            for row in soup.find_all('tr', class_='match'):
                home = row.find('td', class_='team homeTeam')
                away = row.find('td', class_='team awayTeam')
                score = row.find('td', class_='score')
                if not (home and away and score):
                    continue
                score_match = re.search(r'(\d+)\s*-\s*(\d+)', score.get_text(strip=True))
                if score_match:
                    home_name = home.get_text(strip=True)
                    away_name = away.get_text(strip=True)
                    matches.append({
                        'home':       home_name.lower(),
                        'away':       away_name.lower(),
                        'home_name':  home_name,
                        'away_name':  away_name,
                        'score':      f"{score_match.group(1)}-{score_match.group(2)}",
                        'home_score': int(score_match.group(1)),
                        'away_score': int(score_match.group(2)),
                        'total_goals': int(score_match.group(1)) + int(score_match.group(2)),
                    })
        except Exception as e:
            logger.error(f"[Soccerbase] Error fetching {url}: {e}")
        return matches

    def _get_all_matches(self) -> List[Dict]:
        """
        Return all matches. Uses class-level cache so fetching only
        happens ONCE regardless of how many instances are created.
        Fetches all 3 pages in parallel.
        """
        if SoccerbaseScraper._cached_matches is not None:
            print(f"[Soccerbase] Using class-level cache ({len(SoccerbaseScraper._cached_matches)} matches)")
            return SoccerbaseScraper._cached_matches

        print("[Soccerbase] Fetching all 3 pages in parallel...")
        all_matches = []
        with ThreadPoolExecutor(max_workers=self.max_workers) as pool:
            for page_matches in pool.map(self._fetch_page, self.RESULT_URLS):
                all_matches.extend(page_matches)

        SoccerbaseScraper._cached_matches = all_matches
        print(f"[Soccerbase] Fetched and cached {len(all_matches)} total matches")
        return all_matches

    @classmethod
    def clear_cache(cls):
        """Call this to force a fresh fetch on the next request (e.g. daily cron)."""
        cls._cached_matches = None
        print("[Soccerbase] Class-level cache cleared")

    # ── Name matching ────────────────────────────────────────────────────────

    def _clean(self, name: str) -> str:
        if not name:
            return ""
        words = name.lower().split()
        while words and words[0] in self.IGNORED_PREFIXES:
            words.pop(0)
        while words and words[-1] in self.IGNORED_SUFFIXES:
            words.pop()
        return ' '.join(words)

    def _variations(self, name: str) -> List[str]:
        if not name:
            return []
        original = name.lower()
        cleaned = self._clean(name)
        words = original.split()
        candidates = {original, cleaned}
        if len(words) > 1:
            if words[0] in self.IGNORED_PREFIXES:
                candidates.add(' '.join(words[1:]))
                candidates.add(words[-1])
            if words[-1] in self.IGNORED_SUFFIXES:
                candidates.add(' '.join(words[:-1]))
        return [v for v in candidates if v]

    def _matches(self, search: str, page: str) -> bool:
        sc, pc = self._clean(search), self._clean(page)
        if sc == pc:
            return True
        if sc and pc and (sc in pc or pc in sc):
            return True
        if search.lower() in page.lower() or page.lower() in search.lower():
            return True
        return False

    # ── Lookup ───────────────────────────────────────────────────────────────

    def lookup_match(self, team1: str, team2: str) -> Dict:
        """Look up a single match. In-memory scan — very fast after first fetch."""
        if not team1 or not team2:
            return {'found': False, 'team1': team1, 'team2': team2}

        t1_vars = self._variations(team1)
        t2_vars = self._variations(team2)

        for match in self._get_all_matches():
            for t1 in t1_vars:
                for t2 in t2_vars:
                    home_hit = (t1 in match['home'] or self._matches(t1, match['home']))
                    away_hit = (t2 in match['away'] or self._matches(t2, match['away']))
                    reverse_home = (t2 in match['home'] or self._matches(t2, match['home']))
                    reverse_away = (t1 in match['away'] or self._matches(t1, match['away']))

                    if (home_hit and away_hit) or (reverse_home and reverse_away):
                        print(f"[Soccerbase]   ✓ FOUND: {match['home_name']} vs {match['away_name']} = {match['score']}")
                        return {
                            'home_team':   match['home_name'],
                            'away_team':   match['away_name'],
                            'score':       match['score'],
                            'home_score':  match['home_score'],
                            'away_score':  match['away_score'],
                            'total_goals': match['total_goals'],
                            'found':       True,
                        }

        print(f"[Soccerbase]   ✗ NOT FOUND: {team1} vs {team2}")
        return {'found': False, 'team1': team1, 'team2': team2}

    def bulk_lookup(self, matches_list: List[Tuple[str, str]]) -> Dict[str, Dict]:
        """
        Bulk lookup for multiple matches.
        Pages are loaded once (parallel), then all searches are pure in-memory —
        no threading needed for the search step itself.
        """
        if not matches_list:
            return {}

        print(f"\n[Soccerbase] ========== BULK LOOKUP START ==========")
        print(f"[Soccerbase] Looking up {len(matches_list)} matches")

        # Single network call (parallel pages, result cached for future calls)
        self._get_all_matches()

        # Pure in-memory scan — no thread overhead needed
        results = {}
        for team1, team2 in matches_list:
            key = f"{team1}|{team2}"
            results[key] = self.lookup_match(team1, team2)

        found = sum(1 for r in results.values() if r.get('found'))
        print(f"[Soccerbase] Found: {found}/{len(matches_list)} matches")
        print(f"[Soccerbase] ========== BULK LOOKUP COMPLETE ==========\n")
        return results


# ── Module-level singleton (reused across all calls in the same process) ────
_scraper = SoccerbaseScraper()


def get_match_result(team1: str, team2: str) -> Optional[Dict]:
    return _scraper.lookup_match(team1, team2)


def get_bulk_results(matches_list: List[Tuple[str, str]]) -> Dict[str, Dict]:
    return _scraper.bulk_lookup(matches_list)


def clear_match_cache():
    """Call from a scheduled job to force fresh data next request."""
    SoccerbaseScraper.clear_cache()