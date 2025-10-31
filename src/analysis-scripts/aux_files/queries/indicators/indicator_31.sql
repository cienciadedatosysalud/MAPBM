--- Indicadores process preop pillar1 Nº31 indicador Pillar3
--- Valor de Hb previo a la transfusión
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
    round(avg(result_determination_cd::float), 3) as promedio,
    round(median(result_determination_cd::float), 3) as mediana
from (
        select a.*,
            b.result_determination_cd
        from denominador a
            left join (
                select *
from (
        select *, row_number()over(partition by a.patient_id,transf_dt order by result_determination_dt DESC ) as rk_hb
        from (
                select *
                from transfusion_view
                where transf_administered_bl
                and transftype_cd = 'B05AX01'
            ) a
            left join (
                select patient_id,
                    result_determination_cd,
                    result_determination_dt
                from lab_view
                where determination_cd = 'hb'
            ) b on a.patient_id = b.patient_id
            and a.transf_dt between b.result_determination_dt and b.result_determination_dt + interval 1 DAY
        where b.patient_id is not null
    ) where rk_hb = 1
            ) b on a.patient_id = b.patient_id
            and transf_dt between admission_dt and discharge_dt
            and b.result_determination_dt between admission_dt and discharge_dt
        where b.patient_id is not null
    )
group by cohort,
    category_cohort,
    month_year;