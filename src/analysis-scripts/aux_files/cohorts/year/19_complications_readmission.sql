CREATE OR REPLACE TABLE complications_year AS
WITH denominador AS (
    -- Eliminar posibles duplicados si un paciente/episodio está en múltiples cohortes
    SELECT DISTINCT
        patient_id,
        episode_id,
        start_intervention_dt,
        discharge_dt,
        admission_dt
    FROM (
        SELECT patient_id, episode_id, start_intervention_dt FROM cirugia_programada_cohort_year
        UNION
        SELECT patient_id, episode_id, start_intervention_dt FROM cirugia_oncologica_cohort_year
        UNION
        SELECT patient_id, episode_id, start_intervention_dt FROM cirugia_urgente_cohort_year
        UNION
        SELECT patient_id, episode_id, start_intervention_dt FROM proceso_medico_cohort_year
    ) a
    LEFT JOIN (
        SELECT 
            patient_id,
            episode_id,
            discharge_dt,
            start_intervention_dt,
            admission_dt
        FROM episode_view
    ) b 
        ON a.patient_id = b.patient_id
       AND a.episode_id = b.episode_id
       AND a.start_intervention_dt = b.start_intervention_dt
),
data_episode_reingreso_bl AS (
    SELECT DISTINCT
        patient_id,
        cnh_cd,
        episode_id,
        admission_dt,
        list_where(
            [d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20],
            list_transform(
                [poad1,poad2,poad3,poad4,poad5,poad6,poad7,poad8,poad9,poad10,poad11,poad12,poad13,poad14,poad15,poad16,poad17,poad18,poad19,poad20],
                x -> (CASE WHEN x IN ('S','I','E') THEN true ELSE false END)
            )
        ) AS diagnosticos
    FROM (
        SELECT 
            a.*,
            date_trunc('year', a.start_intervention_dt) AS month_year,
            CASE
                WHEN b.patient_id IS NOT NULL THEN true
                ELSE false
            END AS reingreso_bl
        FROM episode_view a
        LEFT JOIN denominador b 
            ON a.patient_id = b.patient_id
           AND a.admission_dt BETWEEN b.discharge_dt AND b.discharge_dt + INTERVAL 30 DAY
    )
    WHERE reingreso_bl
),
-- DISTINCT en array_agg para garantizar 1 sola fila por tabla CSV
akic_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/akic_bl.csv', header = true, all_varchar = TRUE)),
amic_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/amic_bl.csv', header = true, all_varchar = TRUE)),
anastomotic_breakdown_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/anastomotic_breakdown_bl.csv', header = true, all_varchar = TRUE)),
ardsc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/ardsc_bl.csv', header = true, all_varchar = TRUE)),
arrythc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/arrythc_bl.csv', header = true, all_varchar = TRUE)),
bloodinfc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/bloodinfc_bl.csv', header = true, all_varchar = TRUE)),
cardiacc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/cardiacc_bl.csv', header = true, all_varchar = TRUE)),
cpec_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/cpec_bl.csv', header = true, all_varchar = TRUE)),
deliriumc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/deliriumc_bl.csv', header = true, all_varchar = TRUE)),
dvtc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/dvtc_bl.csv', header = true, all_varchar = TRUE)),
gastroc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/gastroc_bl.csv', header = true, all_varchar = TRUE)),
ileusc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/ileusc_bl.csv', header = true, all_varchar = TRUE)),
myoinfc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/myoinfc_bl.csv', header = true, all_varchar = TRUE)),
pneumc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/pneumc_bl.csv', header = true, all_varchar = TRUE)),
postophemc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/postophemc_bl.csv', header = true, all_varchar = TRUE)),
pulmemb_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/pulmemb_bl.csv', header = true, all_varchar = TRUE)),
ssinfc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/ssinfc_bl.csv', header = true, all_varchar = TRUE)),
strokec_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/strokec_bl.csv', header = true, all_varchar = TRUE)),
transfaec_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/transfaec_bl.csv', header = true, all_varchar = TRUE)),
uncinfc_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/uncinfc_bl.csv', header = true, all_varchar = TRUE)),
utic_bl_df AS (SELECT array_agg(DISTINCT code_clean) AS code_clean_list FROM read_csv('aux_files/complications/utic_bl.csv', header = true, all_varchar = TRUE)),

