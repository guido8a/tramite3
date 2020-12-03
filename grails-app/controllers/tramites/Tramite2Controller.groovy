package tramites


import alertas.Alerta
import seguridad.Accn
import seguridad.Persona
import seguridad.Sesn
import utilitarios.DiaLaborable
import utilitarios.Parametros

class Tramite2Controller {

    def diasLaborablesServiceOld
    def enviarService
    def tramitesService
    def dbConnectionService

    def verTramite() {
        def tramite = Tramite.get(params.id)
        return [tramite: tramite]
    }

    def revision() {

        def tramite = Tramite.get(params.id).refresh()

        /*Todo hacer la validacion para determinar si es el jefe*/

        return [tramite: tramite]
    }

    def saveNotas() {
        def tramite = Tramite.get(params.tramite)
        tramite.nota = params.notas
        if (tramite.save(flush: true)) {
            render "ok"
        } else {
            render "error"
        }
    }

    def revisar() {

        if (request.getMethod() == "POST") {
            def tramite = Tramite.get(params.id)
            def user = Persona.get(session.usuario.id)
            def msg = ""
            def band = true
            def per = PermisoUsuario.findByPersonaAndPermisoTramite(user, PermisoTramite.findByCodigo("P005"))
            if (tramite.de.departamento.id != user.departamento.id) {
                band = false
            }
            if (user.puedeJefe != 1 && !per) {
                band = false
            }
            if (band) {
                if (tramite.estadoTramite.codigo == "E001") {
                    tramite.estadoTramite = EstadoTramite.findByCodigo("E002")
                }
                if (tramite.save(flush: true)) {
                    render "ok"
                } else {
                    render "error"
                }
            } else {
                msg = "Usted no tiene autorización para revisar este tramite"
                render "error_" + msg
            }
        } else {
            response.sendError(403)
        }
    }

    def bandejaSalidaDep() {
        def usuario = session.usuario
        def persona = Persona.get(usuario.id)
        def revisar = false
        def bloqueo = false
        if (!session.usuario.esTriangulo()) {
            redirect(action: 'bandejaSalida')
            return
        }

        params.sort = "trmtfccr"
        params.order = "desc"

        return [persona: persona, revisar: revisar, bloqueo: bloqueo, esEditor: session.usuario.puedeEditor]
    }

    def tablaBandejaSalidaDep() {
        def persona = Persona.get(session.usuario.id)
        def busca = false
        def where = ""

        if (!params.sort || params.sort == "") {
            params.sort = "trmtfcrc"
        }
        if (!params.order || params.order == "" || params.order == null) {
            params.order = "DESC"
        }

        if (params.fecha) {
            busca = true
            def fechaIni = new Date().parse("dd-MM-yyyy HH:mm:ss", params.fecha + " 00:00:00")
            def fechaFin = new Date().parse("dd-MM-yyyy HH:mm:ss", params.fecha + " 23:59:59")
            where += "WHERE (trmtfcen >= '${fechaIni.format('yyyy-MM-dd HH:mm:ss')}'" +
                    " AND trmtfcen <= '${fechaFin.format('yyyy-MM-dd HH:mm:ss')}')"
        }
        if (params.asunto) {
            busca = true
            if (where == "") {
                where = "WHERE "
            } else {
                where += " AND "
            }
            where += "(trmtasnt ilike '%${params.asunto.trim()}%')"
        }
        if (params.memorando) {
            busca = true
            if (where == "") {
                where = "WHERE "
            } else {
                where += " AND "
            }
            where += "(trmtcdgo ilike '%${params.memorando.trim()}%')"
        }

        def sql = "SELECT * FROM salida_dpto($persona.id) ${where} ORDER BY ${params.sort} ${params.order}"

        def cn = dbConnectionService.getConnection()
        def rows = cn.rows(sql.toString())
        return [rows: rows, busca: busca]
    }


    def desenviar_ajax_old88() {
        def tramite = Tramite.get(params.id)
        def porEnviar = EstadoTramite.findByCodigo("E001")
        def ids
        def enviado = EstadoTramite.findByCodigo("E003")
        def recibido = EstadoTramite.findByCodigo("E004")

        if (params.ids) {
            ids = params.ids
        } else {
            ids = null
        }

        if (tramite.estadoTramite == recibido) {
            render "NO_Se ha cancelado el proceso de cancelación de envio.<br/>Este trámite no puede ser gestionado."
            return
        }

        if (tramite.estadoTramite != enviado) {
            render "NO_Este trámite no puede ser gestionado."
            return
        }

        def tramiteEsCircular = tramite.tipoDocumento.codigo == "CIR"
        def errores = ""
        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCc = RolPersonaTramite.findByCodigo("R002")
        def rolEnvia = RolPersonaTramite.findByCodigo("E004")
        def strEnvioPrevio = ""
        def quienEnvio = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(tramite, rolEnvia)
        if (quienEnvio.size() == 0) {
            strEnvioPrevio = "- Sin registro de la persona que envió anteriormente -"
        } else if (quienEnvio.size() == 1) {
            quienEnvio = quienEnvio.first()
            strEnvioPrevio = "Enviado anteriormente por " + quienEnvio.persona?.login
        } else {
            strEnvioPrevio = "Enviado anteriormente por "
            quienEnvio.each { q ->
                strEnvioPrevio += q.persona?.login + ", "
            }
        }
        def mensaje = ''

        //esta quitando el enviado a estos
        (ids.split("_")).each { id ->
            def persDoc = PersonaDocumentoTramite.get(id.toLong())
            if (persDoc) {
                def log = strEnvioPrevio + " el " +
                        "${persDoc.fechaEnvio ? persDoc.fechaEnvio.format('dd-MM-yyyy HH:mm') : tramite.fechaEnvio?.format('dd-MM-yyyy HH:mm')}"

                if (persDoc.estado == enviado) {
                    def alerta
                    def pers = persDoc.persona
                    def dpto = persDoc.departamento
                    def tram = persDoc.tramite
                    if (persDoc.rolPersonaTramite == rolPara) {
                        persDoc.fechaEnvio = null
                        persDoc.estado = porEnviar
                        persDoc.tramite.estadoTramite = porEnviar

                        def obsTram = ""
                        if (persDoc.departamento) {
                            obsTram = " al dpto. ${persDoc.departamento.codigo}"
                        } else if (persDoc.persona) {
                            obsTram = " al usuario ${persDoc.persona.login}"
                        }

                        def observacionOriginal = persDoc.observaciones
                        def accion = "Cancelación de envío"
                        def solicitadoPor = ""
                        def usuario = session.usuario.login
                        def texto = log
                        def nuevaObservacion = ""
                        persDoc.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                        observacionOriginal = tramite.observaciones
                        texto = log + obsTram
                        tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                        if (persDoc.save(flush: true)) {
                            if (pers) {
                                alerta = Alerta.findByPersonaAndTramite(pers, tram)
                            } else {
                                alerta = Alerta.findByDepartamentoAndTramite(dpto, tram)
                            }
                            if (alerta) {
                                alerta.mensaje += " - Tramite cambiado de estado"
                                alerta.fechaRecibido = new Date()
                                alerta.save(flush: true)
                            }
                        } else {
                            println "ERROR AL CAMBIAR PERS DOC TRAM: " + persDoc.errors
                            errores += "<li>" + renderErrors(bean: persDoc) + "</li>"
                        }
                        //ademas elimina todas las copias

                        def copias = PersonaDocumentoTramite.withCriteria {
                            eq("tramite", tramite)
                            ne("rolPersonaTramite", rolPara)
                        }.id
                        copias.each { idCopia ->
                            try {
                                def persTram = PersonaDocumentoTramite.get(idCopia)
                                if (persTram) {
                                    if (persTram.rolPersonaTramite == rolCc) {
                                        obsTram = ""
                                        if (persDoc.departamento) {
                                            obsTram = " al dpto. ${persDoc.departamento.codigo}"
                                        } else if (persDoc.persona) {
                                            obsTram = " al usuario ${persDoc.persona.login}"
                                        }
                                        observacionOriginal = tramite.observaciones
                                        accion = "Cancelación de envío de copia"
                                        solicitadoPor = ""
                                        usuario = session.usuario.login
                                        nuevaObservacion = ""
                                        texto = log + obsTram
                                        tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                                    }
                                    persTram.delete(flush: true)
                                    if (persTram.persona) {
                                        alerta = Alerta.findByPersonaAndTramite(persTram.persona, tram)
                                    } else {
                                        alerta = Alerta.findByDepartamentoAndTramite(persTram.departamento, tram)
                                    }
                                    if (alerta) {
                                        alerta.mensaje += " - Tramite cambiado de estado"
                                        alerta.fechaRecibido = new Date()
                                        alerta.save(flush: true)
                                    }
                                }
                            } catch (e) {
                                println "***error: " + e
                            }
                        }
                    } else {
                        try {
                            def obsTram = ""
                            if (persDoc.departamento) {
                                obsTram = " al dpto. ${persDoc.departamento.codigo}"
                            } else if (persDoc.persona) {
                                obsTram = " al usuario ${persDoc.persona.login}"
                            }
                            def observacionOriginal = tramite.observaciones
                            def accion = "Cancelación de envío de copia"
                            def solicitadoPor = ""
                            def usuario = session.usuario.login
                            def nuevaObservacion = ""
                            def texto = log + obsTram
                            tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                            tramite.save(flush: true)
                            persDoc.delete(flush: true)   /*** lo mismo para todos ***/

                            if (pers) {
                                alerta = Alerta.findByPersonaAndTramite(pers, tram)
                            } else {
                                alerta = Alerta.findByDepartamentoAndTramite(dpto, tram)
                            }
                            if (alerta) {
                                alerta.mensaje += " - Tramite cambiado de estado"
                                alerta.fechaRecibido = new Date()
                                alerta.save(flush: true)
                            }
                        } catch (e) {
                            println "desenviar_ajax_old error: " + e
                        }
                    } //
                } else {
                    errores += "<li>El trámite ${persDoc.tramite.codigo} no puede ser gestionado.</li>"
                }
            }
        }

        //originalmente era para todos estos: verifico si ninguno ha recibido le cambio el estado al tramite a borrador
        def recibidos = 0
        def enviados = 0
        PersonaDocumentoTramite.withCriteria {
            eq("tramite", tramite)
            inList("rolPersonaTramite", [rolPara, rolCc])
        }.each { persDoc ->
            if (persDoc.fechaRecepcion) {
                recibidos++
            }
            if (persDoc.fechaEnvio) {
                enviados++
            }
        }
        if (enviados == 0) {
            tramite.estadoTramite = porEnviar
            tramite.fechaEnvio = null
        }
        if (!tramite.save(flush: true)) {
            println "ERROR AL CAMBIAR ESTADO TRAMITE: " + tramite.errors
            errores += "<li>" + renderErrors(bean: tramite) + "</li>"
        }

        if (errores == "") {
            render "OK_Envío del trámite cancelado correctamente"
        } else {
            render "NO_Ha ocurrido un error al cancelar el envío del trámite: " + errores
        }
    }

