--- Pacientes sin ninguna Hb se cumple en el criterio de seleccion de la cohorte
--- Pacientes sin Hb preop en 120 dias se cumple en el criterio de la seleccion de la cohorte
--- Crear vista de las tablas originales con flag true en aquellos registros con problemas de fechas completas 
create or replace view transfusion_view as
select *,
    coalesce(
        (
            EXTRACT(
                HOUR
                FROM transf_dt
            ) = 0
            AND EXTRACT(
                MINUTE
                FROM transf_dt
            ) = 0
            AND EXTRACT(
                SECOND
                FROM transf_dt
            ) = 0
            AND EXTRACT(
                MICROSECOND
                FROM transf_dt
            ) = 0
        ),
        false
    ) as flag_transf_dt
from transfusion
where flag_transf_dt is false;