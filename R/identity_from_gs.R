#' Gets IDENTITY data and cleans up based on parameters
#' @param gsheet_name exact name of the Google Sheet that has the IDENTITY table. If there are more than 1 Google Sheets with this name, an error will be returned. An "IDENTITY_ID" column is required.
#' @param gsheet_tab name of the Google Sheet tab that has the IDENTITY table.
#' @param keep_all_cols TRUE if all the variables are wanted in the output. Otherwise, only the target_cols will be selected.
#' @param include_duplicates TRUE if all the duplicates are desired in the output
#' @param dont_trimws TRUE if white spaces on both the left and right side are not desired in the output
#' @param remove_all character string of length 1 representing the string of artifact and other values to be removed from the final output separated by the OR operator 
#' @import mirCat
#' @import somersaulteR
#' @importFrom reshape2 melt
#' @import dplyr
#' @export

identity_from_gs <-
        function(gsheet_name,
                 gsheet_tab,
                 target_cols,
                 keep_all_cols = FALSE,
                 dont_trimws = FALSE,
                 remove_all = "\t|\n",
                 include_duplicates = FALSE,
                 log = TRUE) {
                
                IDENTITY_TARGET_COLS <- target_cols
                IDENTITY_00 <- mirCat::gs_read_tmp_csv(gsheet_name, tab = gsheet_tab) %>%
                                somersaulteR::call_mr_clean()
                
                if (keep_all_cols == TRUE) {
                        IDENTITY_01 <- IDENTITY_01
                } else {
                        IDENTITY_01 <-
                                IDENTITY_00 %>%
                                dplyr::select(IDENTITY_TARGET_COLS)
                }
                
                if (dont_trimws == TRUE) {
                        IDENTITY_02 <- IDENTITY_01
                } else {
                        IDENTITY_02 <-
                                IDENTITY_01 %>%
                                dplyr::mutate_all(trimws, "both")
                }
                
                if (remove_all == ""|is.null(remove_all)) {
                        IDENTITY_03 <-
                                IDENTITY_02 
                } else {
                        IDENTITY_03 <-
                                IDENTITY_02 %>%
                                dplyr::mutate_all(stringr::str_remove_all, remove_all)
                }
                
                
                IDENTITY_04 <-
                        reshape2::melt(IDENTITY_03, id.vars = "IDENTITY_ID", variable.name = "KEY_FIELD", value.name = "KEY_CONCEPT_NAME") %>%
                        dplyr::mutate_all(as.character) %>%
                        dplyr::mutate(KEY_FIELD = str_replace_all(KEY_FIELD, "^PERMISSIBLE_VALUE_LABEL$", "KMI_PERMISSIBLE_VALUE_LABEL"))
                
                if (include_duplicates == TRUE) {
                        IDENTITY_05 <- IDENTITY_04
                } else {
                        IDENTITY_05 <-
                                IDENTITY_04 %>%
                                dplyr::distinct()
                }
                
                if (log == TRUE) {
                        mirCat::log_this_as(project_log_dir = "GoogleSheets",
                                            project_log_load_comment = "cartographR package IDENTITY data",
                                            #project_log_fn = basename(path_to_identity),
                                            #project_log_fn_md5sum = tools::md5sum(basename(path_to_identity)),
                                            project_log_load_timestamp = mirroR::get_timestamp(),
                                            project_log_gsheet_title = gsheet_name,
                                            project_log_gsheet_tab_name = gsheet_tab,
                                            project_log_gsheet_key = mirCat::gs_id_from_name(gsheet_name)
                        )
                }
                
                return(IDENTITY_05)
        }