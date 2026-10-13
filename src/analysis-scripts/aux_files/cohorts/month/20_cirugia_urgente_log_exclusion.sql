with tabla_final as (select cohort, count(*) as n_registros_final from cirugia_urgente_cohort group by cohort),
    tabla_inicial as (   
	    select cohort, count(*) as n_registros_inicial from (
	    select patient_id, episode_id, 'ffem' as cohort from ffem_cohort
	    ) group by cohort
	)
	select a.*, coalesce(n_registros_final,0) as n_registros, n_registros_inicial-n_registros as registros_excluidos  from tabla_inicial a 
	left join tabla_final b  
	on a.cohort = b.cohort
	order by cohort DESC