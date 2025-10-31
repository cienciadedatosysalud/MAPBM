--- Indicadores Outcome Nº40,41 indicador Outcome
--- Hb al alta en pacientes no transfundidos
--- Nota: Se coge la HB en el periodo de hosp/intervencion más cercana al alta (puede ser antes de la intervencion)
with transfusiones as (
    select *
    from (
            select *
            from (
                    select *
                    from transfusion_view
                    where transf_administered_bl is true
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
denominador_transfundidos as (
    select *
    from (
            select distinct a.*,
                case
                    when b.patient_id is null then false
                    else true
                end as transfundido_bl
            from denominador a
                left join transfusiones b on a.patient_id = b.patient_id
                and transf_dt between admission_dt and discharge_dt
        )
)
select cohort,
    category_cohort,
    month_year,
    transfundido_bl,
    round(avg(result_determination_cd::float), 3) as promedio,
    round(median(result_determination_cd::float), 3) as mediana
from (
        select row_number() over (
                partition by a.patient_id,
                episode_id,
                cohort,
                category_cohort
                order by determination_dt DESC
            ) as rk,
            a.*,
            episode_id,
            cohort,
            category_cohort,
            month_year,
            transfundido_bl
        from (
                select *
                from lab_view
                where determination_cd = 'hb'
            ) a
            left join denominador_transfundidos b on a.patient_id = b.patient_id
            and determination_dt between start_intervention_dt and discharge_dt
        where b.patient_id is not null
    )
where rk = 1
group by cohort,
    category_cohort,
    month_year,
    transfundido_bl;