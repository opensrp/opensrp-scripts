import org.apache.commons.io.IOUtils
import java.nio.charset.StandardCharsets
import groovy.json.JsonSlurper

def flowFile = session.get()
if(!flowFile) return
def jsonSlurper = new JsonSlurper()
def vaccine_flow_content = ''
def mvacc_id = ''

session.read(flowFile, { inputStream ->
    def row = jsonSlurper.parseText(IOUtils.toString(inputStream, StandardCharsets.UTF_8))
    vaccine_flow_content = row.results.all_vaccine.replaceAll("\\s", "").replaceAll("\\+", ",")
    mvacc_id = vaccine_flow_content.substring(0,vaccine_flow_content.indexOf(','))
} as InputStreamCallback)

flowFile = session.putAttribute(flowFile, 'mvacc_id', mvacc_id)
session.transfer(flowFile,REL_SUCCESS)