subquery AS (
    SELECT 
        patient_id,
        cnh_cd,
        episode_id,
        admission_dt,
        bool_or(diagnosticos && b.code_clean_list) AS akic_bl,
        bool_or(diagnosticos && c.code_clean_list) AS amic_bl,
        bool_or(diagnosticos && d.code_clean_list) AS anastomotic_breakdown_bl,
        bool_or(diagnosticos && e.code_clean_list) AS ardsc_bl,
        bool_or(diagnosticos && f.code_clean_list) AS arrythc_bl,
        bool_or(diagnosticos && g.code_clean_list) AS bloodinfc_bl,
        bool_or(diagnosticos && h.code_clean_list) AS cardiacc_bl,
        bool_or(diagnosticos && i.code_clean_list) AS cpec_bl,
        bool_or(diagnosticos && j.code_clean_list) AS deliriumc_bl,
        bool_or(diagnosticos && k.code_clean_list) AS dvtc_bl,
        bool_or(diagnosticos && l.code_clean_list) AS gastroc_bl,
        bool_or(diagnosticos && m.code_clean_list) AS ileusc_bl,
        bool_or(diagnosticos && n.code_clean_list) AS myoinfc_bl,
        bool_or(diagnosticos && o.code_clean_list) AS pneumc_bl,
        bool_or(diagnosticos && p.code_clean_list) AS postophemc_bl,
        bool_or(diagnosticos && q.code_clean_list) AS pulmemb_bl,
        bool_or(diagnosticos && r.code_clean_list) AS ssinfc_bl,
        bool_or(diagnosticos && s.code_clean_list) AS strokec_bl,
        bool_or(diagnosticos && t.code_clean_list) AS transfaec_bl,
        bool_or(diagnosticos && u.code_clean_list) AS uncinfc_bl,
        bool_or(diagnosticos && v.code_clean_list) AS utic_bl
    FROM data_episode_reingreso_bl a,
         akic_bl_df b,
         amic_bl_df c,
         anastomotic_breakdown_bl_df d,
         ardsc_bl_df e,
         arrythc_bl_df f,
         bloodinfc_bl_df g,
         cardiacc_bl_df h,
         cpec_bl_df i,
         deliriumc_bl_df j,
         dvtc_bl_df k,
         gastroc_bl_df l,
         ileusc_bl_df m,
         myoinfc_bl_df n,
         pneumc_bl_df o,
         postophemc_bl_df p,
         pulmemb_bl_df q,
         ssinfc_bl_df r,
         strokec_bl_df s,
         transfaec_bl_df t,
         uncinfc_bl_df u,
         utic_bl_df v
    GROUP BY patient_id, cnh_cd, episode_id, admission_dt
)
SELECT 
    c.* EXCLUDE (
        akic_bl, amic_bl, anastomotic_breakdown_bl, ardsc_bl, arrythc_bl,
        bloodinfc_bl, cardiacc_bl, cpec_bl, deliriumc_bl, dvtc_bl,
        gastroc_bl, ileusc_bl, myoinfc_bl, pneumc_bl, postophemc_bl,
        pulmemb_bl, ssinfc_bl, strokec_bl, transfaec_bl, uncinfc_bl, utic_bl
    ),
    c.akic_bl OR COALESCE(s.akic_bl, false) AS akic_bl,
    c.amic_bl OR COALESCE(s.amic_bl, false) AS amic_bl,
    c.anastomotic_breakdown_bl OR COALESCE(s.anastomotic_breakdown_bl, false) AS anastomotic_breakdown_bl,
    c.ardsc_bl OR COALESCE(s.ardsc_bl, false) AS ardsc_bl,
    c.arrythc_bl OR COALESCE(s.arrythc_bl, false) AS arrythc_bl,
    c.bloodinfc_bl OR COALESCE(s.bloodinfc_bl, false) AS bloodinfc_bl,
    c.cardiacc_bl OR COALESCE(s.cardiacc_bl, false) AS cardiacc_bl,
    c.cpec_bl OR COALESCE(s.cpec_bl, false) AS cpec_bl,
    c.deliriumc_bl OR COALESCE(s.deliriumc_bl, false) AS deliriumc_bl,
    c.dvtc_bl OR COALESCE(s.dvtc_bl, false) AS dvtc_bl,
    c.gastroc_bl OR COALESCE(s.gastroc_bl, false) AS gastroc_bl,
    c.ileusc_bl OR COALESCE(s.ileusc_bl, false) AS ileusc_bl,
    c.myoinfc_bl OR COALESCE(s.myoinfc_bl, false) AS myoinfc_bl,
    c.pneumc_bl OR COALESCE(s.pneumc_bl, false) AS pneumc_bl,
    c.postophemc_bl OR COALESCE(s.postophemc_bl, false) AS postophemc_bl,
    c.pulmemb_bl OR COALESCE(s.pulmemb_bl, false) AS pulmemb_bl,
    c.ssinfc_bl OR COALESCE(s.ssinfc_bl, false) AS ssinfc_bl,
    c.strokec_bl OR COALESCE(s.strokec_bl, false) AS strokec_bl,
    c.transfaec_bl OR COALESCE(s.transfaec_bl, false) AS transfaec_bl,
    c.uncinfc_bl OR COALESCE(s.uncinfc_bl, false) AS uncinfc_bl,
    c.utic_bl OR COALESCE(s.utic_bl, false) AS utic_bl
FROM complications c
LEFT JOIN subquery s
    ON c.patient_id = s.patient_id 
   AND c.cnh_cd = s.cnh_cd 
   AND c.episode_id = s.episode_id 
   AND c.admission_dt = s.admission_dt;