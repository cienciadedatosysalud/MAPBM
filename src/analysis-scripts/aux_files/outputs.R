


agregados <- dbExecute(con, "COPY (with datos_episodio as (
select * from (select patient_id,cnh_cd,episode_id,age_nm,sex_cd,admission_dt,round(epoch(discharge_dt - admission_dt)/86400,3) as los, discharge_type_cd,start_intervention_dt,asa_cd,brs_bl,eras_recovery_bl,
year(start_intervention_dt) as año_cd,
CASE
		WHEN age_nm >= 0
		and age_nm <= 4 THEN '00-04 años'
		WHEN age_nm >= 5
		and age_nm <= 9 THEN '05-09 años'
		WHEN age_nm >= 10
		and age_nm <= 14 THEN '10-14 años'
		WHEN age_nm >= 15
		and age_nm <= 19 THEN '15-19 años'
		WHEN age_nm >= 20
		and age_nm <= 24 THEN '20-24 años'
		WHEN age_nm >= 25
		and age_nm <= 29 THEN '25-29 años'
		WHEN age_nm >= 30
		and age_nm <= 34 THEN '30-34 años'
		WHEN age_nm >= 35
		and age_nm <= 39 THEN '35-39 años'
		WHEN age_nm >= 40
		and age_nm <= 44 THEN '40-44 años'
		WHEN age_nm >= 45
		and age_nm <= 49 THEN '45-49 años'
		WHEN age_nm >= 50
		and age_nm <= 54 THEN '50-54 años'
		WHEN age_nm >= 55
		and age_nm <= 59 THEN '55-59 años'
		WHEN age_nm >= 60
		and age_nm <= 64 THEN '60-64 años'
		WHEN age_nm >= 65
		and age_nm <= 69 THEN '65-69 años'
		WHEN age_nm >= 70
		and age_nm <= 74 THEN '70-74 años'
		WHEN age_nm >= 75
		and age_nm <= 79 THEN '75-79 años'
		WHEN age_nm >= 80
		and age_nm <= 84 THEN '80-84 años'
		WHEN age_nm >= 85 THEN '85 años o más'
		ELSE NULL
	END as grupo_edad_cd from episode_view) a 
left join comorbidities b 
using(patient_id,cnh_cd,episode_id,admission_dt)
left join complications c
using(patient_id,cnh_cd,episode_id,admission_dt)
left join elixhauser d 
using(patient_id,cnh_cd,episode_id,admission_dt)
),
datos_cohort as (
select * from cirugia_oncologica_cohort
union all 
select * from cirugia_programada_cohort
union all
select * from cirugia_urgente_cohort
union all
select * from proceso_medico_cohort
)
select cnh_cd,cohort, category_cohort,count(distinct patient_id || '-' || episode_id) as n_unique_episode, median(age_nm) as mediana_edad,
(QUANTILE_CONT(age_nm, 0.75)-QUANTILE_CONT(age_nm, 0.25)) as iqr_age,
count(distinct patient_id || '-' || episode_id) filter(where sex_cd = '2') as n_mujeres,
count(*) filter(where discharge_type_cd = '4') as n_exitus,
median(los) as mediana_los,
sum(asa_cd::INT) filter(where asa_cd ='1') as asa_cd_1,
sum(asa_cd::INT) filter(where asa_cd ='2') as asa_cd_2,
sum(asa_cd::INT) filter(where asa_cd ='3') as asa_cd_3,
sum(asa_cd::INT) filter(where asa_cd ='4') as asa_cd_4,
sum(asa_cd::INT) filter(where asa_cd ='5') as asa_cd_5,
sum(asa_cd::INT) filter(where asa_cd ='6') as asa_cd_6,
sum(brs_bl::INT) as brs_bl,
sum(eras_recovery_bl::INT) as eras_recovery_bl,
sum(aids_bl::INT) as aids_bl,
sum(ami_bl::INT) as ami_bl,
sum(chf_bl::INT) as chf_bl,
sum(ckd_bl::INT) as ckd_bl,
sum(copd_bl::INT) as copd_bl,
sum(ctp_bl::INT) as ctp_bl,
sum(cvd_bl::INT) as cvd_bl,
sum(dementia_bl::INT) as dementia_bl,
sum(hemiplegia_bl::INT) as hemiplegia_bl,
sum(leuk_bl::INT) as leuk_bl,
sum(lymph_bl::INT) as lymph_bl,
sum(mildliver_bl::INT) as mildliver_bl,
sum(mtx_bl::INT) as mtx_bl,
sum(orgdiab_bl::INT) as orgdiab_bl,
sum(peptic_bl::INT) as peptic_bl,
sum(pvd_bl::INT) as pvd_bl,
sum(severeliver_bl::INT) as severeliver_bl,
sum(tumor_bl::INT) as tumor_bl,
sum(uncdiab_bl::INT) as uncdiab_bl,
sum(akic_bl::INT) as akic_bl,
sum(amic_bl::INT) as amic_bl,
sum(anastomotic_breakdown_bl::INT) as anastomotic_breakdown_bl,
sum(ardsc_bl::INT) as ardsc_bl,
sum(arrythc_bl::INT) as arrythc_bl,
sum(bloodinfc_bl::INT) as bloodinfc_bl,
sum(cardiacc_bl::INT) as cardiacc_bl,
sum(cpec_bl::INT) as cpec_bl,
sum(deliriumc_bl::INT) as deliriumc_bl,
sum(dvtc_bl::INT) as dvtc_bl,
sum(gastroc_bl::INT) as gastroc_bl,
sum(ileusc_bl::INT) as ileusc_bl,
sum(myoinfc_bl::INT) as myoinfc_bl,
sum(pneumc_bl::INT) as pneumc_bl,
sum(postophemc_bl::INT) as postophemc_bl,
sum(pulmemb_bl::INT) as pulmemb_bl,
sum(ssinfc_bl::INT) as ssinfc_bl,
sum(strokec_bl::INT) as strokec_bl,
sum(transfaec_bl::INT) as transfaec_bl,
sum(uncinfc_bl::INT) as uncinfc_bl,
sum(utic_bl::INT) as utic_bl,
sum(aids_bl::INT) as aids_bl_elix,
sum(alcohol_bl::INT) as alcohol_bl_elix,
sum(anemdef_bl::INT) as anemdef_bl_elix,
sum(autoimmune_bl::INT) as autoimmune_bl_elix,
sum(bldloss_bl::INT) as bldloss_bl_elix,
sum(cancer_leuk_bl::INT) as cancer_leuk_bl_elix,
sum(cancer_lymph_bl::INT) as cancer_lymph_bl_elix,
sum(cancer_mets_bl::INT) as cancer_mets_bl_elix,
sum(cancer_nsitu_bl::INT) as cancer_nsitu_bl_elix,
sum(cancer_solid_bl::INT) as cancer_solid_bl_elix,
sum(cbvd_poa_bl::INT) as cbvd_poa_bl_elix,
sum(cbvd_sqla_bl::INT) as cbvd_sqla_bl_elix,
sum(coag_bl::INT) as coag_bl_elix,
sum(dementia_bl::INT) as dementia_bl_elix,
sum(depress_bl::INT) as depress_bl_elix,
sum(diab_cx_bl::INT) as diab_cx_bl_elix,
sum(diab_uncx_bl::INT) as diab_uncx_bl_elix,
sum(drug_abuse_bl::INT) as drug_abuse_bl_elix,
sum(hf_bl::INT) as hf_bl_elix,
sum(htn_cx_bl::INT) as htn_cx_bl_elix,
sum(htn_uncx_bl::INT) as htn_uncx_bl_elix,
sum(liver_mld_bl::INT) as liver_mld_bl_elix,
sum(liver_sev_bl::INT) as liver_sev_bl_elix,
sum(lung_chronic_bl::INT) as lung_chronic_bl_elix,
sum(neuro_movt_bl::INT) as neuro_movt_bl_elix,
sum(neuro_oth_bl::INT) as neuro_oth_bl_elix,
sum(neuro_seiz_bl::INT) as neuro_seiz_bl_elix,
sum(obese_bl::INT) as obese_bl_elix,
sum(paralysis_bl::INT) as paralysis_bl_elix,
sum(perivasc_bl::INT) as perivasc_bl_elix,
sum(psychoses_bl::INT) as psychoses_bl_elix,
sum(pulmcirc_bl::INT) as pulmcirc_bl_elix,
sum(renlfl_mod_bl::INT) as renlfl_mod_bl_elix,
sum(renlfl_sev_bl::INT) as renlfl_sev_bl_elix,
sum(thyroid_hypo_bl::INT) as thyroid_hypo_bl_elix,
sum(thyroid_oth_bl::INT) as thyroid_oth_bl_elix,
sum(ulcer_peptic_bl::INT) as ulcer_peptic_bl_elix,
sum(valve_bl::INT) as valve_bl_elix,
sum(wghtloss_bl::INT) as wghtloss_bl_elix
from (
select * from datos_cohort a 
left join datos_episodio b 
using(patient_id,episode_id,start_intervention_dt)
)
group by cnh_cd,cohort, category_cohort
) TO '../../outputs/agregados_hospital_descriptivo.csv' (FORMAT csv, DELIMITER '|', 
HEADER)
")


