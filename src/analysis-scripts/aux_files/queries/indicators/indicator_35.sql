--- Indicadores Outcome Nº35 indicador Outcome
--- Tasa de transfusión
with transfusiones as (
    select *
    from (
            select *
            from (
                    select *,
                        case
                            when transftype_cd = 'B05AX01' then 'HEM'
                            when transftype_cd = 'B05AX02' then 'PLAQ'
                            when transftype_cd = 'B05AX03' then 'PLAS'
                            else null
                        end as transftype_st
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
numerador as (
    select cohort,
        category_cohort,
        month_year,
        transftype_st,
        count(distinct patient_id||'_'||episode_id) as n_episodios_transf
    from (
            select *
            from transfusiones a
                left join denominador b on a.patient_id = b.patient_id
                and a.transf_dt between admission_dt and discharge_dt
            where b.patient_id is not null
        )
    group by transftype_st,
        cohort,
        category_cohort,
        month_year
)
select a.*,
    n_episodios,
    round(n_episodios_transf * 100 / n_episodios, 3) as result
from numerador a
    left join (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id||'_'||episode_id) as n_episodios
        from denominador
        group by cohort,
            category_cohort,
            month_year
    ) b using(cohort,category_cohort, month_year);