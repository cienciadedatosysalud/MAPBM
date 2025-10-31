--- Indicadores process preop pillar1 indicador 5
--- % de pacientes con evaluación de la anemia preoperatoria con tiempo suficiente
-------------------------------------------
select cohort,category_cohort,month_year,
	coalesce(n_patients,0) as n_patients,
	coalesce(n_unique_episode,0) as n_unique_episode,
    n_patients_total,
    n_episode_total,
    round(coalesce(n_patients,0) * 100 / n_patients_total, 3) as result_patient,
    round(coalesce(n_unique_episode,0)  * 100 / n_episode_total, 3) as result
from (
        select cohort,
            category_cohort,
            month_year,
            count(distinct a.patient_id) as n_patients,
            count(distinct a.patient_id || '-' || episode_id) as n_unique_episode
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
                    category_cohort,
                    month_year
                from cirugia_programada_cohort
            ) b on a.patient_id = b.patient_id
            and result_determination_dt between start_intervention_dt - INTERVAL 90 DAY
            and start_intervention_dt - INTERVAL 21 DAY
        where b.patient_id is not null
        group by cohort,
            category_cohort,
            month_year
        union all
        select cohort,
            category_cohort,
            month_year,
            count(distinct a.patient_id) as n_patients,
            count(distinct a.patient_id || '-' || episode_id) as n_unique_episode
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
                    category_cohort,
                    month_year
                from cirugia_oncologica_cohort
            ) b on a.patient_id = b.patient_id
            and result_determination_dt between start_intervention_dt - INTERVAL 45 DAY
            and start_intervention_dt - INTERVAL 15 DAY
        where b.patient_id is not null
        group by cohort,
            category_cohort,
            month_year
        union all
        select cohort,
            category_cohort,
            month_year,
            count(distinct a.patient_id) as n_patients,
            count(distinct a.patient_id || '-' || episode_id) as n_unique_episode
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
                    category_cohort,
                    month_year
                from cirugia_urgente_cohort
            ) b on a.patient_id = b.patient_id
            and result_determination_dt between start_intervention_dt - INTERVAL 5 DAY
            and start_intervention_dt - INTERVAL 0 DAY
        where b.patient_id is not null
        group by cohort,
            category_cohort,
            month_year
    ) a
    full outer join (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_patients_total,
            count(distinct patient_id || '-' || episode_id) as n_episode_total
        from cirugia_programada_cohort
        group by cohort,
            category_cohort,
            month_year
        union all
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_patients_total,
            count(distinct patient_id || '-' || episode_id) as n_episode_total
        from cirugia_oncologica_cohort
        group by cohort,
            category_cohort,
            month_year
        union all
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_patients_total,
            count(distinct patient_id || '-' || episode_id) as n_episode_total
        from cirugia_urgente_cohort
        group by cohort,
            category_cohort,
            month_year
    ) b using(cohort,category_cohort,month_year) ;



