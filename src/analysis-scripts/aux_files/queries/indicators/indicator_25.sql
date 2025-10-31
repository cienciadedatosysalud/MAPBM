--- Indicadores process preop pillar1 Nº25 indicador Pillar2
--- % de pacientes con anestesia regional
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
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id||'_'||episode_id) filter(
        where anesth_cd = '2'
    ) as n_pacientes_anes_reg,
    count(distinct patient_id||'_'||episode_id) as n_pacientes,
    round(n_pacientes_anes_reg * 100 / n_pacientes, 3) as result
from denominador
group by cohort,
    category_cohort,
    month_year