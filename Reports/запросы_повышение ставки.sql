/*вхождение в режим*/
/*insert into temp.enter_mode*/
select person_id, min(score) score,  min(tms_start) as Date_transf, if(min(tms_start)>= CAST('2017-07-06 16:00:00' AS DATETIME), 1,0) as Flag_newrate,
       IF(max(score) = 900, 1, 0) as Flag_pers /*,IF(count(person_id) >1, 1, 0) as Flag_povt*/
from platiza_scoring2.person_mode_history 
where score = 900       
group by person_id, 
having min(tms_start) >= CAST('2017-01-01' AS DATE)

  /*Выборка клиентов. Вхождение в режим*/

select person_id, max(score) score,  Month(tms_start) as Date_transf, if(min(tms_start)>= CAST('2017-07-06 16:00:00' AS DATETIME), 1,0) as Flag_newrate,
       IF(max(score) = 900, 1, 0) as Flag_pers /*,IF(count(person_id) >1, 1, 0) as Flag_povt*/
       from platiza_scoring2.person_mode_history 
       where score = 900       
       group by person_id
       having min(tms_start) >= CAST('2017-01-01' AS DATE)
  
/*Связка с application. Проверка факта выдачи данные по сумме займа*/


выборка person_id с признаком: platiza_scoring2.application.isResive=1 за период:
tmsFbResive >= person_enter.Date_transf and tmsFbResive <= DATE_ADD(person_enter.Date_trans, INTERVAL 30 DAY):
tmsFbResive -'Время записи результата выдачи займа',
Date_transf  - дата включ. Клиента в катгорию "Персональные условия"


/*Выборка платежей из базы Admin*/  temp.rates r
/*////////////////////старый вариант/////////////////////////////////////////////////////*/

  /*выбор клиентов*/

insert into temp_10.person_cond
SELECT 
    pmh.person_id, pmh.tms_start, if(tms_start>= CAST('2017-07-06 16:00:00' AS DATETIME), 1,0) as Flag_newrate
FROM
    person_mode_history pmh
WHERE
    mode_score_id = 11 && 
    (
  select pmh3.is_finish from person_mode_history pmh3 where pmh3.id = 
        (
  select Max(pmh2.id) from person_mode_history pmh2 where pmh2.person_id = pmh.person_id && pmh2.id<pmh.id
  )
    ) = 1
order by 1 desc

select* from temp_10.person_cond






 /*select count(ap.applicationId), sum(amount) Zaim, avg(term_initial) Avg_sroc, Month(tmsFbResive) as Month1 from platiza_scoring2.application ap, 
 (select person_id, Month(tms_start)  Month1, min(tms_start) as Date_trans 
 from platiza_scoring2.person_mode_history where mode_score_id = 11 
 group by person_id, Month(tms_start) having min(tms_start) > CAST('2017-07-06 16:00:00' AS DATETIME)) as Date1
 where Date1.person_id = ap.personId /*and tmsFbResive is not null*/ and tmsFbResive >= Date1.Date_trans and tmsFbResive <= DATE_ADD(Date1.Date_trans, INTERVAL 30 DAY) 
 group by Month1 */




select sc.Id_zaim, sc.flag_newrate, scoringApplicationId, sum(acc.sum), month(tms), type
from platiza_admin.tr_accounting acc, platiza_admin.application ap, temp.scoring sc
where ap.applicationId=acc.applicationId AND ap.scoringApplicationId=sc.ID_zaim
      AND acc.tms >= CAST('2017-01-01' AS DATE)      
group by sc.Id_zaim, scoringApplicationId, sc.flag_newrate, month(tms), type


/*select ap.scoringApplicationId, ap.applicationId, ret.sum, ret.tms, r.sum, p.sum
from /*platiza_admin.tr_accounting*/platiza_admin.application ap
      

       select sum(ret.sum), sum(r.sum), sum(p.sum)
       from 
       select applicationId, ret.sum, auserID, tms from 
       left join temp.repayment ret  on ap.applicationId=ret.applicationId
       left join temp.penalties p on p.applicationId=ret.applicationId
       left join temp.rates r on p.applicationId=r.applicationId
       group by applicationId, month(tms)
    

where */



/*повторное взятие займа

select ap.person_id, ap. applicationId as ID_zaim, sum(ap.amount) as Sum_zaim, Date_transf, term_initial, ap.isResive as Flag_zaim, isOverdue as Flag_delay,
        if((tmsFbRepay - (tmsFbResive+term_initial))<10,1,0) as Flag_10,  if((tmsFbRepay - (tmsFbResive+term_initial))<30,1,0) as Flag_30, if((tmsFbRepay - (tmsFbResive+term_initial))<15,1,0) as Flag_15+,
        rate, if(tmsFbResive is not NULL, 1,0) as Flag_plat, if((tmsFbRepay - (tmsFbResive+term_initial))<15,1,0) as Flag_15+ 
from platiza_scoring2.application ap,
     (select person_id, max(score) score,  Month(tms_start) as Date_transf, if(min(tms_start)>= CAST('2017-07-06 16:00:00' AS DATETIME), 1,0) as Flag_newrate,
       IF(max(score) = 900, 1, 0) as Flag_pers /*,IF(count(person_id) >1, 1, 0) as Flag_povt*/
       from platiza_scoring2.person_mode_history 
       where score = 900       
       group by person_id, Month(tms_start)
       having min(tms_start) >= CAST('2017-01-01' AS DATE)) as person_enter
where "расчет_персональные".person_id = ap.personId and tmsFbResive >= person_enter.Date_transf and tmsFbResive <= DATE_ADD(person_enter.Date_trans, INTERVAL 30 DAY) 
       AND isResive=1
group by ap.person_id



/*заполнение начисленные проценты*/
INSERT INTO temp.rates (accountingId,tms,auserId, applicationId, type, sum, Balance1, Balance2, Bazis1, Bazis2)
SELECT ta.accountingId,ta.tms,ta.auserId, ta.applicationId, ta.type, ta.sum, ta.Balance1, ta.Balance2, ta.Bazis1, ta.Bazis2
FROM platiza_admin.tr_accounting ta WHERE ta.tms > '2015-12-31' AND ta.type = 'RATE'

/*заполнение начисленные проценты*/
select* from temp.penalties

INSERT INTO temp.rates (accountingId,tms,auserId, applicationId, type, sum, Balance1, Balance2, Bazis1, Bazis2)
SELECT ta.accountingId,ta.tms,ta.auserId, ta.applicationId, ta.type, ta.sum, ta.Balance1, ta.Balance2, ta.Bazis1, ta.Bazis2
FROM platiza_admin.tr_accounting ta WHERE ta.tms > '2015-12-31' AND ta.type = 'PENALTY'


platiza_admin.tr_accounting