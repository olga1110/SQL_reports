insert into temp_10.person_cond


SELECT 
    pmh.person_id, pmh.tms_start, if(tms_start>= CAST('2017-07-06 16:00:00' AS DATETIME), 1,0) as Flag_newrate
FROM
    person_mode_history pmh
WHERE
    mode_score_id = 11 && 
    ( select pmh3.is_finish from person_mode_history pmh3
      where pmh3.id =  (select Max(pmh2.id) from person_mode_history pmh2 where pmh2.person_id = pmh.person_id && pmh2.id<pmh.id)
    ) = 1
order by 1 desc

/*****************************************************************/


SELECT 
    pmh.person_id, month(pmh.tms_start), if(tms_start>= CAST('2017-07-06 16:00:00' AS DATETIME), 1,0) as Flag_newrate
FROM
    person_mode_history pmh
WHERE
    mode_score_id = 11 && 
    ( select pmh3.is_finish from person_mode_history pmh3
      where pmh3.id =  (select Max(pmh2.id) from person_mode_history pmh2 where pmh2.person_id = pmh.person_id && pmh2.id<pmh.id)
    ) = 1 && tms_start>= CAST('2017-09-01' AS DATE)
order by 1 desc




  Select* from platiza_scoring2.person_mode_history order by id desc;

  SELECT COUNT(DISTINCT pmh.person_id) FROM person_mode_history pmh LEFT JOIN person_mode_history pmh1 ON pmh.person_id = pmh1.person_id AND pmh.id>pmh1.id AND DATE_FORMAT(pmh1.tms_start, '%Y-%m')>='2017-01'
                                                                             AND pmh1.mode_score_id!=11
  WHERE pmh.mode_score_id=11 AND DATE_FORMAT(pmh.tms_start, '%Y-%m')='2017-09' AND pmh1.id IS NOT NULL 
  ;



insert into temp_10.person_cond (Flag_povtor)
(select if (count(person_id)>1,1,0) as Flag_povtor
from temp_10.person_cond
group by person_id)

/*повторные переходы*/

Select* from temp_10.person_cond

/*2* Займы: сумма, ставка, просрочка, сроки*/

select app.personid, app. applicationId as ID_zaim, sum(app.amount) as Sum_zaim, month(pc.tms_start) as Month_enter, avg(term_initial), avg(rate), app.isResive as Flag_zaim, isOverdue as Flag_delay,
       if(DATEDIFF(tmsFbRepay,DATE_ADD(tmsFbResive, INTERVAL term_initial DAY))<10,1,0) as Flag_10,  
       if(DATEDIFF(tmsFbRepay,DATE_ADD(tmsFbResive, INTERVAL term_initial DAY))<30,1,0) as Flag_30,
       if(DATEDIFF(tmsFbRepay,DATE_ADD(tmsFbResive, INTERVAL term_initial DAY))<15,1,0) as Flag_15,  
       if((tmsFbResive >= pc.tms_start and tmsFbResive <= DATE_ADD(pc.tms_start, INTERVAL 30 DAY)),1,0) as Flag_inter, 
       Flag_newrate             
from temp_10.person_cond pc left join platiza_scoring2.application as app on pc.person_id = app.personId
      
where app.personid = pc.person_id  
      and month(app.tmsFbResive) = month(pc.tms_start)
      and tms_start>= CAST('2017-01-01' AS DATE)
             
             /*AND isResive=1*/
group by app.personid,applicationId, month(pc.tms_start)


select tmsFbResive, amount from platiza_scoring2.application where personid=870466

/*******************Сумма займа*************************************/

select app.personid, app. applicationId as ID_zaim, sum(app.amount) as Sum_zaim, month(pc.tms_start) as Month_enter, term_initial, rate, app.isResive as Flag_zaim, isOverdue as Flag_delay,
       if(DATEDIFF(tmsFbRepay,DATE_ADD(tmsFbResive, INTERVAL term_initial DAY))<10,1,0) as Flag_10,  
       if(DATEDIFF(tmsFbRepay,DATE_ADD(tmsFbResive, INTERVAL term_initial DAY))<30,1,0) as Flag_30,
       if(DATEDIFF(tmsFbRepay,DATE_ADD(tmsFbResive, INTERVAL term_initial DAY))<15,1,0) as Flag_15,  
       if((tmsFbResive >= pc.tms_start and tmsFbResive <= DATE_ADD(pc.tms_start, INTERVAL 30 DAY)),1,0) as Flag_inter, 
       Flag_newrate             
from temp_10.person_cond pc left join platiza_scoring2.application as app on pc.person_id = app.personId
      
where app.personid = pc.person_id  
      and tms_start>= CAST('2017-01-01' AS DATE)
             /*AND isResive=1*/
group by app.personid,applicationId, month(pc.tms_start)



select* from temp_10.person_cond pc

select* from platiza_scoring2.application where personId= 381 and tmsFbResive>= CAST('2017-01-01' AS DATE)

select* from  temp.scoring
drop table temp.scoring_pers  

/*3* Платежи*/
select sc.Id_zaim, scoringApplicationId, sum(acc.sum), month(tms), type
from platiza_admin.tr_accounting acc, platiza_admin.application ap, temp.scoring sc
where ap.applicationId=acc.applicationId AND ap.scoringApplicationId=sc.ID_zaim AND acc.month(tms)=sc.mounth(tms_start)
      AND acc.tms >= CAST('2017-01-01' AS DATE)      
group by sc.Id_zaim, scoringApplicationId, month(tms), type