create or replace table episode_valid_admission as 
select patient_id,episode_id,admission_dt,discharge_dt from (
select *,
    coalesce(
        (
            EXTRACT(
                HOUR
                FROM admission_dt
            ) = 0
            AND EXTRACT(
                MINUTE
                FROM admission_dt
            ) = 0
            AND EXTRACT(
                SECOND
                FROM admission_dt
            ) = 0
            AND EXTRACT(
                MICROSECOND
                FROM admission_dt
            ) = 0
        ),
        false
    ) as flag_admission_dt,
    coalesce(
        (
            EXTRACT(
                HOUR
                FROM discharge_dt
            ) = 0
            AND EXTRACT(
                MINUTE
                FROM discharge_dt
            ) = 0
            AND EXTRACT(
                SECOND
                FROM discharge_dt
            ) = 0
            AND EXTRACT(
                MICROSECOND
                FROM discharge_dt
            ) = 0
        ),
        false
    ) as flag_discharge_dt,
    flag_admission_dt
    or flag_discharge_dt as flag_admission_complete_time
from episode
where flag_admission_complete_time is false and admission_dt is not null and discharge_dt is not null
);