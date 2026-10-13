--- Indicadores process preop pillar1 Nº31 indicador Pillar3
--- Valor de Hb previo a la transfusión
with denominador as (
    select a.*,
        discharge_dt,
        admission_dt
    from (
            select * exclude(result_determination_dt,result_determination_cd)
            from cirugia_programada_cohort a
            union all
            select *  exclude(result_determination_dt,result_determination_cd)
            from cirugia_oncologica_cohort a
            union all
            select *  exclude(result_determination_dt,result_determination_cd)
            from cirugia_urgente_cohort a
            union all
            select * exclude(admission_dt,result_determination_dt,result_determination_cd)
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
    round(avg(result_determination_cd::float), 3) as promedio,
    round(median(result_determination_cd::float), 3) as mediana,
    count(distinct patient_id||'_'||episode_id) as n_elegibles
from (
select * from (
select *, row_number()over(partition by a.patient_id,transf_dt order by b.result_determination_dt DESC ) as rk_hb from transfundidos a 
left join hemoglobinas_menor_8 b  
on a.patient_id =b.patient_id and b.result_determination_dt between a.transf_dt - interval 1 DAY and a.transf_dt
                        where b.patient_id  is not null) where rk_hb=1
    )
group by cohort,
    category_cohort,
    month_year;