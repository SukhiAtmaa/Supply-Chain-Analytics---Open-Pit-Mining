create schema openpit
use openpit

/*Number of equipment operating in the field*/
select row_number() over(order by `Primary Machine Name`) AS VehicleNo,
`Primary Machine Name` 
from cyclemaster
group by `Primary Machine Name`;

/*Production vs Plan*/
select ROUND(SUM(`Payload (t)`),2) as Transported_Payload
from truckmovement;

select ROUND(SUM(`Payload (t)`),2) as Production_Payload
from cyclemaster
where `Cycle Type` != 'TruckCycle';

/*Top 10 Trucks which has transported maximum Payloads in tons*/
select `Primary Machine Name`, ROUND(SUM(`Payload (t)`),2) as `Total_Payload (t)` 
from truckmovement
group by `Primary Machine Name`
order by `Total_Payload (t)` desc
limit 10;

/*Top 10 Performing Trucks*/
select `Primary Machine Name`, ROUND(SUM(`Payload (t)`)/SUM(`COMPLETEDCYCLEDURATION`),2) as `Load_per_sec (Ton)` 
from truckmovement
group by `Primary Machine Name`
order by `Load_per_sec (Ton)` desc
limit 10
;

/*10 Poorly Performing Trucks*/
select `Primary Machine Name` , count(`Primary Machine Name`) as IncompleteCycles
from truckmovement
where `Completed Cycle Count`= 'no'
group by `Primary Machine Name`
order by IncompleteCycles desc
;

/*Creating Stored Procedure for cycle table*/
DELIMITER $$
create procedure cyclemaster (cycle_type varchar(50))
begin
select *
from cycle
where `Cycle Type` = cycle_type;
end $$
DELIMITER ;

/*Creating Stored Procedure for delay table*/
DELIMITER $$
create procedure delaymaster (Machine_Class_Category_Name varchar(50))
begin
select `Description`, `Engine Stopped Flag`, `Field Notification Required Flag`, `Production Reporting Only Flag`, `Delay Class Name`, `Delay Class Category Name`, `Target Machine Name`, `Target Machine Class Name`, `Target Machine Class Description`, `Target Machine Class Category Name`, `Delay Time`
from delay
where `Target Machine Class Category Name` = Machine_Class_Category_Name;
end $$
DELIMITER ;


/*Creating Stored Procedure for movement table*/
DELIMITER $$
create procedure truckmovement (Truck_Name varchar(10))
begin
select *
from truckmovement
where `Primary Machine Name` = Truck_Name;
end $$
DELIMITER ;

create view OEE
as 
select `Primary Machine Name`, `Cycle Type`, `CT Calendar Time`, `SD_SCHEDULEDDOWNTIME`, `WORKINGDURATION`, `TOTALTIME (CAT)`, `iMine Operating Hours`,`iMine Engine Hours`,`IC`,`TC`,
(`CT Calendar Time`-`SD_SCHEDULEDDOWNTIME`)*100/`CT Calendar Time` as Availability, (`WORKINGDURATION`)*100/`TOTALTIME (CAT)` as Performance, (`iMine Operating Hours`-`iMine Engine Hours`)*100/(`iMine Operating Hours`)*(`IC`)/(`TC`) as Quality
from cyclemaster;

/*Creating Stored Procedure for OEE Calculations*/
DELIMITER $$
create procedure OEE_key (cycle_type varchar(50))
begin
select *
from oee
where `Cycle Type` = cycle_type;
end $$
DELIMITER ;