    private void creaAlerta(Tramite tramite, Persona pers, Departamento dpto) {
        def alerta
        if (pers) {
            alerta = Alerta.findByPersonaAndTramite(pers, tramite)
        } else {
            alerta = Alerta.findByDepartamentoAndTramite(dpto, tramite)
        }
        if (alerta) {
            alerta.mensaje += " - Tramite cambiado de estado"
            alerta.fechaRecibido = new Date()
            alerta.save(flush: true)
        }
    }

    private void cambiaObs(PersonaDocumentoTramite pdt, String strEnvioPrevio, boolean copia) {
        def tramite = pdt.tramite
        def obsTram = ""
        if (pdt.departamento) {
            obsTram = " al dpto. ${pdt.departamento.codigo}"
        } else if (pdt.persona) {
            obsTram = " al usuario ${pdt.persona.login}"
        }

        def observacionOriginal = pdt.observaciones
        def accion = "Cancelación de envío" + (copia ? " de copia" : "")
        def solicitadoPor = ""
        def usuario = session.usuario.login
        def log = strEnvioPrevio + " el " +
                "${pdt.fechaEnvio ? pdt.fechaEnvio.format('dd-MM-yyyy HH:mm') : tramite.fechaEnvio?.format('dd-MM-yyyy HH:mm')}"
        def texto = log
        def nuevaObservacion = ""
        pdt.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
        observacionOriginal = tramite.observaciones
        texto = log + obsTram
        tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
        if (!tramite.save(flush: true)) {
            println "error al cambiar el log del tramite " + tramite.errors
        }
    }

    private String desenviar(PersonaDocumentoTramite pdt, String strEnvioPrevio) {
        if (pdt) {
            def codigoRolPara = "R001"
            def codigoRolCc = "R002"
            def rolPara = RolPersonaTramite.findByCodigo(codigoRolPara)
            def estadoPorEnviar = EstadoTramite.findByCodigo("E001")
            def tramite = pdt.tramite
            def pers = pdt.persona
            def dpto = pdt.departamento

            def errores = ""

            if (pdt.rolPersonaTramite.codigo == codigoRolPara) {
                pdt.fechaEnvio = null
                pdt.estado = estadoPorEnviar
                pdt.tramite.estadoTramite = estadoPorEnviar

                cambiaObs(pdt, strEnvioPrevio, false)

                def elimino = false
                if (pdt.save(flush: true)) {
                    elimino = true
                    creaAlerta(tramite, pers, dpto)
                } else {
//                    println "ERROR AL CAMBIAR PERS DOC TRAM: " + pdt.errors
                    errores += "<li>" + renderErrors(bean: pdt) + "</li>"
                }
                // si desenvio el para se tienen que eliminar todas las copias, vivas o muertas
                // ademas se eliminan los pdt de quien envio y quien recibio
                if (elimino) {
                    def idsCopias = PersonaDocumentoTramite.withCriteria {
                        eq("tramite", tramite)
                        ne("rolPersonaTramite", rolPara)
                    }.id
                    idsCopias.each { idCopia ->
                        def persTram = PersonaDocumentoTramite.get(idCopia)
                        if (persTram) {
                            desenviar(persTram, strEnvioPrevio)
                        }
                    }
                }
                return errores
            } //es PARA
            else {
                if (pdt.rolPersonaTramite.codigo == codigoRolCc) {
                    cambiaObs(pdt, strEnvioPrevio, true)
                    creaAlerta(tramite, pers, dpto)
                } // era una copia: se creo el log y se genero una alerta
                //al final se elimina el pdt
                //si es cirucular tengo que dejar una copia viva
                try {
                    pdt.delete(flush: true)
                } catch (e) {
                    println "No se pudo eliminar tramite al desenviar copia: ${pdt.tramite.codigo}: "  //+ e
                }

                return errores
            } //no es PARA
        } //existe el pdt
        else {
            return "No se encontró"
        } // no existe el pdt
    }

    /**
     * desenvia un tramite
     *      si se desenvía a una copia que no ha sido contestada aún: se la elimina
     *      si se desenvía al para, se desenvía el para y se eliminan todas las copias que no hayan sido contestadas
     *      si alguien ya ha contestado, ya no se puede desenviar a nadie
     * @return
     */
    def desenviar_ajax() {
//        println "desenviar, trmt: ${params.id}"
        def tramite = Tramite.get(params.id)
        def codigoEnviado = "E003"
        def codigoAnulado = "E006"
        def codigoArchivado = "E005"
        def codigoRecibido = "E004"

        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCc = RolPersonaTramite.findByCodigo("R002")

        def codigosOK = [codigoEnviado, codigoArchivado, codigoAnulado, codigoRecibido]

        def porEnviar = EstadoTramite.findByCodigo("E001")

        def ids
        if (params.ids) {
            ids = params.ids
        } else {
            ids = null
        }
        //1ro saco todos los receptores a ver si alguien ha contestado
        def para = tramite.para
        def copias = tramite.allCopias

        def contestaron = ""

        def listaDesenviar = []

        if (para) {
            listaDesenviar += para
        }
        listaDesenviar += copias

        listaDesenviar.each { pdt ->

            def trams = Tramite.findAllByAQuienContestaAndEsRespuestaNueva(pdt, "S")
            def respuestas = PersonaDocumentoTramite.findAllByRolPersonaTramiteInListAndTramiteInList([rolPara, rolCc], trams)
            respuestas.each { rs ->
                if (rs.estado.codigo != codigoAnulado) { //anulado
                    if (rs.persona) {
                        println "contestado persona: $rs.estado $rs.tramite.codigo $rs.persona"
                        contestaron += "<li>El usuario ${rs.persona.nombre} ${rs.persona.apellido} (${rs.persona.login}) ya contestó el documento"
                    } else {
                        println "contestado dpto: $rs.estado $rs.tramite.codigo $rs.departamento"
                        contestaron += "<li>El departamento ${rs.departamento.descripcion} (${rs.departamento.codigo}) ya contestó el documento</li>"
                    }
                }
            }
        }

        if (contestaron != "") {
            render "NO_<h3>No puede quitar el enviado del trámite ${tramite.codigo}</h3>" +
                    "<ul>" + contestaron + "<ul>"
            return
        }
        // nadie ha contestado todavía: puedo desenviar
        def errores = ""
        def rolEnvia = RolPersonaTramite.findByCodigo("E004")
        def strEnvioPrevio = ""
        def quienEnvio = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(tramite, rolEnvia)
        if (quienEnvio.size() == 0) {
            strEnvioPrevio = "Observaciones: " + (params.obs ?: '') + " - Sin registro de la persona que envió anteriormente - "
        } else {
            strEnvioPrevio = "Observaciones: " + (params.obs ?: '') + " - Enviado anteriormente por " + quienEnvio.persona.login.join(', ')
        }

//        la lista de ids de las pers doc tram a las que hay que desenviar
        (ids.split("_")).each { id ->
            def persDoc = PersonaDocumentoTramite.get(id.toLong())
            if (persDoc) {
                if (codigosOK.contains(persDoc.estado.codigo)) {
                    errores += desenviar(persDoc, strEnvioPrevio)
                } //el tramite esta enviado
                else {
//                    println "pdt no existe"
                    errores += "<li>El trámite ${persDoc.tramite.codigo} no puede ser gestionado.</li>"
                } //el tramite no esta enviado
            } //existe la persona doc tram
        } //ids.each

        // verifico de los pdt que quedaron si ninguno ha recibido le cambio el estado al tramite a borrador
        def recibidos = 0
        def enviados = 0
        ([tramite.para] + tramite.copias).each { pdt ->
            if (pdt) {
                if (pdt.fechaRecepcion) {
                    recibidos++
                }
                if (pdt.fechaEnvio) {
                    enviados++
                }
            }
        }
//        println "enviados: $enviados, recibidos: $recibidos"
        if (enviados == 0 && recibidos == 0) {
            tramite.estadoTramite = porEnviar
            tramite.fechaEnvio = null
        } else {
            println "error: no se pudo quitar fecah de envio ni estado de envio al trámite"
        }
        if (!tramite.save(flush: true)) {
            println "ERROR AL CAMBIAR ESTADO TRAMITE: " + tramite.errors
            errores += "<li>" + renderErrors(bean: tramite) + "</li>"
        }

        if (errores == "") {
            def persona = Persona.get(session.usuario.id)

            tramitesService.ejecutaRecibir(persona.departamento, session.usuario)
            render "OK_Envío del trámite cancelado correctamente"
        } else {
            render "NO_Ha ocurrido un error al cancelar el envío del trámite: " + errores
        }
    }

