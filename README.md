## Estimating The Effect of Having Children on Labor Supply

This repository replicates the study from [Angrist and Evans (1998)](http://piketty.pse.ens.fr/fichiers/enseig/ecoineg/articl/AngristEvans1998.pdf), estimating the effect of having children on labor supply using U.S. 1980 Census data and an Instrumental Variables (IV) approach. Specifically, the study uses sibling-sex composition as an instrument for having three or more children.

### Project Structure:

- cleaning_and_analysis.R: R script that processes the census data, performs the analysis, and generates the results.
- cleaning_and_analysis.ipynb: Jupyter Notebook that performs similar tasks as the R script but with Python and R integration.
- utils.py: Contains utility functions used throughout the analysis.

### Empirical Strategy:

We use a sibling-sex composition instrument, following the approach of Angrist and Evans (1998), to estimate the causal effect of having three or more children on labor supply. The instrument exploits the fact that families where the first two children are of the same sex are more likely to have a third child.

First Stage:
The first stage estimates the likelihood of having three or more children based on the sex composition of the first two children:
\text{ThreeOrMoreChildren}_i = \alpha_0 + \alpha_1 \cdot \text{SameSex}_i + \mathbf{X}_i' \beta + u_i

Second Stage:
The second stage uses the predicted value from the first stage to estimate the effect of having three or more children on labor supply outcomes:
\text{Y}_i = \gamma_0 + \gamma_1 \cdot \hat{\text{ThreeOrMoreChildren}}_i + \mathbf{X}_i' \delta + \epsilon_i

Where:
- ThreeOrMoreChildren_i is a binary variable indicating whether family *i* has three or more children.
- SameSex_i is the instrument for having three or more children.
- Y_i is the labor supply outcome (e.g., labor force participation, hours worked per week, or annual labor income).
- X_i is a vector of control variables, including mother's age, race, and the age and gender of the children.

### Data:

The analysis is based on U.S. 1980 Census data, which can be accessed from the Harvard Dataverse here: https://dataverse.harvard.edu/dataset.xhtml?persistentId=hdl:1902.1/11288. The filename of the dataset is m_d_806.tab.

Before running the analysis, download the dataset and place it in the data/ directory.

How to Run:

1. For R:
   - Open the cleaning_and_analysis.R script.
   - Ensure the data file (m_d_806.tab) is in the data/ directory.
   - Run the script using your preferred R environment (e.g., RStudio).

2. For Jupyter Notebook:
   - Open the cleaning_and_analysis.ipynb notebook.
   - Ensure the dataset is in the data/ directory.
   - Execute the cells to perform data cleaning and analysis.

### Requirements:

The project requires the following libraries:

- For R:
  - dplyr
  - AER
  - car
  - lmtest
  - sandwich
  - kableExtra

- For Python (if running the Jupyter notebook):
  - pandas
  - numpy
  - statsmodels
  - rpy2 (for R integration)
"""
# Children-and-Parents-Labor-Supply
