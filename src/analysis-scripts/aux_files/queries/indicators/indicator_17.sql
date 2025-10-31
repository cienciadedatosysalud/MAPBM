--- Indicadores process preop pillar1 Nº17 indicador Pillar3
--- % de pacientes no transfundidos con plasma en preoperatorio
-------------------------------------------
with transfusions as (
    select *
    from transfusion_view
    where transf_administered_bl is true
        and transftype_cd = 'B05AX03'
),
denominador as (
    select cohort,
        category_cohort,
        month_year,
        count(distinct patient_id) as n_paciente,
        count(distinct patient_id || '-' || episode_id) as n_unique_episode
    from (
            select *
            from cirugia_programada_cohort
            union all
             select *
            from cirugia_oncologica_cohort
            union all
            select *
            from cirugia_urgente_cohort
        )
    group by cohort,
        category_cohort,
        month_year
)
select cohort,category_cohort,month_year,
	coalesce(n_paciente_transfusion,0) as n_paciente_transfusion,
	coalesce(n_unique_episode_transfusion,0) as n_unique_episode_transfusion,
    n_paciente,
    n_unique_episode,
    100 - round(coalesce(n_paciente_transfusion,0) * 100 / n_paciente, 3) as result_patient,
    100 - round(
        coalesce(n_unique_episode_transfusion,0) * 100 / n_unique_episode,
        3
    ) as result
from (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_paciente_transfusion,
            count(distinct patient_id || '-' || episode_id) as n_unique_episode_transfusion
        from (
                select *
                from cirugia_urgente_cohort a
                    left join transfusions b on a.patient_id = b.patient_id
                    and b.transf_dt between a.start_intervention_dt - INTERVAL 5 DAY
                    and start_intervention_dt
                where b.patient_id is not null
            )
        group by cohort,
            category_cohort,
            month_year
        union all
        select *
        from (
                select cohort,
                    category_cohort,
                    month_year,
                    count(distinct patient_id) as n_paciente_transfusion,
                    count(distinct patient_id || '-' || episode_id) as n_unique_episode_transfusion
                from (
                        select *
                        from cirugia_programada_cohort a
                            left join transfusions b on a.patient_id = b.patient_id
                            and b.transf_dt between a.start_intervention_dt - INTERVAL 7 DAY
                            and start_intervention_dt
                        where b.patient_id is not null
                    )
                group by cohort,
                    category_cohort,
                    month_year
            )
        union all
        select *
        from (
                select cohort,
                    category_cohort,
                    month_year,
                    count(distinct patient_id) as n_paciente_transfusion,
                    count(distinct patient_id || '-' || episode_id) as n_unique_episode_transfusion
                from (
                        select *
                        from cirugia_oncologica_cohort a
                            left join transfusions b on a.patient_id = b.patient_id
                            and b.transf_dt between a.start_intervention_dt - INTERVAL 7 DAY
                            and start_intervention_dt
                        where b.patient_id is not null
                    )
                group by cohort,
                    category_cohort,
                    month_year
            )
    ) a
    full outer join denominador b using(cohort,category_cohort, month_year);


