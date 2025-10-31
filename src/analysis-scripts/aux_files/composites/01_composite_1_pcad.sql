-- pacientes que cumplen el composite prod y pcad  indicador 5
-- numerador 
create or replace view composite_1 as
select a.*,
    'composite1' as composite,
    case
        when b.patient_id is not null then true
        else false
    end as composite_bl
from (
        select patient_id,
            episode_id,
            start_intervention_dt,
            cohort,
            category_cohort
        from cirugia_programada_cohort
        where cohort in ('prod', 'pcad')
    ) a
    left join (
        select *
        from (
                select distinct a.patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort
                from (
                        select patient_id,
                            result_determination_cd,
                            result_determination_dt
                        from lab_view
                        where determination_cd = 'hb'
                    ) a
                    left join (
                        select patient_id,
                            episode_id,
                            start_intervention_dt,
                            cohort,
                            category_cohort
                        from cirugia_programada_cohort
                    ) b on a.patient_id = b.patient_id
                    and result_determination_dt between start_intervention_dt - INTERVAL 90 DAY
                    and start_intervention_dt - INTERVAL 21 DAY
                where b.patient_id is not null
                    and cohort in ('prod', 'pcad')
            )
    ) b on a.patient_id = b.patient_id
    and a.episode_id = b.episode_id
    and a.start_intervention_dt = b.start_intervention_dt
    and a.cohort = b.cohort;