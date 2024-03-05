@AbapCatalog.sqlViewName: 'ZV_EMPLOYEE_A06'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee'
define root view Z_I_EMPLOYEE_A06
  as select from zemployee_a06 as Employee
{
      //Employee
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
