# The Basics

If you are interested in using squba but are not sure which modules to
start with, look no further! This kit is considered a basic "starter
pack" for squba analyses. All you need to do is configure the input
files to tailor the program to your study aims, and the function will
take care of the rest. This analysis includes 3 modules and will execute
5 total checks:

- Cohort Attrition \|\| Exploratory, Cross-Sectional

- Patient Facts \|\| Exploratory, Cross-Sectional

- Expected Variables Present \|\| Exploratory, Cross-Sectional

- Expected Variables Present \|\| Anomaly Detection, Cross-Sectional

- Expected Variables Present \|\| Anomaly Detection, Longitudinal

## Usage

``` r
squba_basics(
  cohort,
  omop_or_pcornet,
  multi_or_single_site,
  ca_input,
  pf_input,
  pf_visits,
  evp_input,
  evp_variable_filter,
  time_period = "year",
  time_span = c("2015-01-01", "2020-01-01")
)
```

## Arguments

- cohort:

  *tabular input* \|\| **required**

  The cohort to be used for data quality testing. This table should
  contain, at minimum:

  - `site` \| *character* \| the name(s) of institutions included in
    your cohort

  - `person_id` / `patid` \| *integer* / *character* \| the patient
    identifier

  - `start_date` \| *date* \| the start of the cohort period

  - `end_date` \| *date* \| the end of the cohort period

  Note that the start and end dates included in this table will be used
  to limit the search window for the analyses in this module.

- omop_or_pcornet:

  *string* \|\| **required**

  A string, either `omop` or `pcornet`, indicating the CDM format of the
  data

- multi_or_single_site:

  *string* \|\| defaults to `single`

  A string, either `single` or `multi`, indicating whether a single-site
  or multi-site analysis should be executed. This selection will be
  applied across all analyses executed in this kit.

- ca_input:

  *tabular input* \|\| **required**

  A table or CSV file with attrition information for each site included
  in the cohort. This table should minimally contain:

  - `site` \| *character* \| the name of the institution

  - `step_number` \| *integer* \| a numeric identifier for the attrition
    step

  - `attrition_step` \| *character* \| a description of the attrition
    step

  - `num_pts` \| *integer* \| the patient count for the attrition step

- pf_input:

  *tabular input* \|\| **required**

  A table that defines the fact domains to be investigated in the
  analysis. This input should contain:

  - `domain` \| *character* \| a string label for the domain being
    examined (i.e. prescription drugs)

  - `domain_tbl` \| *character* \| the CDM table where information for
    this domain can be found (i.e. drug_exposure)

  - `filter_logic` \| *character* \| logic to be applied to the
    domain_tbl in order to achieve the definition of interest; should be
    written as if you were applying it in a dplyr::filter command in R

- pf_visits:

  *tabular input* \|\| **required**

  A table that defines visit types of interest called in `visit_types.`
  This input should contain:

  - `visit_concept_id` or `enc_type` \| *integer* or *character* \| the
    `visit_concept_id` or `enc_type` that represents the visit type of
    interest (i.e. 9201 or IP)

  - `visit_type` \| *character* \| the string label to describe the
    visit type

  This information will be extracted either from the `visit_occurrence`
  (OMOP) or `encounter` (PCORnet) CDM tables. If you wish to extract
  visit information from other tables, please run the Patient Facts
  module on its own.

