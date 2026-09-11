--- Indicadores Outcome Nº45 indicador 
--- Numero de episodios con complicaciones
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
episode_with_complicaciones as (
    select a.*,
        list_bool_or(array[coalesce(akic_bl, false),
        coalesce(amic_bl, false),
        coalesce(anastomotic_breakdown_bl, false),
        coalesce(ardsc_bl, false),
        coalesce(arrythc_bl, false),
        coalesce(bloodinfc_bl, false),
        coalesce(cardiacc_bl, false),
        coalesce(cpec_bl, false),
        coalesce(deliriumc_bl, false),
        coalesce(dvtc_bl, false),
        coalesce(gastroc_bl, false),
        coalesce(ileusc_bl, false),
        coalesce(myoinfc_bl, false),
        coalesce(pneumc_bl, false),
        coalesce(postophemc_bl, false),
        coalesce(pulmemb_bl, false),
        coalesce(ssinfc_bl, false),
        coalesce(strokec_bl, false),
        coalesce(transfaec_bl, false),
        coalesce(uncinfc_bl, false),
        coalesce(utic_bl, false)]) as complicacion_bl
    from (select *
            from denominador
        ) a
        left join complications b on a.patient_id = b.patient_id
        and a.episode_id = b.episode_id
        and a.admission_dt = b.admission_dt
)
select cohort, category_cohort, month_year, 
count(id_paciente_episodio) filter(where complicacion_bl) as n_episodios_complicaciones,
count(id_paciente_episodio) filter(where complicacion_bl is false)  as n_episodios_sincomplicaciones,
count(id_paciente_episodio)  as n_episodios,
round(n_episodios_complicaciones*100.0/n_episodios,2) as result,
n_episodios as n_elegibles
from episode_with_complicaciones group by cohort, category_cohort, month_year