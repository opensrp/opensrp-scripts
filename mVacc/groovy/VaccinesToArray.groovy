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


def jsonSlurper = new JsonSlurper()
def test = '{"clientUUID" : "be854618-aa5c-472d-9c27-797de3709de0","opensrp_vaccines" : "[{},{},{\\"vaccine_name\\":\\"OPV\\",\\"date_administered\\":\\"2018-05-20\\",\\"sequence\\":\\"0\\"},{\\"vaccine_name\\":\\"BCG\\",\\"date_administered\\":\\"2018-05-20\\",\\"sequence\\":\\"1\\"}]","mvac_all_vaccines" : "421/2017 + BCG + OPV + DTP + PCV + Rota"}'

def inputJson = jsonSlurper.parseText(test)
def opensrpVaccines = inputJson.opensrp_vaccines
def incomingFlowContent = inputJson.mvac_all_vaccines.replaceAll("\\s", "").replaceAll("\\+", ",")
incomingFlowContent = incomingFlowContent.substring(incomingFlowContent.indexOf(',') + 1)
def vaccineArray = incomingFlowContent.split(",")
def opensrpVaccineArray = jsonSlurper.parseText(opensrpVaccines)
def mvaccVaccine = ''
println(opensrpVaccineArray)
println(vaccineArray)
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
    println vaccineSequence.toString() + mvaccVaccine
}

int defaultVaccineSequence(String vaccineName) {
    if (vaccineName.equalsIgnoreCase("OPV")) {
        return 0
    }
    return 1
}









