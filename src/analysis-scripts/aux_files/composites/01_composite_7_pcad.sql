-- pacientes que cumplen compisite prod y pcad indicador 26
create or replace view composite_7 as
select *
from (
        select a.*,
            'composite7' as composite,
            case
                when b.patient_id is not null then true
                else false
            end as composite_bl
        from (
                select distinct patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort
                from cirugia_programada_cohort
                where cohort in ('prod', 'pcad')
            ) a
            left join (
                select distinct a.patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort
                from (
                        select a.patient_id,
                            a.episode_id,
                            a.start_intervention_dt,
                            a.cohort,
                            a.category_cohort,
                            a.month_year,
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
                    ) a
                    left join (
                        select patient_id,
                            h_amb_drug_cd as drug_cd,
                            h_amb_dispensation_dt as dispensation_dt
                        from hosp_amb_pharmacy
                        where h_amb_drug_cd like 'B02A%'
                        union all
                        select patient_id,
                            h_drug_cd as drug_cd,
                            h_dispensation_dt as dispensation_dt
                        from hosp_pharmacy
                        where h_drug_cd like 'B02A%'
                    ) b on a.patient_id = b.patient_id
                    and b.dispensation_dt between a.admission_dt and a.discharge_dt
                where b.patient_id is not null
                    and cohort in ('prod', 'pcad')
            ) b on a.patient_id = b.patient_id
            and a.episode_id = b.episode_id
            and a.start_intervention_dt = b.start_intervention_dt
            and a.cohort = b.cohort
    );