rm(list = ls())
library(readxl)
library(openxlsx)
library(dplyr)
library(tidyr)
library(atRfunctions)


### Load data -------------------------------------------------------------------
emis_1718 <- read_xlsx_sheets("./input/EMIS/2017_2018/EMIS_2017_2018.xlsx")
emis_2019 <- read_xlsx_sheets("./input/EMIS/EMIS_Reshaped/1.Students_Data_reshaped.xlsx")
emis_2021 <- read_xlsx_sheets("./Input/EMIS/EMIS_Reshaped/EMIS_2021_Students_Data_reshaped.xlsx")
emis_2022 <- read_xlsx_sheets("./input/EMIS/2022/UNICEF School Census - School level Data May 25 2023.xlsx")

# names(emis_1718)
# names(emis_2019)
# names(emis_2021)
# names(emis_2022)


## Prepare dfs
emis_1718$`1396` <- emis_1718$`1396` %>% 
  mutate(
    ProvinceEngName = case_when(
      ProvinceEngName %in% c("Kabul City", "Kabul Province") ~ "Kabul",
      TRUE ~ ProvinceEngName
    ),
    DistrictEngName = case_when(
      grepl("Nahia", DistrictEngName) ~ "Kabul",
      TRUE ~ DistrictEngName
    ),
    # Enrollment 1 to 12 Grade
    TotalMaleEnroll_1_to_12 = rowSums(across(c(MaleEnrollGrade1, MaleEnrollGrade2, MaleEnrollGrade3, MaleEnrollGrade4,
                                               MaleEnrollGrade5, MaleEnrollGrade6, MaleEnrollGrade7, MaleEnrollGrade8,
                                               MaleEnrollGrade9, MaleEnrollGrade10, MaleEnrollGrade11, MaleEnrollGrade12)), na.rm = T),
    TotalFemaleEnroll_1_to_12 = rowSums(across(c(FemaleEnrollGrade1, FemaleEnrollGrade2, FemaleEnrollGrade3, FemaleEnrollGrade4,
                                                 FemaleEnrollGrade5, FemaleEnrollGrade6, FemaleEnrollGrade7, FemaleEnrollGrade8,
                                                 FemaleEnrollGrade9, FemaleEnrollGrade10, FemaleEnrollGrade11, FemaleEnrollGrade12)), na.rm = T),
    TotalEnroll_1_to_12 = rowSums(across(c(TotalMaleEnroll_1_to_12, TotalFemaleEnroll_1_to_12)), na.rm = T),
    
    # Attendance 1 - 1 to 12 Grade
    TotalMaleAttended1_1_to_12 = rowSums(across(c(Exam_MaleRegistered_Grade_1, Exam_MaleRegistered_Grade_2, Exam_MaleRegistered_Grade_3, Exam_MaleRegistered_Grade_4,
                                                  Exam_MaleRegistered_Grade_5, Exam_MaleRegistered_Grade_6, Exam_MaleRegistered_Grade_7, Exam_MaleRegistered_Grade_8,
                                                  Exam_MaleRegistered_Grade_9, Exam_MaleRegistered_Grade_10, Exam_MaleRegistered_Grade_11, Exam_MaleRegistered_Grade_12)), na.rm = T),
    
    
    TotalFemaleAttended1_1_to_12 = rowSums(across(c(Exam_FemaleRegistered_Grade_1, Exam_FemaleRegistered_Grade_2, Exam_FemaleRegistered_Grade_3, Exam_FemaleRegistered_Grade_4,
                                                    Exam_FemaleRegistered_Grade_5, Exam_FemaleRegistered_Grade_6, Exam_FemaleRegistered_Grade_7, Exam_FemaleRegistered_Grade_8,
                                                    Exam_FemaleRegistered_Grade_9, Exam_FemaleRegistered_Grade_10, Exam_FemaleRegistered_Grade_11, Exam_FemaleRegistered_Grade_12)), na.rm = T),
    
    
    TotalAttended1_1_to_12 = rowSums(across(c(TotalMaleAttended1_1_to_12, TotalFemaleAttended1_1_to_12)), na.rm = T),
    
    Result_1_12 = case_when(
      TotalEnroll_1_to_12 > TotalAttended1_1_to_12 ~ "Enroll More than Attend",
      TotalEnroll_1_to_12 == TotalAttended1_1_to_12 ~ "Equal",
      TotalEnroll_1_to_12 < TotalAttended1_1_to_12 ~ "Enroll Less than Attend"
    ),
    
    # Total enroll male student - Primary (1 - 6 Grades)
    TotalMaleEnroll_primary = rowSums(across(c(MaleEnrollGrade1, MaleEnrollGrade2, MaleEnrollGrade3, 
                                               MaleEnrollGrade4, MaleEnrollGrade5, MaleEnrollGrade6)), na.rm = T),
    # Total enroll male student - Secondary (7 - 9 Grades)
    TotalMaleEnroll_secondary = rowSums(across(c(MaleEnrollGrade7, MaleEnrollGrade8, MaleEnrollGrade9)), na.rm = T),
    # Total enroll male student - High Secondary (10 - 12 Grades)
    TotalMaleEnroll_high_secondary = rowSums(across(c(MaleEnrollGrade10, MaleEnrollGrade11, MaleEnrollGrade12)), na.rm = T),
    
    
    # Total enroll female student - Primary (1 - 6 Grades)
    TotalFemaleEnroll_primary = rowSums(across(c(FemaleEnrollGrade1, FemaleEnrollGrade2, FemaleEnrollGrade3, 
                                                 FemaleEnrollGrade4, FemaleEnrollGrade5, FemaleEnrollGrade6)), na.rm = T),
    # Total enroll female student - Secondary (7 - 9 Grades)
    TotalFemaleEnroll_secondary = rowSums(across(c(FemaleEnrollGrade7, FemaleEnrollGrade8, FemaleEnrollGrade9)), na.rm = T),
    # Total enroll female student - High Secondary (10 - 12 Grades)
    TotalFemaleEnroll_high_secondary = rowSums(across(c(FemaleEnrollGrade10, FemaleEnrollGrade11, FemaleEnrollGrade12)), na.rm = T),
    
    
    # Total enroll all - Primary (male and female)
    TotalEnroll_primary = rowSums(across(c(TotalMaleEnroll_primary, TotalFemaleEnroll_primary)), na.rm = T),
    # Total enroll all - Secondary (male and female)
    TotalEnroll_secondary = rowSums(across(c(TotalMaleEnroll_secondary, TotalFemaleEnroll_secondary)), na.rm = T),
    # Total enroll all - High Secondary (male and female)
    TotalEnroll_high_secondary = rowSums(across(c(TotalMaleEnroll_high_secondary, TotalFemaleEnroll_high_secondary)), na.rm = T),
    
    
    # Test
    Test = case_when(
      TotalEnroll_1_to_12 == rowSums(across(c(TotalMaleEnroll_primary, TotalMaleEnroll_secondary, TotalMaleEnroll_high_secondary,
                                              TotalFemaleEnroll_primary, TotalFemaleEnroll_secondary, TotalFemaleEnroll_high_secondary)), na.rm = T) ~ "TRUE",
      TRUE ~ "FASLE"
    ),
    
    # Total Attend male student - Primary (1 - 6 Grades)
    TotalMaleAttend_primary = rowSums(across(c(Exam_MaleRegistered_Grade_1, Exam_MaleRegistered_Grade_2, Exam_MaleRegistered_Grade_3, 
                                               Exam_MaleRegistered_Grade_4, Exam_MaleRegistered_Grade_5, Exam_MaleRegistered_Grade_6)), na.rm = T),
    
    # Total Attend male student - Secondary (7 - 9 Grades)
    TotalMaleAttend_secondary = rowSums(across(c(Exam_MaleRegistered_Grade_7, Exam_MaleRegistered_Grade_8, Exam_MaleRegistered_Grade_9)), na.rm = T),
    
    # Total Attend male student - High Secondary (10 - 12 Grades)
    TotalMaleAttend_high_secondary = rowSums(across(c(Exam_MaleRegistered_Grade_10, Exam_MaleRegistered_Grade_11, Exam_MaleRegistered_Grade_12)), na.rm = T),
    
    
    # Total Attend female student - Primary (1 - 6 Grades)
    TotalFemaleAttend_primary = rowSums(across(c(Exam_FemaleRegistered_Grade_1, Exam_FemaleRegistered_Grade_2, Exam_FemaleRegistered_Grade_3, 
                                                 Exam_FemaleRegistered_Grade_4, Exam_FemaleRegistered_Grade_5, Exam_FemaleRegistered_Grade_6)), na.rm = T),
    
    # Total Attend female student - Secondary (7 - 9 Grades)
    TotalFemaleAttend_secondary = rowSums(across(c(Exam_FemaleRegistered_Grade_7, Exam_FemaleRegistered_Grade_8, Exam_FemaleRegistered_Grade_9)), na.rm = T),
    
    # Total Attend female student - High Secondary (10 - 12 Grades)
    TotalFemaleAttend_high_secondary = rowSums(across(c(Exam_FemaleRegistered_Grade_10, Exam_FemaleRegistered_Grade_11, Exam_FemaleRegistered_Grade_12)), na.rm = T),
    
    
    # Total Attend all - Primary (male and female)
    TotalAttend_primary = rowSums(across(c(TotalMaleAttend_primary, TotalFemaleAttend_primary)), na.rm = T),
    # Total Attend all - Secondary (male and female)
    TotalAttend_secondary = rowSums(across(c(TotalMaleAttend_secondary, TotalFemaleAttend_secondary)), na.rm = T),
    # Total Attend all - High Secondary (male and female)
    TotalAttend_high_secondary = rowSums(across(c(TotalMaleAttend_high_secondary, TotalFemaleAttend_high_secondary)), na.rm = T),
    
    
    
    Test_attend = case_when(
      TotalAttended1_1_to_12 == rowSums(across(c(TotalMaleAttend_primary, TotalMaleAttend_secondary, TotalMaleAttend_high_secondary,
                                                 TotalFemaleAttend_primary, TotalFemaleAttend_secondary, TotalFemaleAttend_high_secondary)), na.rm = T) ~ "TRUE",
      TRUE ~ "FASLE"
    )
  )

