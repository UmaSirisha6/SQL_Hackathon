---------------- DataHunters SQL Hackathon Extra Questions ---------------

--1. Number of patients in ICU for different Primary Diagnosis using first_value() Window Function
--   we are using first_value() Window Function.

SELECT 
   "PrimaryDiagnosis",Count("Patient_ID"),
  
    FIRST_VALUE("Service") 
    OVER(
        ORDER BY Count("Patient_ID") desc
    ) Service
FROM 
public."ReAdmissionRegistry" rvis
join public."Service" ser on ser."Service_ID" = rvis."Service_ID"
join public."PrimaryDiagnosis" pd on pd."Diagnosis_ID" = rvis."Diagnosis_ID"
where "Service" = 'ICU'
group by  "PrimaryDiagnosis",ser."Service";


--2. Find the percentage of Kidney Failure as per gender

create function get_PatientCount_with( diagId text)
returns int
language plpgsql
as
$$
declare
   PatientCount integer;
begin
   select count("Patient_ID") 
   into PatientCount
   from "Discharges"
   where "Diagnosis_ID" = diagId;
   
   return PatientCount;
end;
$$;

select ('Kidney Failure in ' || g."Gender" ) as Info,count(d."Patient_ID") as "NoOfPatients", 
       (count(d."Patient_ID")*100)::float/(select get_PatientCount_with('PD011')) as "Percentage%"
from "Discharges" as d
join "Patients" as p on d."Patient_ID" = p."Patient_ID"
join "Gender" as g on p."Gender_ID" = g."Gender_ID" 
where "Diagnosis_ID" = 'PD011' 
group by "Gender" 


--3. Get the 3rd ProviderSpeciality based on number of patients.

With "cte_specialityRank" as (
select av."Patient_ID",av."Provider_ID",p."PS_ID",ps."ProviderSpeciality" 
from "AmbulatoryVisits" as av
join "Providers" as p on av."Provider_ID" = p."Provider_ID"
join "ProviderSpeciality" as ps on p."PS_ID" = ps."PS_ID"
order by p."PS_ID")
select * from 
(select count("Patient_ID") as "NumberOfPatients","ProviderSpeciality",
        ROW_NUMBER() over(order by count("Patient_ID") desc ) as "OrderOfSpeciality"
 from "cte_specialityRank"  
 group by "ProviderSpeciality") as subtable
where "OrderOfSpeciality" = 3

--4. Create view to get the size of HospitalDB_New database

--create view
   Create or replace view hospDBDetails as 
   SELECT PG_SIZE_PRETTY (PG_DATABASE_SIZE ('HospitalDB_New'));

--Select View
    select * from hospDBDetails;

--5. Without using any function ,Select all providers with a name starting 'h' followed by any character , followed by 'r', followed by any character,followed by 'y'.

Select "ProviderName" from public."Providers" where "ProviderName" ilike ('h_r_y%');


--6.Find the major Primary diagnosis faced by patients over age 50.

Select T."PatientCount",T."PrimaryDiagnosis"  from
(Select(count(P1."Patient_ID")) as "PatientCount",P."PrimaryDiagnosis" from 
"Patients" as P1 
 Left Join "Discharges" D ON P1."Patient_ID"= D."Patient_ID"
Left Join "PrimaryDiagnosis" P ON D."Diagnosis_ID" = P."Diagnosis_ID"
Where (date_part('year',AGE(D."AdmissionDate",P1."DateOfBirth"))) > 50
Group by P."PrimaryDiagnosis" order by "PatientCount" desc) T limit 1

--7.Write a Query to list all the Telemedicine Patients in the hospitaldb

Select distinct(p."Patient_ID"),p."FirstName",p."LastName",V."VisitType"
from public."Patients" p 
join public."AmbulatoryVisits" A on A."Patient_ID" = p."Patient_ID"
join public."VisitTypes" V on V."AMVT_ID" = A."AMVT_ID"
where "VisitType" = 'Telemedicine'
order by p."Patient_ID"

