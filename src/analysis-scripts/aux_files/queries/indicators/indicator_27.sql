--- Indicadores process preop pillar1 Nº27 indicador Pillar2
--- % de pacientes con uso de recuperadores de sangre
with denominador as (
    select a.*,
        discharge_dt,
        end_intervention_dt,
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
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id||'_'||episode_id) filter(
        where brs_bl
    ) as n_pacientes_brs_reg,
    count(distinct patient_id||'_'||episode_id) as n_pacientes,
    round(n_pacientes_brs_reg * 100 / n_pacientes, 3) as result
from denominador
group by cohort,
    category_cohort,
    month_year