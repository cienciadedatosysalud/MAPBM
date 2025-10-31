--- Indicadores process preop pillar1 Nº29 indicador Pillar2
--- idem para todos, con y sin valor de conc.fibrin.
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
    count(distinct patient_id||'_'||episode_id) filter(
        where fib_bl
    ) as n_pacientes_fib,
    count(distinct patient_id||'_'||episode_id) as n_pacientes,
    round(n_pacientes_fib * 100 / n_pacientes, 3) as result
from (
        select a.*,
            case
                when b.patient_id is not null then true
                else false
            end fib_bl
        from denominador a
            left join (
                select patient_id,
                    h_amb_drug_cd as drug_cd,
                    h_amb_dispensation_dt as dispensation_dt
                from hosp_amb_pharmacy
                where h_amb_drug_cd LIKE ('B02B%')
                union all
                select patient_id,
                    h_drug_cd as drug_cd,
                    h_dispensation_dt as dispensation_dt
                from hosp_pharmacy
                where h_drug_cd LIKE ('B02B%')
            ) b on a.patient_id = b.patient_id
            and dispensation_dt between admission_dt and discharge_dt
    )
group by cohort,
    category_cohort,
    month_year;