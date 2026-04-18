import dash
from dash import dcc, html
import pandas as pd
import plotly.express as px
import json

# --- Load data ---
county_health = pd.read_csv("../data-processed/county_health_profile.csv")

# Load GeoJSON for county boundaries
with open("../data-raw/boundaries/geojson-counties-fips.json") as f:
    counties_geojson = json.load(f)

# County_fips is zero-padded string
county_health["COUNTY_FIPS"] = county_health["COUNTY_FIPS"].astype(str).str.zfill(5)

# --- Map 1: HPSA Severity ---
hpsa_order = ["Not Designated", "Low", "Moderate", "High", "Critical"]
hpsa_colors = {
    "Not Designated": "#16A34A",
    "Low": "#22C55E",
    "Moderate": "#F59E0B",
    "High": "#EF4444",
    "Critical": "#7F1D1D",
}

fig_hpsa = px.choropleth(
    county_health,
    geojson=counties_geojson,
    locations="COUNTY_FIPS",
    color="HPSA_SEVERITY_TIER",
    color_discrete_map=hpsa_colors,
    category_orders={"HPSA_SEVERITY_TIER": hpsa_order},
    scope="usa",
    hover_name="COUNTY_NAME",
    hover_data={"STATE_ABBR": True, "HPSA_SEVERITY_TIER": True, "COUNTY_FIPS": False},
    labels={"HPSA_SEVERITY_TIER": "PCP Shortage Severity"},
)
fig_hpsa.update_layout(
    paper_bgcolor="#1E293B",
    geo_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=0, b=0),
    legend=dict(
        bgcolor="#1E293B",
        font=dict(color="#F1F5F9"),
        title_text="PCP Shortage Severity",
        title_font=dict(color="#F1F5F9"),
    ),
)

# --- Map 2: Disease Burden ---
disease_colors = {
    "Insufficient Data": "#475569",
    "Low": "#22C55E",
    "Moderate": "#F59E0B",
    "High": "#EF4444",
}

fig_disease = px.choropleth(
    county_health,
    geojson=counties_geojson,
    locations="COUNTY_FIPS",
    color="DISEASE_BURDEN_LEVEL",
    color_discrete_map=disease_colors,
    scope="usa",
    hover_name="COUNTY_NAME",
    hover_data={"STATE_ABBR": True, "DISEASE_BURDEN_LEVEL": True, "COUNTY_FIPS": False},
    labels={"DISEASE_BURDEN_LEVEL": "Disease Burden Level"},
)
fig_disease.update_layout(
    paper_bgcolor="#1E293B",
    geo_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=0, b=0),
    legend=dict(
        bgcolor="#1E293B",
        font=dict(color="#F1F5F9"),
        title_text="Disease Burden Level",
        title_font=dict(color="#F1F5F9"),
    ),
)

# --- Scatter Plot: Poverty Rate vs Excess Preventable Stays ---
fig_scatter = px.scatter(
    county_health,
    x="CHILDREN_IN_POVERTY_PCT",
    y="EXCESS_PREVENTABLE_STAYS",
    color="URBAN_RURAL_CATEGORY",
    hover_name="COUNTY_NAME",
    hover_data={
        "STATE_ABBR": True,
        "CHILDREN_IN_POVERTY_PCT": True,
        "EXCESS_PREVENTABLE_STAYS": True,
    },
    labels={
        "CHILDREN_IN_POVERTY_PCT": "Children in Poverty (%)",
        "EXCESS_PREVENTABLE_STAYS": "Excess Preventable Stays vs National Average",
        "URBAN_RURAL_CATEGORY": "Urban/Rural",
    },
    trendline="ols",
)
fig_scatter.update_layout(
    paper_bgcolor="#1E293B",
    plot_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=10, b=0),
    legend=dict(bgcolor="#1E293B", font=dict(color="#F1F5F9")),
    xaxis=dict(gridcolor="#334155"),
    yaxis=dict(gridcolor="#334155"),
)

# --- Bar Chart: FQHC Effectiveness by Shortage Status ---
fqhc_data = pd.DataFrame(
    {
        "FQHC_ACCESS_GROUP": [
            "Shortage + FQHC",
            "No Shortage + FQHC",
            "Shortage, No FQHC",
            "No Shortage, No FQHC",
        ],
        "AVG_EXCESS_STAYS": [36.3, -71.9, -157.2, -247.2],
        "COUNTY_COUNT": [1880, 177, 719, 181],
    }
)

