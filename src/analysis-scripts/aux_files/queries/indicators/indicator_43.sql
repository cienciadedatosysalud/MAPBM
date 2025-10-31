--- Indicadores Outcome Nº43 indicador 
--- Reingresos 30 días
with denominador as (
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
)
select cohort,
    category_cohort,
    month_year,
    count(*) as result
from (
        select *,
            date_trunc('month', a.start_intervention_dt) as month_year,
            case
                when b.patient_id is not null then true
                else false
            end as reingreso_bl
        from episode_view a
            left join (
                select patient_id,
                    episode_id,
                    admission_dt,
                    start_intervention_dt,
                    discharge_dt,
                    cohort,
                    category_cohort
                from denominador
            ) b on a.patient_id = b.patient_id
            and a.admission_dt between b.discharge_dt and b.discharge_dt + INTERVAL 30 DAY
    )
where reingreso_bl
group by cohort,
    category_cohort,
    month_year;