# Enrollment and Attendance comparison -- Less == Enrollment less than Attendance
round(prop.table(table(emis_1718$`1396`$Result_1_12)) * 100, 1)


emis_1718$`1397` <- emis_1718$`1397` %>% 
  mutate(
    ProvinceEngName = case_when(
      ProvinceEngName %in% c("Kabul City", "Kabul Province") ~ "Kabul",
      TRUE ~ ProvinceEngName
    ),
    DistrictEngName = case_when(
      grepl("Nahia", DistrictEngName) ~ "Kabul",
      TRUE ~ DistrictEngName
    ),
    # Enrollment 1 to 12 Grade
    TotalMaleEnroll_1_to_12 = rowSums(across(c(MaleEnrollGrade1, MaleEnrollGrade2, MaleEnrollGrade3, MaleEnrollGrade4,
                                               MaleEnrollGrade5, MaleEnrollGrade6, MaleEnrollGrade7, MaleEnrollGrade8,
                                               MaleEnrollGrade9, MaleEnrollGrade10, MaleEnrollGrade11, MaleEnrollGrade12)), na.rm = T),
    TotalFemaleEnroll_1_to_12 = rowSums(across(c(FemaleEnrollGrade1, FemaleEnrollGrade2, FemaleEnrollGrade3, FemaleEnrollGrade4,
                                                 FemaleEnrollGrade5, FemaleEnrollGrade6, FemaleEnrollGrade7, FemaleEnrollGrade8,
                                                 FemaleEnrollGrade9, FemaleEnrollGrade10, FemaleEnrollGrade11, FemaleEnrollGrade12)), na.rm = T),
    TotalEnroll_1_to_12 = rowSums(across(c(TotalMaleEnroll_1_to_12, TotalFemaleEnroll_1_to_12)), na.rm = T),
    
    # Attendance 1 - 1 to 12 Grade
    TotalMaleAttended1_1_to_12 = rowSums(across(c(Exam_MaleRegistered_Grade_1, Exam_MaleRegistered_Grade_2, Exam_MaleRegistered_Grade_3, Exam_MaleRegistered_Grade_4,
                                                  Exam_MaleRegistered_Grade_5, Exam_MaleRegistered_Grade_6, Exam_MaleRegistered_Grade_7, Exam_MaleRegistered_Grade_8,
                                                  Exam_MaleRegistered_Grade_9, Exam_MaleRegistered_Grade_10, Exam_MaleRegistered_Grade_11, Exam_MaleRegistered_Grade_12)), na.rm = T),
    
    
    TotalFemaleAttended1_1_to_12 = rowSums(across(c(Exam_FemaleRegistered_Grade_1, Exam_FemaleRegistered_Grade_2, Exam_FemaleRegistered_Grade_3, Exam_FemaleRegistered_Grade_4,
                                                    Exam_FemaleRegistered_Grade_5, Exam_FemaleRegistered_Grade_6, Exam_FemaleRegistered_Grade_7, Exam_FemaleRegistered_Grade_8,
                                                    Exam_FemaleRegistered_Grade_9, Exam_FemaleRegistered_Grade_10, Exam_FemaleRegistered_Grade_11, Exam_FemaleRegistered_Grade_12)), na.rm = T),
    
    
    TotalAttended1_1_to_12 = rowSums(across(c(TotalMaleAttended1_1_to_12, TotalFemaleAttended1_1_to_12)), na.rm = T),
    
    Result_1_12 = case_when(
      TotalEnroll_1_to_12 > TotalAttended1_1_to_12 ~ "Enroll More than Attend",
      TotalEnroll_1_to_12 == TotalAttended1_1_to_12 ~ "Equal",
      TotalEnroll_1_to_12 < TotalAttended1_1_to_12 ~ "Enroll Less than Attend"
    ),
    
    # Total enroll male student - Primary (1 - 6 Grades)
    TotalMaleEnroll_primary = rowSums(across(c(MaleEnrollGrade1, MaleEnrollGrade2, MaleEnrollGrade3, 
                                               MaleEnrollGrade4, MaleEnrollGrade5, MaleEnrollGrade6)), na.rm = T),
    # Total enroll male student - Secondary (7 - 9 Grades)
    TotalMaleEnroll_secondary = rowSums(across(c(MaleEnrollGrade7, MaleEnrollGrade8, MaleEnrollGrade9)), na.rm = T),
    # Total enroll male student - High Secondary (10 - 12 Grades)
    TotalMaleEnroll_high_secondary = rowSums(across(c(MaleEnrollGrade10, MaleEnrollGrade11, MaleEnrollGrade12)), na.rm = T),
    
    
    # Total enroll female student - Primary (1 - 6 Grades)
    TotalFemaleEnroll_primary = rowSums(across(c(FemaleEnrollGrade1, FemaleEnrollGrade2, FemaleEnrollGrade3, 
                                                 FemaleEnrollGrade4, FemaleEnrollGrade5, FemaleEnrollGrade6)), na.rm = T),
    # Total enroll female student - Secondary (7 - 9 Grades)
    TotalFemaleEnroll_secondary = rowSums(across(c(FemaleEnrollGrade7, FemaleEnrollGrade8, FemaleEnrollGrade9)), na.rm = T),
    # Total enroll female student - High Secondary (10 - 12 Grades)
    TotalFemaleEnroll_high_secondary = rowSums(across(c(FemaleEnrollGrade10, FemaleEnrollGrade11, FemaleEnrollGrade12)), na.rm = T),
    
    
    # Total enroll all - Primary (male and female)
    TotalEnroll_primary = rowSums(across(c(TotalMaleEnroll_primary, TotalFemaleEnroll_primary)), na.rm = T),
    # Total enroll all - Secondary (male and female)
    TotalEnroll_secondary = rowSums(across(c(TotalMaleEnroll_secondary, TotalFemaleEnroll_secondary)), na.rm = T),
    # Total enroll all - High Secondary (male and female)
    TotalEnroll_high_secondary = rowSums(across(c(TotalMaleEnroll_high_secondary, TotalFemaleEnroll_high_secondary)), na.rm = T),
    
    
    # Test
    Test = case_when(
      TotalEnroll_1_to_12 == rowSums(across(c(TotalMaleEnroll_primary, TotalMaleEnroll_secondary, TotalMaleEnroll_high_secondary,
                                              TotalFemaleEnroll_primary, TotalFemaleEnroll_secondary, TotalFemaleEnroll_high_secondary)), na.rm = T) ~ "TRUE",
      TRUE ~ "FASLE"
    ),
    
    # Total Attend male student - Primary (1 - 6 Grades)
    TotalMaleAttend_primary = rowSums(across(c(Exam_MaleRegistered_Grade_1, Exam_MaleRegistered_Grade_2, Exam_MaleRegistered_Grade_3, 
                                               Exam_MaleRegistered_Grade_4, Exam_MaleRegistered_Grade_5, Exam_MaleRegistered_Grade_6)), na.rm = T),
    
    # Total Attend male student - Secondary (7 - 9 Grades)
    TotalMaleAttend_secondary = rowSums(across(c(Exam_MaleRegistered_Grade_7, Exam_MaleRegistered_Grade_8, Exam_MaleRegistered_Grade_9)), na.rm = T),
    
    # Total Attend male student - High Secondary (10 - 12 Grades)
    TotalMaleAttend_high_secondary = rowSums(across(c(Exam_MaleRegistered_Grade_10, Exam_MaleRegistered_Grade_11, Exam_MaleRegistered_Grade_12)), na.rm = T),
    
    
    # Total Attend female student - Primary (1 - 6 Grades)
    TotalFemaleAttend_primary = rowSums(across(c(Exam_FemaleRegistered_Grade_1, Exam_FemaleRegistered_Grade_2, Exam_FemaleRegistered_Grade_3, 
                                                 Exam_FemaleRegistered_Grade_4, Exam_FemaleRegistered_Grade_5, Exam_FemaleRegistered_Grade_6)), na.rm = T),
    
    # Total Attend female student - Secondary (7 - 9 Grades)
    TotalFemaleAttend_secondary = rowSums(across(c(Exam_FemaleRegistered_Grade_7, Exam_FemaleRegistered_Grade_8, Exam_FemaleRegistered_Grade_9)), na.rm = T),
    
    # Total Attend female student - High Secondary (10 - 12 Grades)
    TotalFemaleAttend_high_secondary = rowSums(across(c(Exam_FemaleRegistered_Grade_10, Exam_FemaleRegistered_Grade_11, Exam_FemaleRegistered_Grade_12)), na.rm = T),
    
    
    # Total Attend all - Primary (male and female)
    TotalAttend_primary = rowSums(across(c(TotalMaleAttend_primary, TotalFemaleAttend_primary)), na.rm = T),
    # Total Attend all - Secondary (male and female)
    TotalAttend_secondary = rowSums(across(c(TotalMaleAttend_secondary, TotalFemaleAttend_secondary)), na.rm = T),
    # Total Attend all - High Secondary (male and female)
    TotalAttend_high_secondary = rowSums(across(c(TotalMaleAttend_high_secondary, TotalFemaleAttend_high_secondary)), na.rm = T),
    
    
    
    Test_attend = case_when(
      TotalAttended1_1_to_12 == rowSums(across(c(TotalMaleAttend_primary, TotalMaleAttend_secondary, TotalMaleAttend_high_secondary,
                                                 TotalFemaleAttend_primary, TotalFemaleAttend_secondary, TotalFemaleAttend_high_secondary)), na.rm = T) ~ "TRUE",
      TRUE ~ "FASLE"
    )
  )