fqhc_colors = {
    "Shortage + FQHC": "#EF4444",
    "No Shortage + FQHC": "#22C55E",
    "Shortage, No FQHC": "#F59E0B",
    "No Shortage, No FQHC": "#38BDF8",
}

fig_fqhc = px.bar(
    fqhc_data,
    x="AVG_EXCESS_STAYS",
    y="FQHC_ACCESS_GROUP",
    orientation="h",
    color="FQHC_ACCESS_GROUP",
    color_discrete_map=fqhc_colors,
    category_orders={
        "FQHC_ACCESS_GROUP": [
            "Shortage + FQHC",
            "No Shortage + FQHC",
            "Shortage, No FQHC",
            "No Shortage, No FQHC",
        ]
    },
    labels={
        "FQHC_ACCESS_GROUP": "",
        "AVG_EXCESS_STAYS": "Avg Excess Preventable Stays vs National Average",
    },
)
fig_fqhc.add_vline(
    x=0,
    line_dash="dash",
    line_color="#94A3B8",
)
fig_fqhc.update_layout(
    paper_bgcolor="#1E293B",
    plot_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=120, t=10, b=0),
    showlegend=False,
    height=250,
    xaxis=dict(gridcolor="#334155"),
    yaxis=dict(gridcolor="#334155"),
)

# --- Bar Chart: Excess Preventable Stays by HPSA Quartile ---
bar_data = pd.DataFrame(
    {
        "HPSA_QUARTILE": ["Q1 (Lowest)", "Q2", "Q3", "Q4 (Highest)"],
        "AVG_EXCESS_STAYS": [-221.3, -100.0, -13.0, 259.2],
    }
)

quartile_colors = {
    "Q1 (Lowest)": "#22C55E",
    "Q2": "#F59E0B",
    "Q3": "#EF4444",
    "Q4 (Highest)": "#7F1D1D",
}

fig_bar = px.bar(
    bar_data,
    x="AVG_EXCESS_STAYS",
    y="HPSA_QUARTILE",
    orientation="h",
    category_orders={"HPSA_QUARTILE": ["Q4 (Highest)", "Q3", "Q2", "Q1 (Lowest)"]},
    color="HPSA_QUARTILE",
    color_discrete_map=quartile_colors,
    labels={
        "HPSA_QUARTILE": "",
        "AVG_EXCESS_STAYS": "Avg Excess Preventable Stays vs National Average",
    },
)
fig_bar.add_vline(x=0, line_dash="dash", line_color="#94A3B8")
fig_bar.update_layout(
    paper_bgcolor="#1E293B",
    plot_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=10, b=0),
    showlegend=False,
    height=250,
    xaxis=dict(gridcolor="#334155"),
    yaxis=dict(gridcolor="#334155"),
)


# --- Scatter Plot: PCP Density vs Chronic Disease Prevalence ---
scatter_data = county_health[
    county_health["DISEASE_BURDEN_LEVEL"] != "Insufficient Data"
].copy()

disease_burden_colors = {"Low": "#22C55E", "Moderate": "#F59E0B", "High": "#EF4444"}

fig_scatter2 = px.scatter(
    scatter_data,
    x="PCP_PER_100K",
    y="EXCESS_PREVENTABLE_STAYS",
    color="DISEASE_BURDEN_LEVEL",
    color_discrete_map=disease_burden_colors,
    category_orders={"DISEASE_BURDEN_LEVEL": ["Low", "Moderate", "High"]},
    hover_name="COUNTY_NAME",
    hover_data={"STATE_ABBR": True, "PCP_PER_100K": True, "DISEASE_BURDEN_LEVEL": True},
    labels={
        "PCP_PER_100K": "PCPs per 100k Population",
        "EXCESS_PREVENTABLE_STAYS": "Excess Preventable Stays vs National Average",
        "DISEASE_BURDEN_LEVEL": "Disease Burden",
    },
    trendline="ols",
)
fig_scatter2.update_layout(
    paper_bgcolor="#1E293B",
    plot_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=10, b=0),
    legend=dict(
        bgcolor="#1E293B",
        font=dict(color="#F1F5F9"),
        title_text="Disease Burden",
        title_font=dict(color="#F1F5F9"),
    ),
    xaxis=dict(gridcolor="#334155"),
    yaxis=dict(gridcolor="#334155"),
)

# --- Bar Chart: HPSA Counties vs Chronic Disease Prevalence ---
conditions = [
    "Diabetes",
    "Heart Disease",
    "Obesity",
    "Hypertension",
    "COPD",
    "Depression",
]

