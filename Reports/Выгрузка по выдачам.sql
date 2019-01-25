SELECT i.applicationId, i.auserId, i.sum AS loan_amt, 1 AS loan_cnt, i.applicationStatusId, i.title as applicationStatusname, 
  date(i.loanDateStart) as loanDateStart, MONTH(date(i.loanDateStart)) AS vintage_month, YEAR(date(i.loanDateStart)) AS vintage_year,
  i.period AS actual_period, i.planPeriod AS Term, date(i.loanDateEnd) AS loanDateEnd , i.score_group, i.score_before, 
  i.Balance, i.Bazis, i.applicationIsOverdue, i.rate, i.repay AS repayment_v_a, 
  i.prev_apps_id, i.prev_apps_cnt, i.prev_apps_date, i.prev_loan_amt,
  CASE WHEN i.prev_apps_cnt > 0 THEN 0 ELSE 1 END first_loan_flg,
  CASE WHEN r.repayments_v_ta > 50 THEN 1 ELSE 0 END repayment_flg,
  CASE WHEN r.repayments_v_ta >= i.sum THEN 1 ELSE 0 END paid_bazis_flg,
  CASE WHEN r.repayments_v_ta > 50 THEN i.sum ELSE 0 END amt_payment,
  CASE WHEN r.repayments_v_ta >= i.sum THEN i.sum ELSE 0 END amt_paid_bazis,

  r.repayments_v_ta, r.repayments_cnt, r.first_payment_date, r.last_payment_date, r.fld_total_repaid, r.bazis_repaid_amt,
  CASE WHEN r.first_payment_date IS NOT NULL THEN i.planPeriod - DATEDIFF(r.first_payment_date,date(i.loanDateStart)) ELSE NULL END first_payment_over_duedate_days,
  CASE WHEN i.loanDateEnd IS NOT NULL THEN i.planPeriod - DATEDIFF(date(i.loanDateEnd),date(i.loanDateStart)) ELSE NULL END loan_closed_over_duedate_days_v_a,
  CASE WHEN (r.last_payment_date IS NOT NULL) AND (r.fld_total_repaid > 0)
    THEN i.planPeriod - DATEDIFF(r.last_payment_date,date(i.loanDateStart)) ELSE NULL END loan_closed_over_duedate_days_v_ta,
  
  pr.requests_to_prolongate_cnt, pr.requests_to_prolongate_approved_cnt, (i.period - i.planPeriod) AS prolongation_period_days,
  CASE WHEN pr.requests_to_prolongate_cnt > 0 THEN 1 ELSE 0 END flg_request_to_Prolongate,  
  CASE WHEN pr.requests_to_prolongate_approved_cnt > 0 THEN 1 ELSE 0 END flg_request_to_Prolongate_approved, pro.commissions_accrued_amt

   FROM temp.issues AS i
  LEFT JOIN (SELECT applicationId, SUM(sum) AS repayments_v_ta, count(*) AS repayments_cnt, MIN(date(tms)) AS first_payment_date, MAX(date(tms)) AS last_payment_date,
    CASE WHEN MIN(Bazis2) = 0 THEN 1 ELSE 0 END fld_total_repaid, SUM(Bazis1-Bazis2) AS bazis_repaid_amt FROM temp.repayments GROUP BY applicationId) AS r ON r.applicationId = i.applicationId
  LEFT JOIN (SELECT a.applicationId, count(*) AS requests_to_prolongate_cnt, SUM(CASE WHEN a.tmsApprove IS NOT NULL THEN 1 ELSE 0 END) AS requests_to_prolongate_approved_cnt
             FROM platiza_client.prolongate_loan as a GROUP BY a.applicationId) AS pr ON pr.applicationId = i.applicationId
  LEFT JOIN (SELECT ta.applicationId, SUM(ta.sum) AS commissions_accrued_amt FROM platiza_admin.tr_accounting ta 
  WHERE date(ta.tms) > '2015-12-31' AND ((ta.type = 'Rate') OR (ta.type = 'Penalty') OR (ta.type = 'Fee')) GROUP BY ta.applicationId) AS pro ON pro.applicationId = i.applicationId



