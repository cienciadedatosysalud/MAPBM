-- pacientes que cumplen compisite prod y pcad indicador 25 
create or replace view composite_6 as
select *
from (
        with denominador as (
            select a.*,
                discharge_dt,
                end_intervention_dt,
                anesth_cd,
                brs_bl
            from (
                    select *
                    from cirugia_programada_cohort a
                    union all
                    select *
                    from cirugia_oncologica_cohort a
                    union all
                    select *
                    from cirugia_urgente_cohort a
                ) a
                left join (
                    select patient_id,
                        episode_id,
                        discharge_dt,
                        start_intervention_dt,
                        end_intervention_dt,
                        anesth_cd,
                        brs_bl
                    from episode_view
                ) b on a.patient_id = b.patient_id
                and a.episode_id = b.episode_id
                and a.start_intervention_dt = b.start_intervention_dt
        )
        select a.*,
            'composite6' as composite,
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
                from denominador
                where anesth_cd = '2'
                    and cohort in ('prod', 'pcad')
            ) b on a.patient_id = b.patient_id
            and a.episode_id = b.episode_id
            and a.start_intervention_dt = b.start_intervention_dt
            and a.cohort = b.cohort
    );