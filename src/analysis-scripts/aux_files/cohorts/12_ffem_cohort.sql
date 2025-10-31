--- Cirugía de fractura de fémur proximal Cirugía Urgente
--- TODO: Cambiar ruta de los ficheros de absoluta a relativa estructrura de proyecto
create or replace table ffem_cohort as with proc_inclusion_df as (
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
        where Cohort = 'Fractura de Fémur'
    ),
    patients_to_include as (
        select patient_id,
            episode_id,
            sex_cd,
            age_nm,
            start_intervention_dt,
            [proc1,proc2,proc3,proc4,proc5,proc6,proc7,proc8,proc9,proc10,proc11,proc12,proc13,proc14,proc15,proc16,proc17,proc18,proc19,proc20] && b.proc_incl
            and [d1] && b.diag_incl as ffem
        from episode_view a,
            proc_inclusion_df b
        where a.planification_cd = '1'
    )
select *,
    'CIR_URG' as category_cohort
from patients_to_include
where ffem;