--- Indicadores Outcome Nº45 indicador 
--- idem por cada categoría de complicación
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
            union all
            select *
            from proceso_medico_cohort a
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
),
reingresos as (
    select patient_id,
        episode_id,
        sex_cd,
        admission_dt,
        start_intervention_dt,
        discharge_dt,
        cohort,
            category_cohort,
            month_year,
        true as reingreso_bl
    from (
            select *,
                date_trunc('month', a.start_intervention_dt) as month_year,
                case
                    when b.patient_id is not null then true
                    else false
                end as reingreso_bl
            from episode_view a
                left join (
                    select patient_id,
                        episode_id,
                        admission_dt,
                        start_intervention_dt,
                        discharge_dt,
                        cohort,
                        category_cohort
                    from denominador
                ) b on a.patient_id = b.patient_id
                and a.admission_dt between b.discharge_dt and b.discharge_dt + INTERVAL 30 DAY
        )
    where reingreso_bl
),
episode_with_complicaciones as (
    select a.*,
        coalesce(akic_bl, false) as akic_bl,
        coalesce(amic_bl, false) as amic_bl,
        coalesce(anastomotic_breakdown_bl, false) as anastomotic_breakdown_bl,
        coalesce(ardsc_bl, false) as ardsc_bl,
        coalesce(arrythc_bl, false) as arrythc_bl,
        coalesce(bloodinfc_bl, false) as bloodinfc_bl,
        coalesce(cardiacc_bl, false) as cardiacc_bl,
        coalesce(cpec_bl, false) as cpec_bl,
        coalesce(deliriumc_bl, false) as deliriumc_bl,
        coalesce(dvtc_bl, false) as dvtc_bl,
        coalesce(gastroc_bl, false) as gastroc_bl,
        coalesce(ileusc_bl, false) as ileusc_bl,
        coalesce(myoinfc_bl, false) as myoinfc_bl,
        coalesce(pneumc_bl, false) as pneumc_bl,
        coalesce(postophemc_bl, false) as postophemc_bl,
        coalesce(pulmemb_bl, false) as pulmemb_bl,
        coalesce(ssinfc_bl, false) as ssinfc_bl,
        coalesce(strokec_bl, false) as strokec_bl,
        coalesce(transfaec_bl, false) as transfaec_bl,
        coalesce(uncinfc_bl, false) as uncinfc_bl,
        coalesce(utic_bl, false) as utic_bl
    from (
            select patient_id,
                episode_id,
                sex_cd,
                admission_dt,
                start_intervention_dt,
                discharge_dt,
                cohort,
            category_cohort,
            month_year,
                false as reingreso_bl
            from denominador
            union all
            select *
            from reingresos
        ) a
        left join complications b on a.patient_id = b.patient_id
        and a.episode_id = b.episode_id
        and a.admission_dt = b.admission_dt
)
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id||'_'||episode_id) filter (
        where akic_bl
    ) as "Fallo renal agudo",
    count(distinct patient_id||'_'||episode_id) filter (
        where amic_bl
    ) as "Infarto agudo de miocardio",
    count(distinct patient_id||'_'||episode_id) filter (
        where anastomotic_breakdown_bl
    ) as "Ruptura anastomótica",
    count(distinct patient_id||'_'||episode_id) filter (
        where ardsc_bl
    ) as "SDRA",
    count(distinct patient_id||'_'||episode_id) filter (
        where arrythc_bl
    ) as "Arritmia",
    count(distinct patient_id||'_'||episode_id) filter (
        where bloodinfc_bl
    ) as "Infección sanguínea Conf.Lab",
    count(distinct patient_id||'_'||episode_id) filter (
        where cardiacc_bl
    ) as "Paro cardíaco",
    count(distinct patient_id||'_'||episode_id) filter (
        where cpec_bl
    ) as "Edema pulmonar cardiogénico",
    count(distinct patient_id||'_'||episode_id) filter (
        where deliriumc_bl
    ) as "Delirium",
    count(distinct patient_id||'_'||episode_id) filter (
        where dvtc_bl
    ) as "Enfermedad venosa profunda",
    count(distinct patient_id||'_'||episode_id) filter (
        where gastroc_bl
    ) as "Sangrado gastrointestinal",
    count(distinct patient_id||'_'||episode_id) filter (
        where ileusc_bl
    ) as "Íleo paralítico",
    count(distinct patient_id||'_'||episode_id) filter (
        where myoinfc_bl
    ) as "Daño miocárdico después Cirg.NoCardíaca",
    count(distinct patient_id||'_'||episode_id) filter (
        where pneumc_bl
    ) as "Neumonía",
    count(distinct patient_id||'_'||episode_id) filter (
        where postophemc_bl
    ) as "Hemorragia postoperatoria",
    count(distinct patient_id||'_'||episode_id) filter (
        where pulmemb_bl
    ) as "Embolia pulmonar",
    count(distinct patient_id||'_'||episode_id) filter (
        where ssinfc_bl
    ) as "Infección de localización quirúrgica",
    count(distinct patient_id||'_'||episode_id) filter (
        where strokec_bl
    ) as "Ictus",
    count(distinct patient_id||'_'||episode_id) filter (
        where transfaec_bl
    ) as "Eventos adversos rel. transfusión",
    count(distinct patient_id||'_'||episode_id) filter (
        where uncinfc_bl
    ) as "Infección de origen desconocido",
    count(distinct patient_id||'_'||episode_id) filter (
        where utic_bl
    ) as "Infección del tracto urinario",
    from episode_with_complicaciones
group by cohort,
            category_cohort,
            month_year;