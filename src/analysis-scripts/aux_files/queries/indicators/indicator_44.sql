--- Indicadores Outcome Nº44 indicador 
--- Mortalidad intra-hospitalaria
with denominador as (
    select a.*,
        discharge_dt,
        admission_dt,
        discharge_type_cd
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
                cohort,
                discharge_type_cd
            from episode_view
        ) b on a.patient_id = b.patient_id
        and a.episode_id = b.episode_id
        and a.start_intervention_dt = b.start_intervention_dt
)
select cohort,
    category_cohort,
    month_year,
    count(*) as result
from denominador
where discharge_type_cd = '4'
group by cohort,
    category_cohort,
    month_year;