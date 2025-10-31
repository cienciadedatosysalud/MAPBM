--- Composite (all-or-none)
select *
from (
        select cohort,
            category_cohort,
            patient_id,
            episode_id,
            count(distinct composite) as n_composites,
            count(*) filter(
                where composite_bl
            ) as n_composites_true,
            round(n_composites_true * 100 / n_composites, 3) as perc_composite
        from composite_all
        group by cohort,
            category_cohort,
            patient_id,
            episode_id
    )
where perc_composite = 100
    or perc_composite = 0