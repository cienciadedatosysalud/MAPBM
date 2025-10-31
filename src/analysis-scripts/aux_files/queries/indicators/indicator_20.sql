--- Indicadores process preop pillar1 Nº20 indicador Pillar3
--- % de pacientes intervenidos en <48 h desde la admisión
-------------------------------------------
select cohort,
    category_cohort,
    month_year,
    count(*) filter(
        where diff < 2
    ) as n_pacientes_intervention_l48h,
    count(*) as n_pacientes,
    round(
        n_pacientes_intervention_l48h * 100 / n_pacientes,
        3
    ) as result
from (
        select *,
            epoch(a.start_intervention_dt - admission_dt) / 86400.0 as diff
        from (
                select patient_id,
                    episode_id,
                    admission_dt,
                    discharge_dt,
                    start_intervention_dt
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
    )
group by cohort,
    category_cohort,
    month_year;