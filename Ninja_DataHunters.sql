-------------- DataHunters SQL Hackathon ------------------------

-- 1. Get list of Patients order by DateOfBirth descending order 
SELECT "DateOfBirth","FirstName","LastName" 
FROM public."Patients" 
ORDER BY "DateOfBirth" DESC;

-- 2. Display the firstname and lastname of patients who speaks English language
SELECT P."FirstName",P."LastName", L."Language"
FROM public."Patients" P
Left JOIN "Language" L ON L."Language_ID" = P."Language_ID"
WHERE L."Language" = 'English';

--3. Write a query to get list of patient ID's whose PrimaryDiagnosis is 'Flu'. order by patient_ID 
SELECT R."Patient_ID", Pr."PrimaryDiagnosis" 
FROM "ReAdmissionRegistry" R 
left JOIN "PrimaryDiagnosis" Pr ON Pr."Diagnosis_ID" = R."Diagnosis_ID" 
WHERE Pr."PrimaryDiagnosis" = 'Flu'
ORDER BY R."Patient_ID";

--4. Write a query to find the Patient_ID and Admission_ID for the patients whose Primary diaganosis is 'Heart Failure'
SELECT R."Patient_ID", R."Admission_ID", Pr."PrimaryDiagnosis"
FROM "ReAdmissionRegistry" R 
Left JOIN "PrimaryDiagnosis" Pr ON Pr."Diagnosis_ID" = R."Diagnosis_ID" 
WHERE Pr."PrimaryDiagnosis" = 'Heart Failure';

--5. Write a query to get list of patient ID's whose pulse is below the normal range 
SELECT Av."Patient_ID", Av."Pulse"
FROM "AmbulatoryVisits" Av 
WHERE Av."Pulse"  IS NOT null
AND (Av."Pulse" < 60);

--6. Write a query to find the list of patient_ID's discharged with Service in SID01, SID02, SID03
SELECT D."Patient_ID", D."DischargeDate", D."Service_ID"
FROM "Discharges" D 
WHERE D."Service_ID" IN ('SID01', 'SID02', 'SID03');

--7. Write a query to get list of patients who were admitted because of Stomachache.
SELECT P."FirstName", P."LastName", R."ReasonForVisit" 
FROM public."Patients" P
Left JOIN "EDVisits" E ON E."Patient_ID" = P."Patient_ID"
Left JOIN "ReasonForVisit" R ON R."Rsv_ID" = E."Rsv_ID"
WHERE R."Rsv_ID" = 'Rsv01';

--8. Write a query to Update Service ID SID05 to Ortho
UPDATE public."Service"
SET "Service" = 'Ortho'
WHERE "Service_ID" = 'SID05'

COMMIT;
SELECT * FROM public."Service"

--9. Get list of Patient ID's whose visit type was 'Followup' and VisitdepartmentID is 5 or 6
SELECT A."Patient_ID", A."VisitDepartmentID", V."VisitType" 
FROM "AmbulatoryVisits" A
LEFT JOIN "VisitTypes" V ON V."AMVT_ID" = A."AMVT_ID"
WHERE V."VisitType" = 'Follow Up' AND A."VisitDepartmentID" IN ('5', '6');

--10. Create index on ambulatory visit by selecting columns Visit_ID, AMVT_ID and VisitStatus_ID
CREATE UNIQUE INDEX AmbVisit_idx ON public."AmbulatoryVisits" ("Visit_ID", "AMVT_ID", "VisitStatus_ID");

SELECT
indexname,
indexdef
from
pg_indexes
where
tablename = 'AmbulatoryVisits';

--11. Create a trigger to execute after inserting a record into Patients table.Insert value to display result.
--New Table "NewPatientLog" created for trigger.

-- Table: public.NewPatientLog

-- DROP TABLE IF EXISTS public."NewPatientLog";

