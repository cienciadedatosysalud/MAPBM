create or replace table proceso_medico_cohort as 
select a.* from proceso_medico_cohort a 
left join episode_valid_admission b 
using (patient_id,episode_id,admission_dt);