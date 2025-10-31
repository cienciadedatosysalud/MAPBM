--- Indicadores process preop pillar1 22 indicador Pillar3
---  % de pacientes intervenidos sin anemia  Hb>=13 
-------------------------------------------
----
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id||'_'||episode_id) filter(
        where not anemic_oms
    ) as n_pacientes_not_anemic_oms,
    count(distinct patient_id||'_'||episode_id) filter(
        where not anemic_13
    ) as n_pacientes_not_anemic_13,
    count(distinct patient_id||'_'||episode_id) as n_pacientes,
    round(
        n_pacientes_not_anemic_oms * 100 / n_pacientes,
        3
    ) as perc_pacientes_not_anemic_oms,
    round(n_pacientes_not_anemic_13 * 100 / n_pacientes, 3) as result
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
                    and a.result_determination_dt between start_intervention_dt- interval 90 DAY and start_intervention_dt 
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
    count(distinct patient_id||'_'||episode_id) filter(
        where not anemic_oms
    ) as n_pacientes_not_anemic_oms,
    count(distinct patient_id||'_'||episode_id) filter(
        where not anemic_13
    ) as n_pacientes_not_anemic_13,
    count(distinct patient_id||'_'||episode_id) as n_pacientes,
    round(
        n_pacientes_not_anemic_oms * 100 / n_pacientes,
        3
    ) as perc_pacientes_not_anemic_oms,
    round(n_pacientes_not_anemic_13 * 100 / n_pacientes, 3) as perc_pacientes_not_anemic_13
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
                        category_cohort,
                        month_year
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
                    and a.result_determination_dt between start_intervention_dt - interval 45 DAY and start_intervention_dt
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
    count(distinct patient_id||'_'||episode_id) filter(
        where not anemic_oms
    ) as n_pacientes_not_anemic_oms,
    count(distinct patient_id||'_'||episode_id) filter(
        where not anemic_13
    ) as n_pacientes_not_anemic_13,
    count(distinct patient_id||'_'||episode_id) as n_pacientes,
    round(
        n_pacientes_not_anemic_oms * 100 / n_pacientes,
        3
    ) as perc_pacientes_not_anemic_oms,
    round(n_pacientes_not_anemic_13 * 100 / n_pacientes, 3) as perc_pacientes_not_anemic_13
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
    month_year;