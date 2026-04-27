# alltips_scraper/prediction_adjuster.py - FULLY CORRECTED VERSION

from typing import Dict, List, Optional
from datetime import datetime
import re


class PredictionAdjuster:
    """Prediction adjuster with proper null/not found handling"""
    
    @staticmethod
    def calculate_match_stats(home_score: int, away_score: int) -> Dict:
        return {
            'home_score': home_score,
            'away_score': away_score,
            'total_goals': home_score + away_score,
            'both_scored': home_score > 0 and away_score > 0,
            'winner': 'home' if home_score > away_score else 'away' if away_score > home_score else 'draw',
        }
    
    @staticmethod
    def detect_prediction_type(prediction: str) -> str:
        pred_lower = prediction.lower()
        if 'win or draw' in pred_lower or 'to win or draw' in pred_lower:
            return 'double_chance'
        if 'win to nil' in pred_lower:
            return 'win_to_nil'
        if 'to win' in pred_lower and '&' not in pred_lower and 'draw' not in pred_lower:
            return 'win'
        if 'over' in pred_lower or 'under' in pred_lower:
            return 'over_under'
        if ('both teams to score' in pred_lower or 'btts' in pred_lower) and ('&' in pred_lower or 'win' in pred_lower):
            return 'btts_win'
        if 'both teams to score' in pred_lower or 'btts' in pred_lower:
            return 'btts'
        return 'unknown'
    
    @staticmethod
    def extract_team_from_prediction(prediction: str) -> Optional[str]:
        pred = prediction.strip()
        for pattern in [
            r'^(.+?)\s+to win to nil$',
            r'^(.+?)\s+to win$',
            r'^(.+?)\s+&\s+BTTS$',
        ]:
            match = re.match(pattern, pred, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None

    # ── Individual Adjustment Functions ─────────────────────────────────────────

    @staticmethod
    def adjust_win_to_nil(prediction: str, match_stats: Dict, team: str, match_found: bool = True) -> Dict:
        if not match_found or not match_stats:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': None,
                    'was_adjusted': False, 'explanation': 'Match result not found - keeping original'}

        home_score = match_stats['home_score']
        away_score = match_stats['away_score']
        winner = match_stats['winner']

        team_won = winner in ('home', 'away')
        kept_clean_sheet = (winner == 'home' and away_score == 0) or (winner == 'away' and home_score == 0)
        was_correct = team_won and kept_clean_sheet

        if was_correct:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': True,
                    'was_adjusted': False, 'explanation': f'Correct! {team} won {home_score}-{away_score} with clean sheet'}

        if winner == 'draw':
            adjusted = f"{team} to win or draw"
            explanation = f'Match was a draw {home_score}-{away_score}. Try double chance: {adjusted}'
        elif winner == 'home':
            adjusted = "Home Win"
            explanation = f'Home team won {home_score}-{away_score}'
        else:
            adjusted = "Away Win"
            explanation = f'Away team won {home_score}-{away_score}'

        if match_stats['both_scored'] and winner != 'draw':
            adjusted += " & BTTS"
            explanation += " with both teams scoring"

        return {'original': prediction, 'adjusted': adjusted, 'was_correct': False,
                'was_adjusted': True, 'explanation': explanation}

    @staticmethod
    def adjust_win(prediction: str, match_stats: Dict, team: str, match_found: bool = True) -> Dict:
        if not match_found or not match_stats:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': None,
                    'was_adjusted': False, 'explanation': 'Match result not found - keeping original'}

        home_score = match_stats['home_score']
        away_score = match_stats['away_score']
        winner = match_stats['winner']
        was_correct = (winner == 'home')

        if was_correct:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': True,
                    'was_adjusted': False, 'explanation': f'Correct! {team} won {home_score}-{away_score}'}
        elif winner == 'draw':
            adjusted = f"{team} to win or draw"
            return {'original': prediction, 'adjusted': adjusted, 'was_correct': False,
                    'was_adjusted': True, 'explanation': f'Match was a draw {home_score}-{away_score}. Try double chance: {adjusted}'}
        else:
            adjusted = "Home Win" if winner == 'home' else "Away Win"
            return {'original': prediction, 'adjusted': adjusted, 'was_correct': False,
                    'was_adjusted': True, 'explanation': f'Incorrect. Final: {home_score}-{away_score}. Changed to: {adjusted}'}

    @staticmethod
    def adjust_over_under(prediction: str, match_stats: Dict, match_found: bool = True) -> Dict:
        if not match_found or not match_stats:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': None,
                    'was_adjusted': False, 'explanation': 'Match result not found - keeping original'}

        total_goals = match_stats['total_goals']
        match = re.search(r'(\d+\.?\d*)', prediction)
        line = float(match.group(1)) if match else 2.5
        is_over = 'over' in prediction.lower()
        was_correct = total_goals > line if is_over else total_goals < line
        adjusted = prediction if was_correct else (f"Over {line}" if not is_over else f"Under {line} Goals")

        if was_correct:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': True,
                    'was_adjusted': False, 'explanation': f'Correct! Total goals: {total_goals}'}
        return {'original': prediction, 'adjusted': adjusted, 'was_correct': False,
                'was_adjusted': True, 'explanation': f'Incorrect. Total goals: {total_goals}. Changed to: {adjusted}'}

    @staticmethod
    def adjust_btts(prediction: str, match_stats: Dict, match_found: bool = True) -> Dict:
        if not match_found or not match_stats:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': None,
                    'was_adjusted': False, 'explanation': 'Match result not found - keeping original'}

        both_scored = match_stats['both_scored']
        home_score = match_stats['home_score']
        away_score = match_stats['away_score']

        if both_scored:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': True,
                    'was_adjusted': False, 'explanation': f'Correct! Both teams scored ({home_score}-{away_score})'}
        return {'original': prediction, 'adjusted': 'Both Teams to Score - No', 'was_correct': False,
                'was_adjusted': True, 'explanation': f'Incorrect. Final: {home_score}-{away_score}. Changed to: Both Teams to Score - No'}

    @staticmethod
    def adjust_btts_win(prediction: str, match_stats: Dict, home_team: str, away_team: str, match_found: bool = True) -> Dict:
        if not match_found or not match_stats:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': None,
                    'was_adjusted': False, 'explanation': 'Match result not found - keeping original'}

        both_scored = match_stats['both_scored']
        home_score = match_stats['home_score']
        away_score = match_stats['away_score']
        winner = match_stats['winner']
        pred_lower = prediction.lower()

        predicted_team = None
        predicted_team_name = None
        if home_team.lower() in pred_lower:
            predicted_team, predicted_team_name = 'home', home_team
        elif away_team.lower() in pred_lower:
            predicted_team, predicted_team_name = 'away', away_team

        team_won = (predicted_team == 'home' and winner == 'home') or (predicted_team == 'away' and winner == 'away')
        was_correct = team_won and both_scored

        if was_correct:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': True,
                    'was_adjusted': False,
                    'explanation': f'Correct! {predicted_team_name} won {home_score}-{away_score} and both teams scored'}

        btts_str = 'BTTS' if both_scored else 'BTTS No'
        if winner == 'home':
            adjusted = f"{home_team} Win & {btts_str}"
            explanation = f"{home_team} won {home_score}-{away_score}" + (" and both scored" if both_scored else " with no BTTS")
        elif winner == 'away':
            adjusted = f"{away_team} Win & {btts_str}"
            explanation = f"{away_team} won {home_score}-{away_score}" + (" and both scored" if both_scored else " with no BTTS")
        else:
            adjusted = f"Draw & {btts_str}"
            explanation = f"Match ended {home_score}-{away_score} draw"

        return {'original': prediction, 'adjusted': adjusted, 'was_correct': False,
                'was_adjusted': True, 'explanation': explanation}

    # ── FIX 1: was outside class, now correctly indented inside ─────────────────

    @staticmethod
    def adjust_double_chance(prediction: str, match_stats: Dict, home_team: str, away_team: str, match_found: bool = True) -> Dict:
        if not match_found or not match_stats:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': None,
                    'was_adjusted': False, 'explanation': 'Match result not found - keeping original'}

        home_score = match_stats['home_score']
        away_score = match_stats['away_score']
        winner = match_stats['winner']
        pred_lower = prediction.lower()  # ← FIX 2: was 'pred_lover' (typo)

        predicted_team = None
        if home_team.lower() in pred_lower:
            predicted_team = 'home'
        elif away_team.lower() in pred_lower:
            predicted_team = 'away'

        was_correct = (predicted_team == 'home' and winner in ('home', 'draw')) or \
                      (predicted_team == 'away' and winner in ('away', 'draw'))

        if was_correct:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': True,
                    'was_adjusted': False,
                    'explanation': f'Correct! {predicted_team.upper()} won or drew ({home_score}-{away_score})'}

        if winner == 'home':
            adjusted = f"{home_team} to win or draw"
            explanation = f"Home team won {home_score}-{away_score}. Try {home_team} double chance"
        elif winner == 'away':
            adjusted = f"{away_team} to win or draw"
            explanation = f"Away team won {home_score}-{away_score}. Try {away_team} double chance"
        else:
            adjusted = f"{home_team} to win or draw OR {away_team} to win or draw"
            explanation = f"Match was a draw {home_score}-{away_score}. Either team double chance would have won"

        return {'original': prediction, 'adjusted': adjusted, 'was_correct': False,
                'was_adjusted': True, 'explanation': explanation}

    # ── FIX 1 (continued): was outside class, now correctly indented inside ─────

    @staticmethod
    def adjust_win_to_draw_no_loss(prediction: str, match_stats: Dict, team: str, match_found: bool = True) -> Dict:
        if not match_found or not match_stats:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': None,
                    'was_adjusted': False, 'explanation': 'Match result not found - keeping original'}

        home_score = match_stats['home_score']
        away_score = match_stats['away_score']
        winner = match_stats['winner']
        pred_lower = prediction.lower()

        predicted_team = 'home' if 'home' in pred_lower else 'away' if 'away' in pred_lower else None
        was_correct = (predicted_team == 'home' and winner == 'home') or \
                      (predicted_team == 'away' and winner == 'away')

        if was_correct:
            return {'original': prediction, 'adjusted': prediction, 'was_correct': True,
                    'was_adjusted': False, 'explanation': f'Correct! Team won {home_score}-{away_score}'}
        elif winner == 'draw':
            base = prediction.split(' to win')[0]
            adjusted = f"{base} to win or draw"
            return {'original': prediction, 'adjusted': adjusted, 'was_correct': False,
                    'was_adjusted': True,
                    'explanation': f'Match was a draw {home_score}-{away_score}. Try double chance: {adjusted}'}
        else:
            adjusted = "Home Win" if winner == 'home' else "Away Win"
            return {'original': prediction, 'adjusted': adjusted, 'was_correct': False,
                    'was_adjusted': True,
                    'explanation': f'Incorrect. Final: {home_score}-{away_score}. Changed to: {adjusted}'}


