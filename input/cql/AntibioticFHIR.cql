library AntibioticFHIR version '1.0.0'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include CQMCommon version '1.0.000' called CQMCommon

parameter "Measurement Period" Interval<DateTime>

context Patient

define function "Has Comorbid Condition History"(episodeDate List<Encounter>, comorbidConditions List<Condition>):
  (episodeDate eDate
  with comorbidConditions comcondition
      such that date from start of (QICoreCommon."ToPrevalenceInterval"(comcondition)) during 
      Interval[date from start of QICoreCommon."ToInterval"(eDate.period) - 1 year, date from start of QICoreCommon."ToInterval"(eDate.period)] 
      return eDate) is not null 

define function "Has Competing Diagnosis History"(episodeDate List<Encounter>, competingConditions List<Condition>):
  (exists episodeDate eDate
  with competingConditions competcondition
        such that (QICoreCommon."ToPrevalenceInterval"(competcondition)) starts 3 days or less on or after day of start of eDate.period
          return eDate) is not null
 

 define function "Antibiotic Active Overlaps Episode and Starts More than 30 Days Prior to Episode"(episodeDate List<Encounter>, antibioticMedications List<MedicationRequest>):
  exists episodeDate DateOfEpisode
    with antibioticMedications ActiveMedication
        such that exists ( ActiveMedication.dosageInstruction.timing T
            where (QICoreCommon."ToInterval"(T.repeat.bounds)) overlaps day of Interval[date from start of QICoreCommon."ToInterval"(DateOfEpisode.period)  - 30 days , date from start of QICoreCommon."ToInterval"(DateOfEpisode.period) - 1 day]
        )
