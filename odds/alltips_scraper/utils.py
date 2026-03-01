import requests
from bs4 import BeautifulSoup
import cloudscraper
import re
from datetime import datetime
from decouple import config


API_BASE_URL = config('API_BASE_URL')

class BetOfTheDayScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/bet-of-the-day/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_bet_of_the_day(self):
        """Scrape the Bet of the Day section"""
        response = self.scraper.get(self.url)
        if not response:
            return {'error': 'Failed to fetch Bet of the Day page'}
            
        soup = BeautifulSoup(response.content, 'html.parser')
        
        accumulator = {
            'total_odds': None,
            'matches': [],
        }
        
        # Find all tip-wrap sections
        tip_wraps = soup.find_all('div', class_='tip-wrap')
        
        for tip_wrap in tip_wraps:
            date_bar = tip_wrap.find('div', class_='date-bar')
            date_text = date_bar.get_text(strip=True) if date_bar else ""
            
            # Look for tip-box inside this tip-wrap
            tip_box = tip_wrap.find('div', class_='tip-box')
            if tip_box:
                match_data = self._extract_match_from_tip_box(tip_box, date_text)
                if match_data:
                    accumulator['matches'].append(match_data)
            
            # Look for bet-box in this tip-wrap for total odds
            bet_box = tip_wrap.find('div', class_='bet-box')
            if bet_box:
                # Extract total odds from oddsvalue1 span
                total_odds_span = bet_box.find('span', class_='oddsvalue1')
                if total_odds_span and not accumulator['total_odds']:
                    accumulator['total_odds'] = total_odds_span.get_text(strip=True)
                    # Also get the raw data-odd attribute if available
                    raw_odds = total_odds_span.get('data-odd')
                    if raw_odds:
                        accumulator['total_odds_raw'] = raw_odds
        
        accumulator['count'] = len(accumulator['matches'])
        return accumulator
    
    def _extract_match_from_tip_box(self, tip_box, date_text):
        try:
            icons_section = tip_box.find('div', class_='icons')

            teams = []
            seen_teams = set()

            if icons_section:
                team_imgs = icons_section.find_all('img')
                for img in team_imgs:
                    alt_text = img.get('alt', '').strip()

                    if not alt_text or alt_text == 'goto-fix':
                        continue

                    if alt_text not in seen_teams:
                        teams.append(alt_text)
                        seen_teams.add(alt_text)

            title_link = tip_box.find('h2').find('a') if tip_box.find('h2') else None
            prediction_link = tip_box.find('p').find('a') if tip_box.find('p') else None

            match_title = title_link.get_text(strip=True) if title_link else ""
            prediction = (
                prediction_link.find('b').get_text(strip=True)
                if prediction_link and prediction_link.find('b')
                else ""
            )
            match_url = title_link.get('href') if title_link else ""

            # 🔒 Normalize teams using title if available
            if match_title and ' vs ' in match_title:
                teams = match_title.split(' vs ')

            return {
                'date': date_text,
                'match_title': match_title,
                'teams': teams,
                'prediction': prediction,
                'match_url': match_url,
            }

        except Exception as e:
            print(f"Error extracting match from tip-box: {e}")
            return None




class DailyAccumulatorScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/daily-football-accumulator-tips/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_daily_accumulator(self):
        """Scrape the Daily Accumulator Tips section"""
        response = self.scraper.get(self.url)
        if not response:
            return {'error': 'Failed to fetch Daily Accumulator page'}
            
        soup = BeautifulSoup(response.content, 'html.parser')
        
        accumulator = {
            'total_odds': None,
            'matches': [],
        }
        
        # Find all tip-wrap sections
        tip_wraps = soup.find_all('div', class_='tip-wrap')
        
        for tip_wrap in tip_wraps:
            date_bar = tip_wrap.find('div', class_='date-bar')
            date_text = date_bar.get_text(strip=True) if date_bar else ""
            
            # Look for tip-box-wrap inside this tip-wrap
            tip_box_wrap = tip_wrap.find('div', class_='tip-box-wrap')
            if tip_box_wrap:
                tip_boxes = tip_box_wrap.find_all('div', class_='tip-box')
                for tip_box in tip_boxes:
                    match_data = self._extract_match_from_tip_box(tip_box, date_text)
                    if match_data:
                        accumulator['matches'].append(match_data)
            
            # Look for bet-box in this tip-wrap for total odds
            bet_box = tip_wrap.find('div', class_='bet-box')
            if bet_box:
                # Extract total odds from oddsvalue1 span
                total_odds_span = bet_box.find('span', class_='oddsvalue1')
                if total_odds_span and not accumulator['total_odds']:
                    accumulator['total_odds'] = total_odds_span.get_text(strip=True)
                    # Also get the raw data-odd attribute if available
                    raw_odds = total_odds_span.get('data-odd')
                    if raw_odds:
                        accumulator['total_odds_raw'] = raw_odds
        
        accumulator['count'] = len(accumulator['matches'])
        return accumulator
    
    def _extract_match_from_tip_box(self, tip_box, date_text):
        """Extract match data from a tip-box div"""
        try:
            # Extract team icons and names
            icons_section = tip_box.find('div', class_='icons')
            teams = []
            if icons_section:
                team_imgs = icons_section.find_all('img')
                for img in team_imgs:
                    alt_text = img.get('alt', '')
                    if alt_text and alt_text not in ['goto-fix']:
                        teams.append(alt_text)
            
            # Extract match title and prediction
            title_link = tip_box.find('h2').find('a') if tip_box.find('h2') else None
            prediction_link = tip_box.find('p').find('a') if tip_box.find('p') else None
            
            match_title = title_link.get_text(strip=True) if title_link else ""
            prediction = prediction_link.find('b').get_text(strip=True) if prediction_link and prediction_link.find('b') else ""
            match_url = title_link.get('href') if title_link else ""
            
            # Look for individual match odds if available
            individual_odds = None
            # Sometimes individual odds might be in the same tip-box structure
            odds_span = tip_box.find('span', class_='oddsvalue1')
            if odds_span:
                individual_odds = odds_span.get_text(strip=True)
                raw_odds = odds_span.get('data-odd')
            
            return {
                'date': date_text,
                'match_title': match_title,
                'teams': teams,
                'prediction': prediction,
                'match_url': match_url,
            }
            
        except Exception as e:
            print(f"Error extracting match from tip-box: {e}")
            return None

    
class BTTSWinAccumulatorScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/btts-and-win-acca/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_btts_win_accumulator(self):
        """Scrape the BTTS and Win Accumulator section"""
        response = self.scraper.get(self.url)
        if not response:
            return {'error': 'Failed to fetch BTTS and Win Accumulator page'}
            
        soup = BeautifulSoup(response.content, 'html.parser')
        
        accumulator = {
            'total_odds': None,
            'matches': [],
            'type': 'BTTS and Win Accumulator',
            'scraped_at': datetime.now().isoformat()
        }
        
        # Find all tip-wrap sections
        tip_wraps = soup.find_all('div', class_='tip-wrap')
        
        for tip_wrap in tip_wraps:
            date_bar = tip_wrap.find('div', class_='date-bar')
            date_text = date_bar.get_text(strip=True) if date_bar else ""
            
            # Look for tip-box-wrap inside this tip-wrap
            tip_box_wrap = tip_wrap.find('div', class_='tip-box-wrap')
            if tip_box_wrap:
                tip_boxes = tip_box_wrap.find_all('div', class_='tip-box')
                for tip_box in tip_boxes:
                    match_data = self._extract_match_from_tip_box(tip_box, date_text)
                    if match_data:
                        accumulator['matches'].append(match_data)
            
            # Look for bet-box in this tip-wrap for total odds
            bet_box = tip_wrap.find('div', class_='bet-box')
            if bet_box:
                # Extract total odds from oddsvalue1 span
                total_odds_span = bet_box.find('span', class_='oddsvalue1')
                if total_odds_span and not accumulator['total_odds']:
                    accumulator['total_odds'] = total_odds_span.get_text(strip=True)
                    # Also get the raw data-odd attribute if available
                    raw_odds = total_odds_span.get('data-odd')
                    if raw_odds:
                        accumulator['total_odds_raw'] = raw_odds
        
        accumulator['count'] = len(accumulator['matches'])
        return accumulator
    
    def _extract_match_from_tip_box(self, tip_box, date_text):
        """Extract match data from a tip-box div for BTTS and Win"""
        try:
            # Extract team icons and names
            icons_section = tip_box.find('div', class_='icons')
            teams = []
            if icons_section:
                team_imgs = icons_section.find_all('img')
                for img in team_imgs:
                    alt_text = img.get('alt', '')
                    if alt_text and alt_text not in ['goto-fix']:
                        teams.append(alt_text)
            
            # Extract match title and prediction
            title_link = tip_box.find('h2').find('a') if tip_box.find('h2') else None
            prediction_link = tip_box.find('p').find('a') if tip_box.find('p') else None
            
            match_title = title_link.get_text(strip=True) if title_link else ""
            prediction = prediction_link.find('b').get_text(strip=True) if prediction_link and prediction_link.find('b') else ""
            match_url = title_link.get('href') if title_link else ""
            
            
            return {
                'date': date_text,
                'match_title': match_title,
                'teams': teams,
                'prediction': prediction,
                'match_url': match_url,
            }
            
        except Exception as e:
            print(f"Error extracting match from tip-box for BTTS: {e}")
            return None