# ── Main Processing Function ─────────────────────────────────────────────────

def verify_predictions(data: Dict, match_results: Dict[str, Dict], accumulator_type: str) -> Dict:
    print(f"\n[PredictionAdjuster] ========== VERIFICATION START ==========")
    print(f"[PredictionAdjuster] Accumulator type: {accumulator_type}")

    matches = data.get('matches', [])
    print(f"[PredictionAdjuster] Total matches: {len(matches)}")

    verified_count = 0
    adjusted_count = 0

    for idx, match in enumerate(matches, 1):
        teams = match.get('teams', [])
        prediction = match.get('prediction', '')

        print(f"\n[PredictionAdjuster] --- Match {idx}/{len(matches)} ---")
        print(f"[PredictionAdjuster] Teams: {teams}")
        print(f"[PredictionAdjuster] Original prediction: {prediction}")

        if len(teams) >= 2:
            match_key = f"{teams[0]}|{teams[1]}"
            match_result = match_results.get(match_key)
            match_found = match_result and match_result.get('found', False)

            if match_found:
                verified_count += 1
                print(f"[PredictionAdjuster] ✓ Match found!")
                print(f"[PredictionAdjuster]   Actual: {match_result.get('score')}")

                match_stats = PredictionAdjuster.calculate_match_stats(
                    match_result['home_score'],
                    match_result['away_score']
                )

                match.update({
                    'actual_score': match_result['score'],
                    'actual_home_score': match_result['home_score'],
                    'actual_away_score': match_result['away_score'],
                    'total_goals': match_result['total_goals'],
                    'verified': True,
                    'match_found': True,
                })

                pred_type = PredictionAdjuster.detect_prediction_type(prediction)
                team = PredictionAdjuster.extract_team_from_prediction(prediction) or teams[0]

                if pred_type == 'double_chance':
                    adjustment = PredictionAdjuster.adjust_double_chance(prediction, match_stats, teams[0], teams[1], True)
                elif pred_type == 'win_to_nil':
                    adjustment = PredictionAdjuster.adjust_win_to_nil(prediction, match_stats, team, True)
                elif pred_type == 'win':
                    if match_stats['winner'] == 'draw':
                        adjustment = PredictionAdjuster.adjust_win_to_draw_no_loss(prediction, match_stats, team, True)
                    else:
                        adjustment = PredictionAdjuster.adjust_win(prediction, match_stats, team, True)
                elif pred_type == 'over_under':
                    adjustment = PredictionAdjuster.adjust_over_under(prediction, match_stats, True)
                elif pred_type == 'btts':
                    adjustment = PredictionAdjuster.adjust_btts(prediction, match_stats, True)
                elif pred_type == 'btts_win':
                    adjustment = PredictionAdjuster.adjust_btts_win(prediction, match_stats, teams[0], teams[1], True)
                else:
                    adjustment = {'original': prediction, 'adjusted': prediction, 'was_correct': None,
                                  'was_adjusted': False, 'explanation': f'Unknown type: {prediction}'}

                match['adjustment'] = adjustment

                if adjustment.get('was_adjusted', False):
                    adjusted_count += 1
                    match['original_prediction'] = prediction
                    match['prediction'] = adjustment['adjusted']
                    print(f"[PredictionAdjuster]   ❌ Changed to: {adjustment['adjusted']}")
                else:
                    print(f"[PredictionAdjuster]   ✅ CORRECT")

            else:
                print(f"[PredictionAdjuster] ✗ Match NOT found - keeping original")
                match.update({'verified': False, 'match_found': False, 'verification_error': 'Match not found'})

    data.update({
        'verified': True,
        'processed_at': datetime.now().isoformat(),
        'verification_summary': {
            'total_matches': len(matches),
            'verified_matches': verified_count,
            'adjusted_matches': adjusted_count,
            'not_found_matches': len(matches) - verified_count,
        }
    })

    print(f"\n[PredictionAdjuster] Summary: {verified_count} found, {adjusted_count} adjusted\n")
    return data