    def recibirExternoLista_ajax() {
        def tramite = Tramite.get(params.id)
        def copiasExternas = []
        if (tramite.externo == '1') {
            copiasExternas += tramite.para
        }
        copiasExternas += tramite.copias.findAll { it?.departamento?.externo == 1 }
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadosNo = [estadoAnulado, estadoArchivado]
        return [tramite: tramite, copias: copiasExternas, estadosNo: estadosNo]
    }

    def desenviarLista_ajax() {

        def tramite = Tramite.get(params.id)
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadosNo = [estadoAnulado, estadoArchivado]

        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCc = RolPersonaTramite.findByCodigo("R002")

        def tramites = []
        if (tramite.para) {
            tramites += tramite.para
        }
        tramites += tramite.allCopias

        def contestados = ""
        def paraRecibio = ""
        def cont = 0
        def tramitesHijos = Tramite.findAllByPadre(tramite)

        if(tramitesHijos){
            render "error"
        }else{
            tramites.each { PersonaDocumentoTramite pr ->

                def respv = pr.respuestasVivas
                cont += respv.size()

                if (pr.rolPersonaTramite.codigo == "R001") {
                    if (pr.estado.codigo != "E003") {
                        paraRecibio = "El documento está en estado ${pr.estado.descripcion} por lo que no puede ser tramitado."
                    }
                }

                def trams = Tramite.findAllByAQuienContestaAndEsRespuestaNueva(pr, "S")
                println("t " + trams)
                def respuestas

                if(trams){
                    respuestas = PersonaDocumentoTramite.findAllByRolPersonaTramiteInListAndTramiteInList([rolPara, rolCc], trams)

                    println("--> " + respuestas)
                    respuestas.each { rs ->
                        if (rs.estado.codigo != "E006") { //anulado
                            if (rs.persona) {
                                println "contestado persona: $rs.estado $rs.tramite.codigo $rs.persona"
                                contestados += "<li>El usuario ${rs.persona.nombre} ${rs.persona.apellido} (${rs.persona.login}) ya contestó el documento"
                            } else {
                                println "contestado dpto: $rs.estado $rs.tramite.codigo $rs.departamento"
                                contestados += "<li>El departamento ${rs.departamento.descripcion} (${rs.departamento.codigo}) ya contestó el documento</li>"
                            }
                        }
                    }
                }else{
                   contestados += "No se puede quitar el enviado del trámite!"
                }
            }

            return [tramite: tramite, tramites: tramites, estadosNo: estadosNo, contestados: contestados, paraRecibio: paraRecibio, cont: cont]
        }
    }

    def permisoImprimir_ajax() {
        def tramite = Tramite.get(params.id)
        def rolImprimir = RolPersonaTramite.findByCodigo('I005')
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estadoArchivado = EstadoTramite.findByCodigo("E005")

        if (tramite.para) {
            if (tramite.para?.estado == estadoAnulado || tramite.para?.estado == estadoArchivado) {
                render "El trámite se encuentra <strong>${tramite?.para?.estado?.descripcion}</strong>, no puede asignar el permiso de imprimir"
                return
            }
        }

        def personasDoc = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(tramite, rolImprimir)
        def usuario = session.usuario
        def departamento = Persona.get(usuario.id).departamento
        def personal = Persona.findAllByDepartamento(departamento)
        def personalActivo = []
        personal.each { pr ->
            if (pr?.estaActivo && pr?.id != usuario.id /*&& !pr?.esTriangulo() && !pr?.getPuedeJefe()*/) {
                def a = Accn.withCriteria {
                    eq("accnNombre", "bandejaImprimir")
                    permisos {
                        inList("perfil", Sesn.findAllByUsuario(pr).perfil)
                    }
                }
                if (a.size() > 0) {
                    personalActivo += pr
                }
            }
        }
//        println personalActivo
        return [tramite: tramite, personasDoc: personasDoc, personal: personalActivo]
    }

    def bandejaSalida() {
        def usuario = session.usuario
        def persona = Persona.get(usuario?.id)
        def revisar = false
        def bloqueo = false
        if (session.usuario) {
            if (session.usuario.esTriangulo()) {
                redirect(action: 'bandejaSalidaDep')
                return
            }
        } else {
            redirect(controller: 'login', action: 'login')
            return
        }

        params.sort = "trmtfccr"
        params.order = "desc"

        return [persona: persona, revisar: revisar, bloqueo: bloqueo, esEditor: session.usuario.puedeEditor]
    }

    def tablaBandejaSalida() {

        def persona = Persona.get(session.usuario.id)
        def busca = false
        def procedure = "salida_prsn"
        def where = ""

        if (!params.sort || params.sort == "") {
            params.sort = "trmtfcrc"
        }
        if (!params.order || params.order == "" || params.order == null) {
            params.order = "DESC"
        }

        if (session.usuario.puedeEditor) {
            procedure = "salida_editor"
        }

        if (params.fecha) {
            busca = true
            def fechaIni = new Date().parse("dd-MM-yyyy HH:mm:ss", params.fecha + " 00:00:00")
            def fechaFin = new Date().parse("dd-MM-yyyy HH:mm:ss", params.fecha + " 23:59:59")
            where += "WHERE (trmtfcen >= '${fechaIni.format('yyyy-MM-dd HH:mm:ss')}'" +
                    " AND trmtfcen <= '${fechaFin.format('yyyy-MM-dd HH:mm:ss')}')"
        }
        if (params.asunto) {
            busca = true
            if (where == "") {
                where = "WHERE "
            } else {
                where += " AND "
            }
            where += "(trmtasnt ilike '%${params.asunto.trim()}%')"
        }
        if (params.memorando) {
            busca = true
            if (where == "") {
                where = "WHERE "
            } else {
                where += " AND "
            }
            where += "(trmtcdgo ilike '%${params.memorando.trim()}%')"
        }

        def sql = "SELECT * FROM $procedure($persona.id) ${where} ORDER BY ${params.sort} ${params.order}"

        def cn = dbConnectionService.getConnection()
        def rows = cn.rows(sql.toString())
        return [rows: rows, busca: busca, esEditor: session.usuario.puedeEditor]
    }

    def bandejaSalida_old() {
        def usuario = session.usuario
        def persona = Persona.get(usuario.id)
        def revisar = false
        def bloqueo = false
        if (session.usuario.esTriangulo()) {
            redirect(action: 'bandejaSalidaDep')
            return
        }

        def departamento = Persona.get(usuario.id).departamento
        def personal = Persona.findAllByDepartamento(departamento)
        def personalActivo = []
        personal.each {
            if (it?.estaActivo && it?.id != usuario.id) {
                personalActivo += it
            }
        }
        return [persona: persona, revisar: revisar, bloqueo: bloqueo, personal: personalActivo, esEditor: session.usuario.puedeEditor]
    }

    def tablaBandejaSalida_old() {
        def porEnviar = EstadoTramite.findByCodigo("E001")
        def revisado = EstadoTramite.findByCodigo("E002")
        def enviado = EstadoTramite.findByCodigo("E003")
        def recibido = EstadoTramite.findByCodigo("E004")
        def para = RolPersonaTramite.findByCodigo("R001")
        def cc = RolPersonaTramite.findByCodigo("R002")
        def max = params.max.toInteger()
        def offset = params.actual.toInteger()
        def persona = Persona.get(session.usuario.id)
        def tramites = []
        def estados = [porEnviar, revisado, enviado, recibido]

        if (session.usuario.puedeEditor) {
            Persona.findAllByDepartamento(persona.departamento).each { p ->
                def t = Tramite.findAll("from Tramite where deDepartamento is null and de=${p.id} and estadoTramite in (${porEnviar.id},${revisado.id},${enviado.id},${recibido.id}) order by fechaCreacion desc", [max: max, offset: offset])
                if (t.size() > 0) {
                    tramites += t
                }
            }

            def t = Tramite.findAllByDeDepartamentoAndEstadoTramiteInList(persona.departamento, estados, [sort: "fechaCreacion", order: "desc", max: max, offset: offset])
            if (t.size() > 0) {
                tramites += t
            }

        } else {
            tramites = Tramite.withCriteria {
                eq("de", persona)
                isNull("deDepartamento")
                inList("estadoTramite", estados)
                order("fechaCreacion", "desc")
                maxResults(max)
                firstResult(offset)
            }
        }
        tramites?.sort { it.fechaCreacion }
        tramites = tramites?.reverse()

        def trams = []
        def trams2 = []

        tramites.each { tr ->
            def pdt = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInList(tr, [para, cc])
            def agrega = false
            def paraRecibio = false

            pdt.each { pd ->

                if (!pd.fechaRecepcion && pd.estado?.codigo != "E006" && pd.estado?.codigo != "E005") {
                    //No esta anulado ni archivado
                    //ORIGINAL: muestra todos los por enviar, enviados, recibidos si al menos un receptor falta por recibir
                    //Vuelto a cambiar el 24-04-2015:regresar a version anterior
                    if (!trams.contains(tr)) {
                        trams += tr
                    }
                } else {
                }
            }
        }

        return [persona: persona, tramites: trams, esEditor: session.usuario.puedeEditor]
    }

