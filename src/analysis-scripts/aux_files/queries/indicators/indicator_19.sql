--- Indicadores process preop pillar1 Nº19 indicador Pillar3
--- Días de estancia preoperatoria en fractura de fémur
-------------------------------------------
select cohort,
    category_cohort,
    month_year,
    round(
        AVG(
            epoch(a.start_intervention_dt - admission_dt) / 86400.0
        ),
        3
    ) as promedio,
    median(
        epoch(a.start_intervention_dt - admission_dt) / 86400.0
    ) as mediana
from (
        select patient_id,
            episode_id,
            admission_dt,
            discharge_dt,
            start_intervention_dt,
            from episode_view
    ) a
    left join (
        select patient_id,
            episode_id,
            start_intervention_dt,
            cohort,
            category_cohort,
            month_year
        from cirugia_urgente_cohort a
    ) b on a.patient_id = b.patient_id
    and a.start_intervention_dt = b.start_intervention_dt
    and a.episode_id = b.episode_id
where b.patient_id is not null
group by cohort,
    category_cohort,
    month_year;