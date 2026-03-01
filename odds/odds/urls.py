from django.contrib import admin
from django.urls import path
from alltips_scraper import views
from league_scraper.views import (
    europa_league_matches,
    laliga_matches,
    ligue1_matches,
    scottish_premiership_matches,
    swedish_matches,
    team_analysis,
    team_analysis_by_teams,
    epl_matches,
    efl_cup_matches,
    seria_matches,
    bundesliga_matches,
    eliteserien_matches,
    liga_portugal_matches,
    turkish_league_matches,
    uefa_cl_matches,
    dutch_eredivisie_matches,
    worldcup_q_matches,
    worldcup_qafrica_matches,
    worldcup_qasia_matches,
    afcon2025_matches
)


from alltips_scraper.views import (
    anytime_goalscorer,
    bet_of_the_day,
    daily_accumulator,
    btts_win_accumulator,
    over_25_goals_accumulator,
    both_teams_to_score,
)

from customers.views import (
    revenuecat_webhook,
    check_subscription_status,
    contact_us,
)


urlpatterns = [
    path('admin/', admin.site.urls),
    #getting leagues and tips
    path('api/laliga-matches/', laliga_matches, name='laliga_matches'),
    path('api/epl-matches/', epl_matches, name='epl_matches'),
    path('api/efl-cup-matches/', efl_cup_matches, name='efl_cup_matches'),
    path('api/serie-a-matches/', seria_matches, name='seria_matches'),
    path('api/bundesliga-matches/', bundesliga_matches, name='bundesliga_matches'),
    path('api/ligue1-matches/', ligue1_matches, name='ligue1_matches'),
    path('api/eliteserien-matches/', eliteserien_matches, name='eliteserien_matches'),
    path('api/swedish-allsvenskan/', swedish_matches, name='swedish_matches'),
    path('api/liga-portugal-matches/', liga_portugal_matches, name='liga_portugal_matches'),
    path('api/uefa-cl-matches/', uefa_cl_matches, name='uefa_cl_matches'),
    path('api/dutch-eredivisie-matches/', dutch_eredivisie_matches, name='dutch_eredivisie_matches'),
    path('api/turkish-super-lig-matches/', turkish_league_matches, name='turkish_league_matches'),
    path('api/europa-league-matches/', europa_league_matches, name='europa_league_matches'),
    path('api/worldcup-qualification-matches/', worldcup_q_matches, name='worldcup_q_matches'),
    path('api/worldcup-qualification-africa-matches/', worldcup_qafrica_matches, name='worldcup_qafrica_matches'),
    path('api/worldcup-qualification-asia-matches/', worldcup_qasia_matches, name='worldcup_qasia_matches'),
    path('api/scottish-premiership-matches/', scottish_premiership_matches, name='scottish_premiership_matches'),
    path('api/afcon-2025-matches/', afcon2025_matches, name='afcon2025_matches'),


    #gettings alltips &prediction part
    path('api/bet-of-the-day/', bet_of_the_day, name='bet_of_the_day'),
    path('api/daily-accumulator/', daily_accumulator, name='daily_accumulator'),
    path('api/btts-win-accumulator/', btts_win_accumulator, name='btts_win_accumulator'),
    path('api/over-25-goals-accumulator/', over_25_goals_accumulator, name='over_25_goals_accumulator'),
    path('api/BTTS/', both_teams_to_score, name='both_teams_to_score'),
    path('api/goalscorer/', anytime_goalscorer, name='anytime_goalscorer'),

    #subscription and premium features
    path('api/subscription/status/', check_subscription_status, name='subscription-status'),
    # path('api/premium/feature/', premium_feature, name='premium-feature'),

    path('api/revenuecat-webhook/', revenuecat_webhook, name='revenuecat-webhook'),

    # path('api/auth/convert/', convert_anonymous_to_real_user, name='convert-user'),

    path('api/contact-us/', contact_us, name='contact-us'),

    path('api/match/team-analysis/', team_analysis, name='team_analysis'),
    path('api/match/team-analysis/by-teams/', team_analysis_by_teams, name='team_analysis_by_teams'),
]