    def enviar() {
        if (request.getMethod() == "POST") {
            def msg = ""
            def tramite = Tramite.get(params.id)
            def envio = new Date()

            PersonaDocumentoTramite.findAllByTramite(tramite).each { t ->
                t.fechaEnvio = envio
                t.save(flush: true)
            }
            def pdt = new PersonaDocumentoTramite()
            pdt.tramite = tramite
            pdt.persona = session.usuario
            pdt.departamento = session.departamento
            pdt.fechaEnvio = envio
            pdt.rolPersonaTramite = RolPersonaTramite.findByCodigo("E004")

            pdt.personaSigla = pdt.persona.login
            pdt.personaNombre = pdt.persona.nombre + " " + pdt.persona.apellido
            pdt.departamentoNombre = pdt.departamento.descripcion
            pdt.departamentoSigla = pdt.departamento.codigo
            pdt.personaSigla = pdt.persona.login

            pdt.save(flush: true)
            tramite.fechaEnvio = envio
            tramite.estadoTramite = EstadoTramite.findByCodigo('E003')
            if (tramite.save(flush: true)) {
                //CREAR PDF
            } else {
                println tramite.errors
                render "no: " + renderErrors(bean: tramite)
            }
        } else {
            render "403"
        }
    }

    //enviar varios

    def enviarVarios() {
        def prmt = Parametros.get(1)
        def noPDF = ["DEX", "SUM"]
        def usuario = Persona.get(session.usuario.id)
        def cn = dbConnectionService.getConnection()
        def sql = ""
        if (request.getMethod() == "POST") {
            def msg = ""
            def error = ""
            def tramite
            def ids = params.ids
            ids = ids.split(',')
            def band = true
            def cantEnviados = 0
            ids.each { d ->
                def envio = new Date();
                tramite = Tramite.get(d)
                if (tramite.fechaEnvio) {
                    msg += "<br/>El trámite " + tramite.codigo + " ya fue enviado por " +
                            PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(tramite, RolPersonaTramite.findByCodigo("E004")).persona.login.join(", ")
                } else {
                    def pdtEliminar = []
                    def cambiadosDepartamento = 0

                    /*Verifica q la persona o personas a quienes se dirigen los trámites se encuentren en el
                     * mismo departamento de cuando se creo el trámite*/
                    PersonaDocumentoTramite.findAllByTramite(tramite).each { pr ->

                        def personaActual

                        if(pr.rolPersonaTramite.codigo != 'I005'){
                            if(!pr.departamento && pr.persona){
                                personaActual = Persona.get(pr.persona.id)

                                if(personaActual.departamento.id != pr.departamentoPersona?.id){
                                    cambiadosDepartamento ++
                                }
                            }
                        }
                    }

                    cambiadosDepartamento *= prmt.cambioDpto

                    if(cambiadosDepartamento == 0){

                        sql = "update prtr set prtrfcen = '${envio.format('yyyy-MM-dd HH:mm:ss')}', edtr__id = 3 " +
                                "where trmt__id = ${tramite.id} and edtr__id not in (select prtr__id from prtr " +
                                "where trmt__id = ${tramite.id} and edtr__id in (5, 9))"
                        cn.execute(sql.toString())

                        PersonaDocumentoTramite.findAllByTramite(tramite).each { t ->

                            if (t.estado?.codigo != "E006" && t.estado?.codigo != "E005") { //anulado y archivado
                                cantEnviados++
                                if (t.rolPersonaTramite?.codigo == "R001" || t.rolPersonaTramite?.codigo == "R002") {
                                    //para o copia

                                    if (t.tramite.tipoDocumento.codigo != "OFI") {
                                        def alerta = new Alerta()
                                        alerta.mensaje = "${session.departamento.codigo}:${session.usuario} te ha enviado un trámite."
                                        if (t.persona) {
                                            alerta.controlador = "tramite"
                                            alerta.accion = "bandejaEntrada"
                                            alerta.persona = t.persona
                                        } else {
                                            alerta.departamento = t.departamento
                                            alerta.accion = "bandejaEntradaDpto"
                                            alerta.controlador = "tramite3"
                                        }
                                        alerta.datos = t.id
                                        alerta.tramite = t.tramite
                                        if (!alerta.save(flush: true)) {
                                            println "error save alerta " + alerta.errors
                                        }
                                    }
                                }
//                            }
                            } else {
                                println("tramite anulado o archivado ${t.tramite.codigo}")
                                band = false
                            }

                            if (t.rolPersonaTramite.codigo == 'I005') {
                                //si tenia permiso imprimir se elimina
                                pdtEliminar += t.id
                            }
                        }

                        pdtEliminar.each { pdtId ->
                            def pdt = PersonaDocumentoTramite.get(pdtId)
                            pdt.delete(flush: true)
                        }

                        if (cantEnviados > 0) {
//                            println("enviar varios " + envio)
                            def pdt = new PersonaDocumentoTramite()
                            pdt.tramite = tramite
                            pdt.persona = session.usuario
                            pdt.departamento = session.departamento
                            pdt.fechaEnvio = envio
                            pdt.rolPersonaTramite = RolPersonaTramite.findByCodigo("E004") //envia
                            pdt.departamentoPersona = Persona.get(session.usuario.id).departamento

                            pdt.personaSigla = pdt.persona.login
                            pdt.personaNombre = pdt.persona.nombre + " " + pdt.persona.apellido
                            pdt.departamentoNombre = pdt.departamento.descripcion
                            pdt.departamentoSigla = pdt.departamento.codigo
                            pdt.personaSigla = pdt.persona.login

                            pdt.save(flush: true)
                            tramite.fechaEnvio = envio
                            tramite.estadoTramite = EstadoTramite.findByCodigo('E003') //enviado
                            if (tramite.save(flush: true)) {
                                def realPath = servletContext.getRealPath("/")
                                def mensaje = message(code: 'pathImages').toString();
                                if (!noPDF.contains(tramite.tipoDocumento.codigo)) {
                                    enviarService.crearPdf(tramite, usuario, "1", 'download', realPath, mensaje);
                                }
                            } else {
                                println tramite.errors
                                error += renderErrors(bean: tramite)
                            }
                        } else {
                            band = true
                            error += 'No se pudo enviar!'
                        }

                    } else {
                        println "enviar error: la persona ${session.usuario.login} ha cambiado de dpto --> prmtcbdp"
                        error = 'Persona cambiada de departamento'
                    }
                }
            }

            if (error == "") {
                render "ok_" + msg
            } else {
                render "no_" + error
            }
        } else {
            render "403"
        }
    }

    def errores() {
        return [params: params]
    }

    def errores1() {
        flash.message = "No puede enviar este trámite puesto que ha sido anulado o archivado"
        response.sendError(403)
    }

    def busquedaBandejaSalida() {

        def porEnviar = EstadoTramite.findByCodigo("E001")
        def revisado = EstadoTramite.findByCodigo("E002")
        def enviado = EstadoTramite.findByCodigo("E003")
        def recibido = EstadoTramite.findByCodigo("E004")
        def para = RolPersonaTramite.findByCodigo("R001")
        def cc = RolPersonaTramite.findByCodigo("R002")

        def persona = Persona.get(session.usuario.id)
        def tramites = []
        def estados = [porEnviar, revisado, enviado, recibido]

        if (params.fecha) {
            params.fechaIni = new Date().parse("dd-MM-yyyy HH:mm:ss", params.fecha + " 00:00:00")
            params.fechaFin = new Date().parse("dd-MM-yyyy HH:mm:ss", params.fecha + " 23:59:59")
        }

        if (session.usuario.puedeEditor) {
            Persona.findAllByDepartamento(persona.departamento).each { p ->
                def t = Tramite.findAll("from Tramite where deDepartamento is null and de=${p.id} and estadoTramite in (${porEnviar.id},${revisado.id},${enviado.id},${recibido.id}) order by fechaCreacion desc")
                if (t.size() > 0) {
                    tramites += t
                }
            }
            def t = Tramite.findAllByDeDepartamentoAndEstadoTramiteInList(persona.departamento, estados, [sort: "fechaCreacion", order: "desc"])
            if (t.size() > 0) {
                tramites += t
            }
        } else {
            tramites = Tramite.withCriteria {
                eq("de", persona)
                isNull("deDepartamento")
                inList("estadoTramite", estados)
                order("fechaCreacion", "desc")
            }
        }
        tramites?.sort { it.fechaCreacion }
        tramites = tramites?.reverse()

        def trams = []
        def trams2 = []

        tramites.each { tr ->
            def pdt = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInList(tr, [para, cc])
            def agrega = false
            def paraRecibio = false

            pdt.each { pd ->

                if (!pd.fechaRecepcion && pd.estado?.codigo != "E006" && pd.estado?.codigo != "E005") {
                    //No esta anulado ni archivado
                    //ORIGINAL: muestra todos los por enviar, enviados, recibidos si al menos un receptor falta por recibir
                    if (!trams.contains(tr)) {
                        trams += tr
                    }
                } else {
                }
            }
        }
        def res = PersonaDocumentoTramite.withCriteria {
            if (params.fecha) {
                ge('fechaEnvio', params.fechaIni)
                le('fechaEnvio', params.fechaFin)
            }

            tramite {
                if (params.asunto) {
                    ilike('asunto', '%' + params.asunto + '%')
                }
                if (params.memorando) {
                    ilike('codigo', '%' + params.memorando + '%')
                }
                order("fechaCreacion", "desc")
            }

        }

        return [tramites: res.tramite.unique(), pxtTramites: trams]
    }

