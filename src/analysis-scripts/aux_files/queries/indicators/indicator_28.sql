--- Indicadores process preop pillar1 Nº28 indicador Pillar2

with denominador as (
	SELECT *
FROM (
    SELECT 
        q.*,
        ROW_NUMBER() OVER(PARTITION BY q.patient_id ORDER BY q.fib_result_determination_cd ASC) as rn
    FROM (
        SELECT a.*,
               b.fib_result_determination_cd,
               b.fib_result_determination_dt
        FROM (
            SELECT a.*,
                   discharge_dt,
                   admission_dt
            FROM (
                SELECT * FROM cirugia_programada_cohort a
                UNION ALL
                SELECT * FROM cirugia_oncologica_cohort a
                UNION ALL
                SELECT * FROM cirugia_urgente_cohort a
            ) a
            LEFT JOIN (
                SELECT patient_id, episode_id, discharge_dt, start_intervention_dt, admission_dt, cohort
                FROM episode_view
            ) b ON a.patient_id = b.patient_id
                AND a.episode_id = b.episode_id
                AND a.start_intervention_dt = b.start_intervention_dt
        ) a
        JOIN (
            SELECT patient_id, 
                   result_determination_cd as fib_result_determination_cd, 
                   result_determination_dt as fib_result_determination_dt 
            FROM lab 
            WHERE determination_cd ='fib' AND result_determination_cd < 2
        ) b ON a.patient_id = b.patient_id  
            AND b.fib_result_determination_dt BETWEEN a.admission_dt AND a.discharge_dt
    ) q
) final_table
WHERE rn = 1
)
select cohort,
    category_cohort,
    month_year,
    count(distinct patient_id||'_'||episode_id) filter(
        where fib_bl
    ) as n_episodios_fib,
    count(distinct patient_id||'_'||episode_id) as n_episodios,
    round(n_episodios_fib * 100 / n_episodios, 3) as result,
    n_episodios as n_elegibles
from (
        select a.*,
            case
                when b.patient_id is not null then true
                else false
            end fib_bl
        from denominador a
            left join (
                select patient_id,
                    h_amb_drug_cd as drug_cd,
                    h_amb_dispensation_dt as dispensation_dt
                from hosp_amb_pharmacy
                where h_amb_drug_cd LIKE ('B02B%')
                union all
                select patient_id,
                    h_drug_cd as drug_cd,
                    h_dispensation_dt as dispensation_dt
                from hosp_pharmacy
                where h_drug_cd LIKE ('B02B%')
            ) b on a.patient_id = b.patient_id
            and dispensation_dt between admission_dt and discharge_dt
    )
group by cohort,
    category_cohort,
    month_year;