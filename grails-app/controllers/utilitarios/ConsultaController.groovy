package utilitarios

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import wslite.soap.SOAPClient
import wslite.soap.SOAPResponse
import wslite.http.auth.*


class ConsultaController {

    def prueba() {

        def sobre_xml = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:agr="https://www.economiasolidaria.gob.ec/">'
        sobre_xml += '<soap:Header/><soap:Body><agr:WBConsultaCed>'
        sobre_xml += '<agr:cadena>0601983869</agr:cadena>'
        sobre_xml += '</agr:WBConsultaCed></soap:Body></soap:Envelope>'


        def soapUrl = new URL('http://interoperabilidad.dinardap.gob.ec:7979/interoperador?wsdl')
        def connection = soapUrl.openConnection()
        println "abre conexion"
        connection.setRequestMethod("POST")
        connection.setConnectTimeout(5000)
        connection.setReadTimeout(5000)
        println "...post"
        connection.login("iOpaDRIeps")
        connection.password("6Tmq[]3ic}")
        connection.exceptions(true)
        connection.setRequestProperty("Content-Type", "text/plain")
        println "...xml"
        connection.doOutput = true
        println "...do Output"

        Writer writer = new OutputStreamWriter(connection.outputStream)

        writer.write(sobre_xml)
        println "...write"
        writer.flush()
        writer.close()
        connection.connect()
        println "...connect"

        def respuesta = connection.content.text
        def respuestaSri = new XmlSlurper().parseText(respuesta)
        println respuestaSri


/*
        if (respuestaSri == "RECIBIDA") {
            def para_autorizacion = """<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ec="http://ec.gob.sri.ws.autorizacion">
                <soapenv:Header/>
                <soapenv:Body>
                <ec:autorizacionComprobante>
                <claveAccesoComprobante>${clave}</claveAccesoComprobante>
                </ec:autorizacionComprobante>
                </soapenv:Body>
                </soapenv:Envelope>"""

            println "----\n ${para_autorizacion}\n----"
            soapUrl = new URL("https://celcer.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl")
            connection = soapUrl.openConnection()
            println "abre conexion --- atrz"
            connection.setRequestMethod("POST")
            connection.setConnectTimeout(5000)
            connection.setReadTimeout(5000)
            println "...post"
            connection.setRequestProperty("Content-Type", "application/xml")
            println "...xml"
            connection.doOutput = true
            println "...do Output"

            writer = new OutputStreamWriter(connection.outputStream)

            writer.write(para_autorizacion)
            println "...write"
            writer.flush()
            writer.close()
            connection.connect()
            println "...connect atz... "

            respuesta = connection.content.text
            def guardar = new File(path + "/sri${archivo}")
            guardar.write(respuesta)

            def atrz = respuesta =~ /numeroAutorizacion.(\d+)/

            return atrz[0][1]

        } else {
            return "ha ocurrido un error al solicitar la autorización al SRI"
        }
*/

    }

    def prueba1() {
//        def parametros = [login: "iOpaDRIeps", password: "6Tmq[]3ic}", exceptions:true]
        def client = new SOAPClient('http://interoperabilidad.dinardap.gob.ec:7979/interoperador?wsdl')
//        client.authorization = new HTTPBasicAuthorization("iOpaDRIeps", "6Tmq[]3ic}")
        println "...1"

        def valoresBuscarSRI = [:]
        valoresBuscarSRI['login'] = 'iOpaDRIeps'
        valoresBuscarSRI['password'] = '6Tmq[]3ic}'
        valoresBuscarSRI['numeroIdentificacion'] = '1760003330001'
        valoresBuscarSRI['codigoPaquete'] = 186

        def resp = client.send("getFichaGeneral", valoresBuscarSRI);
        println "$resp"
        render resp
    }

    def prueba2() {
        def client = new SOAPClient('http://interoperabilidad.dinardap.gob.ec:7979/interoperador?wsdl')
        println "...1"

        def response = client.send(
                login: "iOpaDRIeps",
                password: "6Tmq[]3ic}",
                connectTimeout:5000,
                readTimeout:20000,
                useCaches:false,
                followRedirects:false,
                sslTrustAllCerts:true) {
            numeroIdentificacion: '1760003330001'
            codigoPaquete: '186'
        }
        println "$response"
        render response
    }

