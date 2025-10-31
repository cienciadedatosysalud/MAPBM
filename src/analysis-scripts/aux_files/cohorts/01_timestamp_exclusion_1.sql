--- Pacientes sin ninguna Hb se cumple en el criterio de seleccion de la cohorte
--- Pacientes sin Hb preop en 120 dias se cumple en el criterio de la seleccion de la cohorte
--- Crear vista de las tablas originales con flag true en aquellos registros con problemas de fechas completas 
create or replace view episode_view as
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
where flag_intervention_complete_time is false and start_intervention_dt is not null and end_intervention_dt is not null;