hpsa_values = [11.33, 6.05, 37.81, 33.81, 7.12, 24.20]
non_hpsa_values = [9.98, 5.41, 36.32, 31.52, 6.02, 23.06]

disease_bar_data = pd.DataFrame(
    {
        "Condition": conditions * 2,
        "Avg_Pct": hpsa_values + non_hpsa_values,
        "HPSA_Status": ["HPSA Designated"] * 6 + ["Not Designated"] * 6,
    }
)

fig_disease_bar = px.bar(
    disease_bar_data,
    x="Condition",
    y="Avg_Pct",
    color="HPSA_Status",
    barmode="group",
    color_discrete_map={"HPSA Designated": "#EF4444", "Not Designated": "#22C55E"},
    labels={"Condition": "", "Avg_Pct": "Average Prevalence (%)", "HPSA_Status": ""},
)
fig_disease_bar.update_layout(
    paper_bgcolor="#1E293B",
    plot_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=10, b=0),
    legend=dict(bgcolor="#1E293B", font=dict(color="#F1F5F9")),
    xaxis=dict(gridcolor="#334155"),
    yaxis=dict(gridcolor="#334155"),
    bargap=0.3,
)

# --- App setup ---
app = dash.Dash(__name__)

app.layout = html.Div(
    style={"backgroundColor": "#0F172A", "minHeight": "100vh", "padding": "20px"},
    children=[
        # Header
        html.Div(
            style={
                "backgroundColor": "#1E293B",
                "padding": "16px",
                "borderRadius": "8px",
                "marginBottom": "16px",
                "textAlign": "center",
            },
            children=[
                html.H1(
                    "Primary Care Shortage Analysis | United States County-Level Data",
                    style={"color": "#F1F5F9", "fontSize": "18px", "margin": "0"},
                )
            ],
        ),
        # KPI Cards row
        html.Div(
            style={"display": "flex", "gap": "12px", "marginBottom": "16px"},
            children=[
                html.Div(
                    style={
                        "backgroundColor": "#1E293B",
                        "padding": "16px",
                        "borderRadius": "8px",
                        "flex": "1",
                    },
                    children=[
                        html.P(
                            "HPSA Designated Counties",
                            style={
                                "color": "#64748B",
                                "fontSize": "12px",
                                "margin": "0",
                            },
                        ),
                        html.H2(
                            "2,599", style={"color": "#38BDF8", "margin": "4px 0 0"}
                        ),
                    ],
                ),
                html.Div(
                    style={
                        "backgroundColor": "#1E293B",
                        "padding": "16px",
                        "borderRadius": "8px",
                        "flex": "1",
                    },
                    children=[
                        html.P(
                            "High Priority Counties",
                            style={
                                "color": "#64748B",
                                "fontSize": "12px",
                                "margin": "0",
                            },
                        ),
                        html.H2("69", style={"color": "#38BDF8", "margin": "4px 0 0"}),
                    ],
                ),
                html.Div(
                    style={
                        "backgroundColor": "#1E293B",
                        "padding": "16px",
                        "borderRadius": "8px",
                        "flex": "1",
                    },
                    children=[
                        html.P(
                            "Average Excess Stays (Top Quartile)",
                            style={
                                "color": "#64748B",
                                "fontSize": "12px",
                                "margin": "0",
                            },
                        ),
                        html.H2(
                            "+259.2", style={"color": "#38BDF8", "margin": "4px 0 0"}
                        ),
                    ],
                ),
                html.Div(
                    style={
                        "backgroundColor": "#1E293B",
                        "padding": "16px",
                        "borderRadius": "8px",
                        "flex": "1",
                    },
                    children=[
                        html.P(
                            "Counties with High Disease Burden",
                            style={
                                "color": "#64748B",
                                "fontSize": "12px",
                                "margin": "0",
                            },
                        ),
                        html.H2("671", style={"color": "#38BDF8", "margin": "4px 0 0"}),
                    ],
                ),
            ],
        ),
        # Maps row
        html.Div(
            style={"display": "flex", "gap": "12px", "marginBottom": "16px"},
            children=[
                html.Div(
                    style={
                        "backgroundColor": "#1E293B",
                        "padding": "16px",
                        "borderRadius": "8px",
                        "flex": "1",
                    },
                    children=[
                        html.H3(
                            "PCP Shortage Severity by County",
                            style={
                                "color": "#94A3B8",
                                "fontSize": "13px",
                                "marginBottom": "8px",
                            },
                        ),
                        dcc.Graph(
                            id="map-hpsa",
                            figure=fig_hpsa,
                            config={"displayModeBar": False},
                        ),
                    ],
                ),
                html.Div(
                    style={
                        "backgroundColor": "#1E293B",
                        "padding": "16px",
                        "borderRadius": "8px",
                        "flex": "1",
                    },
                    children=[
                        html.H3(
                            "Chronic Disease Burden by County",
                            style={
                                "color": "#94A3B8",
                                "fontSize": "13px",
                                "marginBottom": "8px",
                            },
                        ),
                        dcc.Graph(
                            id="map-disease",
                            figure=fig_disease,
                            config={"displayModeBar": False},
                        ),
                    ],
                ),
            ],
        ),
        # Scatter Plot 1
        html.Div(
            style={
                "backgroundColor": "#1E293B",
                "padding": "16px",
                "borderRadius": "8px",
                "marginBottom": "16px",
            },
            children=[
                html.H3(
                    "Poverty Rate vs Excess Preventable Stays by County",
                    style={
                        "color": "#94A3B8",
                        "fontSize": "13px",
                        "marginBottom": "8px",
                    },
                ),
                dcc.Graph(
                    id="scatter-poverty",
                    figure=fig_scatter,
                    config={"displayModeBar": False},
                ),
            ],
        ),
        # Bar Chart 1
        html.Div(
            style={
                "backgroundColor": "#1E293B",
                "padding": "16px",
                "borderRadius": "8px",
                "marginBottom": "16px",
            },
            children=[
                html.H3(
                    "FQHC Effectiveness by Shortage Status",
                    style={
                        "color": "#94A3B8",
                        "fontSize": "13px",
                        "marginBottom": "8px",
                    },
                ),
                dcc.Graph(
                    id="bar-fqhc", figure=fig_fqhc, config={"displayModeBar": False}
                ),
            ],
        ),
        # Bar Chart 3
        html.Div(
            style={
                "backgroundColor": "#1E293B",
                "padding": "16px",
                "borderRadius": "8px",
                "marginBottom": "16px",
            },
            children=[
                html.H3(
                    "Excess Preventable Stays by HPSA Shortage Quartile",
                    style={
                        "color": "#94A3B8",
                        "fontSize": "13px",
                        "marginBottom": "4px",
                    },
                ),
                html.P(
                    "HPSA score vs excess stays: r = 0.18 — counties in the highest shortage quartile average 259.2 excess stays above the national average",
                    style={
                        "color": "#64748B",
                        "fontSize": "11px",
                        "marginBottom": "8px",
                    },
                ),
                dcc.Graph(
                    id="bar-quartile", figure=fig_bar, config={"displayModeBar": False}
                ),
            ],
        ),
        # Scatter Plot 2
        html.Div(
            style={
                "backgroundColor": "#1E293B",
                "padding": "16px",
                "borderRadius": "8px",
                "marginBottom": "16px",
            },
            children=[
                html.H3(
                    "PCP Density vs Excess Preventable Stays by Disease Burden Level",
                    style={
                        "color": "#94A3B8",
                        "fontSize": "13px",
                        "marginBottom": "4px",
                    },
                ),
                html.P(
                    "Overall r = -0.155 (PCP density vs excess stays)",
                    style={
                        "color": "#64748B",
                        "fontSize": "11px",
                        "marginBottom": "8px",
                    },
                ),
                dcc.Graph(
                    id="scatter-pcp",
                    figure=fig_scatter2,
                    config={"displayModeBar": False},
                ),
            ],
        ),
        # Bar chart 3
        html.Div(
            style={
                "backgroundColor": "#1E293B",
                "padding": "16px",
                "borderRadius": "8px",
                "marginBottom": "16px",
            },
            children=[
                html.H3(
                    "Chronic Disease Prevalence: HPSA vs Non-HPSA Counties",
                    style={
                        "color": "#94A3B8",
                        "fontSize": "13px",
                        "marginBottom": "4px",
                    },
                ),
                html.P(
                    "HPSA-designated counties show higher prevalence across all 6 conditions",
                    style={
                        "color": "#64748B",
                        "fontSize": "11px",
                        "marginBottom": "8px",
                    },
                ),
                dcc.Graph(
                    id="bar-disease",
                    figure=fig_disease_bar,
                    config={"displayModeBar": False},
                ),
            ],
        ),
    ],
)

if __name__ == "__main__":
    app.run(debug=True)
