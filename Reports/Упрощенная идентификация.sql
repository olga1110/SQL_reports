SELECT user_id, tms_stage, tms_expire
from platiza_admin.si_process s
WHERE stage = 'SENDCODE' and tms_create >= DATE('2017-01-01')
group by user_id

SELECT user_id,max(time_to_sec(timediff(tms_expire,tms_stage)))
from platiza_admin.si_process s
WHERE err_code<>99 AND stage= 'IDENTIFY' AND status = 'SUCCESS'
group by user_id, DATE()

SELECT vsego.DAY1, klient_ident, klient_vsego

/*Успешно прошли идентификацию*/
FROM
(SELECT DATE(tms_stage) as DAY1, count(distinct user_id) klient_vsego
from platiza_admin.si_process s
WHERE version = 'modulbank'
group by DATE(tms_stage)) vsego 
LEFT JOIN
(SELECT DATE(tms_stage) as DAY1, count(distinct user_id) klient_ident
from platiza_admin.si_process s
WHERE err_code<>99 AND stage= 'IDENTIFY' AND status = 'SUCCESS' AND version = 'modulbank'
group by DATE(tms_stage)) suc
on suc.DAY1= vsego.DAY1

/*Всего отправлены на ID*/

select* from platiza_admin.si_process s

/*парсинг request_url - этап*/

select request_id, SUBSTR(request_url, 46, LOCATE('?',request_url)-46 ), LOCATE('?',request_url), request_url
from platiza_admin.si_request_log
where request_id = '0EAC38F7-AAE5-40A5-AEAF-0BB34B9CF552' 


/*парсинг response_data - текст ответа*/

select request_id, response_data, SUBSTR(response_data, 23, LOCATE(',',response_data)-23), IF(SUBSTR(response_data, 23, LOCATE(',',response_data)-23)='"@status":"ok"',1,0) as FLAG_answer
from platiza_admin.si_request_log response_data
where request_id = '0EAC38F7-AAE5-40A5-AEAF-0BB34B9CF552' 


/*запрос*/

select SUBSTR(response_data, 23, LOCATE(',',request_url)-23)
from platiza_admin.si_request_log

where SUBSTR(request_url, 46, LOCATE('?',request_url)-46 ) = 'smssend' 

SELECT LOCATE('@errortype":',response_data))
from platiza_admin.si_request_log