agregados <- dbExecute(con, "COPY (with datos_episodio as (
select * from (select patient_id,cnh_cd,episode_id,age_nm,sex_cd,admission_dt,round(epoch(discharge_dt - admission_dt)/86400,3) as los, 
discharge_type_cd,start_intervention_dt,asa_cd,brs_bl,eras_recovery_bl,
year(start_intervention_dt) as year,
CASE
		WHEN age_nm >= 0
		and age_nm <= 4 THEN '00-04 años'
		WHEN age_nm >= 5
		and age_nm <= 9 THEN '05-09 años'
		WHEN age_nm >= 10
		and age_nm <= 14 THEN '10-14 años'
		WHEN age_nm >= 15
		and age_nm <= 19 THEN '15-19 años'
		WHEN age_nm >= 20
		and age_nm <= 24 THEN '20-24 años'
		WHEN age_nm >= 25
		and age_nm <= 29 THEN '25-29 años'
		WHEN age_nm >= 30
		and age_nm <= 34 THEN '30-34 años'
		WHEN age_nm >= 35
		and age_nm <= 39 THEN '35-39 años'
		WHEN age_nm >= 40
		and age_nm <= 44 THEN '40-44 años'
		WHEN age_nm >= 45
		and age_nm <= 49 THEN '45-49 años'
		WHEN age_nm >= 50
		and age_nm <= 54 THEN '50-54 años'
		WHEN age_nm >= 55
		and age_nm <= 59 THEN '55-59 años'
		WHEN age_nm >= 60
		and age_nm <= 64 THEN '60-64 años'
		WHEN age_nm >= 65
		and age_nm <= 69 THEN '65-69 años'
		WHEN age_nm >= 70
		and age_nm <= 74 THEN '70-74 años'
		WHEN age_nm >= 75
		and age_nm <= 79 THEN '75-79 años'
		WHEN age_nm >= 80
		and age_nm <= 84 THEN '80-84 años'
		WHEN age_nm >= 85 THEN '85 años o más'
		ELSE NULL
	END as grupo_edad_cd from episode_view) a 
left join comorbidities b 
using(patient_id,cnh_cd,episode_id,admission_dt)
left join complications c
using(patient_id,cnh_cd,episode_id,admission_dt)
left join elixhauser d 
using(patient_id,cnh_cd,episode_id,admission_dt)
),
datos_cohort as (
select * from cirugia_oncologica_cohort
union all 
select * from cirugia_programada_cohort
union all
select * from cirugia_urgente_cohort
union all
select * from proceso_medico_cohort
)
select cnh_cd,year,cohort, category_cohort,count(distinct patient_id || '-' || episode_id) as n_unique_episode, median(age_nm) as mediana_edad,
(QUANTILE_CONT(age_nm, 0.75)-QUANTILE_CONT(age_nm, 0.25)) as iqr_age,
count(distinct patient_id || '-' || episode_id) filter(where sex_cd = '2') as n_mujeres,
count(*) filter(where discharge_type_cd = '4') as n_exitus,
median(los) as mediana_los,
sum(asa_cd::INT) filter(where asa_cd ='1') as asa_cd_1,
sum(asa_cd::INT) filter(where asa_cd ='2') as asa_cd_2,
sum(asa_cd::INT) filter(where asa_cd ='3') as asa_cd_3,
sum(asa_cd::INT) filter(where asa_cd ='4') as asa_cd_4,
sum(asa_cd::INT) filter(where asa_cd ='5') as asa_cd_5,
sum(asa_cd::INT) filter(where asa_cd ='6') as asa_cd_6,
sum(brs_bl::INT) as brs_bl,
sum(eras_recovery_bl::INT) as eras_recovery_bl,
sum(aids_bl::INT) as aids_bl,
sum(ami_bl::INT) as ami_bl,
sum(chf_bl::INT) as chf_bl,
sum(ckd_bl::INT) as ckd_bl,
sum(copd_bl::INT) as copd_bl,
sum(ctp_bl::INT) as ctp_bl,
sum(cvd_bl::INT) as cvd_bl,
sum(dementia_bl::INT) as dementia_bl,
sum(hemiplegia_bl::INT) as hemiplegia_bl,
sum(leuk_bl::INT) as leuk_bl,
sum(lymph_bl::INT) as lymph_bl,
sum(mildliver_bl::INT) as mildliver_bl,
sum(mtx_bl::INT) as mtx_bl,
sum(orgdiab_bl::INT) as orgdiab_bl,
sum(peptic_bl::INT) as peptic_bl,
sum(pvd_bl::INT) as pvd_bl,
sum(severeliver_bl::INT) as severeliver_bl,
sum(tumor_bl::INT) as tumor_bl,
sum(uncdiab_bl::INT) as uncdiab_bl,
sum(akic_bl::INT) as akic_bl,
sum(amic_bl::INT) as amic_bl,
sum(anastomotic_breakdown_bl::INT) as anastomotic_breakdown_bl,
sum(ardsc_bl::INT) as ardsc_bl,
sum(arrythc_bl::INT) as arrythc_bl,
sum(bloodinfc_bl::INT) as bloodinfc_bl,
sum(cardiacc_bl::INT) as cardiacc_bl,
sum(cpec_bl::INT) as cpec_bl,
sum(deliriumc_bl::INT) as deliriumc_bl,
sum(dvtc_bl::INT) as dvtc_bl,
sum(gastroc_bl::INT) as gastroc_bl,
sum(ileusc_bl::INT) as ileusc_bl,
sum(myoinfc_bl::INT) as myoinfc_bl,
sum(pneumc_bl::INT) as pneumc_bl,
sum(postophemc_bl::INT) as postophemc_bl,
sum(pulmemb_bl::INT) as pulmemb_bl,
sum(ssinfc_bl::INT) as ssinfc_bl,
sum(strokec_bl::INT) as strokec_bl,
sum(transfaec_bl::INT) as transfaec_bl,
sum(uncinfc_bl::INT) as uncinfc_bl,
sum(utic_bl::INT) as utic_bl,
sum(aids_bl::INT) as aids_bl_elix,
sum(alcohol_bl::INT) as alcohol_bl_elix,
sum(anemdef_bl::INT) as anemdef_bl_elix,
sum(autoimmune_bl::INT) as autoimmune_bl_elix,
sum(bldloss_bl::INT) as bldloss_bl_elix,
sum(cancer_leuk_bl::INT) as cancer_leuk_bl_elix,
sum(cancer_lymph_bl::INT) as cancer_lymph_bl_elix,
sum(cancer_mets_bl::INT) as cancer_mets_bl_elix,
sum(cancer_nsitu_bl::INT) as cancer_nsitu_bl_elix,
sum(cancer_solid_bl::INT) as cancer_solid_bl_elix,
sum(cbvd_poa_bl::INT) as cbvd_poa_bl_elix,
sum(cbvd_sqla_bl::INT) as cbvd_sqla_bl_elix,
sum(coag_bl::INT) as coag_bl_elix,
sum(dementia_bl::INT) as dementia_bl_elix,
sum(depress_bl::INT) as depress_bl_elix,
sum(diab_cx_bl::INT) as diab_cx_bl_elix,
sum(diab_uncx_bl::INT) as diab_uncx_bl_elix,
sum(drug_abuse_bl::INT) as drug_abuse_bl_elix,
sum(hf_bl::INT) as hf_bl_elix,
sum(htn_cx_bl::INT) as htn_cx_bl_elix,
sum(htn_uncx_bl::INT) as htn_uncx_bl_elix,
sum(liver_mld_bl::INT) as liver_mld_bl_elix,
sum(liver_sev_bl::INT) as liver_sev_bl_elix,
sum(lung_chronic_bl::INT) as lung_chronic_bl_elix,
sum(neuro_movt_bl::INT) as neuro_movt_bl_elix,
sum(neuro_oth_bl::INT) as neuro_oth_bl_elix,
sum(neuro_seiz_bl::INT) as neuro_seiz_bl_elix,
sum(obese_bl::INT) as obese_bl_elix,
sum(paralysis_bl::INT) as paralysis_bl_elix,
sum(perivasc_bl::INT) as perivasc_bl_elix,
sum(psychoses_bl::INT) as psychoses_bl_elix,
sum(pulmcirc_bl::INT) as pulmcirc_bl_elix,
sum(renlfl_mod_bl::INT) as renlfl_mod_bl_elix,
sum(renlfl_sev_bl::INT) as renlfl_sev_bl_elix,
sum(thyroid_hypo_bl::INT) as thyroid_hypo_bl_elix,
sum(thyroid_oth_bl::INT) as thyroid_oth_bl_elix,
sum(ulcer_peptic_bl::INT) as ulcer_peptic_bl_elix,
sum(valve_bl::INT) as valve_bl_elix,
sum(wghtloss_bl::INT) as wghtloss_bl_elix
from (
select * from datos_cohort a 
left join datos_episodio b 
using(patient_id,episode_id,start_intervention_dt)
)
group by cnh_cd,cohort, category_cohort,year
) TO '../../outputs/agregados_hospital_descriptivo_anual.csv' (FORMAT csv, DELIMITER '|', 
HEADER)
")