    def prueba3() {
        def client = new SOAPClient('http://interoperabilidad.dinardap.gob.ec:7979/interoperador?wsdl')
        println "...1"

        def response = client.send(
                login: "iOpaDRIeps",
                password: "6Tmq[]3ic}",
                connectTimeout:5000,
                readTimeout:20000,
                useCaches:false,
                followRedirects:false,
                sslTrustAllCerts:true,
                numeroIdentificacion: '1760003330001',
                codigoPaquete: '186')

        println "$response"
        render response
    }

    def prueba4() {
        def client = new SOAPClient('http://interoperabilidad.dinardap.gob.ec:7979/interoperador?wsdl')
        println "...1"

        def response = client.send(
                login: "iOpaDRIeps",
                password: "6Tmq[]3ic}",
                connectTimeout:5000,
                readTimeout:20000,
                numeroIdentificacion: '1760003330001',
                codigoPaquete: '186')

        println "$response"
        render response
    }

    def prueba5() {
        def client = new SOAPClient('http://interoperabilidad.dinardap.gob.ec:7979/interoperador?wsdl')
        println "...1"

        def response = client.send(
                login: "iOpaDRIeps",
                password: "6Tmq[]3ic}",
                exceptions: true,
                numeroIdentificacion: '1760003330001',
                codigoPaquete: '186')

        println "$response"
        render response
    }

    def prueba_wsdl() {
        String url = 'http://ec.europa.eu/taxation_customs/vies/services/checkVatService'
        SOAPClient client = new SOAPClient("${url}.wsdl")

        SOAPResponse response = client.send(SOAPAction: url) {
                body('xmlns': 'urn:ec.europa.eu:taxud:vies:services:checkVat:types') {
                    checkVat {
                        countryCode("es")
                        vatNumber("B99286353")
                    }
                }
            }
//        render( response.checkVatResponse.valid.text())
        render( response.checkVatResponse.text())
    }

    def prueba_wsdl3() {
        String url = 'http://interoperabilidad.dinardap.gob.ec:7979/interoperador'
        SOAPClient client = new SOAPClient("${url}.wsdl")

        SOAPResponse response = client.send(SOAPAction: url) {
                body('xmlns': 'getFichaGeneral') {
                    checkVat {
                        login("iOpaDRIeps")
                        password("6Tmq[]3ic}")
                        numeroIdentificacion("0601983869")
                        codigoPaquete("186")
                    }
                }
            }
//        render( response.checkVatResponse.valid.text())
        render( response.checkVatResponse.text())
    }

    def prueba_wsdl2() {
        String url = 'http://interoperabilidad.dinardap.gob.ec:7979/interoperador'
        SOAPClient client = new SOAPClient("${url}?wsdl")

        def sobre_xml = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:agr="https://www.economiasolidaria.gob.ec/">'
        sobre_xml += '<soap:Header/><soap:Body><agr:WBConsultaCed>'
        sobre_xml += '<agr:cadena>0601983869</agr:cadena>'
        sobre_xml += '</agr:WBConsultaCed></soap:Body></soap:Envelope>'

/*        connection.setRequestMethod("POST")
        connection.setConnectTimeout(5000)
        connection.setReadTimeout(5000)
        println "...post"
//       connection.login("iOpaDRIeps")
//       connection.password("6Tmq[]3ic}")
//       connection.exceptions(true)
        connection.setRequestProperty("Content-Type", "text/plain")
        println "...xml"
        connection.doOutput = true
        println "...do Output"

        Writer writer = new OutputStreamWriter(connection.outputStream)

        writer.write(sobre_xml)
        println "...write"
        writer.flush()
        writer.close()
        connection.connect()
        println "...connect"

        def respuesta = connection.content.text
        def respuestaSri = new XmlSlurper().parseText(respuesta)
        println respuestaSri*/

        println "...envia"
        SOAPResponse response = client.send(SOAPAction: url) {
                body('xmlns': sobre_xml)
            }
//        render( response.checkVatResponse.valid.text())
        render( response.checkVatResponse.text())
    }


