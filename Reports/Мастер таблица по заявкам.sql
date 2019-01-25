INSERT INTO temp.issues (applicationId, auserId, tmsCreate, sum, period, applicationStatusId,title, rate, repay, Bazis, 
  Balance, applicationIsOverdue, loanDateStart, planPeriod, loanDateEnd, score_group, score_before, attr, prev_apps_id , prev_apps_cnt, prev_apps_date, prev_loan_amt)
SELECT a.applicationId, a.auserId, a.tmsCreate, a.sum, a.period, a.applicationStatusId, apps.title, 
  a.rate, a.repay, a.Bazis, a.Balance, a.applicationIsOverdue, 
  a.loanDateStart, MIN(COALESCE(pl.periodBefore, a.period)) AS planPeriod, a.loanDateEnd,
  SUBSTR(a.attrs,INSTR(a.attrs,'score_group=')+LENGTH('score_group='),1) AS score_group,
  SUBSTR(a.attrs,LENGTH('score_before=')+1,INSTR(a.attrs,'&')-LENGTH('score_before=')-1) AS score_before, a.attrs,
  pa.prev_apps_id, CASE WHEN pa.prev_apps_id IS NULL THEN 0 ELSE pa.prev_apps_cnt END prev_apps_cnt, 
  pa.prevloanDateStart AS prev_apps_date, pa.prev_loan_amt
  FROM platiza_admin.application a
LEFT JOIN platiza_client.prolongate_loan pl ON a.applicationId = pl.applicationId AND pl.status=2 AND pl.isOverdue
LEFT JOIN platiza_admin.application_status apps ON a.applicationStatusId = apps.applicationStatusId
LEFT JOIN (SELECT b.applicationId, count(*) as prev_apps_cnt, SUM(prevloan_amt) AS prev_loan_amt, MAX(b.prev_apps_id) AS prev_apps_id, MAX(date(b.loanDateStart1)) AS prevloanDateStart 
  FROM (SELECT a.applicationId, a1.applicationId AS prev_apps_id, a.loanDateStart, a1.loanDateStart AS loanDateStart1, a1.sum AS prevloan_amt 
    FROM platiza_admin.application a LEFT JOIN platiza_admin.application a1 ON a.auserId = a1.auserId AND a.loanDateStart>=a1.loanDateStart AND a.applicationId <> a1.applicationId
  WHERE date(a.loanDateStart) > '2015-12-31' AND a.applicationStatusId > 3 AND
        ((a1.applicationStatusId > 3) OR (a1.applicationStatusId IS NULL))) as b GROUP BY b.applicationId) pa ON a.applicationId = pa.applicationId
WHERE a.applicationStatusId>3 AND date(a.loanDateStart) > '2015-12-31'
    GROUP BY 1