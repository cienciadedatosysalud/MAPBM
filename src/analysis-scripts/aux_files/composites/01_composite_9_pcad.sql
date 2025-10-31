----  pacientes que cumplen compisite prod y pcad indicador 32
create or replace view composite_9 as with transfusiones as (
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
                    start_intervention_dt,
                    category_cohort,
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
                    start_intervention_dt,
                    category_cohort,
                    admission_dt,
                    discharge_dt
            )
    )
select *
from (
        select a.*,
            'composite9' as composite,
            case
                when b.patient_id is not null then true
                else false
            end as composite_bl
        from (
                select distinct patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort
                from denominador_transfundidos_hematies
                where cohort in ('prod', 'pcad')
            ) a
            left join (
                select distinct patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort
                from denominador_transfundidos_hematies
                where cohort in ('prod', 'pcad')
                    and bolsas_periodo_1dia = 0
            ) b on a.patient_id = b.patient_id
            and a.episode_id = b.episode_id
            and a.start_intervention_dt = b.start_intervention_dt
            and a.cohort = b.cohort
    );