   def prueba6() {
       def sobre_xml = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:agr="https://www.economiasolidaria.gob.ec/">'
       sobre_xml += '<soap:Header/><soap:Body><agr:WBConsultaCed>'
       sobre_xml += '<agr:cadena>0601983869</agr:cadena>'
       sobre_xml += '</agr:WBConsultaCed></soap:Body></soap:Envelope>'


       def soapUrl = new URL('http://interoperabilidad.dinardap.gob.ec:7979/interoperador?wsdl')
       def connection = soapUrl.openConnection()
       println "abre conexion"
       connection.setRequestMethod("POST")
       connection.setConnectTimeout(5000)
       connection.setReadTimeout(5000)
       println "...post"
//       connection.login("iOpaDRIeps")
//       connection.password("6Tmq[]3ic}")
//       connection.exceptions(true)
       connection.setRequestProperty("Content-Type", "text/plain")
       println "...xml"
       connection.doOutput = true
       println "...do Output"

       Writer writer = new OutputStreamWriter(connection.outputStream)

       writer.write(sobre_xml)
       println "...write"
       writer.flush()
       writer.close()
       connection.connect()
       println "...connect"

       def respuesta = connection.content.text
       def respuestaSri = new XmlSlurper().parseText(respuesta)
       println respuestaSri
    }


    boolean httpInit() {
        println "...httpInit"

        def postRequest = null
        def baseUrl = new URL('http://interoperabilidad.dinardap.gob.ec:7979/interoperador?wsdl')
        def queryString = 'q=groovy&format=json&pretty=1'
        def connection = baseUrl.openConnection()
        println "...0"

        connection.with {
            println "...1"
            doOutput = true
            requestMethod = 'POST'
            outputStream.withWriter { writer ->
                writer << queryString
            }
            println "...2"
            response.success = { resp ->
                println "Success! ${resp.status}"
            }
            println "...3"
            response.failure = { resp ->
                println "Request failed with status ${resp.status}"
            }
//            println content.text
        }
        render"ok..."
    }

    String consultarCed(cedula) {
        String strRequest = ""
        strRequest += '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:agr="http://www.agricultura.gob.ec/">'
        strRequest += '<soap:Header/><soap:Body><agr:WBConsultaCed>'
        strRequest += '<agr:cadena>' + cedula + '</agr:cadena>'
        strRequest += '</agr:WBConsultaCed></soap:Body></soap:Envelope>'

        return ejecutar(strRequest, cedula)
    }

    String consultarRuc(ruc) {
        String strRequest = ""
        strRequest += '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:agr="http://www.agricultura.gob.ec/">'
        strRequest += '<soap:Header/><soap:Body>'
        strRequest += '<agr:WBConsultaRUC>'
        strRequest += '<agr:cadenaSRI>' + ruc + '</agr:cadenaSRI>'
        strRequest += '</agr:WBConsultaRUC></soap:Body></soap:Envelope>'

        return ejecutar(strRequest, ruc)
    }

/*
    String ejecutar(strRequest, id) {
        if(postRequest == null || httpClient == null) {
            return "CIRUC: ERROR LA SESION DE VALIDACIÓN NO HA SIDO INICIADA"
        } else {
            StringEntity input = new StringEntity(strRequest)
            input.setContentType("application/soap+xml")
            postRequest.setEntity(input)
            HttpResponse response = httpClient.execute(postRequest)
            def sc =response.getStatusLine().getStatusCode()
            def resultado = ''
            if(sc == 200) {
                resultado = response.getEntity().getContent().text
                def i = resultado.indexOf(';')
                if( i >= 0 ) {
                    resultado = resultado.substring(0,i+1) + id + resultado.substring(i)
                }
            }
            def src =  new XmlSlurper().parseText(resultado)
            resultado = "" + src.text() + ""
            sleep(24)
            return resultado
        }
    }
*/

    void httpFinish() {
        if(httpClient != null) {
            try {
                httpClient.getConnectionManager().shutdown()
            } catch (Exception e) {
                AppException('Cant close HTP Connection',e.getMessage(),'CirucJob')
            }
        }
        httpClient = null
        postRequest = null
    }

} //fin controller
