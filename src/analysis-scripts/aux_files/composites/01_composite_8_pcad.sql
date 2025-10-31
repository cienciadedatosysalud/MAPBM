-- pacientes que cumplen compisite prod y pcad indicador 30
create or replace view composite_8 as with denominador as (
        select a.*,
            discharge_dt,
            admission_dt
        from (
                select *
                from cirugia_programada_cohort a
                union all
                select *
                from cirugia_oncologica_cohort a
                union all
                select *
                from cirugia_urgente_cohort a
                union all
                select *
                from proceso_medico_cohort a
            ) a
            left join (
                select patient_id,
                    episode_id,
                    discharge_dt,
                    start_intervention_dt,
                    admission_dt,
                    cohort
                from episode_view
            ) b on a.patient_id = b.patient_id
            and a.episode_id = b.episode_id
            and a.start_intervention_dt = b.start_intervention_dt
    ),
    denominador_trasnfundidos as (
        select a.*,
            hb_l8
        from denominador a
            left join (
                select *
                from (
                        select *
                        from (
                                select *
                                from transfusion_view
                                where transf_administered_bl
                            ) a
                            left join (
                                select patient_id,
                                    result_determination_cd,
                                    result_determination_dt,
                                    (result_determination_cd::float < 8) as hb_l8
                                from lab_view
                                where determination_cd = 'hb'
                            ) b on a.patient_id = b.patient_id
                            and a.transf_dt between b.result_determination_dt and b.result_determination_dt + interval 1 DAY
                        where b.patient_id is not null
                    )
            ) b on a.patient_id = b.patient_id
            and transf_dt between admission_dt and discharge_dt
            and b.result_determination_dt between admission_dt and discharge_dt
        where b.patient_id is not null
            and cohort in ('prod', 'pcad')
    )
select *
from (
        select distinct patient_id,
            episode_id,
            start_intervention_dt,
            cohort,
            category_cohort,
            'composite8' as composite,
            case
                when hb_l8 is true then true
                else false
            end as composite_bl
        from denominador_trasnfundidos a
    );