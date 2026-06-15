import dash
from dash import dcc, html, dash_table
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from sklearn.preprocessing import MinMaxScaler
import json

# --- Load data ---
county_health = pd.read_csv("../data-processed/county_health_profile.csv")
priority_counties = pd.read_csv("../data-processed/priority_counties_ranking.csv")
access = pd.read_csv("../data-processed/access_impact_analysis.csv")

# GeoJSON for county boundaries
with open("../data-raw/boundaries/geojson-counties-fips.json") as f:
    counties_geojson = json.load(f)

# County_fips is zero-padded string
county_health["COUNTY_FIPS"] = county_health["COUNTY_FIPS"].astype(str).str.zfill(5)
priority_counties["COUNTY_FIPS"] = (
    priority_counties["COUNTY_FIPS"].astype(str).str.zfill(5)
)
access["COUNTY_FIPS"] = access["COUNTY_FIPS"].astype(str).str.zfill(5)


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
    color_discrete_map={
        'Rural': '#6366F1',
        'Micropolitan': '#F97316',
        'Metro': '#10B981'
    },
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
        "AVG_EXCESS_STAYS": [86.5, -70.4, -142.8, -249.4],
        "COUNTY_COUNT": [2024, 192, 742, 186],
    }
)

fqhc_colors = {
    "Shortage + FQHC": "#F87171",
    "No Shortage + FQHC": "#34D399",
    "Shortage, No FQHC": "#FBBF24",
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
        "AVG_EXCESS_STAYS": [-183.2, -88.6, 45, 333.9],
    }
)

quartile_colors = {
    "Q1 (Lowest)": "#38BDF8",
    "Q2": "#FBBF24",
    "Q3": "#34D399",
    "Q4 (Highest)": "#F87171",
}

fig_bar = px.bar(
    bar_data,
    x="HPSA_QUARTILE",
    y="AVG_EXCESS_STAYS",
    category_orders={"HPSA_QUARTILE": ["Q1 (Lowest)", "Q2", "Q3", "Q4 (Highest)"]},
    color="HPSA_QUARTILE",
    color_discrete_map=quartile_colors,
    labels={
        "HPSA_QUARTILE": "",
        "AVG_EXCESS_STAYS": "Avg Excess Preventable Stays vs National Average",
    },
)
fig_bar.add_hline(y=0, line_dash="dash", line_color="#94A3B8")
fig_bar.update_layout(
    paper_bgcolor="#1E293B",
    plot_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=10, b=0),
    showlegend=False,
    height=400,
    xaxis=dict(gridcolor="#334155"),
    yaxis=dict(gridcolor="#334155"),
)

fig_bar.update_traces(width=0.5)

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
    "Stroke",
]

hpsa_values = [11.33, 6.05, 37.81, 33.81, 7.12, 3.32]
non_hpsa_values = [9.98, 5.41, 36.32, 31.52, 6.02, 2.88]

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
    color_discrete_map={"HPSA Designated": "#F87171", "Not Designated": "#34D399"},
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

# --- Heatmap: Triple Burden Counties by State ---
triple_burden = county_health[
    (county_health["IS_HPSA_DESIGNATED"] == 1)
    & (county_health["DISEASE_BURDEN_LEVEL"] == "High")
    & (county_health["ABOVE_NATIONAL_AVG_HOSP"] == 1)
].copy()

triple_burden = (
    triple_burden.merge(
        access[["COUNTY_FIPS", "VULNERABILITY_SCORE", "SHORTAGE_GROUP"]],
        on="COUNTY_FIPS",
        how="left",
    )
    .sort_values(
        ["VULNERABILITY_SCORE", "EXCESS_PREVENTABLE_STAYS"], ascending=[False, False]
    )
    .head(25)
)
# --- Heatmap: Triple Burden Counties by State ---
heatmap_cols = [
    "EXCESS_PREVENTABLE_STAYS",
    "HPSA_SCORE",
    "UNINSURED_PCT",
    "CHILDREN_IN_POVERTY_PCT",
]

heatmap_data = triple_burden.groupby("STATE_ABBR")[heatmap_cols].mean().round(1)

scaler = MinMaxScaler()
heatmap_normalized = pd.DataFrame(
    scaler.fit_transform(heatmap_data),
    columns=heatmap_data.columns,
    index=heatmap_data.index,
)

# Build text labels from actual values
text_labels = heatmap_data.values.tolist()