    def verRezagados() {
        def dep = session.departamento
        def tramites = []
        def ahora = new Date()
        PersonaDocumentoTramite.findAll("from PersonaDocumentoTramite  where fechaEnvio is not null and fechaRecepcion is null and departamento=${dep.id} and persona is null and rolPersonaTramite not in (4,5) order by fechaEnvio ").each { pdt ->
            def fechaBloqueo = pdt.tramite.fechaBloqueo
            if (fechaBloqueo && fechaBloqueo < ahora) {
                if (!tramites.tramite.id.contains(pdt.tramite.id)) {
                    println "add tramites " + pdt
                    tramites.add(pdt)
                }
            }
        }
        return [tramites: tramites]
    }

    def verRezagadosUsu() {
        def tramites = []
        def ahora = new Date()
        PersonaDocumentoTramite.findAll("from PersonaDocumentoTramite  where fechaEnvio is not null and fechaRecepcion is null and persona=${session.usuario.id} and rolPersonaTramite not in (4,5)  order by fechaEnvio").each { pdt ->
            println "pdt " + pdt.id + "  bloq " + pdt.tramite.fechaBloqueo
            def fechaBloqueo = pdt.tramite.fechaBloqueo
            if (fechaBloqueo && fechaBloqueo < ahora) {
                println "add tramites pdt " + pdt.id
                tramites.add(pdt)
            }
        }
        return [tramites: tramites]
    }


    def crearTramiteDep() {
        def pruebasInicio = new Date()
        def pruebasFin
        if (params.padre) {  // contestar documento
            def padre = Tramite.get(params.padre)

            //Verifico que no tenga otras contestaciones: 1 sola respuesta por tramite (18/02/2015)
            def tramitesHijos = Tramite.countByPadre(padre)

            if (params.pdt) {
                def aQuienEstaContestando = PersonaDocumentoTramite.get(params.pdt)


                if (aQuienEstaContestando == null) {
                    flash.message = "No se puede contestar este documento.<br/>" +
                            g.link(controller: 'tramite3', action: 'bandejaEntradaDpto', class: "btn btn-danger") {
                                "Volver a la bandeja de entrada"
                            }
                    redirect(controller: 'tramite', action: "errores")
                    return
                }

                if (params.esRespuestaNueva == 'S') {
                    def respv = aQuienEstaContestando.respuestasVivasEsrn
                    if (respv.size() != 0) {
                        flash.message = "Ya ha realizado una respuesta a este trámite, no puede crear otra.<br/>" +
                                g.link(controller: 'tramite3', action: 'bandejaEntradaDpto', class: "btn btn-danger") {
                                    "Volver a la bandeja de entrada"
                                }
                        redirect(controller: 'tramite', action: "errores")
                        return
                    }
                }
            }
        }

        params.esRespuesta = params.esRespuesta ?: 0
        if (!session.usuario.esTriangulo()) {
            flash.message = "Su perfil (${session.perfil}), no tiene permiso para entrar a esta pantalla"
            response.sendError(403)
        }

//        println("size" + session.usuario.tiposDocumento.size())
        if (session.usuario.tiposDocumento.size() == 0) {
            flash.message = "No puede crear ningún tipo de documento. Contáctese con el administrador."
            redirect(controller: 'tramite', action: "errores")
            return
        }

        def anio = Anio.findAllByNumeroAndEstado(new Date().format("yyyy"), 1, [sort: "id"])
        if (anio.size() == 0) {
            flash.message = "El año ${new Date().format('yyyy')} no está activo, no puede crear trámites nuevos. Contáctese con el administrador."
            redirect(controller: 'tramite', action: "errores")
            return
        } else if (anio.size() > 1) {
            println "HAY MAS DE 1 ANIO ${new Date().format('yyyy')}!!!!!: ${anio}"
        }

        if (anio.findAll { it.estado == 1 }.size() == 0) {
            flash.message = "El año ${new Date().format('yyyy')} no está activado, no puede crear trámites nuevos. Contáctese con el administrador."
            redirect(controller: 'tramite', action: "errores")
            return
        }

        def dias = DiaLaborable.countByAnio(anio.first())
        if (dias < 365) {
            flash.message = "No se encontraron los registros de días laborables del año ${new Date().format('yyyy')}, no puede crear trámites nuevos. Contáctese con el administrador."
            redirect(controller: 'tramite', action: "errores")
            return
        }
        def tramitetr = Tramite.get(params.id)
        if (tramitetr) {
//            println("entro!")
            def paratr = tramitetr.para
            def copiastr = tramitetr.copias
            (copiastr + paratr).each { c ->
                if (c?.estado?.codigo == "E006") {
                    flash.message = "Este trámite ya ha sido enviado, no puede guardar modificaciones."
                    redirect(controller: 'tramite', action: "errores")
                    return
                } else {
                }
            }
        }

        def rolesNo = [RolPersonaTramite.findByCodigo("E004"), RolPersonaTramite.findByCodigo("E003")]
        def padre = null
        def cc = ""
        def principal = null
        def tramite = new Tramite(params)
        if (params.padre) {
            padre = Tramite.get(params.padre)
            principal = padre
            while (true) {
                if (!principal.padre) {
                    break
                } else {
                    principal = principal.padre
                }
            }
            if (params.pdt) {
                if (params.esRespuesta == 1 || params.esRespuesta == '1') {
                    def pdt = PersonaDocumentoTramite.get(params.pdt)
                    def hijos = Tramite.findAllByAQuienContestaAndEstadoNotEqual(pdt, EstadoTramite.findByCodigo("E006"))
                    def tiene = false
                    hijos.each { h ->
                        PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInList(h, [RolPersonaTramite.findByCodigo("E001"), RolPersonaTramite.findByCodigo("E002")]).each { pq ->
                            if (pq.estado?.codigo != "E006") {
                                tiene = true
                            }
                        }
                    }
                    if (tiene) {
                        flash.message = "Ya ha realizado una respuesta a este trámite."
                        redirect(controller: 'tramite', action: "errores")
                        return
                    }
                }
            }
        }

        if (params.id) {
            tramite = Tramite.get(params.id)
            padre = tramite.padre
            principal = padre
            if (principal) {
                while (true) {
                    if (!principal.padre) {
                        break
                    } else {
                        principal = principal.padre
                    }
                }
            }
            (tramite.copias).each { c ->
                if (cc != '') {
                    cc += "_"
                }
                if (c.departamento) {
                    cc += ("-" + c.departamentoId)
                } else {
                    cc += c.personaId
                }
            }
        } else {
            tramite.fechaCreacion = new Date()
        }

        def persona = session.usuario
        def esTriangulo = session.usuario.esTriangulo
        def de = session.usuario
        def todos = []

        def sql = "SELECT id, dscr as label, externo FROM trmt_para(${session.usuario.id}, ${session.perfil.id})"
        def cn = dbConnectionService.getConnection()
        todos = cn.rows(sql.toString())

        def bloqueo = false
        if (session.departamento.estado == "B") {
            bloqueo = true
        }

        def pdt = null
        if (params.pdt) {

            pdt = params.pdt
            def pdto = PersonaDocumentoTramite.get(pdt)
            if (pdto.estado?.codigo != "E004") {
                flash.message = "No puede responder a este tramite puesto que ha sido anulado, archivado o no ha sido recibido"
                response.sendError(403)
            }
        } else if (params.hermano) {

            // println("entro hermano")

            def herm = Tramite.get(params.hermano)
            def p = herm
            padre = p
            pdt = p.para
            padre = herm.padre

            println "Hermano: " + herm
            tramite.agregadoA = herm

            if (!padre) {
                padre = herm
                println "en realidad es padre..."
                def rolPara = RolPersonaTramite.findByCodigo("R001")
                def quienRecibePadre = PersonaDocumentoTramite.withCriteria {
                    eq("tramite", padre)
                    eq("rolPersonaTramite", rolPara)
                }
                if (quienRecibePadre.size() == 1) {
                    pdt = quienRecibePadre.first()
                    println "PDT 1: " + pdt
                } else {
                    flash.message = "No puede agregar un documento a este tramite."
                    response.sendError(403)
                    return
                }
            } else {
                println "PDT 2: " + pdt
                pdt = herm.aQuienContesta
            }
            if (!pdt) {
                pdt = p.copias
                if (pdt.size() == 0) {
                    flash.message = "No puede agregar un documento a este tramite."
                    response.sendError(403)
                    return
                } else {
                    pdt = pdt[0]
                }
            }
            if (pdt.estado?.codigo == "E006") {
                flash.message = "No puede agregar un tramite a un documento anulado"
                response.sendError(403)
            } else {
                pdt = pdt.id
            }

        }
        tramite.tramitePrincipal = 0

//        println "de: " + de
//        println "padre: " + padre
//        println "principal: " + principal
//        println "disponibles: " + todos
//        println "tramite: " + tramite
//        println "bloqueo: " + bloqueo
//        println "cc: " + cc
//        println "rolesNo: " + rolesNo
//        println "pxt: " + pdt
//        println "params: " + params

        if (tramite.id && tramite.esRespuestaNueva) {
            params.esRespuestaNueva = tramite.esRespuestaNueva
        }

        /** Elimina de Disponiles las copias **/
        if(tramite.id) {
            tramite.copias.each { prtr ->

                if(prtr.persona) {
                    if(todos.find { it.id == prtr.persona.id}) {
                        todos -= todos.find { it.id == prtr.persona.id}
                    }
                } else {
                    if(todos.find { it.id == -prtr.departamento.id}) {
                        todos -= todos.find { it.id == -prtr.departamento.id}
                    }
                }
            }
        }


        return [de     : de, padre: padre, principal: principal, disponibles: todos, tramite: tramite,
                bloqueo: bloqueo, cc: cc, rolesNo: rolesNo, pxt: pdt, params: params]
    }

