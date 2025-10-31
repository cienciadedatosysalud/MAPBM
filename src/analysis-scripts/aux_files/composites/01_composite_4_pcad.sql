-- pacientes que cumplen compisite prod y pcad indicador 21 
create or replace view composite_4 as
select *
from (
        select a.*,
            'composite4' as composite,
            case
                when b.patient_id is not null then true
                else false
            end as composite_bl
        from (
                select distinct patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort
                from cirugia_programada_cohort
                where cohort in ('prod', 'pcad')
            ) a
            left join (
                select distinct patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort
                from (
                        select *,
                            case
                                when result_determination_cd::float < 13 then true
                                else false
                            end as anemic_13,
                            case
                                when result_determination_cd::float < 13
                                and sex_cd = '1' then true
                                when result_determination_cd::float < 12
                                and sex_cd = '2' then true
                                else false
                            end as anemic_oms
                        from (
                                select row_number() over(
                                        partition by a.patient_id,
                                        episode_id,
                                        cohort,
                                        start_intervention_dt
                                        order by result_determination_dt DESC
                                    ) as rk,
                                    *
                                from (
                                        select *
                                        from lab_view
                                        where determination_cd = 'hb'
                                    ) a
                                    left join (
                                        select patient_id,
                                            episode_id,
                                            sex_cd,
                                            start_intervention_dt,
                                            cohort,
                                            category_cohort
                                        from cirugia_programada_cohort
                                    ) b on a.patient_id = b.patient_id
                                    and a.result_determination_dt  between start_intervention_dt - interval 120 DAY and start_intervention_dt
                                where b.patient_id is not null
                            )
                        where rk = 1
                            and not anemic_oms
                            and cohort in ('prod', 'pcad')
                    )
            ) b on a.patient_id = b.patient_id
            and a.episode_id = b.episode_id
            and a.start_intervention_dt = b.start_intervention_dt
            and a.cohort = b.cohort
    );