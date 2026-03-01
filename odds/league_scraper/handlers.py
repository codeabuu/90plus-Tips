from .utils import (
    Dutch_Eredivisie_Scraper,
    EFLCupScraper,
    Eliteserien_Scraper,
    LaLigaScraper, EPLScraper,
    Liga_Portugal_Scraper,
    Ligue1_Scraper,
    Scottish_premiership_scraper,
    SerieA_Scraper,
    Bundesliga_Scraper,
    Swedish_Scraper,
    Turkish_League_Scraper,
    UEFA_CL_Scraper,
    World_cupq_scraper,
    World_cupqafrica_scraper,
    World_cupqasia_scraper,
    Afcon2025_scraper
)
from decouple import config

API_BASE_URL = config('API_BASE_URL')

def get_laliga_matches():
    """Get all matches with their detail links"""
    scraper = LaLigaScraper()
    matches = scraper.scrape_matches()
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    return matches

def get_team_analysis(match_url):
    """Get team analysis for a specific match URL"""
    scraper = LaLigaScraper()
    return scraper.scrape_team_analysis(match_url)

def get_team_analysis_by_teams(home_team, away_team, date):
    """Get team analysis by team names and date"""
    # Construct the URL from team names and date
    home_slug = home_team.lower().replace(' ', '-')
    away_slug = away_team.lower().replace(' ', '-')
    match_url = f"{API_BASE_URL}/predictions/{home_slug}-vs-{away_slug}-{date}/"
    
    scraper = LaLigaScraper()
    return scraper.scrape_team_analysis(match_url)


#EPL Functions
def get_epl_matches():
    """Get all EPL matches with their detail links"""
    scraper = EPLScraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

#EFLCup MACHES
def get_efl_cup_matches():
    """Get all EFL Cup matches with their detail links"""
    scraper = EFLCupScraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

#SERIA
def get_seria_matches():
    """Get all Serie A matches with their detail links"""
    scraper = SerieA_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

#bundesliga
def get_bundesliga_matches():
    """Get all Bundesliga matches with their detail links"""
    scraper = Bundesliga_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

#eliteserien norway
def get_eliteserien_matches():
    """Get all Eliteserien matches with their detail links"""
    scraper = Eliteserien_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

#france ligue 1
def get_ligue1_matches():
    """Get all Ligue 1 matches with their detail links"""
    scraper = Ligue1_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result


#swedish scrapper
def get_swedish_matches():
    """Get all Swedish Allsvenskan matches with their detail links"""
    scraper = Swedish_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

#liga portugal
def get_liga_portugal_matches():
    """Get all Liga Portugal matches with their detail links"""
    scraper = Liga_Portugal_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

#uefa cl
def get_uefa_cl_matches():
    """Get all UEFA Champions League matches with their detail links"""
    scraper = UEFA_CL_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

def get_dutch_eredivisie_matches():
    """Get all Dutch Eredivisie matches with their detail links"""
    scraper = Dutch_Eredivisie_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

def get_turkish_matches():
    """Get all Turkish Super Lig matches with their detail links"""
    scraper = Turkish_League_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result


def get_europa_matches():
    """Get all Turkish Super Lig matches with their detail links"""
    scraper = Turkish_League_Scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result


def get_worldcup_q_matches():
    """Get all World Cup Qualification Europe matches with their detail links"""
    scraper = World_cupq_scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

def get_worldcup_qasia_matches():
    """Get all World Cup Qualification Asia matches with their detail links"""
    scraper = World_cupqasia_scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

def get_worldcup_qafrica_matches():
    """Get all World Cup Qualification Africa matches with their detail links"""
    scraper = World_cupqafrica_scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

def get_scottish_matches():
    """Get all Scottish Premiership matches with their detail links"""
    scraper = Scottish_premiership_scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result

def get_afcon2025():
    """Get all African Cup of Nations matches with their detail links"""
    scraper = Afcon2025_scraper()
    result = scraper.scrape_matches()
    
    # If no matches available, return the message
    if not result.get('available', False):
        return result
    
    matches = result['matches']
    
    # Month mapping from numbers to letters
    month_mapping = {
        '01': 'january', '02': 'february', '03': 'march', '04': 'april',
        '05': 'may', '06': 'june', '07': 'july', '08': 'august',
        '09': 'september', '10': 'october', '11': 'november', '12': 'december'
    }
    
    # Add detail links to each match
    for match in matches:
        home = match['home_team'].lower().replace(' ', '-')
        away = match['away_team'].lower().replace(' ', '-')
        
        # Extract date parts and convert month to letters
        date_str = match['date'].split(',')[0]  # "31.10.2025"
        day, month_num, year = date_str.split('.')
        
        # Convert month number to month name
        month_name = month_mapping.get(month_num, '')
        
        # Create date part in the format: "31-october-2025"
        date_part = f"{day}-{month_name}-{year}"
        
        match['detail_link'] = f"{API_BASE_URL}predictions/{home}-vs-{away}-{date_part}/"
    
    result['matches'] = matches
    return result