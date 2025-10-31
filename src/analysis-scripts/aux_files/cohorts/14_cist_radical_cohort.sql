--- Cistectomías radicales Cirugía Programada
create or replace table cist_radical_cohort as with proc_inclusion_df as (
        select array_agg(code_clean) filter(
                where "Tipo código" = 'Procedimiento'
            ) AS proc_incl
        from read_csv(
                '../../docs/CDM/cohort_definition_inclusion.csv',
                header = true,
                all_varchar = TRUE
            )
        where Cohort = 'Cistectomías radicales'
    ),
    patients_to_include as (
        select patient_id,
            episode_id,
            sex_cd,
            age_nm,
            start_intervention_dt,
            [proc1,proc2,proc3,proc4,proc5,proc6,proc7,proc8,proc9,proc10,proc11,proc12,proc13,proc14,proc15,proc16,proc17,proc18,proc19,proc20] && b.proc_incl as cist_radical
        from episode_view a,
            proc_inclusion_df b
        where a.planification_cd = '2'
    )
select *,
    'CIR_PROG' as category_cohort
from patients_to_include
where cist_radical