# Enrollment and Attendance comparison -- Less == Enrollment less than Attendance
round(prop.table(table(emis_1718$`1397`$Result_1_12)) * 100, 1)

enroll_2019_pub <- emis_2019$`Enrollment - Pub` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    )
  )

enroll_2019_priv <- emis_2019$`Enrollment - Priv` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    )
  )

attend_2019_pub <- emis_2019$`Present Students - Pub` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    )
  )

attend_2019_priv <- emis_2019$`Present Students - Priv` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    )
  )

enroll_2021_pub <- emis_2021$`Enrollment - Pub` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Kabul Province" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    )
  )


enroll_2021_priv <- emis_2021$`Enrollment - Pri`%>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Kabul Province" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    )
  )

attend_2021_pub <- emis_2021$`Present Students - Pub` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Kabul Province" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    )
  )

emis_2019$`Present Students-by Dis-Pub` <- emis_2019$`Present Students-by Dis-Pub` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Kabul Province" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    ), 
    district = case_when(
      district == "Khogyani(Wali Mohd Shahid)" ~ "Khogyani(Wali Mohammad Shahid)",
      grepl("Nahia", district) ~ "Kabul",
      TRUE ~ district
    )
  )


emis_2019$`Present Students - by District` <- emis_2019$`Present Students - by District` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Kabul Province" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    ), 
    district = case_when(
      district == "Khogyani(Wali Mohd Shahid)" ~ "Khogyani(Wali Mohammad Shahid)",
      grepl("Nahia", district) ~ "Kabul",
      TRUE ~ district
    )
  )

# Private and Public
emis_2021$`Enrollment by Dis-Pub` <- emis_2021$`Enrollment by Dis-Pub` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Kabul Province" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    ), 
    district = case_when(
      district == "Khogyani(Wali Mohd Shahid)" ~ "Khogyani(Wali Mohammad Shahid)",
      grepl("Nahia", district) ~ "Kabul",
      TRUE ~ district
    )
  )

# Private and Public
emis_2021$`Present Students by Dis-Pub ` <- emis_2021$`Present Students by Dis-Pub ` %>% 
  mutate(
    province = case_when(
      province == "Kabul City" ~ "Kabul",
      province == "Kabul Province" ~ "Kabul",
      province == "Helmand" ~ "Hilmand",
      province == "Herat" ~ "Hirat",
      province == "Nooristan" ~ "Nuristan",
      province == "Sar e Pul" ~ "Sar i Pul",
      TRUE ~ province
    ), 
    district = case_when(
      district == "Khogyani(Wali Mohd Shahid)" ~ "Khogyani(Wali Mohammad Shahid)",
      grepl("Nahia", district) ~ "Kabul",
      TRUE ~ district
    )
  )


