-- Complicaciones mismo episodio, poas N y D 
create or replace table complications as with data_episode as (
        select *
        from (
                select patient_id,
                    cnh_cd,
                    episode_id,
                    admission_dt,
                    list_where([d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20],
									list_transform([poad1,poad2,poad3,poad4,poad5,poad6,poad7,poad8,poad9,poad10,poad11,poad12,poad13,poad14,poad15,poad16,poad17,poad18,poad19,poad20],
									x -> (case when x in ('N','D') then true else false end))) as diagnosticos
                from episode_view
            )
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
            from data_episode a,
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
            utic_bl_df v;