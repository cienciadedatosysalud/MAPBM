--- Cirugía colorectal abierta Cirugía Oncológica
create or replace table ncra_cohort as with proc_inclusion_df as (
        select array_agg(code_clean) filter(
                where "Tipo código" = 'Procedimiento'
            ) AS proc_incl,
            array_agg(code_clean) filter(
                where "Tipo código" != 'Procedimiento'
            ) diag_incl
        from read_csv(
                '../../docs/CDM/cohort_definition_inclusion.csv',
                header = true,
                all_varchar = TRUE
            )
        where Cohort = 'Cirugía Cáncer Colorectal'
            and (
                Subcohort = 'Abierta'
                or Subcohort is null
            )
    ),
    proc_exclusion_df as (
        select array_agg(code_clean) filter(
                where "Tipo código" != 'Procedimiento'
            ) as diag_exc
        from read_csv(
                '../../docs/CDM/cohort_definition_exclusion.csv',
                header = true,
                all_varchar = TRUE
            )
        where Cohort = 'Cirugía Cáncer Colorectal'
    ),
    patients_to_exclude as (
        select patient_id,
            episode_id,
            start_intervention_dt
        from episode_view a,
            proc_exclusion_df b
        where (
                [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && b.diag_exc
            )
    ),
    patients_to_include as (
        select patient_id,
            episode_id,
            sex_cd,
            age_nm,
            start_intervention_dt,
            [proc1,proc2,proc3,proc4,proc5,proc6,proc7,proc8,proc9,proc10,proc11,proc12,proc13,proc14,proc15,proc16,proc17,proc18,proc19,proc20] && b.proc_incl
            and [d1] && b.diag_incl as ncra
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
    ncra,
    'CIR_ONCO' as category_cohort
from patients_to_include a
    left join patients_to_exclude b on a.patient_id = b.patient_id
    and a.start_intervention_dt = b.start_intervention_dt
where b.patient_id is null
    and ncra;