emis_2022$`Open Schools` <- emis_2022$`Open Schools` %>% 
  mutate(
    Province = case_when(
      Province == "Daykundi" ~ "Daikundi",
      Province == "Paktya" ~ "Paktia",
      Province == "Panjsher" ~ "Panjshir",
      Province == "Sar-e-Pul" ~ "Sar i Pul",
      Province == "Maidan Wardak" ~ "Wardak",
      TRUE ~ Province
    ),
    District = case_when(
      District == "Arghanj Khwah" ~ "Arghang Khwah",
      District == "Darwaz-e-Balla" ~ "Darwaz i Bala",
      District == "Darayem" ~ "Drayem",
      District == "Fayzabad" ~ "Faiz Abad",
      District == "Eshkashem" ~ "Ishkashim",
      District == "Jorm" ~ "Jurm",
      District == "Khwahan" ~ "Khawahan",
      District == "Koran Wa Monjan" ~ "Kiran wa Munjan",
      District == "Keshem" ~ "Kishm",
      District == "Kofab" ~ "Kof Ab",
      District == "Nesai" ~ "Nasi",
      District == "Raghestan" ~ "Raghistan",
      District == "Shahr-e-Buzorg" ~ "Shahr i Buzurg",
      District == "Shaki" ~ "Sheki",
      District == "Shuhada" ~ "Shuhada (ZarDew Sarghilan)",
      District == "Teshkan" ~ "Tashkan",
      District == "Warduj" ~ "Wardoj",
      District == "Yaftal-e-Sufla" ~ "Yaftal (Bala wa Payan)",
      District == "Yamgan" ~ "Yamgan (Girwan)",
      
      District == "Bala Murghab" ~ "Murghab",
      District == "Qala-e-Naw" ~ "Qala i Now",
      
      District == "Baghlan-e-Jadid" ~ "Baghalan i Jadid",
      District == "Burka" ~ "Booraka",
      District == "Dahana-e-Ghori" ~ "Dahana i Ghori",
      District == "Fereng Wa Gharu" ~ "Fereng",
      District == "Guzargah-e-Nur" ~ "Guzargah i Noor",
      District == "Khost Wa Fereng" ~ "Khost",
      District == "Khwaja Hejran" ~ "Khwaja Hijran (Jalga Nahrin)",
      District == "Nahrin" ~ "Nahreen",
      District == "Pul-e-Hisar" ~ "Pul i Hisar",
      District == "Pul-e-Khumri" ~ "Puli Khomri",
      District == "Tala Wa Barfak" ~ "Tala wa Barfak",
      
      District == "" ~ "Alburz", # not in the data
      District == "" ~ "Chahi", # not in the data
      District == "Chemtal" ~ "Chamtal",
      District == "Char Bolak" ~ "Char Boolak",
      District == "Charkent" ~ "Char Kent",
      District == "Dehdadi" ~ "Deh Dadi",
      District == "Sharak-e-Hayratan" ~ "Hayratan",
      District == "Keshendeh" ~ "Kishindeh",
      District == "Mazar-e-Sharif" ~ "Mazar Sharif",
      District == "Nahr-e-Shahi" ~ "Nahri Shahi",
      District == "Sholgareh" ~ "Sholgara",
      District == "Shortepa" ~ "Shor Teepa",
      
      District == "Sayghan" ~ "Saighan",
      District == "Shibar" ~ "Shebar",
      District == "Yakawlang No. 2" ~ "Yakawlang Number 2",
      
      District == "Khadir" ~ "Khadeer",
      District == "Kajran" ~ "Kijran",
      District == "Miramor" ~ "Miramoor",
      District == "Nawamesh" ~ "Nawa Mish",
      District == "Patoo" ~ "Pato",
      District == "Sang-e-Takht" ~ "Sang i Takht",
      District == "Shahrestan" ~ "Shahristan",
      District == "Ashtarlay" ~ "Ushturlai",
      
      District == "Khak-e-Safed" ~ "Khak i Safid",
      District == "Lash-e-Juwayn" ~ "Lash Jowayn",
      District == "Pur Chaman" ~ "Purchaman",
      District == "Pushtrod" ~ "Pusht i Road",
      District == "Qala-e-Kah" ~ "Pusht koh (Qala i Kah)",
      District == "Shibkoh" ~ "Shib Koh (Qala i Kah)",
      
      District == "Andkhoy" ~ "And Khoy",
      District == "Bilcheragh" ~ "Belcheragh",
      District == "Garzewan" ~ "Garzeewan",
      District == "" ~ "Ghormach", # Part of Faryab for 17 and 18, and part of Badghis for 21 and 22
      District == "Khan-e-Char Bagh" ~ "Khan Charbagh",
      District == "Maymana" ~ "Maimana",
      District == "Qaysar" ~ "Qaisar",
      District == "Qaram Qul" ~ "Qaramqol",
      District == "Qurghan" ~ "Qarghan",
      District == "Shirin Tagab" ~ "Shirin Tagab",
      
      District == "Gelan" ~ "Gilan",
      District == "Jaghatu" ~ "Jaghato",
      District == "Jaghuri" ~ "Jaghori",
      District == "Khwaja Umari" ~ "Khawaja Umari",
      District == "Wal-e-Muhammad-e-Shahid" ~ "Khogyani(Wali Mohammad Shahid)",
      District == "Nawur" ~ "Nahor",
      District == "Zanakhan" ~ "Zana Khan",
      
      District == "Charsadra" ~ "Charsada",
      District == "Chaghcharan" ~ "Cheghcheran",
      District == "Dawlatyar" ~ "Dawlatyaar",
      District == "DoLayna" ~ "Dolina",
      District == "Lal Wa Sarjangal" ~ "Lal o Sar Jangal",
      District == "Taywarah" ~ "Teywara",
      District == "Tolak" ~ "Tulak",
      
      District == "Bughni" ~ "Baghni",
      District == "Deh-e-Shu" ~ "Disho (Khanshin)",
      District == "Garmser" ~ "Garmseer (Hazar Juft)",
      District == "Nahr-e-Saraj" ~ "Girishk (Nahr i Saraj)",
      District == "Nad-e-Ali" ~ "Nad Ali",
      District == "Nawa-e-Barakzaiy" ~ "Nawa Barakzayee",
      District == "Reg-i-Khan Nishin" ~ "Reg",
      District == "Sangin" ~ "Sangeen",
      District == "Washer" ~ "Washir",
      
      District == "Adraskan" ~ "Adreskan",
      District == "Chisht-e-Sharif" ~ "Chesht i Sharif",
      District == "Ghoryan" ~ "Ghoreyan",
      District == "Kohsan" ~ "Kuhsan",
      District == "Karukh" ~ "Kurkh",
      District == "Kushk Rubat-i-Sangi" ~ "Kushk (Rubatak i Sangi)",
      District == "Kushk-e-Kuhna" ~ "Kushk i Kuhna",
      District == "Obe" ~ "Oba",
      District == "Pashtun Zarghun" ~ "Pashtoon Zarghoon",
      District == "Zindajan" ~ "Zenda Jan",
      # Koh-i-zor, Pushte koh, Zawol and zer-i koh are the districts available in 2021 and 2022
      # And not in 2017 and 2018 (Likely all of them were known as Shindand before)
      # For Attendance
      District == "Koh-i-Zor" ~ "Koh Zor",
      District == "Pusht-e Koh" ~ "Pesht Koh",
      District == "Zer-i Koh" ~ "Zer Koh",
      
      District == "Aqcha" ~ "Aaqcha",
      District == "Darzab" ~ "Darz Ab",
      District == "Khanaqa" ~ "Khaniqa",
      District == "Khwaja Dukoh" ~ "Khawaja Do Koh",
      District == "Mardyan" ~ "Mardeyan",
      District == "Mingajik" ~ "Mengajik wa Ferari",
      District == "Qarqin" ~ "Qarqeen",
      District == "Qush Tepa" ~ "Qush Tipa",
      District == "Shiberghan" ~ "Shibirghan",
      Province == "Jawzjan" & District == "Fayzabad" ~ "Faiz Abad",
      
      District == "Chahar Asyab" ~ "Char Asyab",
      District == "Estalef" ~ "Istalif",
      District == "Khak-e-Jabbar" ~ "Khak Jabbar",
      District == "Musahi" ~ "Mosahi",
      District == "Shakar Dara" ~ "Sharkar Dara",
      District == "Surobi" & Province == "Kabul" ~ "Sorobi",
      # In 2022 data set all Nahias in Kabul are under Kabul district
      # We can use this alternative approach (for 17, 18 and 21) to include figures from 2022 as well
      # grepl("Nahia", District) ~ "Kabul",
      
      District == "Arghestan" ~ "Arghistan",
      District == "Shorabak" ~ "Dand (Shorabak)",
      District == "" ~ "Ghorak", # Not in 21 and 22
      District == "" ~ "Khakreez",  # Not in 21 and 22
      District == "Maywand" ~ "Maiwand",
      District == "Maruf" ~ "Maroof",
      District == "Miyanshin" ~ "Meyan Nishin",
      District == "" ~ "Nish",  # Not in 21 and 22
      District == "Panjwayi" ~ "Panjwayee",
      District == "" ~ "Reegistan",  # Not in 21 and 22
      District == "Spin Boldak" ~ "Speen Boldak",
      District == "Reg Takhta Pul" ~ "Takhta Pul (Reg)",
      District == "Zheray" ~ "Zeray",
      
      District == "Alasay" ~ "Ala Saay",
      District == "Hisa-e-Awal-e-Kohistan" ~ "Hisa i Awal i Kohistan",
      District == "Hisa-e-Duwum-e-Kohistan" ~ "Hisa i Dowom i Kohistan",
      District == "Mahmood-e-Raqi" ~ "Mahmood Raqi",
      
      District == "Shamal" ~ "Dowa Manda (Shamal)",
      District == "Mandozayi" ~ "Ismail Khail Mandozayee",
      District == "Jaji Maydan" ~ "Jaji Maidan",
      District == "Matun" ~ "Matoon (Khost)",
      District == "Musa Khel" ~ "Musa Khail",
      District == "Sabari" ~ "Sabri",
      District == "Spera" ~ "Sepera",
      District == "Tani" ~ "Tanai (Daragi)",
      District == "Terezayi" ~ "Terzayee",
      
      District == "Bar Kunar" ~ "Asmar (Bar Kunar)",
      District == "Dara-e-Pech" ~ "Dara i Paich",
      District == "Nurgal" ~ "Noor Gul",
      District == "Chawkay" ~ "Sawkai",
      District == "" ~ "Shaltan", # Not in 2022
      District == "Shigal" ~ "Sheegal Sheltan",
      District == "Watapur" ~ "Wata Purta",
      
      District == "Chahar Darah" ~ "Chahar Dara",
      District == "Dasht-e-Archi" ~ "Dasht Archi",
      District == "Qala-e-Zal" ~ "Qala i Zal",
      # Aqtash, Gultipa, and Kalbad districts are not in 17 and 18 but int 22
      # For attendance
      District == "Kalbad" ~ "Kalbaad",
      
      District == "Alingar" ~ "Alinigar",
      District == "Alishang" ~ "Alishing",
      District == "Dawlatshah" ~ "Dawlat Shah",
      District == "Mehtarlam" ~ "Mehtarlam Baba",
      District == "Qarghayi" ~ "Qarghayee",
      
      District == "Pul-e-Alam" ~ "Pul i Alam (Kulangar)",
      
      District == "Behsood" ~ "Behsud",
      District == "Chaparkhar" ~ "Chaparhar",
      District == "Dara-e-Nur" ~ "Dara i Noor",
      District == "Deh Bala" ~ "Deh Bala (Haska Mina)",
      District == "Dur Baba" ~ "Door Baba",
      District == "Hesarak" ~ "Hisarak",
      District == "Kuz Kunar" ~ "Koz Kunar (Khiwa)",
      District == "Lalpur" ~ "Lal Pur",
      District == "Muhmand Dara" ~ "Mohmand Dara",
      District == "Nazyan" ~ "Naziyan",
      District == "Pachir Wa Agam" ~ "Pachir wa Agam",
      District == "Rodat" ~ "Rudat",
      District == "Shinwar" ~ "Shinwar (Ghani Khail)",
      District == "Sherzad" ~ "Shirzad",
      District == "Surkh Rod" ~ "Surkhrud",
      
      District == "Khashrod" ~ "Khashroad",
      District == "Kang" ~ "Kung",
      
      District == "Barg-e-Matal" ~ "Barg i Matal",
      District == "Duab" ~ "Doo Ab",
      District == "Kamdesh" ~ "Kamdeesh",
      District == "Mandol" ~ "Mandool",
      District == "Nurgaram" ~ "Noor Geram (Yaningiraj)",
      District == "Parun" ~ "Noristan (Paroon)",
      
      District == "Dand Wa Patan" ~ "Dand Pattan",
      District == "Gardez" ~ "Gardeez",
      District == "Garda Siray" ~ "Gerda Serai",
      District == "Jaji" ~ "Jaji (Aryob)",
      District == "Jani Khel" & Province == "Paktia" ~ "Jani Khail (Mangal)",
      District == "Lija Ahmad Khel" ~ "Laja Ahmad Khail",
      District == "Lija Mangal" ~ "Laja wa Mangal",
      District == "Merzaka" ~ "Mirzaka",
      District == "Ahmadaba" ~ "Road Ahmad Abad",
      District == "Chamkani" ~ "Samkani",
      District == "Zadran" ~ "Wazi Zadran",
      
      District == "Dila" ~ "Della",
      District == "Giyan" ~ "Geyan",
      District == "Jani Khel" & Province == "Paktika" ~ "Jani Khail",
      District == "Zarghun Shahr" ~ "Khair Kot (Zarghon Shahr)",
      District == "Mata Khan" ~ "Matta Khan",
      District == "Nika" ~ "Neka",
      District == "Sar Rawzah" ~ "Sar Rowza",
      District == "Surobi" & Province == "Paktika"  ~ "Surubi",
      District == "Turwo" ~ "Terway",
      District == "Omna" ~ "Umna",
      District == "Urgun" ~ "Urugun",
      District == "Yosuf Khel" ~ "Usuf Khail",
      District == "Wazakhah" ~ "Waza Khwah",
      District == "Wormamay" ~ "Wormami",
      District == "Yahya Khel" ~ "Yahya Khail",
      District == "Ziruk" ~ "Zerok",
      
      District == "Khenj" ~ "Hisa i Awali (Khinj)",
      District == "Anawa" ~ "Unaba",
      
      District == "Jabal Saraj" ~ "Jabal u Saraj",
      District == "Koh-e-Safi" ~ "Koh i Safi",
      District == "Sayed Khel" ~ "Sayed Khail",
      District == "Shekh Ali" ~ "Shikh Ali",
      District == "Surkh-e-Parsa" ~ "Surkh Parsa",
      
      District == "Dara-e-Suf-e-Bala" ~ "Dara i Suf Bala",
      District == "Dara-e-Suf-e-Payin" ~ "Dara i Suf i Payan",
      District == "Feroz Nakhchir" ~ "Feeroz Nakhcheer",
      District == "Hazrat-e-Sultan" ~ "Hazrat Sultan",
      District == "Khuram Wa Sarbagh" ~ "Khuram wa Sarbagh",
      District == "Ruy-e-Duab" ~ "Roy do Ab",
      
      District == "Kohestanat" ~ "Kohistanat",
      District == "Sancharak" ~ "Sang Charak",
      District == "Sar-e-Pul" ~ "Sar i Pul",
      District == "Sayad" ~ "Sayaad",
      District == "Sozmaqala" ~ "Sozma Qala",
      
      District == "Chahab" ~ "Chah i Ab",
      District == "Darqad" ~ "Dar Qad",
      District == "Dasht-e-Qala" ~ "Dasht Qala",
      District == "Eshkmesh" ~ "Ishkamish",
      District == "Khwaja Bahawuddin" ~ "Khwaja Bahawoddin",
      District == "Rostaq" ~ "Rustaq",
      District == "Taloqan" ~ "Taliqan",
      
      District == "Dehrawud" ~ "Dehrawood",
      District == "Shahid-e-Hassas" ~ "Shahid Hasas (Char Cheena)",
      District == "Tirinkot" ~ "Trinkot",
      
      District == "Chak-e-Wardak" ~ "Chak",
      District == "Daymirdad" ~ "Dai Mirdad",
      District == "Hesa-e-Awal-e-Behsud" ~ "Hisa i Awal i Behsud",
      District == "Jalrez" ~ "Jalreez",
      District == "Maydan Shahr" ~ "Maidan Shahr",
      District == "Markaz-e-Behsud" ~ "Markaz Behsud",
      District == "Nerkh" ~ "Nirkh",
      District == "Saydabad" ~ "Sayed Abad",
      
      District == "" ~ "Dai Chopan", # Not in 2022
      District == "Kakar" ~ "Khak Afghan (Kakar)",
      District == "Nawbahar" ~ "Naw Bahar",
      District == "Seuri" ~ "Seyoray",
      District == "Shah Joi" ~ "Shah Joy",
      District == "" ~ "Shamulzai", # Not in 2022
      District == "Tarnak Wa Jaldak" ~ "Tarnak wa Jaldak",
      
      TRUE ~ District
    )
  )



