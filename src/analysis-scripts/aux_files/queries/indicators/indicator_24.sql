--- Indicadores process preop pillar1 Nº24 indicador Pillar1
--- % de pacientes tratados postoperatoriamente con hierro IV
select * from (
with denominador as (
    select a.*,
        discharge_dt,
        end_intervention_dt,
        anesth_cd,
        brs_bl
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
                end_intervention_dt,
                anesth_cd,
                brs_bl,
                cohort
            from episode_view
        ) b on a.patient_id = b.patient_id
        and a.episode_id = b.episode_id
        and a.start_intervention_dt = b.start_intervention_dt
),
anemic_post_intervention as (
    select patient_id,
        episode_id,
        start_intervention_dt,
        cohort,
        category_cohort,
        month_year,
        discharge_dt,
        end_intervention_dt
    from (
            select *,
                case
                    when a.result_determination_cd::float < 13 then true
                    else false
                end as anemic_13,
                case
                    when a.result_determination_cd::float < 13
                    and sex_cd = '1' then true
                    when a.result_determination_cd::float < 12
                    and sex_cd = '2' then true
                    else false
                end as anemic_oms
            from (
                    select *
                    from lab_view
                    where determination_cd = 'hb'
                ) a
                left join denominador b on a.patient_id = b.patient_id
                and a.result_determination_dt between b.end_intervention_dt and discharge_dt
            where b.patient_id is not null
                and (
                    anemic_13
                    or anemic_oms
                )
        )
)
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id) filter(
        where fe_iv_bl
    ) as n_pacientes_feiv,
    count(distinct patient_id) as n_pacientes,
    round(n_pacientes_feiv * 100 / n_pacientes, 3) as result
from (
        select a.*,
            case
                when b.patient_id is not null then true
                else false
            end fe_iv_bl
        from anemic_post_intervention a
            left join (
                select patient_id,
                    h_amb_drug_cd as drug_cd,
                    h_amb_dispensation_dt as dispensation_dt
                from hosp_amb_pharmacy
                where h_amb_drug_cd in ('B03AC')
                union all
                select patient_id,
                    h_drug_cd as drug_cd,
                    h_dispensation_dt as dispensation_dt
                from hosp_pharmacy
                where h_drug_cd in ('B03AC')
            ) b on a.patient_id = b.patient_id
            and dispensation_dt between end_intervention_dt and discharge_dt
    )
group by cohort,
    category_cohort,
    month_year
)
union all
select * from (
with denominador as (
    select a.*,
    	admission_dt,
        discharge_dt,
        end_intervention_dt,
        anesth_cd,
        brs_bl
    from (
            select *
            from proceso_medico_cohort a
        ) a
        left join (
            select patient_id,
                episode_id,
                admission_dt,
                discharge_dt,
                start_intervention_dt,
                end_intervention_dt,
                anesth_cd,
                brs_bl,
                cohort
            from episode_view
        ) b on a.patient_id = b.patient_id
        and a.episode_id = b.episode_id
        and a.start_intervention_dt = b.start_intervention_dt
),
anemic_post_intervention as (
    select patient_id,
        episode_id,
        start_intervention_dt,
        cohort,
        category_cohort,
        month_year,
        admission_dt,
        discharge_dt,
        end_intervention_dt
    from (
            select *,
                case
                    when a.result_determination_cd::float < 13 then true
                    else false
                end as anemic_13,
                case
                    when a.result_determination_cd::float < 13
                    and sex_cd = '1' then true
                    when a.result_determination_cd::float < 12
                    and sex_cd = '2' then true
                    else false
                end as anemic_oms
            from (
                    select *
                    from lab_view
                    where determination_cd = 'hb'
                ) a
                left join denominador b on a.patient_id = b.patient_id
                and a.result_determination_dt between b.admission_dt and discharge_dt
            where b.patient_id is not null
                and (
                    anemic_13
                    or anemic_oms
                )
        )
)
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id) filter(
        where fe_iv_bl
    ) as n_pacientes_feiv,
    count(distinct patient_id) as n_pacientes,
    round(n_pacientes_feiv * 100 / n_pacientes, 3) as result
from (
        select a.*,
            case
                when b.patient_id is not null then true
                else false
            end fe_iv_bl
        from anemic_post_intervention a
            left join (
                select patient_id,
                    h_amb_drug_cd as drug_cd,
                    h_amb_dispensation_dt as dispensation_dt
                from hosp_amb_pharmacy
                where h_amb_drug_cd in ('B03AC')
                union all
                select patient_id,
                    h_drug_cd as drug_cd,
                    h_dispensation_dt as dispensation_dt
                from hosp_pharmacy
                where h_drug_cd in ('B03AC')
            ) b on a.patient_id = b.patient_id
            and dispensation_dt between admission_dt and discharge_dt
    )
group by cohort,
    category_cohort,
    month_year
)