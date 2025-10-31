--- Indicadores process preop pillar1 indicador 9
--- % de pacientes anémicos con determinación de concentración Hb reticulocitaria anemic 13
-------------------------------------------
select cohort,category_cohort,month_year,
	coalesce(n_pacientes_ret_he,0) as n_pacientes_ret_he,
	coalesce(n_unique_episode_ret_he,0) as n_unique_episode_ret_he ,
    n_pacientes,
    n_unique_episode,
    round(coalesce(n_pacientes_ret_he,0) * 100 / n_pacientes, 3) as result_patient,
    round(
        coalesce(n_unique_episode_ret_he,0) * 100 / n_unique_episode,
        3
    ) as result
from (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_pacientes_ret_he,
            count(distinct patient_id || '-' || episode_id) as n_unique_episode_ret_he
        from (
                select *
                from (
                        select patient_id,
                            episode_id,
                            start_intervention_dt,
                            cohort,
                            category_cohort,
                            month_year
                        from cirugia_programada_cohort
                        where anemic_oms
                    ) a
                    left join (
                        select *
                        from lab_view
                        where determination_cd = 'ret_he'
                    ) b on a.patient_id = b.patient_id
                    and result_determination_dt between start_intervention_dt - INTERVAL 90 DAY
                    and start_intervention_dt - INTERVAL 21 DAY
                where b.patient_id is not null
                union all
                select *
                from (
                        select patient_id,
                            episode_id,
                            start_intervention_dt,
                            cohort,
                            category_cohort,
                            month_year
                        from cirugia_oncologica_cohort
                        where anemic_13
                    ) a
                    left join (
                        select *
                        from lab_view
                        where determination_cd = 'ret_he'
                    ) b on a.patient_id = b.patient_id
                    and result_determination_dt between start_intervention_dt - INTERVAL 45 DAY
                    and start_intervention_dt - INTERVAL 15 DAY
                where b.patient_id is not null
                union all
                select *
                from (
                        select patient_id,
                            episode_id,
                            start_intervention_dt,
                            cohort,
                            category_cohort,
                            month_year
                        from cirugia_urgente_cohort
                        where anemic_13
                    ) a
                    left join (
                        select *
                        from lab_view
                        where determination_cd = 'ret_he'
                    ) b on a.patient_id = b.patient_id
                    and result_determination_dt between start_intervention_dt - INTERVAL 5 DAY
                    and start_intervention_dt - INTERVAL 0 DAY
                where b.patient_id is not null
            )
        group by cohort,
            category_cohort,
            month_year
    ) a
    full outer join (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_pacientes,
            count(distinct patient_id || '-' || episode_id) as n_unique_episode
        from (
                select patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort,
                    month_year
                from (
                        select *
                        from cirugia_programada_cohort
                        where anemic_13
                        union all
                        select *
                        from cirugia_oncologica_cohort
                        where anemic_13
                        union all
                        select *
                        from cirugia_urgente_cohort
                        where anemic_13
                    )
            )
        group by cohort,
            category_cohort,
            month_year
    ) b using(cohort,category_cohort,month_year);