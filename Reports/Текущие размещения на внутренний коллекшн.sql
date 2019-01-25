INSERT INTO temp.collector_curr (applicationId, status_id, next_date, create_date, promised_pay, for_control, add_data, owner_id, status_name) 
SELECT ac.applicationId, ac.status_id, ac.next_date, ac.create_time, ac.promised_pay,
  ac.for_control, ac.add_data, ac.owner_id, acs.status_name FROM platiza_admin.application_collector ac
  LEFT JOIN platiza_admin.application_collector_status acs ON ac.status_id = acs.status_id
  WHERE date(ac.create_time) > '2016-12-31'
