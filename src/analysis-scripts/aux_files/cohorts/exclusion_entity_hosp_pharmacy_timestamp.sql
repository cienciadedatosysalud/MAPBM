create or replace view hosp_pharmacy_view as
select * exclude(flag_h_dispensation_dt) from (
select *,
    h_dispensation_dt is null or     
    (
        EXTRACT(
            HOUR
            FROM h_dispensation_dt
        ) = 0
        AND EXTRACT(
            MINUTE
            FROM h_dispensation_dt
        ) = 0
        AND EXTRACT(
            SECOND
            FROM h_dispensation_dt
        ) = 0
        AND EXTRACT(
            MICROSECOND
            FROM h_dispensation_dt
        ) = 0
    )
     as flag_h_dispensation_dt
from hosp_pharmacy where h_drug_cd in ('B03AC', 'B03XA01', 'B03XA02', 'B03XA03')
and flag_h_dispensation_dt is false
)
union all
select * from  hosp_pharmacy where h_drug_cd not in ('B03AC', 'B03XA01', 'B03XA02', 'B03XA03')