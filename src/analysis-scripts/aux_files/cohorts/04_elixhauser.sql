--- Elixhauser
create or replace table elixhauser as with codes as (
        select *
        from read_csv(
                'aux_files/comorbidities/elixhauser_2024.csv',
                header = true,
                all_varchar = true
            )
    ),
    aids_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "AIDS" = 1
    ),
    alcohol_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "ALCOHOL" = 1
    ),
    anemdef_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "ANEMDEF" = 1
    ),
    autoimmune_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "AUTOIMMUNE" = 1
    ),
    bldloss_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "BLDLOSS" = 1
    ),
    cancer_leuk_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "CANCER_LEUK" = 1
    ),
    cancer_lymph_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "CANCER_LYMPH" = 1
    ),
    cancer_mets_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "CANCER_METS" = 1
    ),
    cancer_nsitu_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "CANCER_NSITU" = 1
    ),
    cancer_solid_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "CANCER_SOLID" = 1
    ),
    cbvd_poa_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "CBVD_POA" = 1
    ),
    cbvd_sqla_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "CBVD_SQLA" = 1
    ),
    coag_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "COAG" = 1
    ),
    dementia_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "DEMENTIA" = 1
    ),
    depress_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "DEPRESS" = 1
    ),
    diab_cx_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "DIAB_CX" = 1
    ),
    diab_uncx_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "DIAB_UNCX" = 1
    ),
    drug_abuse_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "DRUG_ABUSE" = 1
    ),
    hf_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "HF" = 1
    ),
    htn_cx_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "HTN_CX" = 1
    ),
    htn_uncx_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "HTN_UNCX" = 1
    ),
    liver_mld_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "LIVER_MLD" = 1
    ),
    liver_sev_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "LIVER_SEV" = 1
    ),
    lung_chronic_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "LUNG_CHRONIC" = 1
    ),
    neuro_movt_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "NEURO_MOVT" = 1
    ),
    neuro_oth_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "NEURO_OTH" = 1
    ),
    neuro_seiz_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "NEURO_SEIZ" = 1
    ),
    obese_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "OBESE" = 1
    ),
    paralysis_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "PARALYSIS" = 1
    ),
    perivasc_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "PERIVASC" = 1
    ),
    psychoses_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "PSYCHOSES" = 1
    ),
    pulmcirc_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "PULMCIRC" = 1
    ),
    renlfl_mod_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "RENLFL_MOD" = 1
    ),
    renlfl_sev_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "RENLFL_SEV" = 1
    ),
    thyroid_hypo_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "THYROID_HYPO" = 1
    ),
    thyroid_oth_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "THYROID_OTH" = 1
    ),
    ulcer_peptic_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "ULCER_PEPTIC" = 1
    ),
    valve_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "VALVE" = 1
    ),
    wghtloss_codes as (
        select array_agg(icd10_code) as code_clean_list
        from codes
        where "WGHTLOSS" = 1
    )
select patient_id,
    cnh_cd,
    episode_id,
    admission_dt,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df1.code_clean_list as aids_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df2.code_clean_list as alcohol_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df3.code_clean_list as anemdef_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df4.code_clean_list as autoimmune_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df5.code_clean_list as bldloss_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df6.code_clean_list as cancer_leuk_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df7.code_clean_list as cancer_lymph_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df8.code_clean_list as cancer_mets_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df9.code_clean_list as cancer_nsitu_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df10.code_clean_list as cancer_solid_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df11.code_clean_list as cbvd_poa_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df12.code_clean_list as cbvd_sqla_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df13.code_clean_list as coag_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df14.code_clean_list as dementia_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df15.code_clean_list as depress_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df16.code_clean_list as diab_cx_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df17.code_clean_list as diab_uncx_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df18.code_clean_list as drug_abuse_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df19.code_clean_list as hf_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df20.code_clean_list as htn_cx_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df21.code_clean_list as htn_uncx_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df22.code_clean_list as liver_mld_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df23.code_clean_list as liver_sev_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df24.code_clean_list as lung_chronic_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df25.code_clean_list as neuro_movt_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df26.code_clean_list as neuro_oth_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df27.code_clean_list as neuro_seiz_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df28.code_clean_list as obese_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df29.code_clean_list as paralysis_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df30.code_clean_list as perivasc_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df31.code_clean_list as psychoses_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df32.code_clean_list as pulmcirc_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df33.code_clean_list as renlfl_mod_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df34.code_clean_list as renlfl_sev_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df35.code_clean_list as thyroid_hypo_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df36.code_clean_list as thyroid_oth_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df37.code_clean_list as ulcer_peptic_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df38.code_clean_list as valve_bl,
    [d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20] && cod_df39.code_clean_list as wghtloss_bl
from episode_view a,
    aids_codes cod_df1,
    alcohol_codes cod_df2,
    anemdef_codes cod_df3,
    autoimmune_codes cod_df4,
    bldloss_codes cod_df5,
    cancer_leuk_codes cod_df6,
    cancer_lymph_codes cod_df7,
    cancer_mets_codes cod_df8,
    cancer_nsitu_codes cod_df9,
    cancer_solid_codes cod_df10,
    cbvd_poa_codes cod_df11,
    cbvd_sqla_codes cod_df12,
    coag_codes cod_df13,
    dementia_codes cod_df14,
    depress_codes cod_df15,
    diab_cx_codes cod_df16,
    diab_uncx_codes cod_df17,
    drug_abuse_codes cod_df18,
    hf_codes cod_df19,
    htn_cx_codes cod_df20,
    htn_uncx_codes cod_df21,
    liver_mld_codes cod_df22,
    liver_sev_codes cod_df23,
    lung_chronic_codes cod_df24,
    neuro_movt_codes cod_df25,
    neuro_oth_codes cod_df26,
    neuro_seiz_codes cod_df27,
    obese_codes cod_df28,
    paralysis_codes cod_df29,
    perivasc_codes cod_df30,
    psychoses_codes cod_df31,
    pulmcirc_codes cod_df32,
    renlfl_mod_codes cod_df33,
    renlfl_sev_codes cod_df34,
    thyroid_hypo_codes cod_df35,
    thyroid_oth_codes cod_df36,
    ulcer_peptic_codes cod_df37,
    valve_codes cod_df38,
    wghtloss_codes cod_df39;