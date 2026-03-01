import requests
from bs4 import BeautifulSoup
import cloudscraper
from decouple import config
from rest_framework.permissions import AllowAny

API_BASE_URL = config('API_BASE_URL')

class LaLigaScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/spanish-la-liga/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        return matches

    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds

    def scrape_team_analysis(self, match_url):
        """Scrape deep team analysis from individual match page"""
        response = self.scraper.get(match_url)
        if not response:
            return {'error': 'Failed to fetch match details'}
            
        soup = BeautifulSoup(response.content, 'html.parser')
        
        analysis = {
            'predictions': [],
            'match_url': match_url,
            'team_analysis': {},
            'form_analysis': {},
            'head_to_head': [],
            'smart_insights': [],
            'key_statistics': {},
            'team_forms': {},
              # Add predictions here
        }
        
        # Extract team names from URL
        url_parts = match_url.split('/')[-2].split('-vs-')
        if len(url_parts) == 2:
            home_team = url_parts[0].replace('-', ' ').title()
            away_team = url_parts[1].split('-')[0].replace('-', ' ').title()
            analysis['teams'] = {
                'home': home_team,
                'away': away_team
            }
        
        # Extract predictions from betting tips section
        tips_section = soup.find('div', id='tips')
        if tips_section:
            bet_boxes = tips_section.find_all('div', class_='bet-box')
            
            for bet_box in bet_boxes:
                # Extract prediction text
                prediction_text = bet_box.find('p')
                if prediction_text:
                    prediction_text = prediction_text.find('strong')
                    if prediction_text:
                        prediction = prediction_text.get_text(strip=True)
                        
                        # Extract bookmaker
                        
                        analysis['predictions'].append({
                            'prediction': prediction,
                        })
        
        # Extract all text content for analysis
        content = soup.find('div', class_=['entry-content', 'main-content'])
        if not content:
            content = soup
        
        # Extract team-specific analysis
        paragraphs = content.find_all('p')
        for p in paragraphs:
            text = p.get_text(strip=True)
            if len(text) > 100:  # Only substantial paragraphs
                if analysis['teams']['home'].split()[0].lower() in text.lower():
                    analysis['team_analysis'][analysis['teams']['home']] = analysis['team_analysis'].get(analysis['teams']['home'], []) + [text]
                elif analysis['teams']['away'].split()[0].lower() in text.lower():
                    analysis['team_analysis'][analysis['teams']['away']] = analysis['team_analysis'].get(analysis['teams']['away'], []) + [text]
        
        # Extract Smart Insights (looking for bullet points or key stats)
        lists = content.find_all('ul')
        for ul in lists:
            items = ul.find_all('li')
            for item in items:
                text = item.get_text(strip=True)
                if any(keyword in text.lower() for keyword in ['conceded', 'unbeaten', 'goals', 'win', 'draw', 'loss', 'average', '%']):
                    analysis['smart_insights'].append(text)
        
        # Extract team statistics tables
        tables = content.find_all('table')
        for table in tables:
            # Check if this is a stats table
            headers = [th.get_text(strip=True) for th in table.find_all('th')]
            if any(team in str(headers) for team in [analysis['teams']['home'], analysis['teams']['away']]):
                rows = table.find_all('tr')
                for row in rows[1:]:  # Skip header
                    cells = [td.get_text(strip=True) for td in row.find_all('td')]
                    if len(cells) >= 3:
                        stat_name = cells[0]
                        analysis['key_statistics'][stat_name] = {
                            analysis['teams']['home']: cells[1],
                            analysis['teams']['away']: cells[2]
                        }
        
        # Extract head-to-head data
        for table in tables:
            # Look for date patterns in table (head-to-head usually has dates)
            rows = table.find_all('tr')
            for row in rows:
                text = row.get_text()
                if any(year in text for year in ['2025', '2024', '2023', '2022']):
                    cells = [td.get_text(strip=True) for td in row.find_all('td')]
                    if len(cells) >= 3 and any('-' in cell for cell in cells):
                        analysis['head_to_head'].append({
                            'date': cells[0],
                            'matchup': cells[1],
                            'result': cells[2]
                        })
        
        # Extract recent form data
        for table in tables:
            previous_element = table.find_previous(['h3', 'h4', 'strong'])
            if previous_element:
                prev_text = previous_element.get_text().lower()
                if 'form' in prev_text or 'recent' in prev_text:
                    team_name = None
                    if analysis['teams']['home'].lower() in prev_text:
                        team_name = analysis['teams']['home']
                    elif analysis['teams']['away'].lower() in prev_text:
                        team_name = analysis['teams']['away']
                    
                    if team_name:
                        analysis['team_forms'][team_name] = self._extract_form_data(table)
        
        return analysis

    def _extract_form_data(self, table):
        """Extract form data from table"""
        form_data = []
        rows = table.find_all('tr')[1:]  # Skip header row
        for row in rows:
            cells = [td.get_text(strip=True) for td in row.find_all('td')]
            if len(cells) >= 2:
                form_match = {
                    'date': cells[0],
                    'fixture': cells[1]
                }
                if len(cells) > 2:
                    form_match['result'] = cells[2]
                form_data.append(form_match)
        return form_data


class EPLScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/english-premier-league/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds



class EFLCupScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/england-efl-cup/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds



class SerieA_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/italy-serie-a/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds


class Bundesliga_Scraper:
    def __init__(self):
            self.url = f"{API_BASE_URL}/leagues/germany-bundesliga/"
            self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds


#norway eliterien
class Eliteserien_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/norway-eliteserien/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds


#france ligue 1
class Ligue1_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/france-ligue-1/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds

        

#swedish league functions
class Swedish_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/swedish-allsvenskan/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds


#liga portugal
class Liga_Portugal_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/liga-portugal/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds



#champions league
class UEFA_CL_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/uefa-champions-league/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Extract match time
                    match_time_span = prediction_box.find('span', class_='league-match-time')
                    match_time = match_time_span.get_text(strip=True) if match_time_span else ""
                    # Clean up the time text (remove the clock icon if present)
                    if match_time:
                        match_time = match_time.replace('🕒', '').strip()
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'time': match_time,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds
    

class Dutch_Eredivisie_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/dutch-eredivisie/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds
    

class Turkish_League_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/turkey-super-lig/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds
    
class Europa_League_Scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/uefa-europa-league/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds
    
class World_cupq_scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/world-cup-qualification-europe/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds
    
class World_cupqafrica_scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/world-cup-qualification-africa/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds
    
class World_cupqasia_scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/world-cup-qualification-asia/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds
    
class Scottish_premiership_scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/scottish-premiership/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds

class Afcon2025_scraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/leagues/africa-cup-of-nations/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_matches(self):
        response = self.scraper.get(self.url)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        matches = []
        
        # Check if there's a "no matches" message
        no_matches_div = soup.find('div', class_='custom-box content-preview notips')
        if no_matches_div:
            no_matches_text = no_matches_div.get_text(strip=True)
            return {
                'matches': [],
                'message': no_matches_text,
                'available': False
            }
        
        # Find all prediction boxes on the page
        prediction_boxes = soup.find_all('div', class_='epl-prediction-box')
        
        for box in prediction_boxes:
            # Find all prediction rows within each box
            rows = box.find_all('div', class_='epl-prediction-row')
            
            for row in rows:
                # Get date for this row
                date_div = row.find('div', class_='date-head')
                date_text = date_div.get_text(strip=True) if date_div else ""
                
                # Find ALL match titles in this row
                title_links = row.find_all('a', class_='league-match-title-link')
                
                for title_link in title_links:
                    teams = title_link.get_text(strip=True)
                    
                    if ' vs ' not in teams:
                        continue
                    
                    # Find the specific prediction box that contains this match
                    prediction_box = title_link.find_parent('div', class_='league-prediction-box-new')
                    if not prediction_box:
                        continue
                    
                    # Get predictions with odds for this specific match
                    predictions_with_odds = self._extract_predictions_with_odds(prediction_box)
                    
                    match_data = {
                        'teams': teams,
                        'date': date_text,
                        'home_team': teams.split(' vs ')[0],
                        'away_team': teams.split(' vs ')[1],
                        'predictions': predictions_with_odds,
                        'detail_link': title_link.get('href', '')
                    }
                    matches.append(match_data)
        
        if matches:
            return {
                'matches': matches,
                'message': f'Found {len(matches)} matches',
                'available': True
            }
        else:
            return {
                'matches': [],
                'message': 'No matches found. Please check back later.',
                'available': False
            }
    
    def _extract_predictions_with_odds(self, prediction_box):
        """Extract predictions along with their odds from the betting tips section"""
        predictions_with_odds = []
        
        betting_section = prediction_box.find('div', class_='league-betting-tips-section')
        
        if betting_section:
            betting_tips = betting_section.find_all('div', class_='league-betting-tip-inline')
            
            for tip in betting_tips:
                # Extract prediction text
                tip_text_div = tip.find('div', class_='league-tip-text')
                prediction_text = tip_text_div.get_text(strip=True) if tip_text_div else ""
                
                # Extract odds value
                odds_value_span = tip.find('span', class_='league-odds-value')
                odds_value = None
                if odds_value_span:
                    odds_text = odds_value_span.get_text(strip=True)
                    # Extract just the number from "2.50 odds"
                    import re
                    odds_match = re.search(r'(\d+\.\d{2})', odds_text)
                    if odds_match:
                        odds_value = float(odds_match.group(1))
                
                prediction_data = {
                    'prediction': prediction_text,
                    'odds': odds_value,
                }
                predictions_with_odds.append(prediction_data)
        
        return predictions_with_odds