## Enrollment ------------------------------------------------------------------
# By Province --------------------
enroll_by_prov_2017 <- emis_1718$`1396` %>% 
  group_by(province = ProvinceEngName) %>% 
  summarise(
    `Total Enrolled Student - 2017` = sum(TotalEnroll, na.rm = T)
  )

enroll_by_prov_2018 <- emis_1718$`1397` %>% 
  group_by(province = ProvinceEngName) %>% 
  summarise(
    `Total Enrolled Student - 2018` = sum(TotalEnroll, na.rm = T)
  )

enroll_by_prov_2019 <- enroll_2019 %>% 
  group_by(province) %>% 
  summarise(
    `Total Enrolled Student - 2019` = sum(total, na.rm = T)
  )

enroll_by_prov_2021 <- enroll_2021 %>% 
  group_by(province) %>% 
  summarise(
    `Total Enrolled Student - 2021` = sum(total, na.rm = T)
  )

enroll_by_prov_2022 <- emis_2022$student_repeat %>% 
  group_by(province = Province) %>% 
  summarise(
    `Total Enrolled Student - 2022` = sum(Number_Of_Existing_Students_Enrolled, na.rm = T)
  )


enroll_by_prov_all <- enroll_by_prov_2017 %>% 
  left_join(enroll_by_prov_2018, by = "province") %>% 
  left_join(enroll_by_prov_2019, by = "province") %>% 
  left_join(enroll_by_prov_2021, by = "province") %>% 
  left_join(enroll_by_prov_2022, by = "province")