CREATE TABLE IF NOT EXISTS public."NewPatientLog"
(
    "Patient_ID" integer NOT NULL,
    "FirstName" text COLLATE pg_catalog."default",
    "LastName" text COLLATE pg_catalog."default",
    "DateOfBirth" date,
    "Gender_ID" text COLLATE pg_catalog."default",
    "Race_ID" text COLLATE pg_catalog."default",
    "Language_ID" text COLLATE pg_catalog."default",
    CONSTRAINT "NewPatientLog_pkey" PRIMARY KEY ("Patient_ID"),
    CONSTRAINT "NewPatientLogGender_ID_FK" FOREIGN KEY ("Gender_ID")
        REFERENCES public."Gender" ("Gender_ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "NewPatientLogLangugae_ID_FK" FOREIGN KEY ("Language_ID")
        REFERENCES public."Language" ("Language_ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "NewPatientLogRace_ID_FK" FOREIGN KEY ("Race_ID")
        REFERENCES public."Race" ("Race_ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."NewPatientLog"
    OWNER to postgres;
-- Index: fki_Gender_ID_FK

-- DROP INDEX IF EXISTS public."NewPatientLogfki_Gender_ID_FK";

CREATE INDEX IF NOT EXISTS "NewPatientLogfki_Gender_ID_FK"
    ON public."NewPatientLog" USING btree
    ("Gender_ID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: fki_Langugae_ID_FK

-- DROP INDEX IF EXISTS public."NewPatientLogfki_Langugae_ID_FK";

CREATE INDEX IF NOT EXISTS "NewPatientLogfki_Langugae_ID_FK"
    ON public."NewPatientLog" USING btree
    ("Language_ID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: fki_Race_ID_FK

-- DROP INDEX IF EXISTS public."NewPatientLogfki_Race_ID_FK";

CREATE INDEX IF NOT EXISTS "NewPatientLogfki_Race_ID_FK"
    ON public."NewPatientLog" USING btree
    ("Race_ID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: index_patient_id

-- DROP INDEX IF EXISTS public.NewPatientLogindex_patient_id;

CREATE OR REPLACE FUNCTION record_insert()
RETURNS TRIGGER AS
$$
BEGIN
INSERT INTO public."NewPatientLog"("Patient_ID", "FirstName", "LastName", "DateOfBirth", "Gender_ID", "Race_ID", "Language_ID")
VALUES (NEW."Patient_ID", NEW."FirstName", NEW."LastName", NEW."DateOfBirth", NEW."Gender_ID", NEW."Race_ID", NEW."Language_ID");
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER New_patient_record
 AFTER INSERT
 ON public."Patients"
 FOR EACH ROW
 EXECUTE PROCEDURE record_insert();
 
 INSERT INTO public."Patients" VALUES (946, 'Kiran', 'Bhat', NULL, 'G001', 'R01', 'L_01');

---12. Write a query to find the ProviderName and Provider Speciality for PS_ID = 'PSID02' 
SELECT P."ProviderName", P."PS_ID", S."ProviderSpeciality" 
FROM public."Providers" P
left JOIN  public."ProviderSpeciality" S ON S."PS_ID" =P."PS_ID"
WHERE S."PS_ID" ='PSID02';

--13. Display the patient names and ages whose age is more than 50 years
SELECT "FirstName", "LastName", age("DateOfBirth") FROM "Patients"  
WHERE age ("DateOfBirth" )> '50 years';

--14. Write a query to get list of patient ID's and service whose are in service as 'Nuerology' 
SELECT R."Patient_ID", S."Service" 
FROM public."ReAdmissionRegistry" R
Left JOIN public."Service" S on S."Service_ID" = R."Service_ID"
WHERE S."Service" = 'Neurology';

--15. Create view on table Provider table on columns ProviderName and Provider_ID 
CREATE VIEW ProviderInfo AS
SELECT "Provider_ID", "ProviderName"
FROM public."Providers";

SELECT * FROM providerinfo;

--16. Write a query to Extract Year from ProviderDateOnStaff 
SELECT providers."Provider_ID", providers."ProviderName", date_part('year', providers."ProviderDateOnStaff") 
FROM public."Providers" providers;

--17. Write a query to get unique Patient_ID, race and Language of patients whose race is White and also speak English.
SELECT P."Patient_ID", R."Race", L."Language"
FROM "Patients" P
Left JOIN "Race" R ON R."Race_ID" = P."Race_ID"
Left JOIN "Language" L ON L."Language_ID" = P."Language_ID"
WHERE R."Race" = 'White' AND L."Language" = 'English';

--18. Get list of patient ID's whose service was 'Cardiology' and discharged to 'Home'
SELECT P."Patient_ID", S."Service", Dd."DischargeDisposition"
From public."Patients" P
LEFT JOIN "Discharges" D ON D."Patient_ID" = P."Patient_ID"
LEFT JOIN "Service" S ON S."Service_ID" = D."Service_ID"
LEFT JOIN "DischargeDisposition" Dd ON Dd."Discharge_ID" = D."Discharge_ID"
WHERE S."Service" = 'Cardiology' AND Dd."DischargeDisposition" = 'Home';

--19. Write a query to get list of Provider names whose Provider name is starting with letter T
SELECT "ProviderName" FROM public."Providers" 
WHERE "ProviderName" LIKE 'T%';

--20. List female patients over the age of 40 who have undergone surgery from January-March 2019
SELECT P."FirstName", P."LastName", age(P."DateOfBirth"), G."Gender", Ps."ProviderSpeciality", A."DateofVisit" 
FROM "Patients" P 
Left JOIN "Gender" G ON G."Gender_ID" = P."Gender_ID"
Left JOIN "AmbulatoryVisits" A ON A."Patient_ID" = P."Patient_ID"
Left JOIN "Providers" Pr ON Pr."Provider_ID" = A."Provider_ID"
Left JOIN "ProviderSpeciality" Ps ON Ps."PS_ID" = Pr."PS_ID"
WHERE (EXTRACT(YEAR FROM "DateofVisit") - EXTRACT(YEAR FROM "DateOfBirth")) > '40' AND G."Gender" = 'Female' AND Ps."PS_ID" = 'PSID02'
AND A."DateofVisit" BETWEEN '2019-01-01' AND '2019-03-31';

-- 21. Write a Query to get list of Male patients. 
select  "FirstName","LastName","Gender"
from public."Patients" pat 
left outer join public."Gender" gen on gen."Gender_ID"  = pat."Gender_ID"
where "Gender" = 'Male'
order by "Patient_ID";

-- 22. Write a query to get list of patient ID's who has discharged to home. 
select  DIS."Patient_ID",disp."DischargeDisposition"
from public."Discharges" dis 
left outer join public."DischargeDisposition" disp on dis."Discharge_ID" = disp."Discharge_ID"
where "DischargeDisposition" = 'Home';    

--23. Find the category of illness(Stomach Ache or Migrane) that has maximum number of patients 
  select * from (
    select "ReasonForVisit",count(distinct "Patient_ID") patient_cnt,
        rank() over(order by count(distinct "Patient_ID") desc) patient_cnt_rnk
        from public."EDVisits" vis 
        left outer join public."ReasonForVisit" res on res."Rsv_ID" = vis."Rsv_ID"
        where ("ReasonForVisit" = 'Stomach Ache' or "ReasonForVisit" ='Migraine')
    group by   "ReasonForVisit" ) as pat_vis
    where patient_cnt_rnk = 1;


--24. Write a query to get list of New Patient ID's. 
 select  pat."Patient_ID",vtyp."VisitType"
    from public."Patients" pat  
    left outer join public."AmbulatoryVisits" vis on vis."Patient_ID" = pat."Patient_ID"
    left outer join public."VisitTypes" vtyp on vtyp."AMVT_ID" = vis."AMVT_ID"
    where "VisitType" = 'New'
   order by pat."Patient_ID";

--25. Create trigger on table Readmission registry 

 -- To Cretae new table "AdmissionsSummary" in HospitalDB_New
   CREATE TABLE IF NOT EXISTS public."AdmissionsSummary"
    ("SummaryID" SERIAL,
     "Patient_ID" integer  NOT NULL,
     "AdmissionCount" integer,
    CONSTRAINT "AdmissionsSummary_pkey" PRIMARY KEY ("SummaryID", "Patient_ID"),
    CONSTRAINT "Patient_ID_FK" FOREIGN KEY ("Patient_ID")
        REFERENCES public."Patients" ("Patient_ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION)
        TABLESPACE pg_default;
  -- Commit  
    Commit;
  --Run ALTER      
    ALTER TABLE IF EXISTS public."AdmissionsSummary"
    OWNER to postgres;    
    
-- Creating a Function and Setting Trigger On public."ReAdmissionRegistry" 
-- This trigger will Count total number of times the patient is admitted as soon as the new dataset is 
-- inserted in "ReAdmissionRegistry"  

    CREATE or replace FUNCTION add_patient_admission_summary() RETURNS trigger AS $pat_add$
    DECLARE
     v_patient_exists integer;
    BEGIN
    
    select count("Patient_ID")
    into v_patient_exists
    from  public."AdmissionsSummary"
    where "Patient_ID" = new."Patient_ID";
       
    if v_patient_exists = 1 then 
        update public."AdmissionsSummary" 
        set "AdmissionCount" = "AdmissionCount" + 1;
        
     else
        insert into public."AdmissionsSummary"
    ("Patient_ID", "AdmissionCount")
    values
    (NEW."Patient_ID",1) ;
     end if;
         RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$pat_add$ LANGUAGE plpgsql;

CREATE or replace TRIGGER pat_add AFTER INSERT ON public."ReAdmissionRegistry"
    FOR EACH ROW EXECUTE FUNCTION add_patient_admission_summary();
    
    
    select * from public."ReAdmissionRegistry"
   
--Insert new data in "ReAdmissionRegistry"  
     INSERT INTO public."ReAdmissionRegistry"(
	"Admission_ID", "Patient_ID", "AdmissionDate", "DischargeDate", "Discharge_ID", "Service_ID", "Diagnosis_ID", "ExpectedLOS", "ExpectedMortality", "ReadmissionFlag", "DaysToReadmission", "EDVisitAfterDischargeFlag")
	VALUES ('722', '750', '2018-03-02', '2018-01-13 15:59:00', 'DID02', 'SID06', 'PD015', '9.954144', '0.384839', '1', '2', '1');

     INSERT INTO public."ReAdmissionRegistry"(
	"Admission_ID", "Patient_ID", "AdmissionDate", "DischargeDate", "Discharge_ID", "Service_ID", "Diagnosis_ID", "ExpectedLOS", "ExpectedMortality", "ReadmissionFlag", "DaysToReadmission", "EDVisitAfterDischargeFlag")
	VALUES ('723', '750', '2018-03-02', '2018-03-03 15:59:00', 'DID02', 'SID06', 'PD015', '9.9541', '0.3849', '1', '2', '1');

    INSERT INTO public."ReAdmissionRegistry"(
	"Admission_ID", "Patient_ID", "AdmissionDate", "DischargeDate", "Discharge_ID", "Service_ID", "Diagnosis_ID", "ExpectedLOS", "ExpectedMortality", "ReadmissionFlag", "DaysToReadmission", "EDVisitAfterDischargeFlag")
	VALUES ('724', '751', '2018-04-12', '2018-04-13 15:59:00', 'DID02', 'SID06', 'PD015', '9.954144', '0.384839', '1', '2', '1');

    
--To check if new record is added to "AdmissionsSummary";
select * from public."AdmissionsSummary";

--26. Select all providers with a name starting 'h' followed by any character , followed by 'r', followed by any character,followed by 'y' 
Select "ProviderName" from public."Providers" where LOWER("ProviderName") like 'h_r_y%';

--27. Show the list of the patients who have cancelled their appointment 
   select  "FirstName","LastName","VisitStatus"
    from public."Patients" pat  
    left outer join public."AmbulatoryVisits" avis on avis."Patient_ID" = pat."Patient_ID"
    left  join public."VisitStatus" stat on stat."VisitStatus_ID" = avis."VisitStatus_ID"
    where stat."VisitStatus" = 'Canceled';

--28. Write a query to get list of ProviderName's with a name starting 'ted' 
Select "ProviderName" from public."Providers" where "ProviderName" LIKE INITCAP('ted%')

--29. Create a view without using any schema or table and check the created view using select statement 
create or replace view getNow  as 
select now() as sysdate;

select * from getNow;
  
--30. Write a query to get unique list of Patient Id's whose reason for visit is car accident. 
 select  distinct pat."Patient_ID","ReasonForVisit"
    from public."Patients" pat 
    left join public."EDVisits" vis on vis."Patient_ID" = pat."Patient_ID"
    left join public."ReasonForVisit" res on res."Rsv_ID" = vis."Rsv_ID"
    where  "ReasonForVisit" = 'Car Accident'     
    order by pat."Patient_ID";


--31. Find which Visit type of patients are maximum in cancelling their appointment 
 select * from (    
       select  "VisitType"
              ,"VisitStatus"
              ,Count("VisitStatus") cnt
              ,rank () over(order by Count("VisitStatus") desc ) cnt_rnk
       from   public."AmbulatoryVisits" avis 
       left outer join public."VisitStatus" stat on stat."VisitStatus_ID" = avis."VisitStatus_ID"
       left outer join public."VisitTypes" typ on typ."AMVT_ID" = avis."AMVT_ID"
       where "VisitStatus" = 'Canceled'
       group by   "VisitType" ,"VisitStatus"
       order by cnt_rnk ) viscnt
       where cnt_rnk = 1;
        
--32. Write a query to Count number of patients by VisitdepartmentID where count greater than 50 
    Select  "VisitDepartmentID", noofpatients from (
          select "VisitDepartmentID", COUNT(distinct pat."Patient_ID") noofpatients
          from  public."Patients" pat 
          inner join public."AmbulatoryVisits" avis on avis."Patient_ID" = pat."Patient_ID"
          Group by "VisitDepartmentID" 
          ORDER by "VisitDepartmentID") as patnum
          where noofpatients >50;
          
--33. Write a query to get list of patient names whose visit type is new and visitdepartmentId is 2. 
 select  "FirstName","LastName","VisitType","VisitDepartmentID"
          from public."Patients" pat 
          left join public."AmbulatoryVisits" avis on avis."Patient_ID" = pat."Patient_ID"
          left join  public."VisitTypes" typ on typ."AMVT_ID" = avis."AMVT_ID"
          where typ."VisitType" = 'New' and avis."VisitDepartmentID"=2;

    
--34. Write a query to find the most common reasons for hospital visit for patients between 50 and 60 years 
         
select * from (
          select  "ReasonForVisit"
                  ,count("ReasonForVisit") visit_cnt_for_50and60_years
                  ,rank() over(order by count(pat."Patient_ID") desc) visit_rnk                 
          from public."Patients" pat 
          left join public."EDVisits" vis on vis."Patient_ID" = pat."Patient_ID"
          left join public."ReasonForVisit" rv on vis."Rsv_ID"= rv."Rsv_ID"
          where (EXTRACT(YEAR FROM "VisitTimestamp") - EXTRACT(YEAR FROM "DateOfBirth"))  between 50 and 60 
          group by "ReasonForVisit"
          order by visit_cnt_for_50and60_years desc) res_for_vis
          where visit_rnk = 1;          
      
--35. Get list of Patients whose gender is Male and who speak English and whose race is White 
 select  "FirstName","LastName","Gender","Language","Race"
        from public."Patients" pat
        left join public."Language" lan on lan."Language_ID" = pat."Language_ID"
        left join public."Race" rac on rac."Race_ID" = pat."Race_ID" 
        left join public."Gender" gen on gen."Gender_ID" = pat."Gender_ID"
        where lan."Language" = 'English'
        and "Race" = 'White'
        and "Gender" = 'Male';

-- 36. Create index on Patient table 
Create index index_patient_id
ON public."Patients"("Patient_ID");

EXPLAIN SELECT *
FROM public."Patients"
WHERE "Patient_ID" = '9';
        
--37. Write a query to get list of Provider ID's where ProviderDateOnStaff year is 2013 and 2010 
Select "Provider_ID", EXTRACT(YEAR FROM "ProviderDateOnStaff") ext_yr  
from public."Providers" 
where EXTRACT(YEAR FROM "ProviderDateOnStaff") in (2013,2010)
order by "Provider_ID";
        
-- 38. Write a query to find out percentage of Ambulatory visits by visit type. 
select typ."VisitType",count(*) visit_typ_cnt, round(count(*)/sum(count(*)) over() * 100,2) Perct_total_visit
      from public."AmbulatoryVisits" avis
      left join public."VisitTypes" typ on  typ."AMVT_ID" = avis."AMVT_ID"
      group by typ."VisitType"
      order by visit_typ_cnt desc;
    
--39. Write a query to get list of patient names who has discharged. 
Select distinct pat."Patient_ID", "FirstName","LastName"
    from public."Patients" as pat
    join public."Discharges" as dis On pat."Patient_ID" = dis."Patient_ID"
    order by pat."Patient_ID";
     
--40. Create view on table EdVisit by selecting some columns and filter data using Where condition

--To create View
Create or replace View EDV AS Select "Patient_ID", "Acuity","EDD_ID" from public."EDVisits";

-- To Select from view 
Select * from public.edv where "Acuity" = '2';

-- 41. Get list of patient names whose primary diagnosis as 'Spinal Cord injury' having Expected LOS is greater than 15
Select PT."FirstName",PT."LastName",N."ExpectedLOS",N."PrimaryDiagnosis" from
(Select R."Patient_ID",R."Diagnosis_ID",R."ExpectedLOS",P."PrimaryDiagnosis" from 
(Select r."Patient_ID",r."Diagnosis_ID",r."ExpectedLOS" from "ReAdmissionRegistry" r
Where r."ExpectedLOS" > '15') R 
join (Select "Diagnosis_ID","PrimaryDiagnosis" from "PrimaryDiagnosis" Where "PrimaryDiagnosis" = 'Spinal Cord Injury') P 
ON R."Diagnosis_ID" = P."Diagnosis_ID") N
Join "Patients" PT
ON N."Patient_ID" = PT."Patient_ID";

-- 42. Write a query to get list of Patient names who haven't discharged
Select P."FirstName" as "Patient_FirstName",P."LastName" as "Patient_LastName" 
from "Patients" P
Where P."Patient_ID" NOT IN (Select D."Patient_ID" from "Discharges" D)

-- 43. Write a query to get list of Provider names whose ProviderSpecialty is Pediatrics.
Select Pr."ProviderName", PS."ProviderSpeciality" from "Providers" Pr 
left join public."ProviderSpeciality" PS ON Pr."PS_ID" = PS."PS_ID" 
Where "ProviderSpeciality" = 'Pediatrics';

-- 44. Write a query to get list of patient ID's who has admitted on 1/7/2018 and discharged on 1/15/2018
Select D."Patient_ID",D."AdmissionDate",D."DischargeDate" from "Discharges" D
Where D."AdmissionDate" ='2018-01-07' AND D."DischargeDate"::timestamp::date ='2018-01-15'

--45. Write a query to find outpatients vs inpatients by monthwise (hint:
-- consider readmission/discharges and ambulatory visits table for inpatients
-- and outpatients) 
Select T1."OutPatients",T2."InPatients",T1."InMonthOf"
from (Select count(public."AmbulatoryVisits"."Patient_ID") as "OutPatients",
      TO_CHAR("AmbulatoryVisits"."DateofVisit",'Month') as "InMonthOf" from public."AmbulatoryVisits" 
      Where "VisitStatus_ID"  = 'VS002' and  
      public."AmbulatoryVisits"."Patient_ID" not in
      (select public."Discharges"."Patient_ID" from public."Discharges")
      Group by "InMonthOf") T1
Left Join (SELECT Count("Patient_ID") as "InPatients",TO_CHAR("AdmissionDate",'Month') AS "InMonthOf"
          from "Discharges"
          Group by "InMonthOf") as T2
on T1."InMonthOf" = T2."InMonthOf";

-- 46. Write a query to get list of Number of Ambulatory Visits by Provider Speciality per month
Select TO_CHAR(avis."DateofVisit",'Month') as Mnth , PS."ProviderSpeciality", Count(avis."AMVT_ID") as "NoOfAmbulatoryVisit" from public."AmbulatoryVisits" avis
left join public."VisitTypes" vis on avis."AMVT_ID" = vis."AMVT_ID"
left join public."Providers" P on avis."Provider_ID" = P."Provider_ID"
left join public."ProviderSpeciality" PS on PS."PS_ID"=P."PS_ID"
Group by  Mnth,PS."ProviderSpeciality"
Order by Mnth

-- 47. Write a query to find Average age for admission by service
Select Ser."Service",AVG(AGE(Ser."AdmissionDate",Ser."DateOfBirth")) as "AvrgAgeOfPatientsAdmitted"
from (Select S."Patient_ID",S."Service",S."AdmissionDate", PT."DateOfBirth" from
       (Select R."Patient_ID", R."Service_ID",S."Service",R."AdmissionDate" from "ReAdmissionRegistry" R
        Join "Service" S ON R."Service_ID" = S."Service_ID") S
Join(Select P."Patient_ID",P."DateOfBirth" from "Patients" P) PT 
on S."Patient_ID" = PT."Patient_ID") Ser
Group by Ser."Service"
 
-- 48. Write a query to get list of patient with their full names whose names contains "Ma"
Select P."PatientFullName"
from (Select concat("FirstName",' ',"LastName") AS "PatientFullName"
From "Patients") P 
where P."PatientFullName" Like '%Ma%'

--49.  Update Visit Timestamp column in EDVisits table by selecting data type as timestamp with timezone
alter table "EDVisits" alter column "VisitTimestamp" type timestamp with time zone;

select "VisitTimestamp" from "EDVisits"

-- 50. Write a create a trigger function on AmbulatoryVisits by selecting any two columns.

-- Creating a Table "AmbulatoryVisitsPatientBPLog" to log the patients Blood pressure details
-- using a trigger function whenever a new record is inserted in the "AmbulatoryVisits" Table

CREATE TABLE IF NOT EXISTS public."AmbulatoryVisitsPatientBPLog"
(
     "Patient_ID" integer,
     "BloodPressureSystolic" real,
    "BloodPressureDiastolic" real
)
TABLESPACE pg_default;
	 
-- Alter the Created table if needed.

ALTER TABLE IF EXISTS public."AmbulatoryVisitsPatientBPLog"
    OWNER to postgres;
	
--selecting "AmbulatoryVisitsPatientBPLog" to display the newly created table "AmbulatoryVisitsPatientBPLog"
	
Select * from public."AmbulatoryVisitsPatientBPLog"
	
-- Creating a Trigger Function to be called when trigger is invoked to insert the records in the newly created 
-- "AmbulatoryVisitsPatientBPLog" table
CREATE OR REPLACE FUNCTION PatientBP_insert() 
  RETURNS trigger AS $Insert_BP$
BEGIN
INSERT INTO public."AmbulatoryVisitsPatientBPLog"("Patient_ID","BloodPressureSystolic","BloodPressureDiastolic")
VALUES(NEW."Patient_ID",NEW."BloodPressureSystolic",New."BloodPressureDiastolic");
RETURN Null;
END;
$Insert_BP$
LANGUAGE 'plpgsql';

-- Creating the Trigger Insert_BP to insert the bp records to the "AmbulatoryVisits" Table
CREATE or replace TRIGGER Insert_BP
AFTER INSERT
  ON public."AmbulatoryVisits"
  FOR EACH ROW
  EXECUTE FUNCTION PatientBP_insert();
  
--  Inserting new record into table public."AmbulatoryVisits"

INSERT INTO public."AmbulatoryVisits" VALUES (952,102,1,'2019-02-18','2019-01-24 11:50:26',12,'AMVT002',157,95,90,'VS003');

-- Displaying the new table with records inserted successfully with the created trigger

Select * from public."AmbulatoryVisitsPatientBPLog" ;

-- Question 51. Insert number of days for Readmission in DaysToReadmission Column for patient ID's from 737 to 742 .( Use any random value)
Update "ReAdmissionRegistry"  set "DaysToReadmission" =
 CASE
 WHEN "Patient_ID" = '737' THEN 7
 WHEN "Patient_ID" = '738' THEN 8
 WHEN "Patient_ID" = '739' THEN 9
 WHEN "Patient_ID" = '740' THEN 10
 ELSE 5
 END 
where "Patient_ID" BETWEEN 737 and 742
Returning "Patient_ID","DaysToReadmission";

-- 52. Get list of Provider names whose name is starting with K and ending with y (Hint:K-Upper, Y-Lower)
Select "ProviderName" from "Providers" P
Where P."ProviderName" LIKE 'K%y';

--  53. Write a query to Split provider First name and Last name into different column
Select "ProviderName", split_part("ProviderName",' ',1) as "Provider_firstname",
                       split_part("ProviderName",' ',2) as "Provider_lastname"
from "Providers";

-- 54. Get list of Patient ID's order by Discharge date
Select "Patient_ID",(D."DischargeDate"::timestamp::date) AS "Dischargdate" from "Discharges" D
order by (D."DischargeDate"::timestamp::date);

-- 55. Write a query to drop View by creating view on table Discharge by selecting columns

-- Query to create a View from Discharge Table
Create  View DischargeTableView
as 
Select
   "Admission_ID",
   "Patient_ID",
   "DischargeDate" 
  from
"Discharges"
Where "Patient_ID" ='20';

-- Query to view the created View 
Select * from DischargeTableView;

-- Query to Drop the Created View
Drop View DischargeTableView;

-- 56. Write a query to get list of Patient ID's where Visitdepartment ID is 1 and
-- BloodPressureSystolic is between 123 to 133
Select "Patient_ID","VisitDepartmentID","BloodPressureSystolic"
from "AmbulatoryVisits" A
Where A."VisitDepartmentID"= '1'and
A."BloodPressureSystolic" Between 123 and 133
order by A."BloodPressureSystolic" ASC;

-- 57. Write the query to create Index on table ReasonForVisit by selecting a
-- column and also write the query drop same index

-- Query To create an index for the values in the "ReasonForVisit" column from "ReasonforVisit" table
CREATE INDEX Reasonforvisitindex 
ON "ReasonForVisit"("ReasonForVisit");

-- Query to drop an created index
DROP INDEX Reasonforvisitindex;

-- 58. Write a query to Count number of unique patients EDDisposition wise.
select count (Distinct evis."Patient_ID") as "NoOfUniquePatients",edis."EDDisposition"
from public."EDVisits" evis
left join public."EDDisposition" edis on edis."EDD_ID"=evis."EDD_ID"
Group by edis."EDDisposition";

-- 59. Write a query to get list of Patient ID's where Visitdepartment ID is 5 or
-- BloodPressureSystolic is NOT NULL
Select "Patient_ID","VisitDepartmentID","BloodPressureSystolic"
from "AmbulatoryVisits" A
Where A."VisitDepartmentID"= '5'or A."BloodPressureSystolic" IS NOT NULL;

-- 60. Query to find the number of patients readmitted by Service
Select "Service",Count("Patient_ID") as "NoOfPatients" from public."ReAdmissionRegistry" rad
left join public."Service" S on S."Service_ID" = rad."Service_ID" 
Group By "Service";

-- 61. Write a query to list male patient ids and their names who are above 40
-- years of age and less than 60 years and have BloodPressureSystolic above
-- 120 and BloodPressureDiastolic above 80 
select p."Patient_ID",p."FirstName",p."LastName",g."Gender",age(NOW(),"DateOfBirth"),
A."BloodPressureSystolic",A."BloodPressureDiastolic"
from "Patients" as p Left Join "Gender" as g 
on p."Gender_ID" = g."Gender_ID" 
Left Join "AmbulatoryVisits" as A 
on p."Patient_ID" = A."Patient_ID"
where "Gender" IN ('Male') AND
"BloodPressureSystolic" > 120 AND
"BloodPressureDiastolic" > 80 AND
Extract(Years from age(NOW(),"DateOfBirth")) Between 40 AND 59;

-- 62. Query to find the number of patients who have visited month wise
select NoOfPatientsVisited, InMonthOf 
from (select count("Patient_ID")as NoOfPatientsVisited,TO_CHAR("DateofVisit",'Month') as InMonthOf, 
      Extract(Month from "DateofVisit") as MonthNum
      from "AmbulatoryVisits" Group by InMonthOf, MonthNum )as subtable
order by MonthNum;

-- 63. Write a query to get list of patient ID's whose BloodPressureSystolic is 131,137,138
select p."Patient_ID",A."BloodPressureSystolic"
from "Patients" as p  
Left Join "AmbulatoryVisits" as A 
on p."Patient_ID" = A."Patient_ID"
where "BloodPressureSystolic" IN (131,137,138);

-- 64. Query to classify expected LOS into 3 categories as per the duration. (Hint:Use of CASE statement)

--On Discharges table
select "ExpectedLOS",
       CASE 
        WHEN "ExpectedLOS" BETWEEN 2 and 6 THEN '1_Minor'
        WHEN "ExpectedLOS" BETWEEN 6 and 11 THEN '2_Major'
        WHEN "ExpectedLOS" BETWEEN 11 and 17 THEN '3_Critical'
        END "Severity"
        from "Discharges" 
        order by "ExpectedLOS"
        
--On ReAdmissionRegistry table
select "ExpectedLOS",
       CASE 
        WHEN "ExpectedLOS" BETWEEN 2 and 6 THEN '1_Minor'
        WHEN "ExpectedLOS" BETWEEN 6 and 11 THEN '2_Major'
        WHEN "ExpectedLOS" BETWEEN 11 and 17 THEN '3_Critical'
        END "Severity"
        from "ReAdmissionRegistry" 
        order by "ExpectedLOS" 

-- 65. Write a query to create a table to list the names of patients whose date of
--     birth is later than 1st jan 1960.Name the table as “Persons”
CREATE TABLE "Persons" as 
select concat("FirstName",' ',"LastName") as PatientName,"DateOfBirth" from "Patients" 
where "DateOfBirth" > '1960-01-01'

select * from "Persons"

-- 66. Write a query to Count number of patients who has discharged after march3rd 2018
select count("Patient_ID") as "NoofPatientsDischargedAfter3rdMar2018" from "Discharges" 
Where DATE("DischargeDate") > '2018-03-03'

-- 67. Replace ICU with emergency (Hint: Do not update or alter the table)
Select REPLACE("Service",'ICU','emergency') as "ServiceUpdated","Service_ID" from "Service"

-- 68. Write a query to get Sum of ExpectedLOS for Service_ID 'SID01';

--On Discharges table
select sum("ExpectedLOS") from "Discharges" where "Service_ID"='SID01';

--On ReAdmissionRegistry table
select sum("ExpectedLOS") from "ReAdmissionRegistry" where "Service_ID"='SID01' ;

-- 69. Create index on table Provider by selecting a column and filter by using WHERE condition

-- To create index
Create INDEX "Index_name_Provider" On "Providers" ("ProviderName");
--To filter data after creatng index
select * from "Providers" where "ProviderName" IN ('Ted Black');

-- 70. List down all triggers in our HealthDB database
SELECT  event_object_table AS table_name ,trigger_name         
FROM information_schema.triggers  
GROUP BY table_name ,trigger_name 
ORDER BY table_name ,trigger_name;

-- 71. Partition the table according to Service_ID and use windows function to calculate percent rank. Order by ExpectedLOS.

--On Discharges table
select "Patient_ID","Service_ID","ExpectedLOS",
PERCENT_RANK() OVER(partition by "Service_ID" order by "ExpectedLOS") as "Percent_Rank"
from "Discharges";

--On ReAdmissionRegistry table
select "Patient_ID","Service_ID","ExpectedLOS",
PERCENT_RANK() OVER(partition by "Service_ID" order by "ExpectedLOS") as "Percent_Rank"
from "ReAdmissionRegistry";

-- 72. Write a query by using common table expressions and case statements to display birthyear ranges
WITH "cte_PatientsAgeGroup" As (
 select "Patient_ID","FirstName","LastName","DateOfBirth",
       CASE 
        WHEN Extract(Year from "DateOfBirth") <=  1966 THEN 'OlderAdulthood' 
        WHEN Extract(Year from "DateOfBirth") BETWEEN 1965 and 1986 THEN 'MiddleAge'
        WHEN Extract(Year from "DateOfBirth") BETWEEN 1987 and 2004 THEN 'YoungAdulthood'
        END "BirthYearRangeCategory"
 from "Patients")
select * from "cte_PatientsAgeGroup";

-- 73. Get list of Provider names whose ProviderSpeciality is Surgery
select p."ProviderName",ps."ProviderSpeciality"
from "Providers" as p Left Join "ProviderSpeciality" as ps
on p."PS_ID" =ps."PS_ID"
where ps."ProviderSpeciality" = 'Surgery';

-- 74. List of patient from rows 11-20 without using where condition.
select "Patient_ID","FirstName","LastName" from "Patients" offset 10 rows Fetch next 10 rows only;

-- 75. Give a query how to find triggers from table AmbulatoryVisits
SELECT  event_object_table AS table_name ,trigger_name         
FROM information_schema.triggers  
WHERE event_object_table = 'AmbulatoryVisits'
GROUP BY table_name , trigger_name 
ORDER BY table_name ,trigger_name;

-- 76. Recreate the below expected output using Substring.
select "Gender",SUBSTRING("Gender",1,1) as "gender" from "Gender";

-- 77. Obtain the below output by grouping the patients
select "Patient_ID","FirstName",('L') as "patient_group" from "Patients" 
Where "FirstName" LIKE 'L%';

--78. Please go through the below screenshot and create the exact output.
select "FirstName",char_length("FirstName") as "LengthOfFirstName" from "Patients";

-- 79. Please go through the below screenshot and create the exact output BloodPressureDiastolic,pulse,bpd,heartrate
select "BloodPressureDiastolic","Pulse",
       trunc("BloodPressureDiastolic"+1) as "bpd",trunc("Pulse") as "HeartRate" 
from "AmbulatoryVisits" offset 1 row Fetch next 21 rows only;

-- 80. Please go through the below screenshot and create the exact output string and numeric
select "BloodPressureSystolic",'The Systolic Blood pressure is '|| to_char("BloodPressureSystolic",'999.99')
        as "Message"
from "AmbulatoryVisits";







