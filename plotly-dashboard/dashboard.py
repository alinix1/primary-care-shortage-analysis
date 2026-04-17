import dash
from dash import dcc, html
import pandas as pd
import plotly.express as px
import json

# --- Load data ---
county_health = pd.read_csv('../data-processed/county_health_profile.csv')

# Load GeoJSON for county boundaries
with open('../data-raw/boundaries/geojson-counties-fips.json') as f:
    counties_geojson = json.load(f)

# County_fips is zero-padded string
county_health['COUNTY_FIPS'] = county_health['COUNTY_FIPS'].astype(str).str.zfill(5)

# --- Map 1: HPSA Severity ---
hpsa_order = ['Not Designated', 'Low', 'Moderate', 'High', 'Critical']
hpsa_colors = {
    'Not Designated': '#16A34A',
    'Low': '#22C55E',
    'Moderate': '#F59E0B',
    'High': '#EF4444',
    'Critical': '#7F1D1D'
}

fig_hpsa = px.choropleth(
    county_health,
    geojson=counties_geojson,
    locations='COUNTY_FIPS',
    color='HPSA_SEVERITY_TIER',
    color_discrete_map=hpsa_colors,
    category_orders={'HPSA_SEVERITY_TIER': hpsa_order},
    scope='usa',
    hover_name='COUNTY_NAME',
    hover_data={'STATE_ABBR': True, 'HPSA_SEVERITY_TIER': True, 'COUNTY_FIPS': False},
    labels={'HPSA_SEVERITY_TIER': 'PCP Shortage Severity'} 
)
fig_hpsa.update_layout(
    paper_bgcolor='#1E293B',
    geo_bgcolor='#1E293B',
    font_color='#F1F5F9',
    margin=dict(l=0, r=0, t=0, b=0),
    legend=dict(bgcolor='#1E293B', 
    font=dict(color='#F1F5F9'),
    title_text='PCP Shortage Severity',
    title_font=dict(color='#F1F5F9')
    ),

)

# --- Map 2: Disease Burden ---
disease_colors = {
    'Insufficient Data': '#475569',
    'Low': '#22C55E',
    'Moderate': '#F59E0B',
    'High': '#EF4444'
}

fig_disease = px.choropleth(
    county_health,
    geojson=counties_geojson,
    locations='COUNTY_FIPS',
    color='DISEASE_BURDEN_LEVEL',
    color_discrete_map=disease_colors,
    scope='usa',
    hover_name='COUNTY_NAME',
    hover_data={'STATE_ABBR': True, 'DISEASE_BURDEN_LEVEL': True, 'COUNTY_FIPS': False}, 
    labels={'DISEASE_BURDEN_LEVEL': 'Disease Burden Level'}
)
fig_disease.update_layout(
    paper_bgcolor='#1E293B',
    geo_bgcolor='#1E293B',
    font_color='#F1F5F9',
    margin=dict(l=0, r=0, t=0, b=0),
    legend=dict(bgcolor='#1E293B', 
    font=dict(color='#F1F5F9'), 
    title_text='Disease Burden Level',
    title_font=dict(color='#F1F5F9')            
     ),
)

# --- App setup ---
app = dash.Dash(__name__)

app.layout = html.Div(
    style={'backgroundColor': '#0F172A', 'minHeight': '100vh', 'padding': '20px'},
    children=[

        # Header
        html.Div(
            style={'backgroundColor': '#1E293B', 'padding': '16px', 'borderRadius': '8px', 'marginBottom': '16px', 'textAlign': 'center'},
            children=[
                html.H1('Primary Care Shortage Analysis | United States County-Level Data',
                        style={'color': '#F1F5F9', 'fontSize': '18px', 'margin': '0'})
            ]
        ),

        # KPI Cards row
        html.Div(
            style={'display': 'flex', 'gap': '12px', 'marginBottom': '16px'},
            children=[
                html.Div(style={'backgroundColor': '#1E293B', 'padding': '16px', 'borderRadius': '8px', 'flex': '1'},
                         children=[html.P('HPSA Designated Counties', style={'color': '#64748B', 'fontSize': '12px', 'margin': '0'}),
                                   html.H2('2,599', style={'color': '#38BDF8', 'margin': '4px 0 0'})]),
                html.Div(style={'backgroundColor': '#1E293B', 'padding': '16px', 'borderRadius': '8px', 'flex': '1'},
                         children=[html.P('High Priority Counties', style={'color': '#64748B', 'fontSize': '12px', 'margin': '0'}),
                                   html.H2('69', style={'color': '#38BDF8', 'margin': '4px 0 0'})]),
                html.Div(style={'backgroundColor': '#1E293B', 'padding': '16px', 'borderRadius': '8px', 'flex': '1'},
                         children=[html.P('Average Excess Stays (Top Quartile)', style={'color': '#64748B', 'fontSize': '12px', 'margin': '0'}),
                                   html.H2('+260.7', style={'color': '#38BDF8', 'margin': '4px 0 0'})]),
                html.Div(style={'backgroundColor': '#1E293B', 'padding': '16px', 'borderRadius': '8px', 'flex': '1'},
                         children=[html.P('Counties with High Disease Burden', style={'color': '#64748B', 'fontSize': '12px', 'margin': '0'}),
                                   html.H2('671', style={'color': '#38BDF8', 'margin': '4px 0 0'})]),
            ]
        ),

        # Maps row
        html.Div(
            style={'display': 'flex', 'gap': '12px', 'marginBottom': '16px'},
            children=[
                html.Div(
                    style={'backgroundColor': '#1E293B', 'padding': '16px', 'borderRadius': '8px', 'flex': '1'},
                    children=[
                        html.H3('PCP Shortage Severity by County', style={'color': '#94A3B8', 'fontSize': '13px', 'marginBottom': '8px'}),
                        dcc.Graph(id='map-hpsa', figure=fig_hpsa, config={'displayModeBar': False})
                    ]
                ),
                html.Div(
                    style={'backgroundColor': '#1E293B', 'padding': '16px', 'borderRadius': '8px', 'flex': '1'},
                    children=[
                        html.H3('Chronic Disease Burden by County', style={'color': '#94A3B8', 'fontSize': '13px', 'marginBottom': '8px'}),
                        dcc.Graph(id='map-disease', figure=fig_disease, config={'displayModeBar': False})
                    ]
                ),
            ]
        ),
    ]
)

if __name__ == '__main__':
    app.run(debug=True)