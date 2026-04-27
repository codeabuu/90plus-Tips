import requests
from bs4 import BeautifulSoup
import re
import json
from concurrent.futures import ThreadPoolExecutor, as_completed
from functools import lru_cache
import time

class SoccerbaseScraper:
    def __init__(self, max_workers: int = 10):
        self.session = requests.Session()
        self.session.headers.update({'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'})
        self.result_urls = [
            "https://www.soccerbase.com/results/home.sd",
            "https://www.soccerbase.com/results/home.sd?type=2",
            "https://www.soccerbase.com/results/home.sd?type=3"
        ]
        self.max_workers = max_workers
        
        # Prefixes and suffixes to ignore
        self.ignored_words = {
            'prefixes': ['la', 'le', 'les', 'los', 'las', 'el', 'il', 'fc', 'afc', 'ac', 'ssc', 'as', 'us', 'sco', '1', 'rc', 'cf', 'vfb', 'stade'],
            'suffixes': ['united', 'city', 'fc', 'afc', 'sc', 'cf', 'club']
        }
        
    @lru_cache(maxsize=3)
    def _get_all_matches(self) -> list:
        """Fetch ALL matches from ALL pages (cached, runs once)"""
        all_matches = []
        
        for url in self.result_urls:
            try:
                resp = self.session.get(url, timeout=5)
                soup = BeautifulSoup(resp.content, 'html.parser')
                
                for row in soup.find_all('tr', class_='match'):
                    home = row.find('td', class_='team homeTeam')
                    away = row.find('td', class_='team awayTeam')
                    score = row.find('td', class_='score')
                    
                    if home and away and score:
                        home_name = home.get_text(strip=True)
                        away_name = away.get_text(strip=True)
                        score_text = score.get_text(strip=True)
                        
                        score_match = re.search(r'(\d+)\s*-\s*(\d+)', score_text)
                        if score_match:
                            all_matches.append({
                                'home': home_name.lower(),
                                'away': away_name.lower(),
                                'home_name': home_name,
                                'away_name': away_name,
                                'score': f"{score_match.group(1)}-{score_match.group(2)}",
                                'home_score': int(score_match.group(1)),
                                'away_score': int(score_match.group(2))
                            })
            except:
                pass
                
        return all_matches
    
    def _clean_team_name(self, name: str) -> str:
        """Remove common prefixes and suffixes from team name"""
        name_lower = name.lower()
        words = name_lower.split()
        
        # Remove prefixes
        while words and words[0] in self.ignored_words['prefixes']:
            words.pop(0)
        
        # Remove suffixes
        while words and words[-1] in self.ignored_words['suffixes']:
            words.pop()
        
        return ' '.join(words) if words else name_lower
    
    def _get_name_variations(self, name: str) -> list:
        """Generate smart variations ignoring prefixes/suffixes"""
        if not name:
            return []
        
        name_lower = name.lower()
        variations = [name_lower]
        
        # Add cleaned version (without prefixes/suffixes)
        cleaned = self._clean_team_name(name)
        if cleaned != name_lower:
            variations.append(cleaned)
        
        # Handle special cases like "Le Havre" -> "Havre"
        words = name_lower.split()
        if len(words) > 1:
            # Add last word (e.g., "Havre" from "Le Havre")
            if words[0] in self.ignored_words['prefixes']:
                variations.append(words[-1])
            
            # Add without first word if it's a prefix
            if words[0] in self.ignored_words['prefixes']:
                variations.append(' '.join(words[1:]))
            
            # Add without last word if it's a suffix
            if words[-1] in self.ignored_words['suffixes']:
                variations.append(' '.join(words[:-1]))
        
        # Remove duplicates and empty strings
        variations = list(set([v for v in variations if v]))
        
        return variations
    
    def _name_matches(self, search_name: str, page_name: str) -> bool:
        """Check if search name matches page name (ignoring prefixes/suffixes)"""
        search_clean = self._clean_team_name(search_name)
        page_clean = self._clean_team_name(page_name)
        
        # Direct match after cleaning
        if search_clean == page_clean:
            return True
        
        # One contains the other
        if search_clean in page_clean or page_clean in search_clean:
            return True
        
        # Original check (for partial matches)
        if search_name.lower() in page_name.lower() or page_name.lower() in search_name.lower():
            return True
        
        return False
    
    def search_match(self, team1: str, team2: str) -> dict:
        """Search for match between two teams using smart name matching"""
        matches = self._get_all_matches()
        
        team1_vars = self._get_name_variations(team1)
        team2_vars = self._get_name_variations(team2)
        
        # Search for match
        for match in matches:
            for t1_var in team1_vars:
                for t2_var in team2_vars:
                    # Check both home/away combinations
                    if (t1_var in match['home'] and t2_var in match['away']) or \
                       (t1_var in match['away'] and t2_var in match['home']):
                        return {
                            'home': match['home_name'],
                            'away': match['away_name'],
                            'score': match['score'],
                            'home_score': match['home_score'],
                            'away_score': match['away_score']
                        }
                    
                    # Try cleaned name matching
                    if self._name_matches(t1_var, match['home']) and self._name_matches(t2_var, match['away']):
                        return {
                            'home': match['home_name'],
                            'away': match['away_name'],
                            'score': match['score'],
                            'home_score': match['home_score'],
                            'away_score': match['away_score']
                        }
                    if self._name_matches(t1_var, match['away']) and self._name_matches(t2_var, match['home']):
                        return {
                            'home': match['home_name'],
                            'away': match['away_name'],
                            'score': match['score'],
                            'home_score': match['home_score'],
                            'away_score': match['away_score']
                        }
        
        return None
    
    def bulk_search(self, json_file: str) -> list:
        """Bulk search from JSON file - SUPER FAST (pages loaded once)"""
        # Load JSON
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        matches = data.get('matches', [])
        
        # Load all pages ONCE
        print(f"📡 Loading match data from Soccerbase...")
        start = time.time()
        self._get_all_matches()
        print(f"   Loaded in {time.time()-start:.2f} seconds")
        
        # Search all matches in parallel
        print(f"⚡ Searching {len(matches)} matches...")
        start = time.time()
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {
                executor.submit(self.search_match, m['team1'], m['team2']): m 
                for m in matches if m.get('team2')
            }
            
            results = []
            for future in as_completed(futures):
                match = futures[future]
                result = future.result()
                results.append({
                    'search': f"{match['team1']} vs {match['team2']}",
                    'team1': match['team1'],
                    'team2': match['team2'],
                    'found': result is not None,
                    'result': result
                })
        
        print(f"   Searched in {time.time()-start:.2f} seconds")
        
        # Save results
        output_file = json_file.replace('.json', '_results.json')
        with open(output_file, 'w') as f:
            json.dump({
                'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
                'total': len(results),
                'found': sum(1 for r in results if r['found']),
                'results': results
            }, f, indent=2)
        
        return results


