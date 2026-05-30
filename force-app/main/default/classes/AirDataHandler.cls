/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-11-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AirDataHandler {

    public class airWrapper{
         @AuraEnabled public String Id;
         @AuraEnabled public String FlightNumber ;
         @AuraEnabled public String Airline;
         @AuraEnabled public String OriginAirport;
         @AuraEnabled public String destinationAir;
         @AuraEnabled public DateTime DepartureTime;
         @AuraEnabled public String flightStatus;
         @AuraEnabled public Integer Capacity;

    }


    @AuraEnabled(cacheable = true)
    public static list<airWrapper> getAirMetadata(){
        List<airWrapper> airWrapperdata = new List<airWrapper>();
        for(Air_Metadata__mdt airdata : [SELECT ID, Airline__c , Capacity__c,Departure_Time__c,Destination_Airport__c, Flight_Number__c,Flight_Status__c,Origin_Airport__c FROM Air_Metadata__mdt ]){
            airWrapper wrapper = new airWrapper();
            wrapper.Id =airdata.Id;
            wrapper.FlightNumber =airdata.Flight_Number__c;
            wrapper.Airline =airdata.Airline__c;
            wrapper.OriginAirport=airdata.Origin_Airport__c;
            wrapper.destinationAir =airdata.Destination_Airport__c;
            wrapper.DepartureTime =airdata.Departure_Time__c;
            wrapper.flightStatus=airdata.Flight_Status__c;
            wrapper.Capacity= (Integer)airdata.Capacity__c;
            
            airWrapperdata.add(wrapper);
        }
        return airWrapperdata;

    }
}