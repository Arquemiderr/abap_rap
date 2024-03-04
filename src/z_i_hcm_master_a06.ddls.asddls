@AbapCatalog.sqlViewName: 'ZV_HCM_A06'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HCM - Master'
define root view z_i_hcm_master_a06 as select from zhcm_master_a06 as HCMMaster
{
    key e_number,
    e_name,
    e_departament,
    status,
    job_title,
    start_date,
    end_date,
    email,
    m_number,
    m_name,
    m_department,
    crea_date_time,
    crea_uname,
    lchg_date_time,
    lchg_uname
}