# Usage
if __name__ == "__main__":
    scraper = SoccerbaseScraper(max_workers=10)
    
    # Test matches with various name formats
    sample_json = {
        "matches": [
    # 🏴󠁧󠁢󠁥󠁮󠁧󠁿 EPL
    {"team1": "Liverpool", "team2": "Crystal Palace"},
    {"team1": "Arsenal", "team2": "Newcastle United"},
    {"team1": "Wolverhampton Wanderers", "team2": "Tottenham Hotspur"},
    {"team1": "West Ham United", "team2": "Everton"},
    {"team1": "Fulham", "team2": "Aston Villa"},

    # 🇩🇪 Bundesliga
    {"team1": "Borussia Dortmund", "team2": "SC Freiburg"},
    {"team1": "VfB Stuttgart", "team2": "Werder Bremen"},
    {"team1": "FSV Mainz", "team2": "Bayern Munich"},
    {"team1": "1. FC Cologne", "team2": "Bayer Leverkusen"},
    {"team1": "1. FC Heidenheim", "team2": "FC St. Pauli"},
    {"team1": "Hamburger SV", "team2": "TSG Hoffenheim"},

    # 🇫🇷 Ligue 1
    {"team1": "Le Havre AC", "team2": "FC Metz"},
    {"team1": "Stade Rennais", "team2": "FC Nantes"},
    {"team1": "Paris FC", "team2": "Lille OSC"},
    {"team1": "Olympique Marseille", "team2": "OGC Nice"},
    {"team1": "FC Lorient", "team2": "Strasbourg Alsace"},
    {"team1": "Angers SCO", "team2": "Paris Saint-Germain"},

    # 🇪🇸 La Liga
    {"team1": "FC Barcelona", "team2": "Getafe CF"},
    {"team1": "Atletico Madrid", "team2": "Athletic Bilbao"},
    {"team1": "Rayo Vallecano", "team2": "Real Sociedad"},
    {"team1": "CA Osasuna", "team2": "Sevilla FC"},
    {"team1": "Villarreal CF", "team2": "RC Celta de Vigo"},

    # 🇮🇹 Serie A
    {"team1": "AC Milan", "team2": "Juventus Turin"},
    {"team1": "Torino FC", "team2": "Inter Milano"},
    {"team1": "Genoa CFC", "team2": "Como 1907"},
    {"team1": "ACF Fiorentina", "team2": "Sassuolo Calcio"},

    # 🇺🇸 MLS
    {"team1": "Chicago Fire", "team2": "Sporting Kansas City"},
    {"team1": "Nashville SC", "team2": "Charlotte FC"},
    {"team1": "DC United", "team2": "Orlando City SC"},
    {"team1": "Seattle Sounders", "team2": "FC Dallas"},
]
    }
    
    # Save JSON
    with open("matches.json", "w") as f:
        json.dump(sample_json, f, indent=2)
    
    # Run search
    results = scraper.bulk_search("matches.json")
    
    # Display results
    print("\n" + "="*60)
    print("SEARCH RESULTS:")
    print("="*60)
    for r in results:
        if r['found']:
            res = r['result']
            print(f"✅ {r['search']}: {res['score']}")
            print(f"   Matched as: {res['home']} vs {res['away']}")
        else:
            print(f"❌ {r['search']}: Not found")