fig_heatmap = go.Figure(
    data=go.Heatmap(
        z=heatmap_normalized.values,
        x=["Excess Stays", "HPSA Score", "Uninsured %", "Child Poverty %"],
        y=heatmap_data.index.tolist(),
        colorscale="RdYlGn_r",
        showscale=False,
        text=text_labels,
        texttemplate="%{text}",
        textfont=dict(size=11, color="white"),
        hovertemplate="State: %{y}<br>Metric: %{x}<br>Value: %{text}<extra></extra>",
    )
)

fig_heatmap.update_layout(
    paper_bgcolor="#1E293B",
    plot_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=10, b=0),
    xaxis=dict(side="bottom"),
    yaxis=dict(autorange="reversed"),
)

# --- Bar Chart: Geographic Distribution ---
regional = pd.read_csv("../data-processed/regional_patterns.csv")
regional["PCT_AFFECTED"] = (
    regional["HIGH_BURDEN_COUNTIES"] / regional["TOTAL_COUNTIES"] * 100
).round(1)
regional = (
    regional[regional["HIGH_BURDEN_COUNTIES"] > 0]
    .sort_values("HIGH_BURDEN_COUNTIES", ascending=False)
    .head(15)
)

fig_geo = px.bar(
    regional,
    x="HIGH_BURDEN_COUNTIES",
    y="STATE_ABBR",
    orientation="h",
    color="AVG_EXCESS_STAYS",
    color_continuous_scale=["#22C55E", "#F59E0B", "#EF4444"],
    labels={
        "HIGH_BURDEN_COUNTIES": "Counties with Shortage + High Disease Burden",
        "STATE_ABBR": "",
        "AVG_EXCESS_STAYS": "Avg Excess Stays",
    },
    hover_data={"PCT_AFFECTED": True, "AVG_EXCESS_STAYS": True},
)
fig_geo.update_layout(
    paper_bgcolor="#1E293B",
    plot_bgcolor="#1E293B",
    font_color="#F1F5F9",
    margin=dict(l=0, r=0, t=10, b=0),
    xaxis=dict(gridcolor="#334155"),
    yaxis=dict(gridcolor="#334155", categoryorder="total ascending"),
    coloraxis_colorbar=dict(
        title=dict(text="Avg Excess Stays", font=dict(color="#F1F5F9")),
        tickfont=dict(color="#F1F5F9"),
    ),
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
                            "2,766", style={"color": "#38BDF8", "margin": "4px 0 0"}
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
                        html.H2("63", style={"color": "#38BDF8", "margin": "4px 0 0"}),
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
                            "346", style={"color": "#38BDF8", "margin": "4px 0 0"}
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
                    "Counties in the highest shortage quartile average ~346 excess stays above the national average",
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
        # Heat map 1
        html.Div(
            style={
                "backgroundColor": "#1E293B",
                "padding": "16px",
                "borderRadius": "8px",
                "marginBottom": "16px",
            },
            children=[
                html.H3(
                    "Triple Burden Counties: Risk Profile of Most Vulnerable States",
                    style={
                        "color": "#94A3B8",
                        "fontSize": "13px",
                        "marginBottom": "4px",
                    },
                ),
                html.P(
                    "Average metrics across the 25 highest-vulnerability triple burden counties by state — darker red = worse outcomes",
                    style={
                        "color": "#64748B",
                        "fontSize": "11px",
                        "marginBottom": "8px",
                    },
                ),
                dcc.Graph(
                    id="heatmap-triple",
                    figure=fig_heatmap,
                    config={"displayModeBar": False},
                ),
            ],
        ),
        # Bar chart 4
        html.Div(
            style={
                "backgroundColor": "#1E293B",
                "padding": "16px",
                "borderRadius": "8px",
                "marginBottom": "16px",
            },
            children=[
                html.H3(
                    "Top 15 States: Counties with PCP Shortage + High Disease Burden",
                    style={
                        "color": "#94A3B8",
                        "fontSize": "13px",
                        "marginBottom": "4px",
                    },
                ),
                html.P(
                    "Color intensity shows avg excess preventable stays — West Virginia has highest burden per county",
                    style={
                        "color": "#64748B",
                        "fontSize": "11px",
                        "marginBottom": "8px",
                    },
                ),
                dcc.Graph(
                    id="bar-geo", figure=fig_geo, config={"displayModeBar": False}
                ),
            ],
        ),
    ],
)

if __name__ == "__main__":
    app.run(debug=True)
