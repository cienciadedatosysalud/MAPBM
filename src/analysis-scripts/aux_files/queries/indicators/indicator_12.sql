--- Indicadores process preop pillar1 Nº12 indicador
--- num Pacientes tratados preoperatoriamente con hierro IV y/o EPO entre 7 y 90 días antes de la cirugía
--- % de pacientes anémicos tratados preoperatoriamente con tiempo suficiente idem para todos (anémicos y no anémicos)
-- B03AC
-- B03XA01
-- B03XA02
-- B03XA03
-------------------------------------------
select cohort,category_cohort,month_year,
	coalesce(n_pacientes_iv_epo,0) as n_pacientes_iv_epo,
	coalesce(n_unique_episode_iv_epo,0) as n_unique_episode_iv_epo,
    n_pacientes,
    n_unique_episode,
    round(coalesce(n_pacientes_iv_epo,0) * 100 / n_pacientes, 3) as result_patient,
    round(
        coalesce(n_unique_episode_iv_epo,0) * 100 / n_unique_episode,
        3
    ) as result
from (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_pacientes_iv_epo,
            count(distinct patient_id || '-' || episode_id) as n_unique_episode_iv_epo
        from (
                select *
                from (
                        select a.*
                        from (
                                select *
                                from cirugia_programada_cohort
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
                        select a.*
                        from (
                                select *
                                from cirugia_oncologica_cohort
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
                        select a.*
                        from (
                                select *
                                from cirugia_urgente_cohort
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
        group by cohort,
            category_cohort,
            month_year
    ) a
    full outer join (
        select cohort,
            category_cohort,
            month_year,
            count(distinct patient_id) as n_pacientes,
            count(distinct patient_id || '-' || episode_id) as n_unique_episode
        from (
                select *
                from cirugia_programada_cohort
                union all
                select *
                from cirugia_oncologica_cohort
                union all
                select *
                from cirugia_urgente_cohort
            )
        group by cohort,
            category_cohort,
            month_year
    ) b using(cohort,category_cohort,month_year) ;