class Over25GoalsAccumulatorScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/over-2-5-goals-accumulator/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_over_25_goals_accumulator(self):
        """Scrape the Over 2.5 Goals Accumulator section"""
        response = self.scraper.get(self.url)
        if not response:
            return {'error': 'Failed to fetch Over 2.5 Goals Accumulator page'}
            
        soup = BeautifulSoup(response.content, 'html.parser')
        
        accumulator = {
            'total_odds': None,
            'matches': [],
        }
        
        # Find all tip-wrap sections
        tip_wraps = soup.find_all('div', class_='tip-wrap')
        
        for tip_wrap in tip_wraps:
            date_bar = tip_wrap.find('div', class_='date-bar')
            date_text = date_bar.get_text(strip=True) if date_bar else ""
            
            # Look for tip-box-wrap inside this tip-wrap
            tip_box_wrap = tip_wrap.find('div', class_='tip-box-wrap')
            if tip_box_wrap:
                tip_boxes = tip_box_wrap.find_all('div', class_='tip-box')
                for tip_box in tip_boxes:
                    match_data = self._extract_match_from_tip_box(tip_box, date_text)
                    if match_data:
                        accumulator['matches'].append(match_data)
            
            # Look for bet-box in this tip-wrap for total odds
            bet_box = tip_wrap.find('div', class_='bet-box')
            if bet_box:
                # Extract total odds from oddsvalue1 span
                total_odds_span = bet_box.find('span', class_='oddsvalue1')
                if total_odds_span and not accumulator['total_odds']:
                    accumulator['total_odds'] = total_odds_span.get_text(strip=True)
                    # Also get the raw data-odd attribute if available
                    raw_odds = total_odds_span.get('data-odd')
                    if raw_odds:
                        accumulator['total_odds_raw'] = raw_odds
        
        return accumulator
    
    def _extract_match_from_tip_box(self, tip_box, date_text):
        """Extract match data from a tip-box div for Over 2.5 Goals"""
        try:
            # Extract team icons and names
            icons_section = tip_box.find('div', class_='icons')
            teams = []
            if icons_section:
                team_imgs = icons_section.find_all('img')
                for img in team_imgs:
                    alt_text = img.get('alt', '')
                    if alt_text and alt_text not in ['goto-fix']:
                        teams.append(alt_text)
            
            # Extract match title and prediction
            title_link = tip_box.find('h2').find('a') if tip_box.find('h2') else None
            prediction_link = tip_box.find('p').find('a') if tip_box.find('p') else None
            
            match_title = title_link.get_text(strip=True) if title_link else ""
            prediction = prediction_link.find('b').get_text(strip=True) if prediction_link and prediction_link.find('b') else ""
            match_url = title_link.get('href') if title_link else ""
            
            return {
                'date': date_text,
                'match_title': match_title,
                'teams': teams,
                'prediction': prediction,
                'match_url': match_url,
            }
            
        except Exception as e:
            print(f"Error extracting match from tip-box for Over 2.5 Goals: {e}")
            return None
        
    
class BothTeamsToScoreScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/both-teams-to-score-tips/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_both_teams_to_score(self):
        """Scrape the Both Teams to Score Tips section"""
        response = self.scraper.get(self.url)
        if not response:
            return {'error': 'Failed to fetch Both Teams to Score Tips page'}
            
        soup = BeautifulSoup(response.content, 'html.parser')
        
        accumulator = {
            'total_odds': None,
            'matches': [],
        }
        
        # Find all tip-wrap sections
        tip_wraps = soup.find_all('div', class_='tip-wrap')
        
        for tip_wrap in tip_wraps:
            date_bar = tip_wrap.find('div', class_='date-bar')
            date_text = date_bar.get_text(strip=True) if date_bar else ""
            
            # Look for tip-box-wrap inside this tip-wrap
            tip_box_wrap = tip_wrap.find('div', class_='tip-box-wrap')
            if tip_box_wrap:
                tip_boxes = tip_box_wrap.find_all('div', class_='tip-box')
                for tip_box in tip_boxes:
                    match_data = self._extract_match_from_tip_box(tip_box, date_text)
                    if match_data:
                        accumulator['matches'].append(match_data)
            
            # Look for bet-box in this tip-wrap for total odds
            bet_box = tip_wrap.find('div', class_='bet-box')
            if bet_box:
                # Extract total odds from oddsvalue1 span
                total_odds_span = bet_box.find('span', class_='oddsvalue1')
                if total_odds_span and not accumulator['total_odds']:
                    accumulator['total_odds'] = total_odds_span.get_text(strip=True)
                    # Also get the raw data-odd attribute if available
                    raw_odds = total_odds_span.get('data-odd')
                    if raw_odds:
                        accumulator['total_odds_raw'] = raw_odds
        
        accumulator['count'] = len(accumulator['matches'])
        return accumulator
    
    def _extract_match_from_tip_box(self, tip_box, date_text):
        """Extract match data from a tip-box div for Both Teams to Score"""
        try:
            # Extract team icons and names
            icons_section = tip_box.find('div', class_='icons')
            teams = []
            if icons_section:
                team_imgs = icons_section.find_all('img')
                for img in team_imgs:
                    alt_text = img.get('alt', '')
                    if alt_text and alt_text not in ['goto-fix']:
                        teams.append(alt_text)
            
            # Extract match title and prediction
            title_link = tip_box.find('h2').find('a') if tip_box.find('h2') else None
            prediction_link = tip_box.find('p').find('a') if tip_box.find('p') else None
            
            match_title = title_link.get_text(strip=True) if title_link else ""
            prediction = prediction_link.find('b').get_text(strip=True) if prediction_link and prediction_link.find('b') else ""
            match_url = title_link.get('href') if title_link else ""
            
            # Look for individual match odds if available
            individual_odds = None
            odds_span = tip_box.find('span', class_='oddsvalue1')
            if odds_span:
                individual_odds = odds_span.get_text(strip=True)
                raw_odds = odds_span.get('data-odd')
            
            return {
                'date': date_text,
                'match_title': match_title,
                'teams': teams,
                'prediction': prediction,
                'match_url': match_url,
            }
            
        except Exception as e:
            print(f"Error extracting match from tip-box for Both Teams to Score: {e}")
            return None