# By Province and Stage ------------------------
# 2017
enroll_by_prov_stage_male_2017 <- emis_1718$`1396` %>%
  group_by(province = ProvinceEngName) %>% 
  summarise(
    Primary = sum(TotalMaleEnroll_primary, na.rm = T),
    Secondary = sum(TotalMaleEnroll_secondary, na.rm = T),
    `Upper Secondary` = sum(TotalMaleEnroll_high_secondary, na.rm = T)
  ) %>% 
  pivot_longer(cols = !province, names_to = "stage", values_to = "Total Enrolled Male Student - 2017")

enroll_by_prov_stage_female_2017 <- emis_1718$`1396` %>%
  group_by(province = ProvinceEngName) %>% 
  summarise(
    Primary = sum(TotalFemaleEnroll_primary, na.rm = T),
    Secondary = sum(TotalFemaleEnroll_secondary, na.rm = T),
    `Upper Secondary` = sum(TotalFemaleEnroll_high_secondary, na.rm = T)
  ) %>% 
  pivot_longer(cols = !province, names_to = "stage", values_to = "Total Enrolled Female Student - 2017")

# 2018
enroll_by_prov_stage_male_2018 <- emis_1718$`1397` %>%
  group_by(province = ProvinceEngName) %>% 
  summarise(
    Primary = sum(TotalMaleEnroll_primary, na.rm = T),
    Secondary = sum(TotalMaleEnroll_secondary, na.rm = T),
    `Upper Secondary` = sum(TotalMaleEnroll_high_secondary, na.rm = T)
  ) %>% 
  pivot_longer(cols = !province, names_to = "stage", values_to = "Total Enrolled Male Student - 2018")

enroll_by_prov_stage_female_2018 <- emis_1718$`1397` %>%
  group_by(province = ProvinceEngName) %>% 
  summarise(
    Primary = sum(TotalFemaleEnroll_primary, na.rm = T),
    Secondary = sum(TotalFemaleEnroll_secondary, na.rm = T),
    `Upper Secondary` = sum(TotalFemaleEnroll_high_secondary, na.rm = T)
  ) %>% 
  pivot_longer(cols = !province, names_to = "stage", values_to = "Total Enrolled Female Student - 2018")


# 2019
enroll_by_prov_stage_male_and_female_2019 <- enroll_2019 %>% 
  group_by(province, stage = school_level) %>% 
  summarise(
    `Total Enrolled Male Student - 2019` = sum(male, na.rm = T),
    `Total Enrolled Female Student - 2019` = sum(female, na.rm = T)
  )

# 2021
enroll_by_prov_stage_male_and_female_2021 <- enroll_2021 %>% 
  group_by(province, stage = school_level) %>% 
  summarise(
    `Total Enrolled Male Student - 2021` = sum(male, na.rm = T),
    `Total Enrolled Female Student - 2021` = sum(female, na.rm = T)
  )


enroll_by_prov_stage_all <- enroll_by_prov_stage_male_2017 %>% 
  left_join(enroll_by_prov_stage_female_2017,  by = c("province","stage")) %>% 
  left_join(enroll_by_prov_stage_male_2018, by = c("province","stage")) %>% 
  left_join(enroll_by_prov_stage_female_2018, by = c("province","stage")) %>% 
  left_join(enroll_by_prov_stage_male_and_female_2019, by = c("province","stage")) %>% 
  left_join(enroll_by_prov_stage_male_and_female_2021, by = c("province","stage"))


# For 2022 TV data the stage indicator was not quite clear
# There is a column (School_Type_primary_secondary) which has 8 unique options including NA

# By District --------------------
enroll_by_dist_2017 <- emis_1718$`1396` %>% 
  group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
  summarise(
    `Total Enrolled Student - 2017` = sum(TotalEnroll, na.rm = T)
  ) %>% 
  ungroup()

enroll_by_dist_2018 <- emis_1718$`1397` %>% 
  group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
  summarise(
    `Total Enrolled Student - 2018` = sum(TotalEnroll, na.rm = T)
  ) %>%
  ungroup()

# 2019 --- district level data not available


enroll_by_dist_2021 <- emis_2021$`Enrollment by Dis-Pub` %>% 
  group_by(province, district) %>% 
  summarise(
    `Total Enrolled Student - 2021` = sum(total, na.rm = T)
  ) %>% 
  ungroup()

enroll_by_dist_2022 <- emis_2022$student_repeat %>% 
  group_by(province = Province, district = District) %>% 
  summarise(
    `Total Enrolled Student - 2022` = sum(Number_Of_Existing_Students_Enrolled, na.rm = T)
  ) %>% 
  ungroup()