# =========================================================================
# Agregados outputs
# =========================================================================


list_cohort <- c('prod','pcad','icv','hist_no_onco','cist_radical','ncrl','ncra','hist_onco','ffem','hdig')

ind_serie_temp_process <- data.frame(ind=c('indicator_05_year','indicator_06_year',
                                   'indicator_07_year','indicator_08_year','indicator_09_year','indicator_10_year',
                                   'indicator_11_year','indicator_12_year','indicator_13_year','indicator_14_year',
                                   'indicator_15_year','indicator_16_year','indicator_17_year','indicator_18_year',
                                   'indicator_19_year','indicator_20_year','indicator_21_year','indicator_22_year',
                                   'indicator_23_year','indicator_24_year','indicator_25_year','indicator_26_year',
                                   'indicator_27_year','indicator_28_year','indicator_29_year','indicator_30_year',
                                   'indicator_31_year','indicator_32_year'),
                             descrip = c('Evaluación de la anemia preoperatoria con tiempo suficiente',
                                        'Estudio del metabolismo del hierro',
                                        'Estudio del metabolismo del hierro (Hb<13)',
                                        'Determinación de Hb reticulocitaria',
                                        'Determinación de Hb reticulocitaria (Hb<13)',
                                        'Tratamiento preoperatorio anemia',
                                        'Tratamiento preoperatorio anemia (Hb<13)',
                                        'Tratamiento preoperatorio (todos, anémicos y no anémicos)',
                                        'Hb de control',
                                        'Tratados preoperatoriamente con un incremento de Hb de +1 pto',
                                        'Incremento de Hb post tratamiento preoperatorio',
                                        'No transfundidos con hematíes en preoperatorio',
                                        'No transfundidos con plasma en preoperatorio',
                                        'No transfundidos con plaquetas en preoperatorio',
										'Días de estancia preoperatoria',
										'Episodios de pacientes intervenidos en <48 h desde la admisión',
                                        'Episodios de pacientes intervenidos sin anemia',
                                        'Episodios de pacientes intervenidos sin anemia (Hb>=13)',
                                        'Valor de Hb previo a la intervención',
                                        'Tratamiento postop. con hierro IV',
                                        'Episodios de pacientes con anestesia regional',
                                        'Tratamiento con antifibrinolíticos',
                                        'Episodios de pacientes con uso de recuperadores de sangre',
                                        'Tratamiento con fibrinógeno',
                                        'Tratamiento con fibrinógeno (para todos, con y sin valor de conc.fibrin.)',
                                        'Episodios de pacientes transfundidos con Hb<8',
                                        'Valor de Hb previo a la transfusión',
                                        'Transfusiones de una sola unidad de hematíes'))


