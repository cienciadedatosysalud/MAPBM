--- Indicadores process preop pillar1 Nº32 indicador Pillar3
--- % de transfusiones de una sola unidad de hematíes
with transfusiones as (
    select *
    from (
            select *,
                lag(transf_dt) over(
                    partition by patient_id
                    order by transf_dt ASC
                ) as transf_dt_anterior,
                lead(transf_dt) over(
                    partition by patient_id
                    order by transf_dt ASC
                ) as transf_dt_posterior,
                case
                    when  epoch(transf_dt - transf_dt_anterior) / 86400.0 < 1 then true
                    when epoch(transf_dt_posterior - transf_dt) / 86400.0  then true
                    when transf_dt_anterior is null then false
                    else false
                end as transfusion_in_less24h
            from (
                    select *
                    from transfusion_view
                    where transf_administered_bl is true
                        and transftype_cd = 'B05AX01'
                )
        )
),
denominador as (
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
),
denominador_transfundidos_hematies as (
    select *
    from (
            select patient_id,
                episode_id,
                cohort,
                category_cohort,
                month_year,
                admission_dt,
                discharge_dt,
                count(*) as bolsas_distintas_administradas,
                count(*) filter(
                    where transfusion_in_less24h is true
                ) as bolsas_periodo_1dia
            from (
                    select *
                    from transfusiones a
                        left JOIN denominador b on a.patient_id = b.patient_id
                        and transf_dt between admission_dt and discharge_dt
                    where b.patient_id is not null
                )
            group by patient_id,
                episode_id,
                cohort,
                category_cohort,
                month_year,
                admission_dt,
                discharge_dt
        )
)
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id||'_'||episode_id) filter(
        where bolsas_periodo_1dia = 0
    ) as n_pacientes_1_bolsa,
    count(distinct patient_id||'_'||episode_id) as n_pacientes,
    round(n_pacientes_1_bolsa * 100 / n_pacientes, 3) as result
from denominador_transfundidos_hematies
group by cohort,
    category_cohort,
    month_year;