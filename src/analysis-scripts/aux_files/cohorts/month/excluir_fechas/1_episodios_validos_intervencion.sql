create or replace table episode_valid_intervention as 
select patient_id,episode_id,start_intervention_dt,end_intervention_dt from (
select *,
    coalesce(
        (
            EXTRACT(
                HOUR
                FROM start_intervention_dt
            ) = 0
            AND EXTRACT(
                MINUTE
                FROM start_intervention_dt
            ) = 0
            AND EXTRACT(
                SECOND
                FROM start_intervention_dt
            ) = 0
            AND EXTRACT(
                MICROSECOND
                FROM start_intervention_dt
            ) = 0
        ),
        false
    ) as flag_start_intervention_dt,
    coalesce(
        (
            EXTRACT(
                HOUR
                FROM end_intervention_dt
            ) = 0
            AND EXTRACT(
                MINUTE
                FROM end_intervention_dt
            ) = 0
            AND EXTRACT(
                SECOND
                FROM end_intervention_dt
            ) = 0
            AND EXTRACT(
                MICROSECOND
                FROM end_intervention_dt
            ) = 0
        ),
        false
    ) as flag_end_intervention_dt,
    flag_start_intervention_dt
    or flag_end_intervention_dt as flag_intervention_complete_time
from episode
where flag_intervention_complete_time is false and start_intervention_dt is not null and end_intervention_dt is not null
);