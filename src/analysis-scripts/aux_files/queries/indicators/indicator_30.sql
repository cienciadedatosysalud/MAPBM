--- Indicadores process preop pillar1 Nº30 indicador Pillar3
--- % de pacientes transfundidos con Hb < 8 g/dl
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
)
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id||'_'||episode_id) filter(
        where hb_l8
    ) as n_pacientes_trans_l8,
    count(distinct patient_id||'_'||episode_id) as n_pacientes,
    round(n_pacientes_trans_l8 * 100 / n_pacientes, 3) as result
from (
        select a.*,
            hb_l8
        from denominador a
            left join (
                select patient_id,
                    unit_id,
                    transf_administered_bl,
                    transf_dt,
                    transftype_cd,
                    flag_transf_dt,
                    result_determination_cd,
                    result_determination_dt,
                    case
                        when n_hb != n_hb_l8 then false
                        else hb_l8
                    end as hb_l8
                from (
                        select *,
                            count(*) over (partition by a.patient_id) as n_hb,
                            count(*) filter(
                                where result_determination_cd::float < 8
                            ) over (partition by a.patient_id) as n_hb_l8
                        from (
                                select *
                                from transfusion_view
                                where transf_administered_bl
                                    and transftype_cd = 'B05AX01'
                            ) a
                            left join (
                                select patient_id,
                                    result_determination_cd,
                                    result_determination_dt,
                                    (result_determination_cd::float < 8) as hb_l8
                                from lab_view
                                where determination_cd = 'hb'
                            ) b on a.patient_id = b.patient_id
                            and a.transf_dt between b.result_determination_dt and b.result_determination_dt + interval 1 DAY
                        where b.patient_id is not null
                    )
            ) b on a.patient_id = b.patient_id
            and transf_dt between admission_dt and discharge_dt
            and b.result_determination_dt between admission_dt and discharge_dt
        where b.patient_id is not null
    )
group by cohort,
    category_cohort,
    month_year;