enroll_by_dist_all <- enroll_by_dist_2017 %>% 
  left_join(enroll_by_dist_2018, by = c("province", "district")) %>% 
  full_join(enroll_by_dist_2021, by = c("province", "district")) %>% 
  full_join(enroll_by_dist_2022, by = c("province", "district"))


not_in_17 <- enroll_by_dist_all[is.na(enroll_by_dist_all$`Total Enrolled Student - 2017`),]
not_in_18 <- enroll_by_dist_all[is.na(enroll_by_dist_all$`Total Enrolled Student - 2018`),]
not_in_21 <- enroll_by_dist_all[is.na(enroll_by_dist_all$`Total Enrolled Student - 2021`),]
not_in_22 <- enroll_by_dist_all[is.na(enroll_by_dist_all$`Total Enrolled Student - 2022`),]


# By District and Stage ------------------------
# 2017
enroll_by_dist_stage_male_2017 <- emis_1718$`1396` %>%
  group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
  summarise(
    Primary = sum(TotalMaleEnroll_primary, na.rm = T),
    Secondary = sum(TotalMaleEnroll_secondary, na.rm = T),
    `Upper Secondary` = sum(TotalMaleEnroll_high_secondary, na.rm = T)
  ) %>% 
  pivot_longer(cols = c(Primary, Secondary, `Upper Secondary`), names_to = "stage", values_to = "Total Enrolled Male Student - 2017")

enroll_by_dist_stage_female_2017 <- emis_1718$`1396` %>%
  group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
  summarise(
    Primary = sum(TotalFemaleEnroll_primary, na.rm = T),
    Secondary = sum(TotalFemaleEnroll_secondary, na.rm = T),
    `Upper Secondary` = sum(TotalFemaleEnroll_high_secondary, na.rm = T)
  ) %>% 
  pivot_longer(cols = c(Primary, Secondary, `Upper Secondary`), names_to = "stage", values_to = "Total Enrolled Female Student - 2017")

# 2018
enroll_by_dist_stage_male_2018 <- emis_1718$`1397` %>%
  group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
  summarise(
    Primary = sum(TotalMaleEnroll_primary, na.rm = T),
    Secondary = sum(TotalMaleEnroll_secondary, na.rm = T),
    `Upper Secondary` = sum(TotalMaleEnroll_high_secondary, na.rm = T)
  ) %>% 
  pivot_longer(cols = c(Primary, Secondary, `Upper Secondary`), names_to = "stage", values_to = "Total Enrolled Male Student - 2018")

enroll_by_dist_stage_female_2018 <- emis_1718$`1397` %>%
  group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
  summarise(
    Primary = sum(TotalFemaleEnroll_primary, na.rm = T),
    Secondary = sum(TotalFemaleEnroll_secondary, na.rm = T),
    `Upper Secondary` = sum(TotalFemaleEnroll_high_secondary, na.rm = T)
  ) %>% 
  pivot_longer(cols = c(Primary, Secondary, `Upper Secondary`), names_to = "stage", values_to = "Total Enrolled Female Student - 2018")

# 2019 --- district level data not available

# 2021
enroll_by_dist_stage_male_and_female_2021 <- emis_2021$`Enrollment by Dis-Pub` %>% 
  group_by(province, district, stage = school_level) %>% 
  summarise(
    `Total Enrolled Male Student - 2019` = sum(male, na.rm = T),
    `Total Enrolled Female Student - 2019` = sum(female, na.rm = T)
  )

# 2022 --- stage level not accurate and clear


enroll_by_dist_stage_all <- enroll_by_dist_stage_male_2017 %>% 
  left_join(enroll_by_dist_stage_female_2017, by = c('province', 'district', 'stage')) %>% 
  left_join(enroll_by_dist_stage_male_2018, by = c('province', 'district', 'stage')) %>% 
  left_join(enroll_by_dist_stage_female_2018, by = c('province', 'district', 'stage')) %>% 
  full_join(enroll_by_dist_stage_male_and_female_2021, by = c('province', 'district', 'stage'))

dist_not_in_17 <- enroll_by_dist_stage_all[is.na(enroll_by_dist_stage_all$`Total Enrolled Male Student - 2017`),]
dist_not_in_18 <- enroll_by_dist_stage_all[is.na(enroll_by_dist_stage_all$`Total Enrolled Male Student - 2018`),]
dist_not_in_21 <- enroll_by_dist_stage_all[is.na(enroll_by_dist_stage_all$`Total Enrolled Male Student - 2019`),]


# By Grade ----------------------- (NA)

## Attendance ------------------------------------------------------------------
# By Province --------------------
attend_by_prov_2017 <- emis_1718$`1396` %>% # Not sure about the right indicators
  group_by(province = ProvinceEngName) %>%
  summarise(
    `Total Present Student - 2017` = sum(TotalAttended1_1_to_12, na.rm = T)
  )

attend_by_prov_2018 <- emis_1718$`1397` %>% # Not sure about the right indicators
  group_by(province = ProvinceEngName) %>%
  summarise(
    `Total Present Student - 2018` = sum(TotalAttended1_1_to_12, na.rm = T)
  )

attend_by_prov_2019 <- attend_2019 %>% 
  group_by(province) %>% 
  summarise(
    `Total Present Student - 2019` = sum(total, na.rm = T)
  )

attend_by_prov_2021 <- attend_2021 %>% 
  group_by(province) %>% 
  summarise(
    `Total Present Student - 2021` = sum(total, na.rm = T)
  )

attend_by_prov_2022 <- emis_2022$student_repeat %>% 
  group_by(province = Province) %>% 
  summarise(
    `Total Present Student - 2022` = sum(Overall_Present_Existing_Students, na.rm = T)
  )


attend_by_prov_all <- attend_by_prov_2017 %>% 
  left_join(attend_by_prov_2018, by = "province") %>%
  left_join(attend_by_prov_2019, by = "province") %>% 
  left_join(attend_by_prov_2021, by = "province") %>% 
  left_join(attend_by_prov_2022, by = "province")


# By Province and Stage ------------------
attend_by_prov_stage_all <- left_join(
  # 2017
  emis_1718$`1396` %>%
    group_by(province = ProvinceEngName) %>% 
    summarise(
      Primary = sum(TotalMaleAttend_primary, na.rm = T),
      Secondary = sum(TotalMaleAttend_secondary, na.rm = T),
      `Upper Secondary` = sum(TotalMaleAttend_high_secondary, na.rm = T)
    ) %>% 
    pivot_longer(cols = !province, names_to = "stage", values_to = "Total Present Male Student - 2017"),
  
  emis_1718$`1396` %>%
    group_by(province = ProvinceEngName) %>% 
    summarise(
      Primary = sum(TotalFemaleAttend_primary, na.rm = T),
      Secondary = sum(TotalFemaleAttend_secondary, na.rm = T),
      `Upper Secondary` = sum(TotalFemaleAttend_high_secondary, na.rm = T)
    ) %>% 
    pivot_longer(cols = !province, names_to = "stage", values_to = "Total Present Female Student - 2017"), by = c("province", "stage")) %>% 
  
  # 2018
  left_join(
    emis_1718$`1397` %>% 
      group_by(province = ProvinceEngName) %>% 
      summarise(
        Primary = sum(TotalMaleAttend_primary, na.rm = T),
        Secondary = sum(TotalMaleAttend_secondary, na.rm = T),
        `Upper Secondary` = sum(TotalMaleAttend_high_secondary, na.rm = T)
      ) %>% 
      pivot_longer(cols = !province, names_to = "stage", values_to = "Total Present Male Student - 2018"), by = c("province", "stage")) %>%
  
  # 2018
  left_join(
    emis_1718$`1397` %>% 
      group_by(province = ProvinceEngName) %>% 
      summarise(
        Primary = sum(TotalFemaleAttend_primary, na.rm = T),
        Secondary = sum(TotalFemaleAttend_secondary, na.rm = T),
        `Upper Secondary` = sum(TotalFemaleAttend_high_secondary, na.rm = T)
      ) %>% 
      pivot_longer(cols = !province, names_to = "stage", values_to = "Total Present Female Student - 2018"), by = c("province", "stage")) %>%
  
  # 2019
  left_join(
    attend_2019 %>%
      group_by(province, stage = school_level) %>%
      summarise(
        `Total Present Male Student - 2019` = sum(male, na.rm = T),
        `Total Present Female Student - 2019` = sum(female, na.rm = T)), by = c("province", "stage")) %>% 
  
  # 2021
  left_join(
    attend_2021 %>%
      group_by(province,stage = school_level) %>%
      summarise(
        `Total Present Male Student - 2021` = sum(male, na.rm = T),
        `Total Present Female Student - 2021` = sum(female, na.rm = T)), by = c("province", "stage"))