class AnytimeGoalscorerScraper:
    def __init__(self):
        self.url = f"{API_BASE_URL}/anytime-goalscorer-tip/"
        self.scraper = cloudscraper.create_scraper()
    
    def scrape_anytime_goalscorer(self):
        """Scrape the Anytime Goalscorer Tips section"""
        response = self.scraper.get(self.url)
        if not response:
            return {'error': 'Failed to fetch Anytime Goalscorer Tips page'}
            
        soup = BeautifulSoup(response.content, 'html.parser')
        
        accumulator = {
            'total_odds': None,
            'matches': [],
        }
        
        # Find all tip-wrap sections
        tip_wraps = soup.find_all('div', class_='tip-wrap')
        
        for tip_wrap in tip_wraps:
            date_bar = tip_wrap.find('div', class_='date-bar')
            date_text = date_bar.get_text(strip=True) if date_bar else ""
            
            # Look for tip-box-wrap inside this tip-wrap
            tip_box_wrap = tip_wrap.find('div', class_='tip-box-wrap')
            if tip_box_wrap:
                tip_boxes = tip_box_wrap.find_all('div', class_='tip-box')
                for tip_box in tip_boxes:
                    match_data = self._extract_match_from_tip_box(tip_box, date_text)
                    if match_data:
                        accumulator['matches'].append(match_data)
            
            # Look for bet-box in this tip-wrap for total odds
            bet_box = tip_wrap.find('div', class_='bet-box')
            if bet_box:
                # Extract total odds from oddsvalue1 span
                total_odds_span = bet_box.find('span', class_='oddsvalue1')
                if total_odds_span and not accumulator['total_odds']:
                    accumulator['total_odds'] = total_odds_span.get_text(strip=True)
                    # Also get the raw data-odd attribute if available
                    raw_odds = total_odds_span.get('data-odd')
                    if raw_odds:
                        accumulator['total_odds_raw'] = raw_odds
        
        accumulator['count'] = len(accumulator['matches'])
        return accumulator
    
    def _extract_match_from_tip_box(self, tip_box, date_text):
        """Extract match data from a tip-box div for Anytime Goalscorer"""
        try:
            # Extract team icons and names
            icons_section = tip_box.find('div', class_='icons')
            teams = []
            if icons_section:
                team_imgs = icons_section.find_all('img')
                for img in team_imgs:
                    alt_text = img.get('alt', '')
                    if alt_text and alt_text not in ['goto-fix']:
                        teams.append(alt_text)
            
            # Extract match title and prediction
            title_link = tip_box.find('h2').find('a') if tip_box.find('h2') else None
            prediction_link = tip_box.find('p').find('a') if tip_box.find('p') else None
            
            match_title = title_link.get_text(strip=True) if title_link else ""
            prediction = prediction_link.find('b').get_text(strip=True) if prediction_link and prediction_link.find('b') else ""
            match_url = title_link.get('href') if title_link else ""
            
            return {
                'date': date_text,
                'match_title': match_title,
                'teams': teams,
                'prediction': prediction,
                'match_url': match_url,
            }
            
        except Exception as e:
            print(f"Error extracting match from tip-box for Anytime Goalscorer: {e}")
            return None


