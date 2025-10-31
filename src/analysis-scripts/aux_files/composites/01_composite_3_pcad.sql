-- pacientes que cumplen el composite prod y pcad  indicador 10
create or replace view composite_3 as
select *
from (
        select a.*,
            'composite3' as composite,
            case
                when b.patient_id is not null then true
                else false
            end as composite_bl
        from (
                select patient_id,
                    episode_id,
                    start_intervention_dt,
                    cohort,
                    category_cohort
                from cirugia_programada_cohort
                where anemic_oms
                    and cohort in ('prod', 'pcad')
            ) a
            left join (
                select distinct a.*
                from (
                        select patient_id,
                            episode_id,
                            start_intervention_dt,
                            cohort,
                            category_cohort
                        from cirugia_programada_cohort
                        where anemic_oms
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
                    and cohort in ('prod', 'pcad')
            ) b on a.patient_id = b.patient_id
            and a.episode_id = b.episode_id
            and a.start_intervention_dt = b.start_intervention_dt
            and a.cohort = b.cohort
    );