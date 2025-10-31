--- Hemorragia gastrointestinal Proceso médico
create or replace table hdig_cohort as
select distinct *
from (
        select *
        from (
                with proc_inclusion_df as (
                    select array_agg(code_clean) filter(
                            where "Tipo código" != 'Procedimiento'
                        ) diag_incl
                    from read_csv(
                            '../../docs/CDM/cohort_definition_inclusion.csv',
                            header = true,
                            all_varchar = TRUE
                        )
                    where Cohort = 'Hemorragia Digestiva'
                        and "Inclusión/Exclusión" = 'I'
                ),
                patients_to_include as (
                    select patient_id,
                        episode_id,
                        sex_cd,
                        age_nm,
                        start_intervention_dt,
                        [d1] && b.diag_incl as hdig
                    from episode_view a,
                        proc_inclusion_df b
                    where a.planification_cd = '1'
                )
                select *,
                    'PROC_MED' as category_cohort
                from patients_to_include
                where hdig
            )
        union all
        select *
        from (
                with proc_inclusion_df as (
                    select array_agg(code_clean) filter(
                            where "Tipo código" != 'Procedimiento'
                        ) diag_incl
                    from read_csv(
                            '../../docs/CDM/cohort_definition_inclusion.csv',
                            header = true,
                            all_varchar = TRUE
                        )
                    where Cohort = 'Hemorragia Digestiva'
                        and "Inclusión/Exclusión" = 'I'
                ),
                patients_to_include as (
                    select patient_id,
                        episode_id,
                        sex_cd,
                        age_nm,
                        start_intervention_dt,
                        (
                            [d2,d3,d4,d5] && b.diag_incl
                            and (
                                d1 LIKE ('K70%')
                                or d1 LIKE ('K71%')
                                or d1 LIKE ('K743%')
                                or d1 LIKE ('K744%')
                                or d1 LIKE ('K745%')
                                or d1 LIKE ('K746%')
                                or d1 LIKE ('K7581')
                            )
                        ) as hdig
                    from episode_view a,
                        proc_inclusion_df b
                    where a.planification_cd = '1'
                )
                select *,
                    'PROC_MED' as category_cohort
                from patients_to_include
                where hdig
            )
    );