import org.apache.commons.io.IOUtils
import java.nio.charset.StandardCharsets
import groovy.json.JsonSlurper
import java.text.SimpleDateFormat

def flowFile = session.get()
if (!flowFile) return
def jsonSlurper = new JsonSlurper()

def conceptMap = [
        'BCG'    : '886AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'OPV'    : '783AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'PCV'    : '162342AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'Penta'  : '1685AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'Rota'   : '159698AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'Measles': '36AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        'MR'     : '162586AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
]
def maxCountMap = [
        'BCG'    : '2',
        'OPV'    : '4',
        'PCV'    : '3',
        'Penta'  : '3',
        'Rota'   : '2',
        'Measles': '2',
        'MR'     : '2'
]

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
    Object identifiers
    int duration
}

class Identifiers {
    String MVAC_UUID
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
    if (formSubmissionField.equals("bcg")) {
        if (calculate > 1)
            formSubmissionField = formSubmissionField + calculate
        else
            formSubmissionField = formSubmissionField
    } else
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

String getDate(String format) {
    return new SimpleDateFormat(format).format(new Date())
}

int defaultVaccineSequence(String vaccineName) {
    if (vaccineName.equalsIgnoreCase("OPV")) {
        return 0
    }
    return 1
}

session.write(flowFile, { inputStream, outputStream ->
    def inputJson = jsonSlurper.parseText(IOUtils.toString(inputStream, StandardCharsets.UTF_8))
    def opensrpVaccines = inputJson.opensrp_vaccines
    def clientUUID = inputJson.clientUUID
    def locationId = inputJson.home_facility_uuid
    def providerId = inputJson.provider_id
    def incomingFlowContent = inputJson.mvac_all_vaccines.replaceAll("\\s", "").replaceAll("\\+", ",")
    incomingFlowContent = incomingFlowContent.substring(incomingFlowContent.indexOf(',') + 1)
    def vaccineArray = incomingFlowContent.split(",")
    def opensrpVaccineArray = jsonSlurper.parseText(opensrpVaccines)
    def mvaccVaccine = ''
    def eventList = []
    vaccineArray.each {
        mvaccVaccine = it.toString()
        if(mvaccVaccine.equalsIgnoreCase("DTP")){
            mvaccVaccine = "Penta"
        }
        def vaccineSequence = defaultVaccineSequence(mvaccVaccine)
        opensrpVaccineArray.each {
            if (it.vaccine_name != null) {
                def opensrpVaccine = it.vaccine_name
                if (opensrpVaccine.equalsIgnoreCase(mvaccVaccine) && it.sequence < maxCountMap.getAt(mvaccVaccine)) {
                    vaccineSequence = (it.sequence as Integer) + 1
                }
            }
        }
        def currentDate = getDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        def vaccineDate = getDate("yyyy-MM-dd")
        Obs vaccineObsDate = generateObs(vaccineSequence, conceptMap.getAt(mvaccVaccine), "date", mvaccVaccine.toLowerCase(), vaccineDate)
        Obs vaccineObsCalculate = generateObs(vaccineSequence, conceptMap.getAt(mvaccVaccine), "calculate", mvaccVaccine.toLowerCase(), vaccineSequence.toString())
        Obs[] vaccineObs = [vaccineObsDate, vaccineObsCalculate]

        Identifiers identifiers = new Identifiers(
                MVAC_UUID: UUID.randomUUID()
        )

        Event vaccineEvent = new Event(
                type: 'Event',
                dateCreated: currentDate,
                baseEntityId: clientUUID,
                locationId: locationId,
                eventDate: currentDate,
                eventType: 'Vaccination',
                formSubmissionId: UUID.randomUUID(),
                providerId: providerId,
                entityType: 'vaccination',
                duration: 0,
                identifiers: identifiers,
                obs: vaccineObs
        )
        eventList.add(vaccineEvent)
    }

    outputStream.write(groovy.json.JsonOutput.toJson(events: eventList).getBytes(StandardCharsets.UTF_8))
} as StreamCallback)

session.transfer(flowFile, REL_SUCCESS)
