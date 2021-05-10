options compress=yes;run;

libname data "/data/dart/2014/ORD_AlAly_201403107D/Andrew/Projects/PM_Obesity";

*import all .csv files to SAS;
%macro drive(dir,ext); 
   %local cnt filrf rc did memcnt name; 
   %let cnt=0;          

   %let filrf=mydir;    
   %let rc=%sysfunc(filename(filrf,&dir)); 
   %let did=%sysfunc(dopen(&filrf));
    %if &did ne 0 %then %do;   
   %let memcnt=%sysfunc(dnum(&did));    

    %do i=1 %to &memcnt;              
                       
      %let name=%qscan(%qsysfunc(dread(&did,&i)),-1,.);                    
                    
      %if %qupcase(%qsysfunc(dread(&did,&i))) ne %qupcase(&name) %then %do;
       %if %superq(&ext) = %superq(&name) %then %do;                         
          %let cnt=%eval(&cnt+1);       
          %put %qsysfunc(dread(&did,&i));  
          proc import datafile="&dir/%qsysfunc(dread(&did,&i))" out=july&cnt 
           dbms=csv replace;            
          run;          
       %end; 
      %end;  

    %end;
      %end;
  %else %put &dir cannot be open.;
  %let rc=%sysfunc(dclose(&did));      
             
 %mend drive;
 
%drive(/data/dart/2014/ORD_AlAly_201403107D/GIS/obesity/Green_Space/Data_for_SAS,csv) 


proc sql;
create table July1_2_buffer as
select a.lat as buffer_lat, a.lon as buffer_lon, b.*
from july1 as a
left join july2 as b
on geodist(a.lat,a.lon,b.lat,b.lon) <= 1
order by buffer_lat, buffer_lon, lat, lon, grid_code;
quit; 



*concatenate all days of July into one dataset;
data july (keep=lat lon NDVI);
	format lat lon grid_code;
	set JULY1-JULY31;
	rename grid_code = NDVI;
run; *n=15,564,853;

*delete individual day datasets;
proc datasets library=WORK;
delete JULY1-JULY31;
run;

proc sql;
create table data.NDVI_buffers  as
select a.lat as buffer_lat, a.lon as buffer_lon, b.*
from july as a
left join july as b
on geodist(a.lat,a.lon,b.lat,b.lon) <= 1
order by buffer_lat, buffer_lon, lat, lon, ndvi;
quit; 


proc sort data=july;
	by lat lon NDVI;
run;
	