ind_serie_temp_outcome <- data.frame(ind=c('indicator_35_year','indicator_36_year', 'indicator_36_year','indicator_36_year','indicator_36_year'),
                             descrip = c('Tasa de transfusión (hematíes)','Índice de transfusión (hematíes)',
                                         'Índice total de transfusión (hematíes)',
                                         'Índice total de transfusión (plaquetas)',
                                         'Índice total de transfusión (plasma)'),
                             code=c('HEM','HEM','HEM','PLAQ','PLAS'),
                             var=c('result','indice_transf','result','result','result'),
                             ind_plot=c('indicator_35','indicator_36_1', 'indicator_36_2','indicator_36_3','indicator_36_4')
                             )


for(cohort_ in list_cohort){

data_all <- data.frame()

data <- dbGetQuery(con_result, paste0("select * from indicator_01_year where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
}

data$result <- paste0('Promedio: ',data$promedio,' y Mediana: ', data$mediana)

data$descrip <- 'Promedio y mediana de la 1º Hb antes de la cirugía'
data$month_year <- as.numeric(format(data$month_year, "%Y"))
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_01_year'
data_all <- rbind(data_all,data)

data <- dbGetQuery(con_result, paste0("select * from indicator_01_year where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
}
data$result <- round(100*(data$n_episodios_l13/data$n_episodios),2)

data$descrip <- 'Prevalencia anemia preoperatoria (Hb<13) en %'
data$month_year <- as.numeric(format(data$month_year, "%Y"))
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_01_year'
data_all <- rbind(data_all,data)


for(i in ind_serie_temp_process$ind){
  data <- dbGetQuery(con_result, paste0("select * from ",i," where cohort = '",cohort_,"'"))
  ind_serie_temp_ <- ind_serie_temp_process %>% filter(ind %in% i)
    if(i %in% c('indicator_15_year','indicator_19_year','indicator_23_year','indicator_31_year')){
      if(nrow(data)==0){
 data[1,] <- NA 
}

      data$result <- paste0('Promedio: ',data$promedio,' y Mediana: ', data$mediana)
      data$descrip <- ind_serie_temp_$descrip
      data$month_year <- as.numeric(format(data$month_year, "%Y"))
      data <- data %>% dplyr::select(descrip,result,month_year)
      data$indicator <- i
}else{
  if(nrow(data)==0){
 data[1,] <- NA 
}
    data$descrip <- ind_serie_temp_$descrip
    data$result <- round(data$result,2)
    data$month_year <- as.numeric(format(data$month_year, "%Y"))
    data <- data %>% dplyr::select(descrip,result,month_year)
    data$indicator <- i
  }

  data_all <- rbind(data_all,data)
      
} 

##### composite #####################################################



data <- dbGetQuery(con, paste0("select *
from (
        select cohort,
            category_cohort,
            patient_id,
            episode_id,
            month_year,
            count(distinct composite) as n_composites,
            count(*) filter(
                where composite_bl
            ) as n_composites_true,
            round(n_composites_true * 100 / n_composites, 3) as perc_composite
        from composite_all
        group by cohort,
            category_cohort,
            patient_id,
            episode_id,
            month_year
    ) where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
}  
data$month_year <- as.numeric(format(data$month_year, "%Y"))
data <- data %>% group_by(month_year) %>% 
  summarise(promedio=round(mean(perc_composite,na.rm=TRUE),2),
            mediana=round(median(perc_composite,na.rm=TRUE),2))

data$descrip <- 'Porcentaje composite (opportunity based) por episodio'


data$result <- paste0('Promedio: ',data$promedio,' y Mediana: ', data$mediana)

data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'composite_all'
data_all <- rbind(data_all,data)


data <- dbGetQuery(con, paste0("select *
from (
        select cohort,
            category_cohort,
            patient_id,
            episode_id,
            month_year,
            count(distinct composite) as n_composites,
            count(*) filter(
                where composite_bl
            ) as n_composites_true,
            round(n_composites_true * 100 / n_composites, 3) as perc_composite
        from composite_all
        group by cohort,
            category_cohort,
            patient_id,
            episode_id,
            month_year
    ) where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
} 
  
data$month_year <- as.numeric(format(data$month_year, "%Y"))

data <- data %>% mutate(episodes_100 = ifelse(perc_composite==100,1,0))
data <- data %>% group_by(month_year,cohort) %>% 
  summarise(result=sum(episodes_100),
            n_episodes = length(unique(episode_id))) %>% 
  ungroup()
data$result <- round(100*(data$result/data$n_episodes),2)

data$descrip <- '% episodios con composite (all-or-none)'
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'composite_all'
data_all <- rbind(data_all,data)

########################################################################

##### outcome #####################################################



for(i in 1:nrow(ind_serie_temp_outcome)){
  ind_serie_temp_ <- ind_serie_temp_outcome[i,]
  data <- dbGetQuery(con_result, paste0("select * from ",ind_serie_temp_$ind," where cohort = '",cohort_,"'"))
  data <- data %>% filter(transftype_st %in% ind_serie_temp_$code)
  if(ind_serie_temp_$ind %in% c('indicator_35_year')){
    if(nrow(data)==0){
 data[1,] <- NA 
} 
      data$month_year <- as.numeric(format(data$month_year, "%Y"))
      
      data$descrip <- ind_serie_temp_$descrip
      data <- data %>% dplyr::select(descrip,result,month_year)
      data$indicator <- ind_serie_temp_$ind
    }else{
    if(nrow(data)==0){
 data[1,] <- NA 
}   
    data$month_year <- as.numeric(format(data$month_year, "%Y"))
    data$descrip <- ind_serie_temp_$descrip
    data <- data %>% 
      dplyr::select(month_year,descrip,result=ind_serie_temp_$var)
    data$indicator <- ind_serie_temp_$ind
}
    data_all <- rbind(data_all,data)
  }


data <- dbGetQuery(con_result, paste0("select * from indicator_40_year where cohort = '",cohort_,"' and transfundido_bl is false"))
if(nrow(data)==0){
 data[1,] <- NA 
} 
data$result <- paste0('Promedio: ',data$promedio,' y Mediana: ', data$mediana)

data$descrip <- 'Promedio y mediana de Hb alta no transfundidos'
data$month_year <- as.numeric(format(data$month_year, "%Y"))
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_40_year'
data_all <- rbind(data_all,data)

data <- dbGetQuery(con_result, paste0("select * from indicator_40_year where cohort = '",cohort_,"' and transfundido_bl"))
if(nrow(data)==0){
 data[1,] <- NA 
} 
data$result <- paste0('Promedio: ',data$promedio,' y Mediana: ', data$mediana)

data$descrip <- 'Promedio y mediana de Hb alta transfundidos'
data$month_year <- as.numeric(format(data$month_year, "%Y"))
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_40_year'
data_all <- rbind(data_all,data)


data <- dbGetQuery(con_result, paste0("select * from indicator_42_year where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
} 
data$result <- paste0('Promedio: ',data$promedio,' y Mediana: ', data$mediana)

data$descrip <- 'Promedio y mediana de días de estancia hospitalaria'
data$month_year <- as.numeric(format(data$month_year, "%Y"))
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_42_year'
data_all <- rbind(data_all,data)


data <- dbGetQuery(con_result, paste0("select * from indicator_43_year where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
}
data$month_year <- as.numeric(format(data$month_year, "%Y"))

data <- data %>% group_by(month_year) %>% summarise(result=sum(result,na.rm = TRUE))
data$descrip <- 'Reingresos 30 días'
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_43_year'
data_all <- rbind(data_all,data)

data <- dbGetQuery(con_result, paste0("select * from indicator_44_year where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
}
data$month_year <- as.numeric(format(data$month_year, "%Y"))

data$descrip <- 'Mortalidad intra-hospitalaria'
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_44_year'
data_all <- rbind(data_all,data)


data <- dbGetQuery(con_result, paste0("select * from indicator_45_year where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
}
data$month_year <- as.numeric(format(data$month_year, "%Y"))

data <- data %>% group_by(month_year) %>% summarise(result=sum(result,na.rm = TRUE))

data$descrip <- 'Episodios con complicaciones'
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_45_year'
data_all <- rbind(data_all,data)

data <- dbGetQuery(con_result, paste0("select * from indicator_46_year where cohort = '",cohort_,"'"))
if(nrow(data)==0){
 data[1,] <- NA 
}
data$month_year <- as.numeric(format(data$month_year, "%Y"))
data <- data %>% pivot_longer(!c(cohort,category_cohort,month_year),names_to = 'complc',values_to = 'result')

data <- data %>% group_by(month_year,complc) %>% summarise(result=sum(result,na.rm = TRUE))
data$descrip <- paste0('N episodios con complicaciones desglosado (',data$complc,')')
data <- data %>% dplyr::select(descrip,result,month_year)
data$indicator <- 'indicator_46_year'
data_all <- rbind(data_all,data)
data_all$cohort <- cohort_

duckdb_register(con_result,"datos_promedio",data_all)

data_all <- dbGetQuery(con_result, 
"with datos as (
select
	descrip,
	replace(descrip, 'y mediana ', '') as descrip_promedio,
	trim(trim(replace(replace(descrip, 'Promedio y', ''), 'mediana', 'Mediana'))) as descrip_mediana,
	month_year,
	indicator,
	cohort,
	replace(split_part(result, 'y', 1), 'Promedio: ', '') as promedio,
	trim(replace(split_part(result, 'y', 2), 'Mediana: ', '')) as mediana
from
	(
	select
		*
	from
		datos_promedio
	where
		descrip like 'Promedio y mediana%')
),
datos_resto as (select * from datos_promedio 
where descrip not like 'Promedio y mediana%' and (indicator not in ('indicator_15_year','indicator_19_year','indicator_23_year','indicator_31_year',
'composite_all') and (result not like 'Promedio%' or result is null))),
datos_promedios as (
select descrip || ' (mediana)' as descrip_mediana,
	descrip || ' (promedio)' as descrip_promedio,
	month_year,
	indicator,
	cohort,
	replace(split_part(result, 'y', 1), 'Promedio: ', '') as promedio,
	trim(replace(split_part(result, 'y', 2), 'Mediana: ', '')) as mediana
from (select * from datos_promedio where indicator in ('indicator_15_year', 'indicator_19_year', 'indicator_23_year', 'indicator_31_year', 'composite_all')
			and result like 'Promedio%'))
select
	descrip_promedio as descrip,
	trim(promedio) as result,
	month_year,
	indicator,
	cohort
from
	datos
union all 
select
	descrip_mediana as descrip,
	trim(mediana) as result,
	month_year,
	indicator,
	cohort
from
	datos
union all 
select
	descrip_promedio as descrip,
	trim(promedio) as result,
	month_year,
	indicator,
	cohort
from
	datos_promedios
union all 
select
	descrip_mediana as descrip,
	trim(mediana) as result,
	month_year,
	indicator,
	cohort
from
	datos_promedios
	union all 
	select * from datos_resto
")
duckdb_unregister(con_result,"datos_promedio")
data_all$result[data_all$result %in% "NA"] <- NA
data_all$hospital <- unique(hospital$cnh_cd)
data_all <- data_all |> dplyr::rename(year=month_year)
write.table(data_all,paste0('../../outputs/tabla_indicadores_agregado_anual_',cohort_,'.csv'),sep='|',row.names=FALSE)

}