# By District ------------------
# Not sure about the right indicators
attend_by_dist_2017 <- emis_1718$`1396` %>%
  group_by(province = ProvinceEngName, district = DistrictEngName) %>%
  summarise(
    `Total Present Student - 2017` = sum(TotalAttended1_1_to_12, na.rm = T)
  ) %>%
  ungroup()

attend_by_dist_2018 <- emis_1718$`1397` %>%
  group_by(province = ProvinceEngName, district = DistrictEngName) %>%
  summarise(
    `Total Present Student - 2018` = sum(TotalAttended1_1_to_12, na.rm = T)
  ) %>%
  ungroup()

attend_by_dist_2019 <- emis_2019$`Present Students-by Dis-Pub` %>%
  group_by(province, district) %>%
  summarise(
    `Total Present Student - 2019` = sum(total, na.rm = T)
  ) %>% 
  ungroup()

attend_by_dist_2021 <- emis_2021$`Present Students by Dis-Pub ` %>% 
  group_by(province, district) %>% 
  summarise(
    `Total Present Student - 2021` = sum(total, na.rm = T)
  ) %>% 
  ungroup()

attend_by_dist_2022 <- emis_2022$student_repeat %>% 
  group_by(province = Province, district = District) %>% 
  summarise(
    `Total Present Student - 2022` = sum(Overall_Present_Existing_Students, na.rm = T)
  ) %>% 
  ungroup()


attend_by_dist_all <- attend_by_dist_2017 %>% 
  full_join(attend_by_dist_2018, by = c("province","district")) %>%
  full_join(attend_by_dist_2019, by = c("province","district")) %>%
  full_join(attend_by_dist_2021, by = c("province","district")) %>% 
  full_join(attend_by_dist_2022, by = c("province","district"))


not_in_17_en <- attend_by_dist_all[is.na(attend_by_dist_all$`Total Present Student - 2017`),]
not_in_18_en <- attend_by_dist_all[is.na(attend_by_dist_all$`Total Present Student - 2018`),]
not_in_19_en <- attend_by_dist_all[is.na(attend_by_dist_all$`Total Present Student - 2019`),]
not_in_21_en <- attend_by_dist_all[is.na(attend_by_dist_all$`Total Present Student - 2021`),]
not_in_22_en <- attend_by_dist_all[is.na(attend_by_dist_all$`Total Present Student - 2022`),]


# By District and Stage ------------------
attend_by_dist_stage_all <- left_join(
  # 2017
  emis_1718$`1396` %>%
    group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
    summarise(
      Primary = sum(TotalMaleAttend_primary, na.rm = T),
      Secondary = sum(TotalMaleAttend_secondary, na.rm = T),
      `Upper Secondary` = sum(TotalMaleAttend_high_secondary, na.rm = T)
    ) %>% 
    pivot_longer(cols = c(Primary, Secondary, `Upper Secondary`), names_to = "stage", values_to = "Total Present Male Student - 2017"),
  
  emis_1718$`1396` %>%
    group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
    summarise(
      Primary = sum(TotalFemaleAttend_primary, na.rm = T),
      Secondary = sum(TotalFemaleAttend_secondary, na.rm = T),
      `Upper Secondary` = sum(TotalFemaleAttend_high_secondary, na.rm = T)
    ) %>% 
    pivot_longer(cols = c(Primary, Secondary, `Upper Secondary`), names_to = "stage", values_to = "Total Present Female Student - 2017"), by = c("province", "district", "stage")) %>% 
  
  # 2018
  left_join(
    emis_1718$`1397` %>% 
      group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
      summarise(
        Primary = sum(TotalMaleAttend_primary, na.rm = T),
        Secondary = sum(TotalMaleAttend_secondary, na.rm = T),
        `Upper Secondary` = sum(TotalMaleAttend_high_secondary, na.rm = T)
      ) %>% 
      pivot_longer(cols = c(Primary, Secondary, `Upper Secondary`), names_to = "stage", values_to = "Total Present Male Student - 2018"), by = c("province", "district", "stage")) %>%
  
  # 2018
  left_join(
    emis_1718$`1397` %>% 
      group_by(province = ProvinceEngName, district = DistrictEngName) %>% 
      summarise(
        Primary = sum(TotalFemaleAttend_primary, na.rm = T),
        Secondary = sum(TotalFemaleAttend_secondary, na.rm = T),
        `Upper Secondary` = sum(TotalFemaleAttend_high_secondary, na.rm = T)
      ) %>% 
      pivot_longer(cols = c(Primary, Secondary, `Upper Secondary`), names_to = "stage", values_to = "Total Present Female Student - 2018"), by = c("province", "district", "stage")) %>%
  
  # 2019
  left_join(
    emis_2019$`Present Students-by Dis-Pub` %>%
      group_by(province, district, stage = school_level) %>%
      summarise(
        `Total Present Male Student - 2019` = sum(male, na.rm = T),
        `Total Present Female Student - 2019` = sum(female, na.rm = T)), by = c("province", "district", "stage")) %>% 
  
  # 2021
  left_join(
    emis_2021$`Present Students by Dis-Pub ` %>%
      group_by(province, district, stage = school_level) %>%
      summarise(
        `Total Present Male Student - 2021` = sum(male, na.rm = T),
        `Total Present Female Student - 2021` = sum(female, na.rm = T)), by = c("province", "district", "stage"))


# Export outputs
students_enrollment = list(
  Province = enroll_by_prov_all,
  Province_Stage = enroll_by_prov_stage_all,
  District = enroll_by_dist_all %>% arrange(province, district),
  District_Stage = enroll_by_dist_stage_all %>% arrange(province, district)
)

students_attendance = list(
  Province = attend_by_prov_all,
  Province_Stage = attend_by_prov_stage_all,
  District = attend_by_dist_all %>% arrange(province, district),
  District_Stage = attend_by_dist_stage_all %>% arrange(province, district)
)


# Analysis
write.xlsx(students_enrollment, "./output/EMIS/EMIS_Students_Enrollement.xlsx")
write.xlsx(students_attendance, "./output/EMIS/EMIS_Students_Attendance.xlsx")


# Recoded data sets
write.xlsx(emis_1718, "./input/EMIS/recoded/EMIS_2017_2018.xlsx")
write.xlsx(emis_2019, "./input/EMIS/recoded/EMIS_2019.xlsx")
write.xlsx(emis_2021, "./input/EMIS/recoded/EMIS_2021.xlsx")
write.xlsx(emis_2022, "./input/EMIS/recoded/EMIS_2022.xlsx")
