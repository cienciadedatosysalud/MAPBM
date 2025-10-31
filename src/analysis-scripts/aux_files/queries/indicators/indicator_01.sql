--- Indicadores descriptivos 1 y 2 
--- Prevalencia anemia preoperatoria
-------------------------------------------
--- Hb <13
-------------------------------------------
select cohort,
    category_cohort,
    month_year,
    round(AVG(result_determination_cd::FLOAT), 2) as promedio,
    median(result_determination_cd::FLOAT) as mediana,
    count(*) filter(
        where anemic_13
    ) as n_episodios_l13,
    count(*) as n_episodios
from cirugia_programada_cohort
group by cohort,
    category_cohort,
    month_year
union all
select cohort,
    category_cohort,
    month_year,
    round(AVG(result_determination_cd::FLOAT), 2) as promedio,
    median(result_determination_cd::FLOAT) as mediana,
    count(*) filter(
        where anemic_13
    ) as n_episodios_l13,
    count(*) as n_episodios
from cirugia_oncologica_cohort
group by cohort,
    category_cohort,
    month_year
union all
select cohort,
    category_cohort,
    month_year,
    round(AVG(result_determination_cd::FLOAT), 2) as promedio,
    median(result_determination_cd::FLOAT) as mediana,
    count(*) filter(
        where anemic_13
    ) as n_episodios_l13,
    count(*) as n_episodios
from (
        select row_number() over(
                partition by patient_id,
                cohort
                order by result_determination_dt ASC
            ) as rk_hb,
            *
        from (
                select a.*,
                    cohort,
                    category_cohort,
                    month_year,
                    anemic_13
                from (
                        select patient_id,
                            result_determination_cd,
                            result_determination_dt
                        from lab_view
                        where determination_cd = 'hb'
                    ) a
                    left join cirugia_urgente_cohort b on a.patient_id = b.patient_id
                    and a.result_determination_dt between start_intervention_dt - INTERVAL 5 DAY
                    and start_intervention_dt
                where b.patient_id is not null
            )
    )
where rk_hb = 1
group by cohort,
    category_cohort,
    month_year
union all
select cohort,
    category_cohort,
    month_year,
    round(AVG(result_determination_cd::FLOAT), 2) as promedio,
    median(result_determination_cd::FLOAT) as mediana,
    count(*) filter(
        where anemic_13
    ) as n_episodios_l13,
    count(*) as n_episodios
from (
        select row_number() over(
                partition by patient_id,
                cohort
                order by result_determination_dt ASC
            ) as rk_hb,
            *
        from (
                select a.*,
                    cohort,
                    category_cohort,
                    month_year,
                    anemic_13
                from (
                        select patient_id,
                            result_determination_cd,
                            result_determination_dt
                        from lab_view
                        where determination_cd = 'hb'
                    ) a
                    left join (
                        select a.admission_dt,
                            b.*
                        from(
                                (
                                    select episode_id,
                                        patient_id,
                                        start_intervention_dt,
                                        admission_dt
                                    from episode_view
                                ) a
                                left join proceso_medico_cohort b on a.patient_id = b.patient_id
                                and a.episode_id = b.episode_id
                                and a.start_intervention_dt = b.start_intervention_dt
                            )
                        where b.patient_id is not null
                    ) b on a.patient_id = b.patient_id
                    and a.result_determination_dt between admission_dt - INTERVAL 5 DAY
                    and admission_dt
                where b.patient_id is not null
            )
    )
where rk_hb = 1
group by cohort,
    category_cohort,
    month_year;