--- Indicadores process preop pillar1 Nº23 indicador Pillar3
---  Valor  de Hb previo a la intervención
-------------------------------------------
select cohort,
    category_cohort,
    month_year,
    round(avg(result_determination_cd::FLOAT), 3) as promedio,
    round(median(result_determination_cd::FLOAT), 3) as mediana
from (
        select *,
            case
                when result_determination_cd::float < 13 then true
                else false
            end as anemic_13,
            case
                when result_determination_cd::float < 13
                and sex_cd = '1' then true
                when result_determination_cd::float < 12
                and sex_cd = '2' then true
                else false
            end as anemic_oms
        from (
                select row_number() over(
                        partition by a.patient_id,
                        episode_id,
                        cohort,
                        start_intervention_dt
                        order by result_determination_dt DESC
                    ) as rk,
                    *
                from (
                        select *
                        from lab_view
                        where determination_cd = 'hb'
                    ) a
                    left join (
                        select patient_id,
                            episode_id,
                            sex_cd,
                            start_intervention_dt,
                            cohort,
                            category_cohort,
                            month_year
                        from cirugia_programada_cohort
                    ) b on a.patient_id = b.patient_id
                    and a.result_determination_dt between start_intervention_dt - interval 90 DAY  and start_intervention_dt
                where b.patient_id is not null
            )
        where rk = 1
    )
group by cohort,
    category_cohort,
    month_year
union all
select cohort,
    category_cohort,
    month_year,
    round(avg(result_determination_cd::FLOAT), 3) as promedio_hb,
    round(median(result_determination_cd::FLOAT), 3) as median_hb
from (
        select *,
            case
                when result_determination_cd::float < 13 then true
                else false
            end as anemic_13,
            case
                when result_determination_cd::float < 13
                and sex_cd = '1' then true
                when result_determination_cd::float < 12
                and sex_cd = '2' then true
                else false
            end as anemic_oms
        from (
                select row_number() over(
                        partition by a.patient_id,
                        episode_id,
                        cohort,
                        start_intervention_dt
                        order by result_determination_dt DESC
                    ) as rk,
                    *
                from (
                        select *
                        from lab_view
                        where determination_cd = 'hb'
                    ) a
                    left join (
                        select patient_id,
                            episode_id,
                            sex_cd,
                            start_intervention_dt,
                            cohort,
                            category_cohort,
                            month_year
                        from cirugia_oncologica_cohort
                    ) b on a.patient_id = b.patient_id
                    and a.result_determination_dt between start_intervention_dt- interval 45 DAY and start_intervention_dt 
                where b.patient_id is not null
            )
        where rk = 1
    )
group by cohort,
    category_cohort,
    month_year
union all
select cohort,
    category_cohort,
    month_year,
    round(avg(result_determination_cd::FLOAT), 3) as promedio_hb,
    round(median(result_determination_cd::FLOAT), 3) as median_hb
from (
        select *,
            case
                when result_determination_cd::float < 13 then true
                else false
            end as anemic_13,
            case
                when result_determination_cd::float < 13
                and sex_cd = '1' then true
                when result_determination_cd::float < 12
                and sex_cd = '2' then true
                else false
            end as anemic_oms
        from (
                select row_number() over(
                        partition by a.patient_id,
                        episode_id,
                        cohort,
                        start_intervention_dt
                        order by result_determination_dt DESC
                    ) as rk,
                    *
                from (
                        select *
                        from lab_view
                        where determination_cd = 'hb'
                    ) a
                    left join (
                        select patient_id,
                            episode_id,
                            sex_cd,
                            start_intervention_dt,
                            cohort,
                            category_cohort,
                            month_year
                        from cirugia_urgente_cohort
                    ) b on a.patient_id = b.patient_id
                    and a.result_determination_dt between start_intervention_dt - interval 5 DAY and start_intervention_dt 
                where b.patient_id is not null
            )
        where rk = 1
    )
group by cohort,
    category_cohort,
    month_year