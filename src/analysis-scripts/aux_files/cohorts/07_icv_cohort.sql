-- Cirugía de válvula cardiaca Cirugía Programada
create or replace table icv_cohort as with proc_inclusion_df as (
        select array_agg(code_clean) AS proc_incl
        from read_csv(
                '../../docs/CDM/cohort_definition_inclusion.csv',
                header = true,
                all_varchar = TRUE
            )
        where Cohort = 'Cirugía Valvular Cardíaca'
    ),
    proc_exclusion_df as (
        select array_agg(code_clean) filter(
                where "Tipo código" = 'Procedimiento'
            ) as proc_exc
        from read_csv(
                '../../docs/CDM/cohort_definition_exclusion.csv',
                header = true,
                all_varchar = TRUE
            )
        where Cohort = 'Cirugía Valvular Cardíaca'
    ),
    patients_to_exclude as (
        select patient_id,
            episode_id,
            start_intervention_dt
        from episode_view a,
            proc_exclusion_df b
        where (
                [proc1,proc2,proc3,proc4,proc5,proc6,proc7,proc8,proc9,proc10,proc11,proc12,proc13,proc14,proc15,proc16,proc17,proc18,proc19,proc20] && b.proc_exc
            )
    ),
    patients_to_include as (
        select patient_id,
            episode_id,
            sex_cd,
            age_nm,
            start_intervention_dt,
            [proc1,proc2,proc3,proc4,proc5,proc6,proc7,proc8,proc9,proc10,proc11,proc12,proc13,proc14,proc15,proc16,proc17,proc18,proc19,proc20] && b.proc_incl as icv
        from episode_view a,
            proc_inclusion_df b,
            proc_exclusion_df c
        where a.planification_cd = '2'
    )
select a.patient_id,
    a.episode_id,
    sex_cd,
    age_nm,
    a.start_intervention_dt,
    icv,
    'CIR_PROG' as category_cohort
from patients_to_include a
    left join patients_to_exclude b on a.patient_id = b.patient_id
    and a.start_intervention_dt = b.start_intervention_dt
where b.patient_id is null
    and icv is true;