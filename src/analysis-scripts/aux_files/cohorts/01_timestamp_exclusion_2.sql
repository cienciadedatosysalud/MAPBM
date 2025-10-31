--- Pacientes sin ninguna Hb se cumple en el criterio de seleccion de la cohorte
--- Pacientes sin Hb preop en 120 dias se cumple en el criterio de la seleccion de la cohorte
--- Crear vista de las tablas originales con flag true en aquellos registros con problemas de fechas completas 
create or replace view lab_view as
select *,
    determination_dt is null
    or (
        EXTRACT(
            HOUR
            FROM determination_dt
        ) = 0
        AND EXTRACT(
            MINUTE
            FROM determination_dt
        ) = 0
        AND EXTRACT(
            SECOND
            FROM determination_dt
        ) = 0
        AND EXTRACT(
            MICROSECOND
            FROM determination_dt
        ) = 0
    ) as flag_determination_dt,
    result_determination_dt is null
    or (
        EXTRACT(
            HOUR
            FROM result_determination_dt
        ) = 0
        AND EXTRACT(
            MINUTE
            FROM result_determination_dt
        ) = 0
        AND EXTRACT(
            SECOND
            FROM result_determination_dt
        ) = 0
        AND EXTRACT(
            MICROSECOND
            FROM result_determination_dt
        ) = 0
    ) as flag_result_determination_dt
from lab
where flag_result_determination_dt is false