create or replace table cirugia_oncologica_cohort as 
select a.* from cirugia_oncologica_cohort a 
left join episode_valid_intervention b 
using (patient_id,episode_id,start_intervention_dt);