SELECT *, 
  CASE WHEN loan_closed_over_duedate_days_v_ta = NULL OR loan_closed_over_duedate_days_v_ta < 0 THEN 1 ELSE 0 END flg_overdue
  FROM (SELECT i.applicationId, i.auserId, i.sum AS loan_amt, 1 AS loan_cnt, i.applicationStatusId, i.title as applicationStatusname, 
  date(i.loanDateStart) as loanDateStart, MONTH(date(i.loanDateStart)) AS vintage_month, YEAR(date(i.loanDateStart)) AS vintage_year,
  i.period AS actual_period, i.planPeriod AS Term, date(i.loanDateEnd) AS loanDateEnd , i.score_group, i.score_before, 
  i.Balance, i.Bazis, i.applicationIsOverdue, i.rate, i.repay AS repayment_v_a,
  r.repayments_v_ta, r.repayments_cnt, r.first_payment_date, r.last_payment_date, r.fld_total_repaid,
  CASE WHEN r.first_payment_date IS NOT NULL THEN i.planPeriod - DATEDIFF(r.first_payment_date,date(i.loanDateStart)) ELSE NULL END first_payment_over_duedate_days,
  CASE WHEN i.loanDateEnd IS NOT NULL THEN i.planPeriod - DATEDIFF(date(i.loanDateEnd),date(i.loanDateStart)) ELSE NULL END loan_closed_over_duedate_days_v_a,
  CASE WHEN (r.last_payment_date IS NOT NULL) AND r.fld_total_repaid > 0 
    THEN i.planPeriod - DATEDIFF(r.last_payment_date,date(i.loanDateStart)) ELSE NULL END loan_closed_over_duedate_days_v_ta,
  
  pr.requests_to_prolongate_cnt, pr.requests_to_prolongate_approved_cnt, (i.period - i.planPeriod) AS prolongation_period_days,
  CASE WHEN pr.requests_to_prolongate_cnt > 0 THEN 1 ELSE 0 END flg_request_to_Prolongate,  
  CASE WHEN pr.requests_to_prolongate_approved_cnt > 0 THEN 1 ELSE 0 END flg_request_to_Prolongate_approved, 

  res.offers_to_restruct_cnt, res.offers_to_restruct_accepted_cnt, res.offers_to_restruct_done_cnt,
  CASE WHEN res.offers_to_restruct_cnt > 0 THEN 1 ELSE 0 END offers_to_restruct_flg,
  CASE WHEN res.offers_to_restruct_accepted_cnt > 0 THEN 1 ELSE 0 END offers_to_restruct_accepted_flg,
  CASE WHEN res.offers_to_restruct_done_cnt > 0 THEN 1 ELSE 0 END offers_to_restruct_done_flg,

  ch.collection_was_in_work_cnt, ch.collection_start_date, 
  CASE WHEN ch.collection_was_in_work_cnt > 0 THEN 1 ELSE 0 END collection_was_in_work_flg,
  CASE WHEN ch.collection_start_date IS NOT NULL THEN i.planPeriod - DATEDIFF(ch.collection_start_date,date(i.loanDateStart)) ELSE NULL END collection_start_over_duedate_days,
  
  crm.atc_no_answer_cnt, crm.atc_out_cnt, crm.ptp_cnt, (crm.atc_no_answer_cnt+crm.atc_out_cnt+crm.ptp_cnt) atc_out_calls_cnt_v1, crm.atc_out_calls_cnt AS atc_out_calls_cnt_v2, 
  CASE WHEN crm.first_atc_date < '2100-01-01' THEN 1 ELSE 0 END collection_atc_flg,
  CASE WHEN crm.first_contact_date < '2100-01-01' THEN 1 ELSE 0 END collection_contact_flg,
  crm.in_calls_cnt, CASE WHEN crm.in_calls_cnt > 0 THEN 1 ELSE 0 END in_calls_flg,
  crm.operator_init_rekurent_cnt, CASE WHEN crm.operator_init_rekurent_cnt > 0 THEN 1 ELSE 0 END operator_init_rekurent_flg,
  crm.contact_with_third_person_cnt, CASE WHEN crm.contact_with_third_person_cnt > 0 THEN 1 ELSE 0 END contact_with_third_person_flg, 
  crm.collection_control_cnt, CASE WHEN crm.collection_control_cnt > 0 THEN 1 ELSE 0 END collection_control_flg,     
  crm.collection_return_to_stack_cnt, CASE WHEN crm.collection_return_to_stack_cnt > 0 THEN 1 ELSE 0 END collection_return_to_stack_cnt_flg,   
  CASE WHEN crm.first_atc_date = '2100-01-01' THEN NULL ELSE crm.first_atc_date END first_atc_date,
  CASE WHEN crm.first_contact_date = '2100-01-01' THEN NULL ELSE crm.first_contact_date END first_contact_date,

  CASE WHEN (crm.first_atc_date = '2100-01-01') AND (ch.collection_start_date IS NOT NULL) THEN DATEDIFF(crm.first_atc_date,ch.collection_start_date) ELSE NULL END days_to_atc,
  CASE WHEN (crm.first_contact_date = '2100-01-01') AND (ch.collection_start_date IS NOT NULL) THEN DATEDIFF(crm.first_contact_date,ch.collection_start_date) ELSE NULL END days_to_contact

  FROM temp.issues AS i
  LEFT JOIN (SELECT applicationId, SUM(sum) AS repayments_v_ta, count(*) AS repayments_cnt, MIN(date(tms)) AS first_payment_date, MAX(date(tms)) AS last_payment_date,
    CASE WHEN MIN(Bazis2) = 0 THEN 1 ELSE 0 END fld_total_repaid FROM temp.repayments GROUP BY applicationId) AS r ON r.applicationId = i.applicationId
  LEFT JOIN (SELECT a.applicationId, count(*) AS requests_to_prolongate_cnt, SUM(CASE WHEN a.tmsApprove IS NOT NULL THEN 1 ELSE 0 END) AS requests_to_prolongate_approved_cnt
             FROM platiza_client.prolongate_loan as a GROUP BY a.applicationId) AS pr ON pr.applicationId = i.applicationId
  LEFT JOIN (SELECT cor.applicationId, count(*) AS offers_to_restruct_cnt, SUM(CASE WHEN cor.accepted_at IS NOT NULL THEN 1 ELSE 0 END) AS offers_to_restruct_accepted_cnt,
  SUM(CASE WHEN cor.status = 'DONE' THEN 1 ELSE 0 END) AS offers_to_restruct_done_cnt FROM platiza_admin.crm_overdue_restruct cor GROUP BY cor.applicationId) AS res ON res.applicationId = i.applicationId 
  LEFT JOIN (SELECT application_id, count(*) AS collection_was_in_work_cnt, MIN(date(tms)) AS collection_start_date  FROM temp.collector_history GROUP BY application_id) AS ch ON ch.application_id = i.applicationId
  LEFT JOIN (SELECT app_id, SUM(CASE WHEN log_type = 'Попытка звонка, не отвечает' THEN 1 ELSE 0 END) atc_no_answer_cnt,    
           SUM(CASE WHEN log_type = 'Попытка звонка, недоступен' THEN 1 ELSE 0 END) atc_out_cnt,
           SUM(CASE WHEN log_type = 'Обещание оплаты на звонке' THEN 1 ELSE 0 END) ptp_cnt,
           SUM(CASE WHEN (type_id = 2) OR (type_id = 3) OR (type_id = 16)  THEN 1 ELSE 0 END) as atc_out_calls_cnt,
           SUM(CASE WHEN log_type = 'Входящий звонок' THEN 1 ELSE 0 END) in_calls_cnt,
           SUM(CASE WHEN log_type = 'Рекурентное списание оператором' THEN 1 ELSE 0 END) operator_init_rekurent_cnt,
           SUM(CASE WHEN log_type = 'Общение с 3-им лицом' THEN 1 ELSE 0 END) contact_with_third_person_cnt,
           SUM(CASE WHEN log_type = 'На контроле в рамках коллекшн' THEN 1 ELSE 0 END) collection_control_cnt,
           SUM(CASE WHEN log_type = 'Вернули в очередь коллекшн' THEN 1 ELSE 0 END) collection_return_to_stack_cnt,
           MIN(CASE WHEN (log_type = 'Попытка звонка, не отвечает') OR (log_type = 'Попытка звонка, недоступен') OR (log_type = 'Обещание оплаты на звонке') THEN date(ts) ELSE '2100-01-01' END) first_atc_date,    
           MIN(CASE WHEN (log_type = 'Обещание оплаты на звонке') THEN date(ts) ELSE '2100-01-01' END) first_contact_date 
           FROM temp.crm_log_type WHERE app_id IS NOT NULL GROUP BY app_id) AS crm ON crm.app_id = i.applicationId) as a