    def saveDep() {
//        println("params save dep " + params)

        params.tramite.asunto = params.tramite.asunto.decodeHTML()
        params.tramite.asunto = params.tramite.asunto.replaceAll(/</, /&lt;/)
        params.tramite.asunto = params.tramite.asunto.replaceAll(/>/, /&gt;/)

        def ccLista = []
        if (params.tramite.hiddenCC) {
            params.tramite.hiddenCC.split("_").each { ccl ->
                if (ccl.toInteger() > 0) {
                    ccLista += (Persona.get(ccl).nombre + " " + Persona.get(ccl).apellido)
                } else {
                    ccLista += (Departamento.get(ccl.toInteger() * -1).descripcion)
                }

            }
        }

        if (params.tramite.esRespuestaNueva == 'S' && params.tramite.aQuienContesta.id) {
            def aa = PersonaDocumentoTramite.get(params.tramite.aQuienContesta.id)
            if (aa?.estado?.codigo == 'E003' || aa?.estado?.codigo == 'E005' || aa?.estado?.codigo == 'E006') {
                flash.tipo = "error"
                flash.message = "Ha ocurrido un error al grabar el tramite"
                redirect(controller: 'tramite3', action: "bandejaEntradaDpto")
                return
            }
        }

        def persona = Persona.get(session.usuario.id)
        def estadoTramiteBorrador = EstadoTramite.findByCodigo("E001");
        def aqc
        def paramsTramite = params.remove("tramite")

        if (paramsTramite.aQuienContesta.id) {
            def aQuienEstaContestando = PersonaDocumentoTramite.get(paramsTramite.aQuienContesta.id)

            if (aQuienEstaContestando == null) {

                flash.message = "No se puede contestar este documento.<br/>" +
                        g.link(controller: 'tramite3', action: 'bandejaEntradaDpto', class: "btn btn-danger") {
                            "Volver a la bandeja de entrada"
                        }
                redirect(controller: 'tramite', action: "errores")
                return
            }

            if (paramsTramite.esRespuestaNueva == 'S') {
                def respv = aQuienEstaContestando.respuestasVivasEsrn
                if (respv.size() != 0) {
                    flash.message = "Ya ha realizado una respuesta a este trámite, no puede crear otra.<br/>" +
                            g.link(controller: 'tramite3', action: 'bandejaEntradaDpto', class: "btn btn-danger") {
                                "Volver a la bandeja de entrada"
                            }
                    redirect(controller: 'tramite', action: "errores")
                    return
                }
            }
        }

        def tipoTramite
        if (params.confi == "on") {
            tipoTramite = TipoTramite.findByCodigo("C")
        } else {
            tipoTramite = TipoTramite.findByCodigo("N")
        }
        paramsTramite.tipoTramite = tipoTramite
        if (params.anexo == "on") {
            paramsTramite.anexo = 1
        } else {
            paramsTramite.anexo = 0
        }
        if (params.externo == "on") {
            paramsTramite.externo = 1
        } else {
            paramsTramite.externo = 0
        }

        if (paramsTramite.externo == '1' || paramsTramite.externo == 1) {
            paramsTramite.estadoTramiteExterno = EstadoTramiteExterno.findByCodigo("EX03") //pendiente
        }

        if (params.paraExt) {
            paramsTramite.paraExterno = params.paraExt
        } else {
            paramsTramite.paraExterno = null
        }
        if (params.paraExt2) {
            paramsTramite.paraExterno = params.paraExt2
        }
        //println "PARAMS TRAM: " + paramsTramite
        def tipoDocParaExterno = TipoDocumento.get(paramsTramite["tipoDocumento.id"])
        if (paramsTramite.id) {
            tipoDocParaExterno = Tramite.get(paramsTramite.id).tipoDocumento
        }
        if (tipoDocParaExterno.codigo == "DEX") {
            paramsTramite.paraExterno = params.paraExt3
        }

//        paramsTramite.de = persona
        paramsTramite.deDepartamento = persona.departamento
        paramsTramite.deDepartamento.id = persona.departamento.id
        paramsTramite.estadoTramite = estadoTramiteBorrador
        if (paramsTramite.id) {
            paramsTramite.fechaModificacion = new Date()
        } else {

            paramsTramite.fechaCreacion = new Date()
            paramsTramite.anio = Anio.findByNumero(paramsTramite.fechaCreacion.format("yyyy"))
            def num = 1
            Numero objNum
            def numero = Numero.withCriteria {
                eq("departamento", persona.departamento)
                eq("tipoDocumento", TipoDocumento.get(paramsTramite.tipoDocumento.id))
                order("valor", "desc")
            }
            if (numero.size() == 0) {
                objNum = new Numero([
                        departamento : persona.departamento,
                        tipoDocumento: TipoDocumento.get(paramsTramite.tipoDocumento.id)
                ])
            } else {
                objNum = numero.first()
                num = objNum.valor + 1
            }
            objNum.valor = num
            if (!objNum.save(flush: true)) {
                println "Error al crear Numero: " + objNum.errors
            }
            paramsTramite.numero = num
            paramsTramite.codigo = TipoDocumento.get(paramsTramite.tipoDocumento.id).codigo + "-" + num + "-" + persona.departamento.codigo + "-" + paramsTramite.anio.numero[2..3]

        }
        def tramite
        def error = false
        if (paramsTramite.id) {
            tramite = Tramite.get(paramsTramite.id)
        } else {
            tramite = new Tramite()
            if (paramsTramite.aQuienContesta.id) {
                if (paramsTramite.esRespuesta == 1 || paramsTramite.esRespuesta == '1') {
                    def pdt = PersonaDocumentoTramite.get(paramsTramite.aQuienContesta.id)
                    def hijos = Tramite.findAllByAQuienContestaAndEstadoNotEqual(pdt, EstadoTramite.findByCodigo("E006"))
                    def tiene = false
                    hijos.each { h ->
                        PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInList(h, [RolPersonaTramite.findByCodigo("E001"), RolPersonaTramite.findByCodigo("E002")]).each { pq ->
                            if (pq.estado?.codigo != "E006") {
                                tiene = true
                            }
                        }
                    }
                    if (tiene) {
                        flash.message = "Ya ha realizado una respuesta a este trámite."
                        redirect(controller: 'tramite', action: "errores")
                        return
                    }
                }
            }
        }

        tramite.properties = paramsTramite
        if (tramite.tipoDocumento.codigo == "DEX") {

            tramite.estadoTramiteExterno = EstadoTramiteExterno.findByCodigo("E001")
            if(params.aip == 'on'){
                tramite.aip = 'S'
            }else{
                tramite.aip = 'N'
            }
        }

        tramite.departamento = persona.departamento

        //log persona creador
        tramite.creador = persona
        tramite.login = persona.login
        tramite.persona = persona.nombre + " " + persona.apellido
        tramite.departamentoNombre = persona.departamento.descripcion
        tramite.departamentoSigla = persona.departamento.codigo
        tramite.textoPara = params?.textoPara

        if (ccLista.size() > 0) {
            tramite.texto = tramite.texto ?: ''
            tramite.texto += '<p></p>'
            tramite.texto += "[cc]: "

            ccLista.each { n ->
                tramite.texto += n

                if (n != ccLista.last()) {
                    tramite.texto += ' - '
                }

            }
        }

        if (!tramite.save(flush: true)) {
            println "error save tramite " + tramite.errors
            flash.tipo = "error"
            flash.message = "Ha ocurrido un error al grabar el tramite, por favor, verifique la información ingresada"
            redirect(controller: "tramite2", action: "crearTramiteDep", id: tramite.id)
            return
        } else {

            if (tramite.padre) {
                tramite.padre.estado = "C"
                tramite.aQuienContesta = PersonaDocumentoTramite.get(paramsTramite.aQuienContesta.id)
                if (tramite.aQuienContesta == null) {
                    tramite.aQuienContesta = aqc
                } else {
                    aqc = tramite.aQuienContesta
                }
                tramite.padre.save(flush: true)
                if (tramite.padre.estadoTramiteExterno) {
                    tramite.estadoTramiteExterno = tramite.padre.estadoTramiteExterno

                }
                tramite.save(flush: true)
            } else {
                //si no tiene padre, es create y no llegó parámetro de trámite principal
                // ponerle el numero de tramite principal
                if (!paramsTramite.id && (!paramsTramite.tramitePrincipal || paramsTramite.tramitePrincipal.toString() == "0")) {
                    tramite.tramitePrincipal = tramite.id
                    tramite.save(flush: true)
                }
            }

            /*
             * para/cc: si es negativo el id > es a la bandeja de entrada del departamento
             *          si es positivo es una persona
             */
            if (paramsTramite.para || tramite.tipoDocumento.codigo == "OFI") {
                def rolPara = RolPersonaTramite.findByCodigo('R001')
                def para
                if (paramsTramite.para) {
                    para = paramsTramite.para.toInteger()
                } else {
                    para = session.usuario.departamento.id.toInteger() * -1
                }
                def paraDocumentoTramite = PersonaDocumentoTramite.withCriteria {
                    eq("tramite", tramite)
                    eq("rolPersonaTramite", rolPara)
                }
                if (paraDocumentoTramite.size() == 0) {
                    paraDocumentoTramite = new PersonaDocumentoTramite()
                    paraDocumentoTramite.tramite = tramite //******
                    paraDocumentoTramite.rolPersonaTramite = rolPara
                } else if (paraDocumentoTramite.size() == 1) {
                    paraDocumentoTramite = paraDocumentoTramite.first()
                } else {
                    paraDocumentoTramite.each {
                        it.delete(flush: true)
                    }
                    paraDocumentoTramite = new PersonaDocumentoTramite()
                    paraDocumentoTramite.tramite = tramite //*****
                    paraDocumentoTramite.rolPersonaTramite = rolPara
                }
                if (para > 0) {
                    //persona
                    paraDocumentoTramite.persona = Persona.get(para)
                    paraDocumentoTramite.departamentoPersona = Persona.get(para).departamento
                    paraDocumentoTramite.departamento = null

                    paraDocumentoTramite.personaSigla = paraDocumentoTramite.persona.login
                    paraDocumentoTramite.personaNombre = paraDocumentoTramite.persona.nombre + " " + paraDocumentoTramite.persona.apellido
                    paraDocumentoTramite.departamentoNombre = paraDocumentoTramite.persona.departamento.descripcion
                    paraDocumentoTramite.departamentoSigla = paraDocumentoTramite.persona.departamento.codigo
                    paraDocumentoTramite.personaSigla = paraDocumentoTramite.persona.login
                } else {
                    //departamento
                    paraDocumentoTramite.persona = null
                    paraDocumentoTramite.departamento = Departamento.get(para * -1)

                    paraDocumentoTramite.departamentoNombre = paraDocumentoTramite.departamento.descripcion
                    paraDocumentoTramite.departamentoSigla = paraDocumentoTramite.departamento.codigo
                }
                if (!paraDocumentoTramite.save(flush: true)) {
                    println "error para: " + paraDocumentoTramite.errors
                }
            } else {
                def paraOld = PersonaDocumentoTramite.withCriteria {
                    eq("tramite", tramite)
                    eq("rolPersonaTramite", RolPersonaTramite.findByCodigo('R001'))
                }
                if (paraOld.size() > 0) {
                    println "Habian ${paraOld.size()} paras que fueron borrados"
                    paraOld.each {
                        it.delete(flush: true)
                    }
                }
            }
            def rolCc = RolPersonaTramite.findByCodigo('R002')

            PersonaDocumentoTramite.withCriteria {
                eq("tramite", tramite)
                eq("rolPersonaTramite", rolCc)
            }.each {
                it.delete(flush: true)
            }
            if (paramsTramite.hiddenCC.toString().size() > 0) {
                (paramsTramite.hiddenCC.split("_")).each { cc ->
                    def ccDocumentoTramite = new PersonaDocumentoTramite()
                    ccDocumentoTramite.tramite = tramite
                    ccDocumentoTramite.rolPersonaTramite = rolCc
                    if (cc.toInteger() > 0) {
                        //persona
                        ccDocumentoTramite.persona = Persona.get(cc.toInteger())
                        ccDocumentoTramite.departamentoPersona = Persona.get(cc.toInteger()).departamento

                        ccDocumentoTramite.personaSigla = ccDocumentoTramite.persona.login
                        ccDocumentoTramite.personaNombre = ccDocumentoTramite.persona.nombre + " " + ccDocumentoTramite.persona.apellido
                        ccDocumentoTramite.departamentoNombre = ccDocumentoTramite.persona.departamento.descripcion
                        ccDocumentoTramite.departamentoSigla = ccDocumentoTramite.persona.departamento.codigo
                        ccDocumentoTramite.personaSigla = ccDocumentoTramite.persona.login
                    } else {
                        //departamento
                        ccDocumentoTramite.departamento = Departamento.get(cc.toInteger() * -1)

                        ccDocumentoTramite.departamentoNombre = ccDocumentoTramite.departamento.descripcion
                        ccDocumentoTramite.departamentoSigla = ccDocumentoTramite.departamento.codigo
                    }
                    if (!ccDocumentoTramite.save(flush: true)) {
                        println "error cc: " + ccDocumentoTramite.errors
                    }
                }
            }
            def tipoDoc
            if (paramsTramite.id) {
                tipoDoc = tramite.tipoDocumento
            } else {
                tipoDoc = TipoDocumento.get(paramsTramite.tipoDocumento.id)
            }
            def externos = ["DEX", "OFI"]
            if (externos.contains(tramite.tipoDocumento.codigo)) {
                tramite.externo = '1'
                tramite.save(flush: true)
            } else {
                def paraFinal = PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(tramite, RolPersonaTramite.findByCodigo('R001'))
                if (paraFinal) {
                    if (paraFinal.departamento) {
                        if (paraFinal.departamento.externo == 1) {
                            paraFinal.tramite.externo = "1"
                            paraFinal.tramite.save(flush: true)
                        } else {
                            paraFinal.tramite.externo = "0"
                            paraFinal.tramite.save(flush: true)
                        }
                    } else {
                        if (paraFinal.persona) {
                            if (paraFinal.persona.departamento.externo == 1) {
                                paraFinal.tramite.externo = "1"
                                paraFinal.tramite.save(flush: true)
                            } else {
                                paraFinal.tramite.externo = "0"
                                paraFinal.tramite.save(flush: true)
                            }
                        }
                    }
                }


            }
            if (tipoDoc.codigo == "DEX") {
                //aqui envia y recibe automaticamente el tramite
                def ahora = new Date();
                def rolEnvia = RolPersonaTramite.findByCodigo("E004")
                def rolRecibe = RolPersonaTramite.findByCodigo("E003")
                def rolPara = RolPersonaTramite.findByCodigo("R001")

                def estadoEnviado = EstadoTramite.findByCodigo('E003')
                def estadoRecibido = EstadoTramite.findByCodigo('E004')

                def pdt = new PersonaDocumentoTramite()
                pdt.tramite = tramite
                pdt.persona = persona
                pdt.departamento = persona.departamento

                pdt.personaSigla = persona.login
                pdt.personaNombre = persona.nombre + " " + persona.apellido
                pdt.departamentoNombre = persona.departamento.descripcion
                pdt.departamentoSigla = persona.departamento.codigo
                pdt.personaSigla = persona.login
                pdt.departamentoPersona = persona.departamento

                pdt.fechaEnvio = ahora
                pdt.rolPersonaTramite = rolEnvia
                if (!pdt.save(flush: true)) {
                    println "error al grabar prtr1" + pdt.errors
                }

                def pdt2 = new PersonaDocumentoTramite()
                pdt2.tramite = tramite
                pdt2.persona = persona
                pdt2.departamento = persona.departamento

                pdt2.personaSigla = persona.login
                pdt2.personaNombre = persona.nombre + " " + persona.apellido
                pdt2.departamentoNombre = persona.departamento.descripcion
                pdt2.departamentoSigla = persona.departamento.codigo
                pdt2.personaSigla = persona.login
                pdt2.departamentoPersona = persona.departamento
                pdt2.fechaEnvio = ahora
                pdt2.fechaRecepcion = ahora
                pdt2.rolPersonaTramite = rolRecibe
                if (!pdt2.save(flush: true)) {
                    println "error al grabar prtr2" + pdt2.errors
                }

                def pdtPara = PersonaDocumentoTramite.withCriteria {
                    eq("tramite", tramite)
                    eq("rolPersonaTramite", rolPara)
                }
                if (pdtPara.size() > 0) {
                    def limite = ahora
                    limite = diasLaborablesServiceOld.fechaMasTiempo(limite, tramite.prioridad.tiempo)
                    if (!limite) {
                        flash.message = "Ha ocurrido un error al calcular la fecha límite: " + limite
                        redirect(controller: 'tramite', action: 'errores')
                        return
                    }
                    if (pdtPara.size() > 1) {
                        println "Se encontraron varios pdtPara!! se utiliza el primero......."
                    }

                    pdtPara = pdtPara.first()
                    pdtPara.fechaEnvio = ahora
                    pdtPara.fechaRecepcion = ahora
                    pdtPara.fechaLimiteRespuesta = limite
                    pdtPara.estado = estadoRecibido

                    if (!pdtPara.save(flush: true)) {
                        println "error ala guardar pdtPara: " + pdtPara.errors
                    }
                }

                tramite.fechaEnvio = ahora
                tramite.estadoTramite = estadoRecibido
                if (tramite.aQuienContesta == null) {
                    tramite.aQuienContesta = aqc
                }
                if (!tramite.save(flush: true)) {
                    println "error al grabar trámite:" + tramite.errors
                }

                if (paramsTramite.esRespuestaNueva == "N") {
                    def observacionOriginalObs = tramite.observaciones
                    def accionObs = "Documento agregado al trámite " + tramite.agregadoA.codigo
                    def solicitadoPorObs = ""
                    def usuarioObs = "por " + session.usuario.login
                    def textoObs = ""
                    def nuevaObservacionObs = ""
                    tramite.observaciones = tramitesService.observaciones(observacionOriginalObs, accionObs, solicitadoPorObs, usuarioObs, textoObs, nuevaObservacionObs)
                    tramite.save(flush: true)
                }

                if (params.anexo == "on") {
                    redirect(controller: "documentoTramite", action: "anexo", id: tramite.id)
                    return
                } else {
                    redirect(controller: "tramite3", action: "bandejaEntradaDpto")
                    return
                }
            } else {
                if (tipoDoc.codigo != "OFI") {
                }
            }
        }

        if (paramsTramite.esRespuestaNueva == "N") {
            def observacionOriginalObs = tramite.observaciones
            def accionObs = "Documento agregado al trámite " + tramite.agregadoA.codigo
            def solicitadoPorObs = ""
            def usuarioObs = "por " + session.usuario.login
            def textoObs = ""
            def nuevaObservacionObs = ""
            tramite.observaciones = tramitesService.observaciones(observacionOriginalObs, accionObs, solicitadoPorObs, usuarioObs, textoObs, nuevaObservacionObs)
            tramite.save(flush: true)
        }

        if (tramite.tipoDocumento.codigo == "SUM" /*|| tramite.tipoDocumento.codigo == "DEX"*/) {
            redirect(controller: "tramite2", action: "bandejaSalidaDep", id: tramite.id)
            return
        } else {
            if (params.anexo == "on") {
                redirect(controller: "documentoTramite", action: "anexo", id: tramite.id)
                return
            } else {
                redirect(controller: "tramite", action: "redactar", id: tramite.id)
                return
            }
        }
    }

