//import org.apache.commons.io.IOUtils
//import java.nio.charset.StandardCharsets
//import groovy.json.JsonSlurper
//
//def flowFile = session.get()
//if(!flowFile) return
//def jsonSlurper = new JsonSlurper()
//def AttributesMap = [:]
//
//session.write(flowFile, { inputStream,outputStream ->
//    def inputJson = jsonSlurper.parseText(IOUtils.toString(inputStream, StandardCharsets.UTF_8))
//    AttributesMap = ['mvacc_vaccine_id': inputJson.mvac_all_vaccines, 'mvacc_vaccines': inputJson.clientUUID]
//
//    outputStream.write(inputJson.mvac_all_vaccines.getBytes(StandardCharsets.UTF_8))
//} as StreamCallback)
//
//flowFile = session.putAllAttributes(flowFile,AttributesMap)
//session.transfer(flowFile,REL_SUCCESS)

import groovy.json.JsonSlurper
import org.codehaus.groovy.classgen.genArrays

import java.text.SimpleDateFormat

def conceptMap = [
        'BCG'    : '886AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'OPV'    : '783AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'PCV'    : '162342AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'Penta'  : '1685AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'Rota'   : '159698AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'Measles': '36AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'MR'     : '162586AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
]

def jsonSlurper = new JsonSlurper()
def test = '{"providerId" : "biddemo","locationId" : "le854618-aa5c-472d-9c27-797de3709de0","clientUUID" : "be854618-aa5c-472d-9c27-797de3709de0","opensrp_vaccines" : "[{},{},{\\"vaccine_name\\":\\"OPV\\",\\"date_administered\\":\\"2018-05-20\\",\\"sequence\\":\\"0\\"},{\\"vaccine_name\\":\\"BCG\\",\\"date_administered\\":\\"2018-05-20\\",\\"sequence\\":\\"1\\"}]","mvac_all_vaccines" : "421/2017 + BCG + OPV + DTP + PCV + Rota"}'

def inputJson = jsonSlurper.parseText(test)
def opensrpVaccines = inputJson.opensrp_vaccines
def clientUUID = inputJson.clientUUID
def locationId = inputJson.locationId
def providerId = inputJson.providerId
def incomingFlowContent = inputJson.mvac_all_vaccines.replaceAll("\\s", "").replaceAll("\\+", ",")
incomingFlowContent = incomingFlowContent.substring(incomingFlowContent.indexOf(',') + 1)
def vaccineArray = incomingFlowContent.split(",")
def opensrpVaccineArray = jsonSlurper.parseText(opensrpVaccines)
def mvaccVaccine = ''
def eventList = []
vaccineArray.each {
    mvaccVaccine = it
    def vaccineSequence = defaultVaccineSequence(mvaccVaccine)
    opensrpVaccineArray.each {
        if (it.vaccine_name != null) {
            def opensrpVaccine = it.vaccine_name
            if (opensrpVaccine.equalsIgnoreCase(mvaccVaccine) && it.sequence > vaccineSequence) {
                vaccineSequence = (vaccineSequence as Integer) + 1
            }
        }
    }
    def currentDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").format(new Date())
    def vaccineDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date())

    Obs vaccineObsDate = generateObs(vaccineSequence, conceptMap.getAt(mvaccVaccine), "date", mvaccVaccine.toLowerCase(), vaccineDate)
    Obs vaccineObsCalculate = generateObs(vaccineSequence, conceptMap.getAt(mvaccVaccine), "calculate", mvaccVaccine.toLowerCase(), vaccineSequence.toString())
    Obs[] vaccineObs = [vaccineObsDate, vaccineObsCalculate]

    Event vaccineEvent = new Event(
            type: 'Event',
            dateCreated: currentDate,
            baseEntityId: clientUUID,
            locationId: locationId,
            eventDate: currentDate,
            eventType: 'Vaccination',
            formSubmissionId: UUID.randomUUID().toString(),
            providerId: providerId,
            entityType: 'vaccination',
            duration: 0,
            obs: vaccineObs
    )
    eventList.add(vaccineEvent)

}

println(groovy.json.JsonOutput.toJson(events: eventList))

class Event {
    String type
    String dateCreated
    String baseEntityId
    String locationId
    String eventDate
    String eventType
    String formSubmissionId
    String providerId
    String entityType
    Obs[] obs
    int duration
}

class Obs {
    String fieldType
    String fieldDataType
    String fieldCode
    String parentCode
    String[] values
    String formSubmissionField
    String[] humanReadableValues
}

Obs generateObs(int calculate, String vaccineConcept, String fieldDataType, String formSubmissionField, String[] values) {
    Obs obs = new Obs()
    String[] humanReadableValues = new String()
    obs.setProperty("fieldType", 'concept')
    obs.setProperty("fieldDataType", fieldDataType)
    obs.setProperty("parentCode", vaccineConcept)
    if (formSubmissionField.equals("bcg") && calculate > 1)
        formSubmissionField = formSubmissionField + calculate
    else
        formSubmissionField = formSubmissionField + "_" + calculate

    if (fieldDataType.equals("date")) {
        obs.setProperty("fieldCode", '1410AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
        obs.setProperty("formSubmissionField", formSubmissionField)
    } else {
        obs.setProperty("fieldCode", '1418AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
        obs.setProperty("formSubmissionField", formSubmissionField + '_dose')
    }

    obs.setProperty("values", values)
    obs.setProperty("humanReadableValues", humanReadableValues)

    return obs
}

int defaultVaccineSequence(String vaccineName) {
    if (vaccineName.equalsIgnoreCase("OPV")) {
        return 0
    }
    return 1
}







