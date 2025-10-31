--- Indicadores Outcome Nº42 indicador 
--- Días de estancia hospitalaria
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
    round(
        avg(epoch(discharge_dt - admission_dt) / 86400.0),
        3
    ) as promedio,
    round(
        median(epoch(discharge_dt - admission_dt) / 86400.0),
        3
    ) as mediana
from denominador
group by cohort,
    category_cohort,
    month_year;