    //asignar permiso imprimir

    def permisoImprimir() {
        def persona = Persona.get(params.persona)
        def tramite = Tramite.get(params.id)
        def rolImprimir = RolPersonaTramite.findByCodigo('I005')
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estadoArchivado = EstadoTramite.findByCodigo("E005")

        if (tramite.para) {
            if (tramite.para?.estado == estadoAnulado || tramite.para?.estado == estadoArchivado) {
                render "er_El trámite se encuentra <strong>${tramite?.para?.estado?.descripcion}</strong>, no puede asignar el permiso de imprimir"
                return
            }
        }

        //antes de crear elimino los que existen
        def idsExisten = PersonaDocumentoTramite.withCriteria {
            eq("tramite", tramite)
            eq("rolPersonaTramite", rolImprimir)
        }

        if (idsExisten.size() > 0) {
            def ids = idsExisten.id
            ids.each { id ->
                def pdt = PersonaDocumentoTramite.get(id)
                pdt.delete(flush: true)
            }
        }

        //una vez eliminados los existentes creo el nuevo registro
        def personaDoc = new PersonaDocumentoTramite();

        personaDoc.tramite = tramite
        personaDoc.persona = persona
        personaDoc.personaSigla = personaDoc.persona.login
        personaDoc.personaNombre = personaDoc.persona.nombre + " " + personaDoc.persona.apellido
        personaDoc.departamentoNombre = personaDoc.persona.departamento.descripcion
        personaDoc.departamentoSigla = personaDoc.persona.departamento.codigo
        personaDoc.personaSigla = personaDoc.persona.login

        def observacionOriginal = personaDoc.observaciones
        def accion = "Asignación de permiso imprimir"
        def solicitadoPor = ""
        def usuario = session.usuario.login
        def texto = "Agregado permiso de imprimir a ${persona.login}"
        def nuevaObservacion = params.observaciones
        personaDoc.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
        observacionOriginal = personaDoc.tramite.observaciones
        personaDoc.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
        personaDoc.rolPersonaTramite = rolImprimir
        personaDoc.fechaEnvio = new Date()

        if (!personaDoc.save(flush: true)) {
            render "no_Ocurrió un error al otorgar el permiso"
        } else {
            //despues de otorgar el permiso de imprimir mando una alerta al usuario
            def alerta = new Alerta()
            alerta.persona = persona
            alerta.mensaje = session.usuario.nombre + " " + session.usuario.apellido + " le ha asignado permiso para imprimir el documento número " + tramite.codigo + ". Por favor revise su bandeja de documentos por imprimir."
            alerta.accion = "bandejaImprimir"
            alerta.controlador = "tramite3"
            alerta.fechaCreacion = new Date()
            alerta.tramite = tramite
            if (!alerta.save(flush: true)) {
                println "Error al mandar la alerta"
            }
            render "ok_Permiso de impresión otorgado correctamente"
        }
    }

