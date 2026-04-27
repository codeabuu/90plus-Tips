from django.http import JsonResponse
from django.core.cache import cache
from .decorators import cache_matches
import logging
from .handlers import (
    get_bundesliga_matches,
    get_epl_matches,
    get_europa_matches,
    get_liga_portugal_matches,
    get_ligue1_matches,
    get_swedish_matches,
    get_team_analysis,
    get_team_analysis_by_teams,
    get_laliga_matches,
    get_efl_cup_matches,
    get_seria_matches,
    get_eliteserien_matches,
    get_dutch_eredivisie_matches,
    get_uefa_cl_matches,
    get_turkish_matches,
    get_worldcup_q_matches,
    get_worldcup_qafrica_matches,
    get_worldcup_qasia_matches,
    get_scottish_matches,
    get_afcon2025,
)
logger = logging.getLogger(__name__)

@cache_matches()
def laliga_matches(request):
    """Return La Liga matches with their detail links"""
    result = get_laliga_matches()
    # Ensure it returns the full structure
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def epl_matches(request):
    """Return EPL matches with their detail links"""
    result = get_epl_matches()
    return JsonResponse(result)

@cache_matches()
def efl_cup_matches(request):
    """Return matches with their detail links"""
    result = get_efl_cup_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })


@cache_matches()
def seria_matches(request):
    """Return Serie A matches with their detail links"""
    result = get_seria_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def bundesliga_matches(request):
    """Return Bundesliga matches with their detail links"""
    result = get_bundesliga_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def eliteserien_matches(request):
    """Return Eliteserien matches with their detail links"""
    result = get_eliteserien_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })


@cache_matches()
def ligue1_matches(request):
    """Return Ligue 1 matches with their detail links"""
    result = get_ligue1_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def swedish_matches(request):
    """Return Swedish Allsvenskan matches with their detail links"""
    result = get_swedish_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def liga_portugal_matches(request):
    """Return Liga Portugal matches with their detail links"""
    result = get_liga_portugal_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def uefa_cl_matches(request):
    """Return UEFA Champions League matches with their detail links"""
    result = get_uefa_cl_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def dutch_eredivisie_matches(request):
    """Return Dutch Eredivisie matches with their detail links"""
    result = get_dutch_eredivisie_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def turkish_league_matches(request):
    """Return Turkish Super Lig matches with their detail links"""
    result = get_turkish_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })
    

@cache_matches()
def europa_league_matches(request):
    """Return UEFA Europa League matches with their detail links"""
    result = get_europa_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })
    
@cache_matches()
def worldcup_q_matches(request):
    """Return World Cup Qualification Europe matches with their detail links"""
    result = get_worldcup_q_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def worldcup_qafrica_matches(request):
    """Return World Cup Qualifiscation Africa matches with their detail links"""
    result = get_worldcup_qafrica_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()
def worldcup_qasia_matches(request):
    """Return World Cup Qualification Asia matches with their detail links"""
    result = get_worldcup_qasia_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })

@cache_matches()   
def scottish_premiership_matches(request):
    """Return Scottish Premiership matches with their detail links"""
    result = get_scottish_matches()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })
    
cache_matches()   
def afcon2025_matches(request):
    """Return African Cup of Nations matches with their detail links"""
    result = get_afcon2025()
    if isinstance(result, dict) and 'matches' in result:
        return JsonResponse(result)
    else:
        return JsonResponse({
            'matches': result,
            'message': f'Found {len(result)} matches' if result else 'No matches found',
            'available': bool(result)
        })


@cache_matches()
def team_analysis(request):
    """Get deep team analysis for a specific match URL"""
    match_url = request.GET.get('url')
    
    if not match_url:
        return JsonResponse({'error': 'Missing match URL parameter'}, status=400)
    
    try:
        analysis = get_team_analysis(match_url)
        return JsonResponse({'analysis': analysis})
        
    except Exception as e:
        return JsonResponse({
            'error': f'Failed to analyze match: {str(e)}'
        }, status=500)

@cache_matches()
def team_analysis_by_teams(request):
    """Get team analysis by providing team names and date"""
    home_team = request.GET.get('home_team')
    away_team = request.GET.get('away_team')
    date = request.GET.get('date')  # Format: 31-october-2025
    
    if not all([home_team, away_team, date]):
        return JsonResponse({
            'error': 'Missing parameters: home_team, away_team, and date are required'
        }, status=400)
    
    try:
        analysis = get_team_analysis_by_teams(home_team, away_team, date)
        return JsonResponse({'analysis': analysis})
        
    except Exception as e:
        return JsonResponse({
            'error': f'Failed to analyze match: {str(e)}'
        }, status=500)