WHERE SUBSTR(response_data, 23,  SUBSTR(response_data,LOCATE('"@status":',response_data),3) = '"@status":"err"'


'@errortype":'
SELECT SUBSTR(response_data, LOCATE('"@status":',response_data)+10,  LOCATE(',',response_data) - (LOCATE('"@status":',response_data)+10)) AS STAT
from platiza_admin.si_request_log


SELECT SUBSTR(response_data, LOCATE('"@errortype":',response_data)+13,  (LOCATE('"@spid"',response_data)-1) - (LOCATE('"@errortype":',response_data)+13)) AS errortype
from platiza_admin.si_request_log
WHERE SUBSTR(response_data, LOCATE('"@status":',response_data)+10,  LOCATE(',',response_data) - (LOCATE('"@status":',response_data)+10)) = "err"

request_

/*УСПЕШНАЯ ИДЕНТИФИКАЦИЯ*/

SELECT vsego.DAY1, klient_ident, klient_vsego

/*Успешно прошли идентификацию*/
FROM
(SELECT DATE(tms_stage) as DAY1, count(distinct user_id) klient_ident
from platiza_admin.si_process s
WHERE err_code<>99 AND stage= 'IDENTIFY' AND status = 'SUCCESS' AND version = 'modulbank'
group by DATE(tms_stage)) suc

LEFT JOIN

/*Всего отправлены на ID*/

(SELECT DATE(tms_stage) as DAY1, count(distinct user_id) klient_vsego
from platiza_admin.si_process s
WHERE version = 'modulbank'
group by DATE(tms_stage)) vsego
on suc.DAY1= vsego.DAY1


/*результирующий из логов*/

 INSERT INTO temp.si_request_log
 SELECT request_id, SUBSTR(request_url, 46, LOCATE('?',request_url)-46 ) AS Step, SUBSTR(response_data, LOCATE('"@status":',response_data)+10,  LOCATE(',',response_data) - (LOCATE('"@status":',response_data)+10)) AS STAT,  
 IF (SUBSTR(response_data, LOCATE('"@status":',response_data)+10,  LOCATE(',',response_data) - (LOCATE('"@status":',response_data)+10)) = '"err"', SUBSTR(response_data, LOCATE('"@errortype":',response_data)+13,  (LOCATE('"@spid"',response_data)-1) - (LOCATE('"@errortype":',response_data)+13)), "" )
 AS errortype, request_date, response_date, time_to_sec(timediff(response_date,request_date)) as scroc
 from platiza_admin.si_request_log



/*статистика по ошибкам каждого этапа*/
 SELECT step,errortype, COUNT(errortype)
 FROM temp.si_request_log 
 WHERE errortype IS NOT NULL and errortype <> ""
 GROUP BY step,errortype


/*лаги между этапами*/



SELECT day1, avg(time1) as 'Среднее время переход этап1-этап2', avg(time2) as 'Среднее время переход этап2-этап3', avg(sroc1) as 'Среднее время на этапе1', avg(sroc2) as 'Среднее время на этапе2', avg(sroc3) as 'Среднее время на этапе3' 
FROM
(SELECT date(sms.smssend_date) as day1, sms.request_id, time_to_sec(timediff(smscodecheck_date,smssend_date)) as time1, time_to_sec(timediff(identification_date,endsmscodecheck_date)) as time2,  
       sroc1, sroc2, sroc3
FROM
(select request_id, request_date, ` response_date` as smssend_date, scroc as sroc1
from temp.si_request_log l
where step = 'smssend'
group by request_id) sms
LEFT JOIN
(select request_id, request_date  as smscodecheck_date, ` response_date` as endsmscodecheck_date, scroc as sroc2
from temp.si_request_log l
where step = 'smscodecheck'
group by request_id) codecheck
ON sms.request_id = codecheck.request_id
LEFT JOIN
(select request_id, request_date as identification_date, ` response_date` as endidentification_date, scroc as sroc3
from temp.si_request_log l
where step = 'identification'
group by request_id) ident
ON ident.request_id = codecheck.request_id) as tab

GROUP BY day1
ORDER BY 1 

/*проверка*/
select* from platiza_admin.si_request_log
WHERE request_id = '8DA80862-5EBC-446D-AB2E-73592F01B1B2'

/*--------------------*/
/*лаги между этапами*/


select sroc1.day1, 'Среднее время 1этапа', 'Среднее время переход этап1-этап2','Среднее время переход этап2-этап3', 'Среднее время 2этапа', 'Среднее время 3этапа' 
from

(SELECT day1, avg(sroc1) as 'Среднее время 1этапа'
FROM
(SELECT date(sms.smssend_date) as day1, sms.request_id, time_to_sec(timediff(smscodecheck_date,smssend_date)) as time1, time_to_sec(timediff(identification_date,endsmscodecheck_date)) as time2,  
       sroc1, sroc2, sroc3
FROM
(select request_id, request_date, ` response_date` as smssend_date, scroc as sroc1
from temp.si_request_log l
where step = 'smssend'
group by request_id) sms
LEFT JOIN
(select request_id, request_date  as smscodecheck_date, ` response_date` as endsmscodecheck_date, scroc as sroc2
from temp.si_request_log l
where step = 'smscodecheck'
group by request_id) codecheck
ON sms.request_id = codecheck.request_id
LEFT JOIN
(select request_id, request_date as identification_date, ` response_date` as endidentification_date, scroc as sroc3
from temp.si_request_log l
where step = 'identification'
group by request_id) ident
ON ident.request_id = codecheck.request_id) as tab

WHERE sroc1 IS NOT NULL 

GROUP BY day1
ORDER BY 1) as sroc1

LEFT JOIN 
(SELECT day1, avg(time1) as 'Среднее время переход этап1-этап2'
FROM
(SELECT date(sms.smssend_date) as day1, sms.request_id, time_to_sec(timediff(smscodecheck_date,smssend_date)) as time1, time_to_sec(timediff(identification_date,endsmscodecheck_date)) as time2,  
       sroc1, sroc2, sroc3
FROM
(select request_id, request_date, ` response_date` as smssend_date, scroc as sroc1
from temp.si_request_log l
where step = 'smssend'
group by request_id) sms
LEFT JOIN
(select request_id, request_date  as smscodecheck_date, ` response_date` as endsmscodecheck_date, scroc as sroc2
from temp.si_request_log l
where step = 'smscodecheck'
group by request_id) codecheck
ON sms.request_id = codecheck.request_id
LEFT JOIN
(select request_id, request_date as identification_date, ` response_date` as endidentification_date, scroc as sroc3
from temp.si_request_log l
where step = 'identification'
group by request_id) ident
ON ident.request_id = codecheck.request_id) as tab

WHERE time1 IS NOT NULL 

GROUP BY day1
ORDER BY 1) as step1
ON step1.day1 = sroc1.day1

LEFT JOIN 
(SELECT day1, avg(time2) as 'Среднее время переход этап2-этап3'
FROM
(SELECT date(sms.smssend_date) as day1, sms.request_id, time_to_sec(timediff(smscodecheck_date,smssend_date)) as time1, time_to_sec(timediff(identification_date,endsmscodecheck_date)) as time2,  
       sroc1, sroc2, sroc3
FROM
(select request_id, request_date, ` response_date` as smssend_date, scroc as sroc1
from temp.si_request_log l
where step = 'smssend'
group by request_id) sms
LEFT JOIN
(select request_id, request_date  as smscodecheck_date, ` response_date` as endsmscodecheck_date, scroc as sroc2
from temp.si_request_log l
where step = 'smscodecheck'
group by request_id) codecheck
ON sms.request_id = codecheck.request_id
LEFT JOIN
(select request_id, request_date as identification_date, ` response_date` as endidentification_date, scroc as sroc3
from temp.si_request_log l
where step = 'identification'
group by request_id) ident
ON ident.request_id = sms.request_id) as tab

WHERE time2 IS NOT NULL 

GROUP BY day1
ORDER BY 1) as step2

ON step1.day1 = step2.day1
 
LEFT JOIN 

(SELECT day1, avg(sroc2) as 'Среднее время 1этапа'
FROM
(SELECT date(sms.smssend_date) as day1, sms.request_id, time_to_sec(timediff(smscodecheck_date,smssend_date)) as time1, time_to_sec(timediff(identification_date,endsmscodecheck_date)) as time2,  
       sroc1, sroc2, sroc3
FROM
(select request_id, request_date, ` response_date` as smssend_date, scroc as sroc1
from temp.si_request_log l
where step = 'smssend'
group by request_id) sms
LEFT JOIN
(select request_id, request_date  as smscodecheck_date, ` response_date` as endsmscodecheck_date, scroc as sroc2
from temp.si_request_log l
where step = 'smscodecheck'
group by request_id) codecheck
ON sms.request_id = codecheck.request_id
LEFT JOIN
(select request_id, request_date as identification_date, ` response_date` as endidentification_date, scroc as sroc3
from temp.si_request_log l
where step = 'identification'
group by request_id) ident
ON ident.request_id = codecheck.request_id) as tab

WHERE sroc2 IS NOT NULL 

GROUP BY day1
ORDER BY 1) as sroc2

ON step2.day1 = sroc2.day1

LEFT JOIN

(SELECT day1, avg(sroc3) as 'Среднее время 1этапа'
FROM
(SELECT date(sms.smssend_date) as day1, sms.request_id, time_to_sec(timediff(smscodecheck_date,smssend_date)) as time1, time_to_sec(timediff(identification_date,endsmscodecheck_date)) as time2,  
       sroc1, sroc2, sroc3
FROM
(select request_id, request_date, ` response_date` as smssend_date, scroc as sroc1
from temp.si_request_log l
where step = 'smssend'
group by request_id) sms
LEFT JOIN
(select request_id, request_date  as smscodecheck_date, ` response_date` as endsmscodecheck_date, scroc as sroc2
from temp.si_request_log l
where step = 'smscodecheck'
group by request_id) codecheck
ON sms.request_id = codecheck.request_id
LEFT JOIN
(select request_id, request_date as identification_date, ` response_date` as endidentification_date, scroc as sroc3
from temp.si_request_log l
where step = 'identification'
group by request_id) ident
ON ident.request_id = codecheck.request_id) as tab

WHERE sroc3 IS NOT NULL 

GROUP BY day1
ORDER BY 1) as sroc3

on sroc3.day1 = step1.day1

/*проверка*/
select* from platiza_admin.si_request_log
WHERE request_id = '8DA80862-5EBC-446D-AB2E-73592F01B1B2'

, avg(time2) as 'Среднее время переход этап2-этап3', avg(sroc1) as 'Среднее время на этапе1', avg(sroc2) as 'Среднее время на этапе2', avg(sroc3) as 'Среднее время на этапе3' 


select* from temp.si_request_log
where Step = 'identification' and request_date is not null


select* from platiza_admin.si_request_log
where  request_id = 'B36A5AC5-7F51-4776-987E-2023E4CF3F01'