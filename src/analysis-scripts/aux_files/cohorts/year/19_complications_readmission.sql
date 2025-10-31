-- Complicaciones reingreso , poas 'S','I','E'
update complications
set akic_bl= complications.akic_bl or subquery.akic_bl,
amic_bl= complications.amic_bl or subquery.amic_bl,
anastomotic_breakdown_bl= complications.anastomotic_breakdown_bl or subquery.anastomotic_breakdown_bl,
ardsc_bl= complications.ardsc_bl or subquery.ardsc_bl,
arrythc_bl= complications.arrythc_bl or subquery.arrythc_bl,
bloodinfc_bl= complications.bloodinfc_bl or subquery.bloodinfc_bl,
cardiacc_bl= complications.cardiacc_bl or subquery.cardiacc_bl,
cpec_bl= complications.cpec_bl or subquery.cpec_bl,
deliriumc_bl= complications.deliriumc_bl or subquery.deliriumc_bl,
dvtc_bl= complications.dvtc_bl or subquery.dvtc_bl,
gastroc_bl= complications.gastroc_bl or subquery.gastroc_bl,
ileusc_bl= complications.ileusc_bl or subquery.ileusc_bl,
myoinfc_bl= complications.myoinfc_bl or subquery.myoinfc_bl,
pneumc_bl= complications.pneumc_bl or subquery.pneumc_bl,
postophemc_bl= complications.postophemc_bl or subquery.postophemc_bl,
pulmemb_bl= complications.pulmemb_bl or subquery.pulmemb_bl,
ssinfc_bl= complications.ssinfc_bl or subquery.ssinfc_bl,
strokec_bl= complications.strokec_bl or subquery.strokec_bl,
transfaec_bl= complications.transfaec_bl or subquery.transfaec_bl,
uncinfc_bl= complications.uncinfc_bl or subquery.uncinfc_bl,
utic_bl= complications.utic_bl or subquery.utic_bl
from (
with denominador as (
    select a.*,
        discharge_dt,
        admission_dt
    from (
            select *
            from cirugia_programada_cohort a
            union all
            select *
            from cirugia_oncologica_cohort a
            union all
            select *
            from cirugia_urgente_cohort a
            union all
            select *
            from proceso_medico_cohort a
        ) a
        left join (
            select patient_id,
                episode_id,
                discharge_dt,
                start_intervention_dt,
                admission_dt,
                cohort
            from episode_view
        ) b on a.patient_id = b.patient_id
        and a.episode_id = b.episode_id
        and a.start_intervention_dt = b.start_intervention_dt
),
data_episode_reingreso_bl as (
        select patient_id,
                    cnh_cd,
                    episode_id,
                    admission_dt,list_where([d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20],
									list_transform([poad1,poad2,poad3,poad4,poad5,poad6,poad7,poad8,poad9,poad10,poad11,poad12,poad13,poad14,poad15,poad16,poad17,poad18,poad19,poad20],
									x -> (case when x in ('S','I','E') then true else false end))) as diagnosticos
from (
        select *,
            date_trunc('year', a.start_intervention_dt) as month_year,
            case
                when b.patient_id is not null then true
                else false
            end as reingreso_bl
        from episode_view a
            left join (
                select patient_id,
                    episode_id,
                    admission_dt,
                    start_intervention_dt,
                    discharge_dt,
                    cohort,
                    category_cohort
                from denominador
            ) b on a.patient_id = b.patient_id
            and a.admission_dt between b.discharge_dt and b.discharge_dt + INTERVAL 30 DAY
    )
where reingreso_bl
    ),
    akic_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/akic_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    amic_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/amic_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    anastomotic_breakdown_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/anastomotic_breakdown_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    ardsc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/ardsc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    arrythc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/arrythc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    bloodinfc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/bloodinfc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    cardiacc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/cardiacc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    cpec_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/cpec_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    deliriumc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/deliriumc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    dvtc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/dvtc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    gastroc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/gastroc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    ileusc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/ileusc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    myoinfc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/myoinfc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    pneumc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/pneumc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    postophemc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/postophemc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    pulmemb_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/pulmemb_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    ssinfc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/ssinfc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    strokec_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/strokec_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    transfaec_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/transfaec_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    uncinfc_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/uncinfc_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    ),
    utic_bl_df as (
        select array_agg(code_clean) as code_clean_list
        from read_csv(
                'aux_files/complications/utic_bl.csv',
                header = true,
                all_varchar = TRUE
            )
    )
select patient_id,
    cnh_cd,
    episode_id,
    admission_dt,
            diagnosticos && b.code_clean_list as akic_bl,
            diagnosticos && c.code_clean_list as amic_bl,
            diagnosticos && d.code_clean_list as anastomotic_breakdown_bl,
            diagnosticos && e.code_clean_list as ardsc_bl,
            diagnosticos && f.code_clean_list as arrythc_bl,
            diagnosticos && g.code_clean_list as bloodinfc_bl,
            diagnosticos && h.code_clean_list as cardiacc_bl,
            diagnosticos && i.code_clean_list as cpec_bl,
            diagnosticos && j.code_clean_list as deliriumc_bl,
            diagnosticos && k.code_clean_list as dvtc_bl,
            diagnosticos && l.code_clean_list as gastroc_bl,
            diagnosticos && m.code_clean_list as ileusc_bl,
            diagnosticos && n.code_clean_list as myoinfc_bl,
            diagnosticos && o.code_clean_list as pneumc_bl,
            diagnosticos && p.code_clean_list as postophemc_bl,
            diagnosticos && q.code_clean_list as pulmemb_bl,
            diagnosticos && r.code_clean_list as ssinfc_bl,
            diagnosticos && s.code_clean_list as strokec_bl,
            diagnosticos && t.code_clean_list as transfaec_bl,
            diagnosticos && u.code_clean_list as uncinfc_bl,
            diagnosticos && v.code_clean_list as utic_bl,
            from data_episode_reingreso_bl a,
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
            ) subquery
where complications.patient_id = subquery.patient_id and complications.cnh_cd = subquery.cnh_cd and complications.episode_id = subquery.episode_id and
complications.admission_dt = subquery.admission_dt

