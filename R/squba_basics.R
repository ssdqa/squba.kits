
#' The Basics
#'
#' If you are interested in using squba but are not sure which modules to start
#' with, look no further! This kit is considered a basic "starter pack" for
#' squba analyses. All you need to do is configure the input files to tailor
#' the program to your study aims, and the function will take care of the rest.
#' This analysis includes 3 modules and will execute 5 total checks:
#' - Cohort Attrition || Exploratory, Cross-Sectional
#' - Patient Facts || Exploratory, Cross-Sectional
#' - Expected Variables Present || Exploratory, Cross-Sectional
#' - Expected Variables Present || Anomaly Detection, Cross-Sectional
#' - Expected Variables Present || Anomaly Detection, Longitudinal
#'
#' Note that single or multi-site selection is a global selection that will be controlled
#' in the function parameters and be applied across all executions.
#'
#' @param cohort *tabular input* || **required**
#'
#'   The cohort to be used for data quality testing. This table should contain,
#'   at minimum:
#'   - `site` | *character* | the name(s) of institutions included in your cohort
#'   - `person_id` / `patid` | *integer* / *character* | the patient identifier
#'   - `start_date` | *date* | the start of the cohort period
#'   - `end_date` | *date* | the end of the cohort period
#'
#'   Note that the start and end dates included in this table will be used to
#'   limit the search window for the analyses in this module.
#'
#' @param omop_or_pcornet *string* || **required**
#'
#'   A string, either `omop` or `pcornet`, indicating the CDM format of the data
#'
#' @param multi_or_single_site *string* || defaults to `single`
#'
#'   A string, either `single` or `multi`, indicating whether a single-site or
#'   multi-site analysis should be executed. This selection will be applied
#'   across all analyses executed in this kit.
#'
#' @param ca_input *tabular input* || **required**
#'
#'  A table or CSV file with attrition information for each site included in the cohort.
#'  This table should minimally contain:
#'  - `site` | *character* | the name of the institution
#'  - `step_number` | *integer* | a numeric identifier for the attrition step
#'  - `attrition_step` | *character* | a description of the attrition step
#'  - `num_pts` | *integer* | the patient count for the attrition step
#'
#' @param pf_input *tabular input* || **required**
#'
#'   A table that defines the fact domains to be investigated in the analysis. This
#'   input should contain:
#'   - `domain` | *character* | a string label for the domain being examined (i.e. prescription drugs)
#'   - `domain_tbl` | *character* | the CDM table where information for this domain can be found (i.e. drug_exposure)
#'   - `filter_logic` | *character* | logic to be applied to the domain_tbl in order to achieve the definition of interest; should be written as if you were applying it in a dplyr::filter command in R
#'
#' @param pf_visits *tabular input* || **required**
#'
#'   A table that defines visit types of interest called in `visit_types.` This input
#'   should contain:
#'   - `visit_concept_id` or `enc_type` | *integer* or *character* | the `visit_concept_id` or `enc_type` that represents the visit type of interest (i.e. 9201 or IP)
#'   - `visit_type` | *character* | the string label to describe the visit type
#'
#'   This information will be extracted either from the `visit_occurrence` (OMOP) or `encounter` (PCORnet) CDM tables. If you
#'   wish to extract visit information from other tables, please run the Patient Facts module on its own.
#'
#' @param evp_input *tabular input* || **required**
#'
#'   A table with information about each of the variables that should be examined
#'   in the analysis. This table should contain the following columns:
#'   - `variable` | *character* | a string label for the variable captured by the associated codeset
#'   - `domain_tbl` | *character* | the CDM table where the variable is found
#'   - `concept_field` | *character* | the string name of the field in the domain table where the concepts are located
#'   - `date_field` | *character* | the name of the field in the domain table with the date that should be used for temporal filtering
#'   - `vocabulary_field` | *character* | for PCORnet applications, the name of the field in the domain table with a vocabulary identifier to differentiate concepts from one another (ex: dx_type); can be set to NA for OMOP applications
#'   - `codeset_name` | *character* | the name of the codeset that defines the variable of interest
#'   - `filter_logic` | *character* | logic to be applied to the domain_tbl in order to achieve the definition of interest; should be written as if you were applying it in a dplyr::filter command in R
#'
#'   To see an example of the structure of this file, please see `?expectedvariablespresent::evp_variable_file_omop` or
#'   `?expectedvariablespresent::evp_variable_file_pcornet`
#'
#' @param evp_variable_filter *string or vector* || **required**
#'
#'   For the longitudinal analysis, we **HIGHLY RECOMMEND** choosing up to 3 of your variables
#'   for which the analysis should be executed. This is recommended in order to keep runtime low.
#'   The function will not error if you choose to select more than 3 variables, but please know
#'   this will take longer to process.
#'
#' @param time_period *string* || defaults to `year`
#'
#'   A string indicating the distance between dates within the specified time_span.
#'   Defaults to `year`, but other time periods such as `month` or `week` are
#'   also acceptable
#'
#' @param time_span *vector - length 2* || defaults to `c('2015-01-01', '2020-01-01')`
#'
#'   A vector indicating the lower and upper bounds of the time series for longitudinal analyses
#'
#' @returns
#'   This function will return a named list, with parent lists for each module and child
#'   lists for each check. It will contain 5 dataframes, one for each of the analyses
#'   executed in the kit. Each of these tables can be passed into the respective module's
#'   *_output function to produce visualizations.
#'
#' @import argos
#' @importFrom dplyr filter
#' @importFrom dplyr distinct
#' @importFrom dplyr pull
#' @importFrom dplyr ungroup
#' @importFrom stringr str_c
#'
#' @export
#'
#' @examples
#' # Cohort Input
#' my_cohort <- dplyr::tibble('site' = c('Site A', 'Site A', 'Site B'),
#'                            'person_id' = c(1, 2, 3),
#'                            'start_date' = c('2012-01-01', '2015-07-04',
#'                                             '2014-12-31'),
#'                            'end_date' = c('2018-01-01', '2020-07-04',
#'                                           '2025-12-31'))
#'
#' # Attrition Input
#' cohortattrition::sample_attrition
#'
#' # Expected Variables Present Input
#' expectedvariablespresent::evp_variable_file_omop
#' expectedvariablespresent::evp_variable_file_pcornet
#'
#' # Patient Facts Input
#' patientfacts::pf_domain_file
#' patientfacts::pf_visit_file_omop
#' patientfacts::pf_visit_file_pcornet
#'
#' \dontrun{
#' # Execute Function
#' squba_basics(cohort = my_cohort,
#'              omop_or_pcornet = 'omop' | 'pcornet',
#'              multi_or_single_site = 'multi' | 'single',
#'              ca_input = my_ca_file,
#'              evp_input = my_evp_file,
#'              pf_input = my_pf_domains,
#'              pf_visits = my_pf_visits)
#' }
#'
squba_basics <- function(cohort,
                         omop_or_pcornet,
                         multi_or_single_site,
                         ca_input,
                         pf_input,
                         pf_visits,
                         evp_input,
                         evp_variable_filter,
                         time_period = 'year',
                         time_span = c('2015-01-01', '2020-01-01')){

  if(length(evp_variable_filter) > 3){
    cli::cli_warn(str_c('We recommend limiting the longitudinal analysis to 3 or fewer variables to
                        maintain a reasonable runtime. This execution will pause for 5 seconds:
                        you may choose to either stop and adjust the filter or let it proceed.'))
  }
  if(length(evp_variable_filter) > 3){
    Sys.sleep(5)
  }

  if(multi_or_single_site == 'multi'){
    mss <- 'Multi-Site'
  }else{
    mss <- 'Single Site'
  }

  result_list <- list('Cohort Attrition' = NULL,
                      'Patient Facts' = NULL,
                      'Expected Variables Present' = NULL)

  ## Cohort Attrition (Exploratory, Cross-Sectional)
  cli::cli_alert_info(paste0('Cohort Attrition: ', mss, ', Exploratory, Cross-Sectional'))
  start_step <- ca_input %>%
    filter(step_number == min(step_number)) %>%
    distinct(step_number) %>%
    pull(step_number)

  name_build <- paste0(mss, ', Exploratory, Cross-Sectional')

  ca_exp_cs <- cohortattrition::ca_process(attrition_tbl = ca_input,
                                           multi_or_single_site = multi_or_single_site,
                                           anomaly_or_exploratory = 'exploratory',
                                           start_step_num = start_step)

  result_list$`Cohort Attrition`[[1]] <- ca_exp_cs
  names(result_list$`Cohort Attrition`) <- name_build

  ## Patient Facts (Exploratory, Cross-Sectional)
  cli::cli_alert_info(paste0('Patient Facts: ', mss, ', Exploratory, Cross-Sectional'))
  visit_filt <- pf_visits %>% distinct(visit_type) %>% pull()

  if(omop_or_pcornet == 'omop'){
    vtn <- 'visit_occurrence'
  }else{
    vtn <- 'encounter'
  }

  pf_exp_cs <- patientfacts::pf_process(cohort = cohort,
                                        omop_or_pcornet = omop_or_pcornet,
                                        multi_or_single_site = multi_or_single_site,
                                        anomaly_or_exploratory = 'exploratory',
                                        time = FALSE,
                                        domain_tbl = pf_input,
                                        visit_tbl = cdm_tbl(vtn),
                                        visit_type_table = pf_visits,
                                        visit_types = visit_filt,
                                        study_name = 'squba_basics')

  result_list$`Patient Facts`[[1]] <- pf_exp_cs
  names(result_list$`Patient Facts`) <- name_build

  ## Expected Variables Present (Exploratory, Cross-Sectional)
  cli::cli_alert_info(paste0('Expected Variables Present: ', mss, ', Exploratory, Cross-Sectional'))
  evp_exp_cs <- expectedvariablespresent::evp_process(cohort = cohort,
                                                      omop_or_pcornet = omop_or_pcornet,
                                                      multi_or_single_site = multi_or_single_site,
                                                      anomaly_or_exploratory = 'exploratory',
                                                      time = FALSE,
                                                      evp_variable_file = evp_input)

  result_list$`Expected Variables Present`[[1]] <- evp_exp_cs

  ## Expected Variables Present (Anomaly Detection, Cross-Sectional)
  cli::cli_alert_info(paste0('Expected Variables Present: ', mss, ', Anomaly Detection, Cross-Sectional'))
  name_build2 <- paste0(mss, ', Anomaly Detection, Cross-Sectional')

  evp_anom_cs <- expectedvariablespresent::evp_process(cohort = cohort,
                                                       omop_or_pcornet = omop_or_pcornet,
                                                       multi_or_single_site = multi_or_single_site,
                                                       anomaly_or_exploratory = 'anomaly',
                                                       time = FALSE,
                                                       evp_variable_file = evp_input)

  result_list$`Expected Variables Present`[[2]] <- evp_anom_cs

  ## Expected Variables Present (Anomaly Detection, Longitudinal)
  cli::cli_alert_info(paste0('Expected Variables Present: ', mss, ', Anomaly Detection, Longitudinal'))
  name_build3 <- paste0(mss, ', Anomaly Detection, Longitudinal')

  evp_anom_la <- expectedvariablespresent::evp_process(cohort = cohort,
                                                       omop_or_pcornet = omop_or_pcornet,
                                                       multi_or_single_site = multi_or_single_site,
                                                       anomaly_or_exploratory = 'anomaly',
                                                       time = TRUE,
                                                       time_period = time_period,
                                                       time_span = time_span,
                                                       output_level = 'patient',
                                                       evp_variable_file = evp_input %>%
                                                         filter(variable %in% evp_variable_filter))

  result_list$`Expected Variables Present`[[3]] <- evp_anom_la %>% ungroup()
  names(result_list$`Expected Variables Present`) <- c(name_build, name_build2, name_build3)

  ## Finish
  return(result_list)

}
