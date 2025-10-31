--- Indicadores process preop pillar1 Nº14 indicador
--- num Pacientes tratados preoperatoriamente con hierro IV y/o EPO entre 7 y 90 días antes de la cirugía
--- den Pacientes anémicos en preoperatorio, y tratados preoperatoriamente
--- % de pacientes tratados preoperatoriamente con un incremento de Hb de +1 pto  ANEMIC 13
-------------------------------------------
with denominador as (
    select *
    from (
            select a.*,
                dispensation_dt
            from (
                    select *
                    from cirugia_programada_cohort
                    where anemic_13
                ) a
                left join (
                    select patient_id,
                        h_amb_drug_cd as drug_cd,
                        h_amb_dispensation_dt as dispensation_dt
                    from hosp_amb_pharmacy
                    where h_amb_drug_cd in ('B03AC', 'B03XA01', 'B03XA02', 'B03XA03')
                    union all
                    select patient_id,
                        h_drug_cd as drug_cd,
                        h_dispensation_dt as dispensation_dt
                    from hosp_pharmacy
                    where h_drug_cd in ('B03AC', 'B03XA01', 'B03XA02', 'B03XA03')
                ) b on a.patient_id = b.patient_id
                and dispensation_dt between start_intervention_dt - INTERVAL 90 DAY
                and start_intervention_dt - INTERVAL 7 DAY
            where b.patient_id is not null
        )
    union all
    select *
    from (
            select a.*,
                dispensation_dt
            from (
                    select *
                    from cirugia_oncologica_cohort
                    where anemic_13
                ) a
                left join (
                    select patient_id,
                        h_amb_drug_cd as drug_cd,
                        h_amb_dispensation_dt as dispensation_dt
                    from hosp_amb_pharmacy
                    where h_amb_drug_cd in ('B03AC', 'B03XA01', 'B03XA02', 'B03XA03')
                    union all
                    select patient_id,
                        h_drug_cd as drug_cd,
                        h_dispensation_dt as dispensation_dt
                    from hosp_pharmacy
                    where h_drug_cd in ('B03AC', 'B03XA01', 'B03XA02', 'B03XA03')
                ) b on a.patient_id = b.patient_id
                and dispensation_dt between start_intervention_dt - INTERVAL 45 DAY
                and start_intervention_dt - INTERVAL 15 DAY
            where b.patient_id is not null
        ) a
),
hb_pre_tratamiento as (
    select patient_id,
        result_determination_dt,
        result_determination_cd as result_determination_pre_tratamiento,
        episode_id,
        cohort,
        category_cohort,
        month_year,
        start_intervention_dt,
        dispensation_dt
    from (
            select row_number() over(
                    partition by a.patient_id,
                    episode_id,
                    cohort
                    order by a.result_determination_dt DESC
                ) as rk,
                *
            from (
                    select patient_id,
                        result_determination_cd,
                        result_determination_dt
                    from lab_view
                    where determination_cd = 'hb'
                ) a
                left join (
                    select patient_id,
                        episode_id,
                        cohort,
                        category_cohort,
                        month_year,
                        start_intervention_dt,
                        dispensation_dt
                    from denominador
                ) b on a.patient_id = b.patient_id
                and a.result_determination_dt <= b.dispensation_dt
            where b.patient_id is not null
        )
    where rk = 1
),
hb_pre_intervencion as (
    select patient_id,
        result_determination_dt,
        result_determination_cd as result_determination_pre_intervencion,
        episode_id,
        cohort,
        category_cohort,
        month_year,
        start_intervention_dt,
        dispensation_dt
    from (
            select row_number() over(
                    partition by a.patient_id,
                    episode_id,
                    cohort
                    order by a.result_determination_dt DESC
                ) as rk,
                *
            from (
                    select patient_id,
                        result_determination_cd,
                        result_determination_dt
                    from lab_view
                    where determination_cd = 'hb'
                ) a
                left join (
                    select patient_id,
                        episode_id,
                        cohort,
                        category_cohort,
                        month_year,
                        start_intervention_dt,
                        dispensation_dt
                    from denominador
                ) b on a.patient_id = b.patient_id
                and a.result_determination_dt <= b.start_intervention_dt
            where b.patient_id is not null
        )
    where rk = 1
),
numerador as (
    select cohort,
        category_cohort,
        month_year,
        count(distinct patient_id) as n_pacientes_hb,
        count(distinct patient_id || '-' || episode_id) as n_unique_episode_hb
    from (
            select *
            from hb_pre_tratamiento a
                inner join hb_pre_intervencion b on a.patient_id = b.patient_id
                and a.episode_id = b.episode_id
                and a.start_intervention_dt = b.start_intervention_dt
                and a.dispensation_dt = b.dispensation_dt
                and a.cohort = b.cohort
        )
    where result_determination_pre_intervencion::FLOAT - result_determination_pre_tratamiento::FLOAT >= 1
    group by cohort,
        category_cohort,
        month_year
)
select cohort,
    category_cohort,
    month_year,
    coalesce(n_pacientes_hb, 0) as n_pacientes_hb,
    coalesce(n_unique_episode_hb, 0) as n_unique_episode_hb,
    n_paciente,
    n_unique_episode,
    round(coalesce(n_pacientes_hb, 0) * 100 / n_paciente, 3) as result_patient,
    round(
        coalesce(n_unique_episode_hb, 0) * 100 / n_unique_episode,
        3
    ) as result
from numerador a
    full outer join (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_paciente,
            count(distinct patient_id || '-' || episode_id) as n_unique_episode
        from denominador
        group by cohort,
            category_cohort,
            month_year
    ) b using(cohort, category_cohort, month_year);