    def busquedaBandejaSalidaDep() {

        def persona = Persona.get(session.usuario.id)
        def tramites = []
        def porEnviar = EstadoTramite.findByCodigo("E001")
        def revisado = EstadoTramite.findByCodigo("E002")
        def enviado = EstadoTramite.findByCodigo("E003")
        def recibido = EstadoTramite.findByCodigo("E004")
        def para = RolPersonaTramite.findByCodigo("R001")
        def cc = RolPersonaTramite.findByCodigo("R002")

        if (params.fecha) {
            params.fechaIni = new Date().parse("dd-MM-yyyy HH:mm:ss", params.fecha + " 00:00:00")
            params.fechaFin = new Date().parse("dd-MM-yyyy HH:mm:ss", params.fecha + " 23:59:59")
        }

        def trams = PersonaDocumentoTramite.withCriteria {
            if (params.fecha) {
                ge('fechaEnvio', params.fechaIni)
                le('fechaEnvio', params.fechaFin)
            }
            tramite {
                if (params.asunto) {
                    ilike('asunto', '%' + params.asunto + '%')
                }
                if (params.memorando) {
                    ilike('codigo', '%' + params.memorando + '%')
                }
                eq("deDepartamento", persona.departamento)
                inList("estadoTramite", [porEnviar, revisado, enviado, recibido])
                order("fechaCreacion", "desc")
            }
        }

        trams.tramite.each { tr ->
            def pdt = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInList(tr, [para, cc])
            def agrega = false
            def paraRecibio = false

            pdt.each { pd ->

                if (!pd.fechaRecepcion && pd.estado?.codigo != "E006" && pd.estado?.codigo != "E005") {
                    //No esta anulado ni archivado

                    def estaPorEnviar = pd.estado == null || (pd.estado && pd.estado.codigo == porEnviar.codigo)

                    if (!paraRecibio) {
                        agrega = true
                    }
                    if (estaPorEnviar) {
                        if (!paraRecibio) {
                            agrega = true
                        }
                    } else {
                        if (pd.rolPersonaTramite?.codigo == para.codigo && pd.estado?.codigo != enviado.codigo) {
                            agrega = false
                            paraRecibio = true
                        }
                    }
                } else {

                    if (pd.rolPersonaTramite?.codigo == para.codigo && pd.estado?.codigo != enviado.codigo) {
                        agrega = false
                        paraRecibio = true
                    }
                }

            }

            if (agrega) {
                tramites += tr
            }
        }

        return [tramites: tramites.unique()]
    }

    def confirmacion_ajax () {
        def destinatario
        def color = "#bf2523"

        def documento = TipoDocumento.get(params.tipo)

        if(params.ext){
            color = "#dF8C6C"
            destinatario = params.ext
        }else{
            switch(documento.descripcion){
                case 'ACTA':
                    color = "#76aed1"
                    break;
                case "CIRCULAR":
                    color = "#802020"
                    break;
                case "FORMULARIO HORAS EXTRAS":
                    color = "#ffbe4b"
                    break;
                case "INFORME":
                    color = "#2a2ed1"
                    break;
                case "INFORME HORAS EXTRAS":
                    color = "#88449e"
                    break;
                case "INGRESAR DOC. EXTERNO":
                    color = "#BF2523"
                    break;
                case "MEMORANDO":
                    color = "#407b89"
                    break;
                case "SOLICITUD DE MATERIALES":
                    color = "#47bFc2"
                    break;
                case "SUMILLA":
                    color = "#eF7055"
                    break;
            }

            if(params.para.contains("-")){
                def d = params.para.split("-")
                destinatario = Departamento.get(d[1])?.descripcion

            }else{
                destinatario = Persona.get(params.para).nombre + " " + Persona.get(params.para).apellido
            }
        }

        return[documento: documento, para: destinatario, asunto: params.asunto, color: color]
    }

    def revisarHijos () {
        def tramite = Tramite.get(params.id)
        def sql = "select * from trmt_cadena(${tramite?.id}) where edtr__id not in (9,5);"
        def cn = dbConnectionService.getConnection()
        def rows = cn.rows(sql.toString())

        if(rows.size() == 1){
            render "no"
        }else{
            render "ok"
        }
    }

    def observaciones_ajax(){
        def tramite = Tramite.get(params.id)
        return[tramite:tramite]
    }
}