- evp_input:

  *tabular input* \|\| **required**

  A table with information about each of the variables that should be
  examined in the analysis. This table should contain the following
  columns:

  - `variable` \| *character* \| a string label for the variable
    captured by the associated codeset

  - `domain_tbl` \| *character* \| the CDM table where the variable is
    found

  - `concept_field` \| *character* \| the string name of the field in
    the domain table where the concepts are located

  - `date_field` \| *character* \| the name of the field in the domain
    table with the date that should be used for temporal filtering

  - `vocabulary_field` \| *character* \| for PCORnet applications, the
    name of the field in the domain table with a vocabulary identifier
    to differentiate concepts from one another (ex: dx_type); can be set
    to NA for OMOP applications

  - `codeset_name` \| *character* \| the name of the codeset that
    defines the variable of interest

  - `filter_logic` \| *character* \| logic to be applied to the
    domain_tbl in order to achieve the definition of interest; should be
    written as if you were applying it in a dplyr::filter command in R

  To see an example of the structure of this file, please see
  [`?expectedvariablespresent::evp_variable_file_omop`](https://ssdqa.github.io/expectedvariablespresent/reference/evp_variable_file_omop.html)
  or
  [`?expectedvariablespresent::evp_variable_file_pcornet`](https://ssdqa.github.io/expectedvariablespresent/reference/evp_variable_file_pcornet.html)

- evp_variable_filter:

  *string or vector* \|\| **required**

  For the longitudinal analysis, we **HIGHLY RECOMMEND** choosing up to
  3 of your variables for which the analysis should be executed. This is
  recommended in order to keep runtime low. The function will not error
  if you choose to select more than 3 variables, but please know this
  will take longer to process.

- time_period:

  *string* \|\| defaults to `year`

  A string indicating the distance between dates within the specified
  time_span. Defaults to `year`, but other time periods such as `month`
  or `week` are also acceptable

- time_span:

  *vector - length 2* \|\| defaults to `c('2015-01-01', '2020-01-01')`

  A vector indicating the lower and upper bounds of the time series for
  longitudinal analyses

## Value

This function will return a named list, with parent lists for each
module and child lists for each check. It will contain 5 dataframes, one
for each of the analyses executed in the kit. Each of these tables can
be passed into the respective module's \*\_output function to produce
visualizations.

## Details

Note that single or multi-site selection is a global selection that will
be controlled in the function parameters and be applied across all
executions.

## Examples

``` r
# Cohort Input
my_cohort <- dplyr::tibble('site' = c('Site A', 'Site A', 'Site B'),
                           'person_id' = c(1, 2, 3),
                           'start_date' = c('2012-01-01', '2015-07-04',
                                            '2014-12-31'),
                           'end_date' = c('2018-01-01', '2020-07-04',
                                          '2025-12-31'))

# Attrition Input
cohortattrition::sample_attrition
#> # A tibble: 10 × 4
#>    site   step_number attrition_step                             num_pts
#>    <chr>        <dbl> <chr>                                        <dbl>
#>  1 site 1           0 All Patients                                 10900
#>  2 site 1           1 Patients with at least 2 visits since 2015    7800
#>  3 site 1           2 Patients with a T2DM diagnosis                2200
#>  4 site 1           3 Patients with an Hba1c lab                    2000
#>  5 site 1           4 Patients with an Hba1c result > 6.5%          1900
#>  6 site 2           0 All Patients                                 17000
#>  7 site 2           1 Patients with at least 2 visits since 2015   10500
#>  8 site 2           2 Patients with a T2DM diagnosis                5500
#>  9 site 2           3 Patients with an Hba1c lab                    5000
#> 10 site 2           4 Patients with an Hba1c result > 6.5%          4800

# Expected Variables Present Input
expectedvariablespresent::evp_variable_file_omop
#> # A tibble: 1 × 6
#>   variable         domain_tbl concept_field date_field codeset_name filter_logic
#>   <chr>            <chr>      <chr>         <chr>      <chr>        <lgl>       
#> 1 Sample OMOP Var… condition… condition_co… condition… dx_hyperten… NA          
expectedvariablespresent::evp_variable_file_pcornet
#> # A tibble: 1 × 7
#>   variable     domain_tbl concept_field date_field vocabulary_field codeset_name
#>   <chr>        <chr>      <chr>         <chr>      <chr>            <chr>       
#> 1 Sample PCOR… diagnosis  dx            admit_date dx_type          sample_code…
#> # ℹ 1 more variable: filter_logic <lgl>

# Patient Facts Input
patientfacts::pf_domain_file
#> # A tibble: 2 × 3
#>   domain             domain_tbl           filter_logic                    
#>   <chr>              <chr>                <chr>                           
#> 1 diagnoses          condition_occurrence NA                              
#> 2 prescription drugs drug_exposure        drug_type_concept_id == 38000177
patientfacts::pf_visit_file_omop
#> # A tibble: 8 × 2
#>   visit_concept_id visit_type
#>              <dbl> <chr>     
#> 1             9201 inpatient 
#> 2             9202 outpatient
#> 3             9203 emergency 
#> 4           581399 outpatient
#> 5             9201 all       
#> 6             9202 all       
#> 7             9203 all       
#> 8           581399 all       
patientfacts::pf_visit_file_pcornet
#> # A tibble: 8 × 2
#>   enc_type visit_type
#>   <chr>    <chr>     
#> 1 IP       inpatient 
#> 2 AV       outpatient
#> 3 ED       emergency 
#> 4 TH       outpatient
#> 5 IP       all       
#> 6 AV       all       
#> 7 ED       all       
#> 8 TH       all       

if (FALSE) { # \dontrun{
# Execute Function
squba_basics(cohort = my_cohort,
             omop_or_pcornet = 'omop' | 'pcornet',
             multi_or_single_site = 'multi' | 'single',
             ca_input = my_ca_file,
             evp_input = my_evp_file,
             pf_input = my_pf_domains,
             pf_visits = my_pf_visits)
} # }
```
