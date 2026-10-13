--- Indicadores descriptivos 1 y 2 
--- Prevalencia anemia preoperatoria
-------------------------------------------
--- Hb <13
-------------------------------------------
select cohort,
    category_cohort,
    month_year,
    round(AVG(result_determination_cd::FLOAT), 2) as promedio,
    median(result_determination_cd::FLOAT) as mediana,
    count(*) filter(
        where anemic_13
    ) as n_episodios_l13,
    count(*) as n_episodios,
    count(*) as n_elegibles
from cirugia_programada_cohort
group by cohort,
    category_cohort,
    month_year
union all
select cohort,
    category_cohort,
    month_year,
    round(AVG(result_determination_cd::FLOAT), 2) as promedio,
    median(result_determination_cd::FLOAT) as mediana,
    count(*) filter(
        where anemic_13
    ) as n_episodios_l13,
    count(*) as n_episodios,
    count(*) as n_elegibles
from cirugia_oncologica_cohort
group by cohort,
    category_cohort,
    month_year
union all
select cohort,
    category_cohort,
    month_year,
    round(AVG(result_determination_cd::FLOAT), 2) as promedio,
    median(result_determination_cd::FLOAT) as mediana,
    count(*) filter(
        where anemic_13
    ) as n_episodios_l13,
    count(*) as n_episodios,
    count(*) as n_elegibles
from cirugia_urgente_cohort
group by cohort,
    category_cohort,
    month_year
union all
select cohort,
    category_cohort,
    month_year,
    round(AVG(result_determination_cd::FLOAT), 2) as promedio,
    median(result_determination_cd::FLOAT) as mediana,
    count(*) filter(
        where anemic_13
    ) as n_episodios_l13,
    count(*) as n_episodios,
    count(*) as n_elegibles
from proceso_medico_cohort
group by cohort,
    category_cohort,
    month_year