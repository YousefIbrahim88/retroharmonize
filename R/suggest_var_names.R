#' Suggest Variable Names
#' 
#' The function harmonizes the variable names of surveys (of class \code{survey}) that 
#' are imported from an external file as a wave.
#' 
#' @param metadata A metadata table created by \code{metadata_create} and binded together for 
#' all surveys in \code{waves}.
#' @param permanent_names A character vector of names to keep. 
#' @param survey_program If \code{permanent_names = NULL} then \code{\link{suggest_permanent_names}} is 
#' called with this parameter, unless it is also \code{NULL}
#' @param case Unless it is set to \code{NULL} it will standardize the suggested variable name with 
#' \code{\link[snakecase]{to_any_case}}. The default is \code{"snake"}.
#' @importFrom dplyr mutate left_join select
#' @importFrom tidyselect all_of
#' @importFrom purrr set_names
#' @importFrom assertthat assert_that
#' @import snakecase
#' @family harmonization functions
#' @return A \code{metadata} tibble augmented with $var_name_suggested
#' @examples
#' examples_dir <- system.file("examples", package = "retroharmonize")
#' survey_list <- dir(examples_dir)[grepl("\\.rds", dir(examples_dir))]
#' 
#' example_surveys <- read_surveys(
#'   file.path( examples_dir, survey_list), 
#'   save_to_rds = FALSE)

#' metadata <- lapply ( X = example_surveys, FUN = metadata_create )
#' metadata <- do.call(rbind, metadata)
#' 
#' suggest_var_names(metadata, survey_program = "eurobarometer" )
#' @export

suggest_var_names <- function( metadata, 
                               permanent_names = NULL, 
                               survey_program = NULL, 
                               case = "snake" ) {
  
  names_to_keep <- NULL
  recognized_survey_programs <- c("eurobarometer", "afrobarometer")
  
  paste(recognized_survey_programs, collapse = '", "')
  
  if (!is.null(survey_program)) {
    if ( survey_program %in% c("eurobarometer")) {
      
    } else {
      rsp <- paste(recognized_survey_programs, collapse = "' OR '")
      warning ( glue::glue("Currently only survey_program = '{rsp}' is recognized.") )
    }
  }
  
  return_metadata <- metadata %>%
    mutate ( var_name_suggested = ifelse ( 
      test = .data$var_name_orig %in% c("rowid", "wex", "w1", "isocntry"), 
      yes  = .data$var_name_orig, 
      no   = var_label_normalize(.data$label_orig)))
  
  if ( is.null(case) ) {
    return_metadata
  } else {
    return_metadata %>%
      mutate ( var_name_suggested = snakecase::to_any_case(string = .data$var_name_suggested , 
                                                           case = case ))
  }
} 

#' Suggest Permanent Names
#' 
#' Established survey programs usually have their own variable name conventions. 
#' The suggested constant names keep these variable names constant. 
#' @param survey_program Suggest permanent names for the survey progarm \code{"eurobarometer"}
#' @importFrom dplyr case_when
#' @return A character vector with suggested permanent names.
#' @examples suggest_permanent_names ( "eurobarometer" )
 
suggest_permanent_names <- function( survey_program = "eurobarometer") {
  
  ## Use generic ifelse, because different length should be returned
  
  if ( survey_program == "eurobarometer" ) {
    return(c("rowid", "wex", "w1", "isocntry")) 
  } else if ( survey_program == "afrobarometer") {
      return(NA_character_)
  }  else {
      return(NA_character_)
    }
}
