--- Indicadores process preop pillar1 Nº13 indicador
--- num Pacientes tratados preoperatoriamente con hierro IV y/o EPO entre 7 y 90 días antes de la cirugía
--- den Pacientes anémicos en preoperatorio, y tratados preoperatoriamente
--- % de pacientes con Hb de control  ANEMIC 13
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
                and dispensation_dt between start_intervention_dt - INTERVAL 5 DAY
                and start_intervention_dt - INTERVAL 0 DAY
            where b.patient_id is not null
        ) a
)
select cohort,category_cohort,month_year,
	coalesce(n_pacientes_hb_control,0) as n_pacientes_hb_control,
	coalesce(n_unique_episode_hb_control,0) as n_unique_episode_hb_control ,
    n_paciente,
    n_unique_episode,
    round(coalesce(n_pacientes_hb_control,0) * 100 / n_paciente, 3) as result_patient,
    round(
        coalesce(n_unique_episode_hb_control,0) * 100 / n_unique_episode,
        3
    ) as result
from (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_pacientes_hb_control,
            count(distinct patient_id || '-' || episode_id) as n_unique_episode_hb_control
        from (
                select *
                from denominador a
                    left join (
                        select *
                        from lab_view
                        where determination_cd = 'hb'
                    ) b on a.patient_id = b.patient_id
                    and b.result_determination_dt between dispensation_dt and start_intervention_dt
                where b.patient_id is not null
            )
        group by cohort,
            category_cohort,
            month_year
    ) a
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
    ) b using(cohort,category_cohort,month_year);
