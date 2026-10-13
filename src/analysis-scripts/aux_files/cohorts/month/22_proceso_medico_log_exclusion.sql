with tabla_final as (select cohort, count(*) as n_registros_final from proceso_medico_cohort group by cohort),
    tabla_inicial as (   
	    select cohort, count(*) as n_registros_inicial from (
	    select patient_id, episode_id, 'hdig' as cohort from hdig_cohort
	    ) group by cohort
	)
	select a.*, coalesce(n_registros_final,0) as n_registros, n_registros_inicial-n_registros as registros_excluidos  from tabla_inicial a 
	left join tabla_final b  
	on a.cohort = b.cohort
	order by cohort DESC