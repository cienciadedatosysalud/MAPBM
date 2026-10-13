create or replace table cirugia_programada_cohort as 
select a.* from cirugia_programada_cohort a 
left join episode_valid_intervention b 
using (patient_id,episode_id,start_intervention_dt);
