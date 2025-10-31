create or replace table cirugia_urgente_cohort as
select patient_id || '_' || episode_id as id_paciente_episodio,
    patient_id,
    result_determination_cd,
    result_determination_dt,
    episode_id,
    sex_cd,
    age_nm,
    start_intervention_dt,
    cohort,
    category_cohort,
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
    end as anemic_oms,
    date_trunc('year', start_intervention_dt)::DATE as month_year
from (
        select row_number() over(
                partition by patient_id,
                cohort
                order by result_determination_dt ASC
            ) as rk_hb,
            *
        from (
                select *
                from (
                        select patient_id,
                            episode_id,
                            sex_cd,
                            age_nm,
                            start_intervention_dt,
                            'ffem' as cohort,
                            category_cohort,
                            from ffem_cohort
                        where patient_id not in (
                                select distinct patient_id
                                from lab_view
                                group by patient_id
                                having count(*) filter(
                                        where determination_cd = 'hb'
                                    ) = 0
                            )
                            and start_intervention_dt is not null
                    ) a
                    left join (
                        select patient_id,
                            result_determination_cd,
                            result_determination_dt
                        from lab_view
                        where determination_cd = 'hb'
                    ) b on a.patient_id = b.patient_id
                    and result_determination_dt between start_intervention_dt - INTERVAL 5 DAY
                    and start_intervention_dt
                where b.patient_id is not null
            )
    )
where rk_hb = 1;