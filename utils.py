import numpy as np
import pandas as pd
from IPython.display import display, HTML
from linearmodels.iv import IV2SLS

# Function to format estimates with asterisks based on p-values
def format_estimates(result, param):
    est = result.params[param]
    se = result.std_errors[param]
    pval = result.pvalues[param]
    
    # Determine significance level and assign stars
    if pval < 0.001:
        stars = "***"
    elif pval < 0.01:
        stars = "**"
    elif pval < 0.05:
        stars = "*"
    else:
        stars = ""
    
    return f"{est:.2f}{stars}<br>({se:.2f})"

# Function to convert DataFrame to an HTML table with styling
def df_to_table(df):
    # Convert the DataFrame to HTML with centered text
    html = df.to_html(escape=False, index=False)
    
    # Add CSS style to center everything and apply LaTeX-like font
    html = f"""
    <style>
        table {{margin-left: auto; margin-right: auto; text-align: center; font-family: 'CMU Serif', 'Computer Modern Roman', serif;}}
        th, td {{text-align: center;}}
    </style>
    <link href="https://cdn.jsdelivr.net/npm/cmu-serif-font@1.1.0/css/cmu-serif.min.css" rel="stylesheet">
    {html}
    """
    # Display the table as HTML
    display(HTML(html))

# Function to run IV regressions and collect formatted results
def run_iv_regressions(data, outcomes, covariates, instrumented, instrument):
    results = []
    for outcome in outcomes:
        # Prepare the data
        y = data[outcome]
        X = data[covariates]
        endog = data[instrumented]
        instr = data[instrument]
        
        # Remove missing values
        df_reg = pd.concat([y, X, endog, instr], axis=1).dropna()
        y = df_reg[outcome]
        X = df_reg[covariates]
        endog = df_reg[instrumented]
        instr = df_reg[instrument]
        
        # Run the 2SLS regression
        model = IV2SLS(y, X, endog, instr).fit()
        
        # Format the estimate
        formatted_estimate = format_estimates(model, instrumented)
        
        results.append(formatted_estimate)
    return results