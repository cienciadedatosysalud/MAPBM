--- Indicadores process preop pillar1 Nº30 indicador Pillar3
--- % de episodios pacientes transfundidos con Hb < 8 g/dl
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
            select * exclude(admission_dt)
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
),
transfundidos as (
select * from denominador a 
left join (select *
        from transfusion_view
        where transf_administered_bl
    
) b 
on a.patient_id = b.patient_id and transf_dt between admission_dt and discharge_dt 
where b.patient_id is not null 	
),
hemoglobinas_menor_8 as (
select patient_id,
                                    result_determination_cd,
                                    result_determination_dt,
                                    (result_determination_cd::float < 8) as hb_l8
                                from lab_view
                                where determination_cd = 'hb' 
)
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id||'_'||episode_id) filter(
        where hb_l8
    ) as n_episodios_trans_l8,
    count(distinct patient_id||'_'||episode_id) as n_episodios,
    round(n_episodios_trans_l8 * 100 / n_episodios, 3) as result,
    n_episodios as n_elegibles from (
select * from transfundidos a 
left join hemoglobinas_menor_8 b  
on a.patient_id =b.patient_id and b.result_determination_dt between a.transf_dt - interval 1 DAY and a.transf_dt
                        where b.patient_id is not null 
) group by cohort,
    category_cohort,
    month_year;