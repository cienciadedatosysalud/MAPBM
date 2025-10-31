create or replace view composite_all as
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_1
union all
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_2
union all
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_3
union all
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_4
union all
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_5
union all
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_6
union all
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_7
union all
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_8
union all
select *,date_trunc('month',start_intervention_dt) as month_year
from composite_9;