import org.apache.commons.io.IOUtils
import java.nio.charset.StandardCharsets
import groovy.json.JsonSlurper
import java.text.SimpleDateFormat
import groovy.time.TimeCategory

import java.text.SimpleDateFormat

def flowFile = session.get()
if (!flowFile) return
jsonSlurper = new JsonSlurper()
currentDate = getDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ", new Date())
motherBaseID = UUID.randomUUID()
childBaseID = UUID.randomUUID()

class Client {
    String dateCreated
    String baseEntityId
    String firstName
    String lastName
    String gender
    String birthdate
    boolean birthdateApprox
    String type
    boolean deathdateApprox
    Object identifiers
    Object attributes
    Object relationships
    Object addresses
}

class Identifiers {
    String MVAC_UNDER_5_ID
    String ZEIR_ID
}

class Attributes {
    String Home_Facility
}

class AddressFields {
    String address3
    String address2
}

String getDate(String format, Date date) {
    return new SimpleDateFormat(format).format(date)
}

Client makeClient(Object clientObject, boolean child) {
    client = new Client()

    identifiers = new Identifiers(MVAC_UNDER_5_ID: clientObject.under5id, ZEIR_ID: clientObject.zeir_id)
    clientAttributes = new Attributes(Home_Facility: clientObject.home_facility_name)

    addressFields = new AddressFields(address3: clientObject.home_facility_uuid, address2: clientObject.homeaddress)
    String[] mother = [motherBaseID]
    relationshipsMap = ['mother': mother]
    Object mumIds = jsonSlurper.parseText(groovy.json.JsonOutput.toJson("M_ZEIR_ID": clientObject.mzeir))

    addressFields = jsonSlurper.parseText(groovy.json.JsonOutput.toJson("addressType": "usual_residence", addressFields: addressFields))
    Object[] address = [addressFields]

    client.setProperty("dateCreated", currentDate)
    client.setProperty("type", "Client")
    client.setProperty("birthdate", getDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Date.parse('dd/MM/yy', clientObject.cdob)))
    client.setProperty("deathdateApprox", false)

    if (child) {
        childName = clientObject.childname.trim().split(" ")
        client.setProperty("baseEntityId", childBaseID)
        client.setProperty("firstName", childName[0])
        client.setProperty("lastName", childName[1])
        client.setProperty("identifiers", identifiers)
        client.setProperty("gender", clientObject.childsex == "M" ? "Male" : "Female")
        client.setProperty("birthdate", getDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Date.parse('dd/MM/yy', clientObject.cdob)))
        client.setProperty("birthdateApprox", false)
        client.setProperty("relationships", relationshipsMap)
    } else {
        motherName = clientObject.gname.trim().split(" ")
        client.setProperty("baseEntityId", motherBaseID)
        client.setProperty("firstName", motherName[0])
        client.setProperty("lastName", motherName[1])
        client.setProperty("identifiers", mumIds)
        client.setProperty("gender", "Female")
        client.setProperty("birthdateApprox", true)
        use(groovy.time.TimeCategory) {
            client.setProperty("birthdate", getDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ", 10.years.ago))
        }
    }

    client.setProperty("attributes", clientAttributes)
    client.setProperty("addresses", address)
    return client
}

class Event {
    String type
    String dateCreated
    String baseEntityId
    String locationId
    String eventDate
    String eventType
    String formSubmissionId
    String providerId
    Obs[] obs
    Object identifiers
    int duration
    String entityType
}


class Obs {
    String fieldType
    String fieldDataType
    String fieldCode
    String parentCode
    String[] values
    String formSubmissionField
    String[] humanReadableValues
    String[] set
}

Event makeRegistrtionEvent(Object clientObject, boolean child) {
    Event regEvent = new Event()
    locationId = clientObject.home_facility_uuid
    eventIds = jsonSlurper.parseText(groovy.json.JsonOutput.toJson("MVAC_UUID": UUID.randomUUID()))
    Obs vaccineObsCalculate = generateObs("formsubmissionField", "text", "Home_Facility", "Home_Facility", locationId)
    Obs[] vaccineObs = [vaccineObsCalculate]
    if (child) {
        regEvent.setProperty("baseEntityId", childBaseID)
        regEvent.setProperty("eventType", "Birth Registration")
        regEvent.setProperty("entityType", "child")
    } else {
        regEvent.setProperty("baseEntityId", motherBaseID)
        regEvent.setProperty("eventType", "New Woman Registration")
        regEvent.setProperty("entityType", "mother")
    }
    regEvent.setProperty("type", 'Event')
    regEvent.setProperty("dateCreated", currentDate)

    regEvent.setProperty("locationId", locationId)
    regEvent.setProperty("eventDate", currentDate)

    regEvent.setProperty("formSubmissionId", UUID.randomUUID())
    regEvent.setProperty("providerId", clientObject.provider_id)
    regEvent.setProperty("identifiers", eventIds)
    regEvent.setProperty("obs", vaccineObs)

    return regEvent
}

Obs generateObs(String fieldType, String fieldDataType, String fieldCode, String formSubmissionField, String[] values) {
    Obs obs = new Obs()
    String[] humanReadableValues = new String()
    String[] set = new String()
    obs.setProperty("fieldType", fieldType)
    obs.setProperty("fieldDataType", fieldDataType)
    obs.setProperty("parentCode", "")
    obs.setProperty("fieldCode", fieldCode)
    obs.setProperty("values", values)
    obs.setProperty("formSubmissionField", formSubmissionField)
    obs.setProperty("values", values)
    obs.setProperty("humanReadableValues", humanReadableValues)
    obs.setProperty("set", set)

    return obs
}

session.write(flowFile, { inputStream, outputStream ->
    def inputJson_test = jsonSlurper.parseText(IOUtils.toString(inputStream, StandardCharsets.UTF_8))
    def eventList = []
    def clientList = []
    eventList.add(makeRegistrtionEvent(inputJson_test, true))
    eventList.add(makeRegistrtionEvent(inputJson_test, false))
    clientList.add(makeClient(inputJson_test, true))
    clientList.add(makeClient(inputJson_test, false))
    Object regEvents = groovy.json.JsonOutput.toJson(events: eventList, clients: clientList)
    outputStream.write(regEvents.getBytes(StandardCharsets.UTF_8))
} as StreamCallback)

session.transfer(flowFile, REL_SUCCESS)
