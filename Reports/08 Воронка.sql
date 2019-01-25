SELECT
  week(a.tms) AS `date`,/* COALESCE(CONCAT(lc.title,' (',s.pc,')'),s.pc) AS 'pc',
  IF(lc.id = 4 AND lp.partner_id IS NOT NULL,CONCAT(lp.name,' (',s.p1,')'),s.p1) AS 'p1', s.p2, mid(s.query_params,locate('&a_id=',s.query_params)+6, locate('%',s.query_params,
locate('a_id=',s.query_params))-(locate('&a_id=',s.query_params)+6)) as eid,*/
  
  COUNT(*) AS cnt,
  
  sum(CASE
    WHEN EXISTS(SELECT 1 FROM platiza_client.inn_found if1 WHERE if1.auserId = a.auserId) THEN 1 ELSE 0
  END) AS `inn_try`,
  
  sum(CASE
    WHEN EXISTS(SELECT 1 FROM platiza_client.inn_found if2 WHERE if2.auserId = a.auserId AND if2.status = 'DONE') THEN 1 ELSE 0
  END) AS `inn_success`,
  
  sum(CASE
    WHEN EXISTS(SELECT 1 FROM platiza_client.anketa a1 WHERE a1.auserId = a.auserId AND a1.anketaIndex = 0) THEN 1 ELSE 0
  END) AS `anketa_try`,
  
  sum(CASE
    WHEN EXISTS(SELECT 1 FROM platiza_client.anketa a2 WHERE a2.auserId = a.auserId AND a2.anketaIndex = 0 AND a2.status = 'VALID') THEN 1 ELSE 0
  END) AS `anketa_success`,
  
  sum(CASE
    WHEN EXISTS(SELECT 1 FROM platiza_client.ausermeta a3 WHERE a3.auserId = a.auserId AND a3.applicationId = 0 AND a3.ametaId = 'userPresentation' AND a3.val = 'on') THEN 1 ELSE 0
  END) AS `presentation_end`,
  
  sum(CASE
    WHEN EXISTS(SELECT 1 FROM platiza_client.application a4 WHERE a4.auserId = a.auserId) THEN 1 ELSE 0
  END) AS `app_try`,
  
  sum(CASE
    WHEN EXISTS(SELECT 1 FROM platiza_client.application a4 WHERE a4.auserId = a.auserId AND a4.applicationStatusId IN (4,5)) THEN 1 ELSE 0
  END) AS `app_success`


FROM
  platiza_client.auser a
  /*LEFT JOIN loginSession s ON a.auserId = s.auserId
  LEFT JOIN platiza_client.login_channel lc ON lc.id = s.pc
  LEFT JOIN platiza_client.leads_partner lp ON lp.partner_id = s.p1*/
WHERE DATE(a.tms)>='2017-01-01' /*AND DATE(a.tms)<='2017-07-03'*/
  AND a.partner_id=7
GROUP BY 1/*,2,3,4,5*/