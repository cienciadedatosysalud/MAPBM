with tabla_final as (select cohort, count(*) as n_registros_final from cirugia_programada_cohort group by cohort),
    tabla_inicial as (   
	    select cohort, count(*) as n_registros_inicial from (
	    select patient_id, episode_id, 'hist_no_onco' as cohort from hist_no_onco_cohort
		union all
	    select patient_id, episode_id, 'icv' as cohort from icv_cohort
	    union all 
	    select patient_id, episode_id, 'pcad' as cohort from pcad_cohort
	    union all 
	    select patient_id, episode_id, 'prod' as cohort from prod_cohort
	    union all 
	    select patient_id, episode_id, 'cist_radical' as cohort from cist_radical_cohort
	    ) group by cohort
	)
	select a.*, coalesce(n_registros_final,0) as n_registros, n_registros_inicial-n_registros as registros_excluidos  from tabla_inicial a 
	left join tabla_final b  
	on a.cohort = b.cohort
	order by cohort DESC