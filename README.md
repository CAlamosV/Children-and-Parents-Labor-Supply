## Estimating The Effect of Having Children on Labor Supply and Income
This repo follows [Angrist and Evans (1998)](http://piketty.pse.ens.fr/fichiers/enseig/ecoineg/articl/AngristEvans1998.pdf) and uses 1980 US census data to estimate the effect of having children on labor supply through an Instrumental Variables (IV) strategy.

### Project Structure

- `cleaning_and_analysis.R`: R script that processes the census data, performs the analysis, and generates the results.
- `cleaning_and_analysis.ipynb`: Jupyter Notebook that performs the same tasks.
- `utils.py`: Contains utility functions used throughout the analysis.

### Empirical Strategy
I exploit the fact that if the first two children in a family are of the same sex, the probability of having a third child is higher.
Using this exogenous variation in the number of children in a household, I use an IV approach to estimate the effect of having a third child on labor supply and income.
I report results separately for the full sample of women, married women, and married men.

The empirical specification is as follows:

First Stage:
```math
\text{ThreeOrMoreChildren}_i = \alpha_0 + \alpha_1 \cdot \text{SameSex}_i + \mathbf{X}_i' \beta + u_i
```

Second Stage:
```math
\text{Y}_i = \gamma_0 + \gamma_1 \cdot \hat{\text{ThreeOrMoreChildren}}_i + \mathbf{X}_i' \delta + \epsilon_i
```

Where:
- $\text{ThreeOrMoreChildren}_i$ is a binary variable indicating whether family $i$ has three or more children.
- $\text{Y}_i$ is the outcome for a parent in family $i$. This can be an indicator for labor force participation, hours worked per week, weeks worked per year, or annual labor income.
- $\hat{\text{ThreeOrMoreChildren}}_i$ is the predicted value from the first stage.
- $\text{SameSex}_i$ is the instrument for having three or more children.
- $\mathbf{X}_i$ is a vector of control variables including the mother's age, race, and age at birth of oldest child, as well as indicators for the gender of children.

The coefficient of interest is $\gamma_1$, which captures the causal effect of having three or more children on measures labor supply and income.

### Data
The data used is available for public use and can be downloaded at this [link](https://dataverse.harvard.edu/dataset.xhtml?persistentId=hdl:1902.1/11288) from the Harvard Dataverse (the filename is `m_d_806.tab`).

### Requirements
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
