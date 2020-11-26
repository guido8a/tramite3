package tramites

import alertas.Alerta
import seguridad.Persona
import seguridad.Sesn


class TramiteAdminController{

    def tramitesService
    def dbConnectionService

    def redireccionarTramitesUI() {

    }

    def buscarPersonasRedireccionar() {
//        println "buscarPersonasRedireccionar ... $params"
        def nombre = params.nombre.trim() != "" ? params.nombre.trim() : null
        def apellido = params.apellido.trim() != "" ? params.apellido.trim() : null
        def user = params.user.trim() != "" ? params.user.trim() : null
        def resultado = []
        def band
        def rolPara = RolPersonaTramite.findByCodigo('R001');
        def rolCopia = RolPersonaTramite.findByCodigo('R002');
        def enviado = EstadoTramite.findByCodigo("E003")
        def recibido = EstadoTramite.findByCodigo("E004")
        def anulado = EstadoTramite.findByCodigo("E006")
        def data = [:]
        def personas
        def contador = 0
//        println "inicia busqueda de personas..."
        personas = Persona.withCriteria {
            if (nombre) {
                ilike("nombre", "%" + nombre + "%")
            }
            if (apellido) {
                ilike("apellido", "%" + apellido + "%")
            }
            if (user) {
                ilike("login", "%" + user + "%")
            }
            maxResults(10)
        }
//        println "fin busqueda de personas..."
        personas.each { pr ->
            contador = 0
            data = [:]
            data.persona = pr
            data.tieneTrmt = 0
            data.bandejaSalida = 0

            def sql = "SELECT count(*) cuenta FROM entrada_prsn($pr.id)"
            def cn = dbConnectionService.getConnection()
            data.tieneTrmt = cn.firstRow(sql.toString()).cuenta

            sql = "select count(*) cuenta FROM (select * from salida_prsn($pr.id) except select * from salida_dpto($pr.id)) as salida"
            data.bandejaSalida = cn.firstRow(sql.toString()).cuenta
//            println "data: ${data.tieneTrmt} y ${data.bandejaSalida}"

            resultado.add(data)
        }
        return [personas: resultado]
    }

    def asociarTramiteExterno_ajax() {
        def dep = Departamento.get(session.departamento.id)

        def codigo = params.codigo;
        def trmt = Tramite.get(params.original)
        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCc = RolPersonaTramite.findByCodigo("R002")
        def persDoc = PersonaDocumentoTramite.withCriteria {
            eq("tramite", trmt)
            inList("rolPersonaTramite", [rolPara, rolCc])
            eq("departamento", dep)
        }
        def msg = ""

        if (persDoc.size() == 1) {
            def original = persDoc.first()
            def tramites = Tramite.findAllByCodigoIlike(codigo)
            if (tramites.size() > 0) {
                def estadoArchivado = EstadoTramite.findByCodigo("E005")
                def estadoAnulado = EstadoTramite.findByCodigo("E006")
                def estadoEnviado = EstadoTramite.findByCodigo("E003")
                def estadoRecibido = EstadoTramite.findByCodigo("E004")

                msg = "<p>Seleccione el trámite al que se asociará <strong>${original.tramite.codigo}</strong> "
                msg += "(creado el ${original.fechaCreacion.format('dd-MM-yyyy HH:mm')}, asunto: <strong>${original.tramite.asunto}</strong>)</p>"
                msg += "<table class='table table-condensed table-bordered'>"
                msg += "<thead>"
                msg += "<tr>"
                msg += "<th>Trámite</th>"
                msg += "<th>De</th>"
                msg += "<th>Para</th>"
                msg += "<th>Info.</th>"
                msg += "<th>Seleccionar</th>"
                msg += "</tr>"
                msg += "</thead>"
                def algo = false
                tramites.each { tr ->
                    def cod = tr.codigo
                    def de = tr.deDepartamento ? tr.deDepartamento.codigo : tr.de.login
                    def asunto = tr.asunto

                    def personas = PersonaDocumentoTramite.withCriteria {
                        eq("tramite", tr)
                        or {
                            eq("rolPersonaTramite", rolPara)
                            eq("rolPersonaTramite", rolCc)
                        }
                        eq("estado", estadoRecibido)
                        tramite {
                            lt("fechaEnvio", original.tramite.fechaCreacion)
                        }
                    }
                    personas.each { cc ->
                        algo = true
                        msg += "<tr>"
                        msg += "<td>${cod}</td>"
                        msg += "<td>${de}</td>"
                        msg += "<td>${cc.rolPersonaTramite.descripcion} ${cc.departamento ? cc.departamento.codigo : cc.persona.login}</td>"
                        msg += "<td><strong>Asunto: ${asunto}</strong><br/>${tramiteFechas(cc)}</td>"
                        msg += "<td><a href='#' class='btn btn-success select' id='${cc.id}'><i class='fa fa-check'></i></a></td>"
                        msg += "</tr>"
                    }
                }
                msg += "</table>"

                msg += "<script type='text/javascript'>"
                msg += '$(function(){'
                msg += '$(".select").click(function() {'
                msg += "openLoader('Asociando trámites');"
                msg += '$.ajax({\n' +
                        '   type: "POST",\n' +
                        '   url: "' + createLink(controller: 'tramiteAdmin', action: 'guardarAsociarTramite') + '",\n' +
                        '   data: {\n' +
                        '\tid: $(this).attr("id"),\n' +
                        '\toriginal: ' + original.id + '\n' +
                        '\t},\n' +
                        '   success: function(msg){\n' +
                        '     location.reload(true);\n' +
                        '   }\n' +
                        ' });'
                msg += "return false;"
                msg += '});'
                msg += '});'
                msg += "</script>"

                if (!algo) {
                    msg = "<div class='alert alert-danger'>"
                    msg += "No se encontró un trámite con código " + codigo.toUpperCase() + " que cumpla las condiciones necesarias."
                    msg += "</div>"
                }

            } else {
                msg = "<div class='alert alert-danger'>"
                msg += "No se encontró un trámite disponible con código " + codigo.toUpperCase()
                msg += "</div>"
            }
        } else {
            msg = "<div class='alert alert-danger'>Ha ocurrido un error grave</div>"
            println "se encontraron ${persDoc.size()} personas doc tram: tramite: ${params.original}, PARA o COPIA el departamento ${dep.codigo} (${dep.id}); ${persDoc}"
        }
        render msg
    }

    def asociarTramite_ajax() {
        def original = PersonaDocumentoTramite.get(params.original)
        def duenioDep = original.tramite.deDepartamento
        def duenioPer = original.tramite.de
        def codigo = params.codigo;
        def msg
        def tramites = Tramite.findAllByCodigoIlike(codigo)
        if (tramites.size() == 0) {
            msg = "<div class='alert alert-danger'>"
            msg += "No se encontró un trámite disponible con código " + codigo.toUpperCase()
            msg += "</div>"
        } else {
            def rolPara = RolPersonaTramite.findByCodigo("R001")
            def rolCc = RolPersonaTramite.findByCodigo("R002")

            def estadoArchivado = EstadoTramite.findByCodigo("E005")
            def estadoAnulado = EstadoTramite.findByCodigo("E006")
            def estadoEnviado = EstadoTramite.findByCodigo("E003")
            def estadoRecibido = EstadoTramite.findByCodigo("E004")

            msg = "<p>Seleccione el trámite al que se asociará <strong>${original.tramite.codigo}</strong> "
            msg += "(creado el ${original.fechaCreacion.format('dd-MM-yyyy HH:mm')}, asunto: <strong>${original.tramite.asunto}</strong>)</p>"
            msg += "<table class='table table-condensed table-bordered'>"
            msg += "<thead>"
            msg += "<tr>"
            msg += "<th>Trámite</th>"
            msg += "<th>De</th>"
            msg += "<th>Para</th>"
            msg += "<th>Info.</th>"
            msg += "<th>Seleccionar</th>"
            msg += "</tr>"
            msg += "</thead>"
            def algo = false
            tramites.each { tr ->
                def hijosVivos = 0
                (Tramite.findAllByPadre(tr)).each { th ->
                    def prtrHijo = PersonaDocumentoTramite.withCriteria {
                        eq("tramite", th)
                        inList("rolPersonaTramite", [rolCc, rolPara])
                        ne("estado", estadoAnulado)
                    }
                    hijosVivos += prtrHijo.size()
                }
                if (hijosVivos == 0) {
                    def cod = tr.codigo
                    def de = tr.deDepartamento ? tr.deDepartamento.codigo : tr.de.login
                    def asunto = tr.asunto

                    def personas = PersonaDocumentoTramite.withCriteria {
                        eq("tramite", tr)
                        or {
                            eq("rolPersonaTramite", rolPara)
                            eq("rolPersonaTramite", rolCc)
                        }
                        eq("estado", estadoRecibido)
                        tramite {
                            lt("fechaEnvio", original.tramite.fechaCreacion)
                        }
                        if (duenioDep) {
                            eq("departamento", duenioDep)
                        } else if (duenioPer) {
                            eq("persona", duenioPer)
                        }
                    }
                    personas.each { cc ->
                        algo = true
                        msg += "<tr>"
                        msg += "<td>${cod}</td>"
                        msg += "<td>${de}</td>"
                        msg += "<td>${cc.rolPersonaTramite.descripcion} ${cc.departamento ? cc.departamento.codigo : cc.persona.login}</td>"
                        msg += "<td><strong>Asunto: ${asunto}</strong><br/>${tramiteFechas(cc)}</td>"
                        msg += "<td><a href='#' class='btn btn-success select' id='${cc.id}'><i class='fa fa-check'></i></a></td>"
                        msg += "</tr>"
                    }
                }
            }
            msg += "</table>"

            msg += "<script type='text/javascript'>"
            msg += '$(function(){'
            msg += '$(".select").click(function() {'
            msg += "openLoader('Asociando trámites');"
            msg += '$.ajax({\n' +
                    '   type: "POST",\n' +
                    '   url: "' + createLink(action: 'guardarAsociarTramite') + '",\n' +
                    '   data: {\n' +
                    '\tid: $(this).attr("id"),\n' +
                    '\toriginal: ' + params.original + '\n' +
                    '\t},\n' +
                    '   success: function(msg){\n' +
                    '     location.reload(true);\n' +
                    '   }\n' +
                    ' });'
            msg += "return false;"
            msg += '});'
            msg += '});'
            msg += "</script>"

            if (!algo) {
                msg = "<div class='alert alert-danger'>"
                msg += "No se encontró un trámite con código " + codigo.toUpperCase() + " que cumpla las condiciones necesarias."
                msg += "</div>"
            }
        }
        render msg
    }

    def guardarAsociarTramite() {
        def original = PersonaDocumentoTramite.get(params.original)
        def nuevoPadre = PersonaDocumentoTramite.get(params.id)

        original.tramite.padre = nuevoPadre.tramite
        original.tramite.aQuienContesta = nuevoPadre

        def nuevaObsPersDoc = "Asociado al trámite ${nuevoPadre.tramite.codigo}"
        def nuevaObsTram = "Trámite ${original.rolPersonaTramite.descripcion}"
        if (original.departamento) {
            nuevaObsTram += " el dpto. ${original.departamento.codigo}"
        } else if (original.persona) {
            nuevaObsTram += " el usuario ${original.persona.login}"
        }
        nuevaObsTram += " asociado al trámite ${nuevoPadre.tramite.codigo}"

        def observacionOriginal = original.observaciones
        def accion = "Asociación de trámite"
        def solicitadoPor = ""
        def usuario = session.usuario.login
        def texto = nuevaObsPersDoc
        def nuevaObservacion = ""
        original.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
        observacionOriginal = original.tramite.observaciones
        texto = nuevaObsTram
        original.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

        nuevoPadre.tramite.estado = "C"
        def msg = ""
        if (!original.save(flush: true)) {
            msg += renderErrors(bean: original)
        }
        if (!original.tramite.save(flush: true)) {
            msg += renderErrors(bean: original.tramite)
        }
        if (!nuevoPadre.tramite.save(flush: true)) {
            msg += renderErrors(bean: nuevoPadre.tramite)
        }
        if (msg != "") {
            msg = "NO*<ul>" + msg + "</ul>"
        } else {
            msg = "OK"
        }
        render msg
    }

    def copiaParaLista_ajax() {
        def tramite
        if (params.id) {
            def persDocTram = PersonaDocumentoTramite.get(params.id)
            tramite = persDocTram.tramite
        } else if (params.tramite) {
            tramite = Tramite.get(params.tramite)
        }
        def paraTramite = tramite.para
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadosNo = [estadoAnulado/*, estadoArchivado*/]

        if (!paraTramite) {
            if (tramite.copias.size() == 0) {
                return [tramite: tramite, error: "No puede crear copias"]
            }
        }

        if (estadosNo.contains(paraTramite?.estado)) {
            return [tramite: tramite, error: "El trámite se encuentra <strong>${paraTramite.estado.descripcion}</strong>, no puede crear copias"]
        } else {
            def de = tramite.de
            def deDep = tramite.deDepartamento
            def para = tramite.para
            def persona = Persona.get(session.usuario.id)

            def disp, disponibles = [], users = [], disp2 = [], todos = []

            def sql = "SELECT id, dscr as label, externo FROM trmt_para(${session.usuario.id}, ${session.perfil.id})"
            def cn = dbConnectionService.getConnection()
            todos = cn.rows(sql.toString())
//            println "crear copia... ok"

            def existen = []
            def borrar = []
            sql = "SELECT prsn__id, dpto__id from prtr where trmt__id = ${tramite.id} and rltr__id in (1,2)"
//            println "sql: $sql"
            cn.eachRow(sql.toString()){ d ->
                existen.add(d?.prsn__id?.toInteger() > 0 ? d.prsn__id : -d.dpto__id)
            }

            def aBorrar
            if(existen){
                existen.each { c ->
                    aBorrar = todos.find { it.id == c}
                    borrar.add(todos.find { it.id == c})
//                    println "existe: ${aBorrar}"
                }
            }

//            println "existen: $existen: ${borrar.label}"
//            println "todos: ${todos[1..10]}"
            todos = todos - borrar

            return [tramite: tramite, disponibles: todos]
        }
    }

    def enviarCopias_ajax() {
        def tramite
//        println "enviarCopias_ajax params $params -- trmt: ${tramite.id}"
        if (params.id) {
            def persDocTram = PersonaDocumentoTramite.get(params.id)
            tramite = persDocTram.tramite
        } else if (params.tramite) {
            tramite = Tramite.get(params.tramite)
        }
        def copias = params.copias.trim().split("_")

        def rolCopia = RolPersonaTramite.findByCodigo("R002")
        def estadoEnviado = EstadoTramite.findByCodigo("E003")
        def estadoPorEnviar = EstadoTramite.findByCodigo("E001")
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estadoArchivado = EstadoTramite.findByCodigo("E005")

        def errores = ""

        if (params.copias.trim() == "") {
            render "NO*" + "Tiene que seleccionar al menos una persona para enviar copia."
            return
        }

        if (tramite.para) {
            if (tramite.para?.estado == estadoAnulado /*|| tramite.para?.estado == estadoArchivado */ || tramite.para?.estado == estadoPorEnviar) {
                render "NO*" + "El trámite se encuentra <strong>${tramite.para?.estado.descripcion}</strong>, no puede crear copias"
                return
            }
        } else {
            if (tramite.copias.size() == 0) {
                render "NO*" + "No puede crear copias"
                return
            }
        }

        copias.each { copia ->
            copia = copia.trim()
            if (copia != "") {
                def id = copia.toInteger()
                def copiaPers = new PersonaDocumentoTramite()
                if (id > 0) {
                    copiaPers.persona = Persona.get(id)

                    copiaPers.personaSigla = copiaPers.persona.login
                    copiaPers.personaNombre = copiaPers.persona.nombre + " " + copiaPers.persona.apellido
                    copiaPers.departamentoNombre = copiaPers.persona.departamento.descripcion
                    copiaPers.departamentoSigla = copiaPers.persona.departamento.codigo
                } else {
                    copiaPers.departamento = Departamento.get(id * -1)

                    copiaPers.departamentoNombre = copiaPers.departamento.descripcion
                    copiaPers.departamentoSigla = copiaPers.departamento.codigo
                }
                copiaPers.fechaEnvio = new Date()
                copiaPers.tramite = tramite
                copiaPers.rolPersonaTramite = rolCopia
                copiaPers.estado = estadoEnviado

                if (!copiaPers.save(flush: true)) {
                    errores += "<li>" + renderErrors(bean: copiaPers) + "</li>"
                } else {
                    def alerta = new Alerta()
                    alerta.mensaje = "${session.departamento.codigo}:${session.usuario} te ha enviado un trámite."
                    if (copiaPers.persona) {
                        alerta.controlador = "tramite"
                        alerta.accion = "bandejaEntrada"
                        alerta.persona = copiaPers.persona
                    } else {
                        alerta.departamento = copiaPers.departamento
                        alerta.accion = "bandejaEntradaDpto"
                        alerta.controlador = "tramite3"
                    }
                    alerta.datos = copiaPers.id
                    alerta.tramite = copiaPers.tramite
                    if (!alerta.save(flush: true)) {
                        println "error save alerta " + alerta.errors
                    }
                }
            } else {

            }
        }
        if (errores == "") {
            render "OK"
        } else {
            render "NO*<ul>" + errores + "</ul>"
        }
    }

    def cambiarEstado() {
        def tramite = Tramite.get(params.id)
        return [params: params, tramite: tramite]
    }

    def guardarEstado() {

        def persDocTram = PersonaDocumentoTramite.get(params.prtr)
        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estadoEnviado = EstadoTramite.findByCodigo("E003")
        def estados = [estadoArchivado, estadoAnulado, estadoEnviado]

//        println("estado " + persDocTram.estado.codigo)

        if (estados.contains(persDocTram?.estado)) {
            render "NO*el trámite está ${persDocTram.estado.descripcion}, no puede cambiar el estado"
            return
        }

        def tramite = Tramite.get(params.id)
        def estado = EstadoTramiteExterno.get(params.estado)

        tramite.estadoTramiteExterno = estado

        if (tramite.save(flush: true)) {
            render "OK*Estado cambiado exitosamente"
        } else {
            render "NO*Ha ocurrido un error al cambiar de estado el trámite: " + renderErrors(bean: tramite)
        }
    }

    def redireccionarTramites() {


        println("-- " + params)

        def persona = Persona.get(params.id)

        if (!params.sort || params.sort == "") {
            params.sort = "trmtfcen"
        }
        if (!params.order || params.order == "" || params.order == null) {
            params.order = "DESC"
        }

        def sql = "SELECT * FROM entrada_prsn($persona.id) ORDER BY ${params.sort} ${params.order}"
//        println "redireccionar tram: $sql"
        def cn = dbConnectionService.getConnection()
        def rows = cn.rows(sql.toString())

        def personas
        def dep = persona.departamento
        def filtradas = []
        def sesion

        def fecha = new Date() - 10
        def fcha = fecha.format('yyyy-MM-dd')
        def deps


//        println "actual:  ${persona?.departamento?.id} antes: ${persona?.departamentoDesdeId}"
        if (persona?.departamento?.id == persona?.departamentoDesdeId) {
            if (persona.estaActivo) {
                personas = Persona.withCriteria {
                    eq("departamento", persona.departamento)
                    ne("id", persona.id)
                    order("apellido", "asc")
                }.findAll {
                    it.estaActivo
                }
            } else {
//                deps = Tramite.findAll("from Tramite where creador=${persona.id} and departamento != ${dep.id} order by id desc")
                deps = Tramite.findAll("from Tramite where creador=${persona} and departamento != ${dep} order by id desc")
//                deps = Tramite.withCriteria {
//                    eq("creador",persona)
//                    ne("departamento",dep)
//                }
                if (deps.size() > 0) {
                    dep = deps.departamento.first()
                }
                personas = Persona.withCriteria {
                    eq("departamento", dep)
                    ne("id", persona.id)
                    order("apellido", "asc")
                }.findAll {
                    it.estaActivo
                }
            }
            personas.each {
                sesion = Sesn.findAllByUsuario(it)
                if (it.esTriangulo() && sesion.size() == 1) {
                } else {
                    if (it.puedeRecibirOff) {
                        filtradas += it
                    }
                }
            }
        } else {
//            println ".....1"
            def depaDesde

//            deps = Tramite.findAll("from Tramite where creador=${persona.id} and departamento != ${dep.id} and fechaCreacion > '${fcha} 00:00' order by id desc")

            deps = Tramite.withCriteria {
                eq("creador",persona)
                ne("departamento",dep)
                gt("fechaCreacion",fecha)
            }

//            println "deps: ${deps.id}"
            if (deps.size() > 0) {
                if (persona?.departamentoDesde) {
                    depaDesde = persona.departamentoDesde
                } else {
                    depaDesde = persona.departamento
                }
            } else {
                depaDesde = dep
            }

            if (persona.estaActivo) {
                personas = Persona.withCriteria {
                    eq("departamento", depaDesde)
                    ne("id", persona.id)
                    order("nombre", "asc")
                }.findAll {
                    it.estaActivo
                }
            } else {
                /** si la persona cambia de departamento dos veces dentro de 10 días se produce error por que se
                 * direccionaría al personal del departamento de hace 10 días y no al inmediato anterior
                 */
//                println ".. no activo"
//                deps = Tramite.findAll("from Tramite where creador=${persona.id} and departamento != ${dep.id} and fechaCreacion > '${fcha} 00:00' order by id desc")
                deps = Tramite.withCriteria {
                    eq("creador",persona)
                    ne("departamento",dep)
                    gt("fechaCreacion",fecha)
                }
//                println "deps: ${deps.id}"
                if (deps.size() > 0) {
                    dep = deps.departamento.first()
                } else {
                    depaDesde = dep
                }
//                println "dpto: ${depaDesde.id}, dep: ${dep.id}"

                personas = Persona.withCriteria {
                    eq("departamento", depaDesde)
                    ne("id", persona.id)
                    order("nombre", "asc")
                }.findAll {
                    it.estaActivo
                }
            }
//            println "personas: ${personas.id}"
            personas.each {
                sesion = Sesn.findAllByUsuario(it)
                if (it.esTriangulo() && sesion.size() == 1) {
                } else {
                    if (it.puedeRecibirOff) {
                        filtradas += it
                    }
                }
            }
        }

        /** mostrar bandeja de salida personal **/
//        println "... es triángulo: ${persona.esTriangulo()}, id: ${persona.id}"
        def salida = cn.rows("select * from salida_prsn(${persona.id}) except select * from salida_dpto(${persona.id})".toString())

        return [persona: persona, rows: rows, personas: personas, dep: dep, filtradas: filtradas, salida: salida]
    }

    def redireccionarTramites_old() {
        def persona = Persona.get(params.id)

        def rolPara = RolPersonaTramite.findByCodigo('R001');
        def rolCopia = RolPersonaTramite.findByCodigo('R002');
        def rolImprimir = RolPersonaTramite.findByCodigo('I005')

        def estadoEnviado = EstadoTramite.findByCodigo("E003")
        def estadoRecibido = EstadoTramite.findByCodigo("E004")

        def tramites = PersonaDocumentoTramite.withCriteria {
            eq("persona", persona)
            or {
                eq("rolPersonaTramite", rolPara)
                eq("rolPersonaTramite", rolCopia)
            }
            or {
                eq("estado", estadoEnviado)
                eq("estado", estadoRecibido)
            }
            order("fechaEnvio", "desc")
        }
        tramites = tramites.findAll { Tramite.countByAQuienContesta(it) == 0 }
        def personas

        def dep = persona.departamento

        def filtradas = []
        def sesion

        if (persona?.departamento?.id == persona?.departamentoDesde) {

            if (persona.estaActivo) {
                personas = Persona.withCriteria {
                    eq("departamento", persona.departamento)
                    ne("id", persona.id)
                    order("apellido", "asc")
                }.findAll {
                    it.estaActivo
                }
            } else {
                def deps = Tramite.findAll("from Tramite where de=${persona.id} and departamento != ${dep.id} order by id desc")
                if (deps.size() > 0) {
                    dep = deps.departamento.first()
                }
                personas = Persona.withCriteria {
                    eq("departamento", dep)
                    ne("id", persona.id)
                    order("apellido", "asc")
                }.findAll {
                    it.estaActivo
                }
            }
            personas.each {
                sesion = Sesn.findAllByUsuario(it)
                if (it.esTriangulo() && sesion.size() == 1) {
                } else {
                    if (it.puedeRecibirOff) {
                        filtradas += it
                    }
                }
            }

        } else {

            def depaDesde

            if (persona?.departamentoDesde) {
                depaDesde = persona.departamentoDesde
            } else {
                depaDesde = persona.departamento
            }

            if (persona.estaActivo) {
                personas = Persona.withCriteria {
                    eq("departamento", depaDesde)
                    ne("id", persona.id)
                    order("apellido", "asc")
                }.findAll {
                    it.estaActivo
                }
            } else {
                def deps = Tramite.findAll("from Tramite where de=${persona.id} and departamento != ${dep.id} order by id desc")
                if (deps.size() > 0) {
                    dep = deps.departamento.first()
                }
                personas = Persona.withCriteria {
                    eq("departamento", depaDesde)
                    ne("id", persona.id)
                    order("apellido", "asc")
                }.findAll {
                    it.estaActivo
                }
            }
            personas.each {
                sesion = Sesn.findAllByUsuario(it)
                if (it.esTriangulo() && sesion.size() == 1) {
                } else {
                    if (it.puedeRecibirOff) {
                        filtradas += it
                    }
                }
            }
        }

        return [persona: persona, tramites: tramites, personas: personas, dep: dep, filtradas: filtradas]
    }

    // no es posible redireccionar trámites de departamento, solo entre personas y de persona a dpto
    def redireccionarTramite_ajax() {
        println "params: $params"
        def persona = Persona.get(params.id)
        def trmt = Tramite.get(params.pr)
        def redDpto = null, redPrsn = null
        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCopia = RolPersonaTramite.findByCodigo("R002")
        def rolImprime = EstadoTramite.findByCodigo("I005")
        def estadoAnulado = EstadoTramite.findByCodigo("E006")

        if (params.quien.toString().startsWith("-")) {
            redDpto = Departamento.get(params.quien.toInteger() * -1)
        } else {
            redPrsn = Persona.get(params.quien)
        }
        def pr = PersonaDocumentoTramite.findByTramiteAndPersonaAndRolPersonaTramiteInList(trmt, persona, [rolPara, rolCopia, rolImprime])
//        println "prtr... ${pr.id}"

        def errores = ""

        if (pr.rolPersonaTramite.codigo == "I005") {
            pr.delete(flush: true)
        } else {
            def obs = "Trámite antes dirigido a " + persona.nombre + " " + persona.apellido + ", redireccionado"

//            def personaAntes = pr.persona
            def dptoAntes = pr.departamento

            if (redDpto) {
                def prtrExisten = PersonaDocumentoTramite.withCriteria {
                    eq("tramite", pr.tramite)
                    eq("departamento", redDpto)
                    inList("rolPersonaTramite", [rolPara, rolCopia])
                }
                if (prtrExisten.size() == 0) {
                    pr.persona = null
                    pr.departamento = redDpto
                    obs += " al departamento ${pr.departamento.descripcion}"
                } else {
                    if (pr.rolPersonaTramiteId == rolCopia.id) {
                        //si es copia, la anulo
                        pr.estado = estadoAnulado
                        pr.fechaAnulacion = new Date()
                        obs = "Trámite anulado automáticamente al redireccionar debido a un duplicado en la bandeja receptora"
                    } else {
                        prtrExisten.each { prtrExiste ->
                            if (prtrExiste.rolPersonaTramiteId == rolCopia.id) {
                                prtrExiste.estado = estadoAnulado
                                prtrExiste.fechaAnulacion = new Date()
                                def obs1 = "Trámite anulado automáticamente al redireccionar debido a un duplicado en la bandeja receptora"
                                def observacionOriginal = prtrExiste.observaciones
                                def accion = "Redirección de trámite"
                                def solicitadoPor = ""
                                def usuario = session.usuario.login
                                def texto = obs1
                                def nuevaObservacion = ""
                                prtrExiste.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                                observacionOriginal = prtrExiste.tramite.observaciones
                                prtrExiste.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                                if (!prtrExiste.save(flush: true)) {
                                    println "ERROR AQUI: " + prtrExiste.errors
                                }
                                if (!prtrExiste.tramite.save(flush: true)) {
                                    println "ERROR AQUI3 : " + prtrExiste.tramite.errors
                                }
                            }
                        }
                        pr.persona = null
                        pr.departamento = redDpto
                        obs += " al departamento ${pr.departamento.descripcion}"
                    }
                }
            } else {
                println " redirecciona a persona: $redPrsn"
                def prtrExisten = PersonaDocumentoTramite.withCriteria {
                    eq("tramite", trmt)
                    eq("persona", redPrsn)
                    inList("rolPersonaTramite", [rolPara, rolCopia])
                }
                println "si existe otro: $prtrExisten"
                if (prtrExisten.size() == 0) {
                    println "no es repetido... ${redPrsn.class}"
                    pr.persona = redPrsn
                    obs += " al usuario ${pr?.persona?.login}"
                    println "actualizó prsn a ${pr.persona}"
                } else {
                    if (pr.rolPersonaTramiteId == rolCopia.id) {
                        //si es copia, la anulo
                        pr.estado = estadoAnulado
                        pr.fechaAnulacion = new Date()
                        obs = "Trámite anulado automáticamente al redireccionar debido a un duplicado en la bandeja receptora"
                    } else {
                        prtrExisten.each { prtrExiste ->
                            if (prtrExiste.rolPersonaTramiteId == rolCopia.id) {
                                prtrExiste.estado = estadoAnulado
                                prtrExiste.fechaAnulacion = new Date()
                                def obs1 = "Trámite anulado automáticamente al redireccionar debido a un duplicado en la bandeja receptora"
                                def observacionOriginal = prtrExiste.observaciones
                                def accion = "Redirección de trámite"
                                def solicitadoPor = ""
                                def usuario = session.usuario.login
                                def texto = obs1
                                def nuevaObservacion = ""
                                prtrExiste.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                                observacionOriginal = prtrExiste.tramite.observaciones
                                prtrExiste.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                                if (!prtrExiste.save(flush: true)) {
                                    println "ERROR AQUI2: " + prtrExiste.errors
                                }
                            }
                        }
                        pr.persona = redPrsn
                        obs += " al usuario ${pr.persona.login}"
                    }
                }
            }
//            def tramite = pr.tramite
            def observacionOriginal = pr.observaciones
            def accion = "Redirección de trámite"
            def solicitadoPor = ""
            def usuario = "por: " + session.usuario.login
            def texto = obs
            def nuevaObservacion = ""
            pr.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            observacionOriginal = trmt.observaciones
            trmt.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

            if (trmt.save(flush: true)) {
                println "tr.save ok, i: ${trmt.id}"
                if (!pr.persona && !pr.departamento) {
                    pr.persona = personaAntes
                    pr.departamento = dptoAntes
                    observacionOriginal = pr.observaciones
                    accion = ""
                    solicitadoPor = ""
                    usuario = ""
                    texto = "Redirección no efectuada a causa de un error."
                    nuevaObservacion = ""
                    pr.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                    observacionOriginal = trmt.observaciones
                    trmt.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                    if (trmt.save(flush: true)) {
                    }
                    errores += "<ul><li>Ha ocurrido un error al redireccionar.</li></ul>"
                }
                if (pr.save(flush: true)) {
                } else {
                    println pr.errors
                    errores += renderErrors(bean: pr)
                }
            }
            if (errores == "") {
                render "OK"
            } else {
                render errores
            }
        }
    }

    def arbolAdminTramite() {
        def html = "", url = "", tramite = null

        if (params.id) {
            def usu = Persona.get(session.usuario.id)
            def puedeAdministrar = session.usuario.puedeAdmin
            tramite = Tramite.get(params.id.toLong())
            if (tramite) {
                def principal = tramite
                if (tramite.padre) {
                    principal = tramite.padre
                    while (true) {
                        if (!principal.padre) {
                            break
                        } else {
                            principal = principal.padre
                        }
                    }
                }
                html = "<ul>" + "\n"
                html += makeTreeExtended(principal)
                html += "</ul>" + "\n"
            }
            url = createLink(controller: "buscarTramite", action: "busquedaTramite")
        }
        return [html2: html, url: url, tramite: tramite]
    }

    def arbolAdminTramiteParcial() {
        def html = "", url = "", tramite = null

        if (params.id) {
            def usu = Persona.get(session.usuario.id)
            def puedeAdministrar = session.usuario.puedeAdmin
            tramite = Tramite.get(params.id.toLong())
            if (tramite) {
                def principal = tramite
                html = "<ul>" + "\n"
                html += makeTreeExtended(principal)
                html += "</ul>" + "\n"
            }
            url = createLink(controller: "buscarTramite", action: "busquedaTramite")
        }
        return [html2: html, url: url, tramite: tramite]
    }

    def dialogAdmin() {
//        println("params quitar" + params)

        def tramite = Tramite.get(params.id)
        def personasRec = []

        if (params.cop == 'true') {

            def prtrCopia = PersonaDocumentoTramite.get(params.prtr)

            if (prtrCopia?.persona) {
                if (tramite?.departamento != prtrCopia.persona.departamento) {
                    Persona.findAllByDepartamento(prtrCopia?.persona?.departamento).each { rc ->
                        if (rc.estaActivo) {
                            def k = [:]
                            k.key = rc.nombre + " " + rc.apellido + " (funcionario de ${rc.departamento.codigo})"
                            k.value = rc.nombre + " " + rc.apellido + " (" + rc.login + " - " + rc.departamento.codigo + ")"
                            personasRec.add(k)
                        }
                    }
                }
            } else {
                if (tramite?.departamento != prtrCopia.departamento) {
                    Persona.findAllByDepartamento(prtrCopia?.departamento).each { rc ->
                        if (rc.estaActivo) {
                            def k = [:]
                            k.key = rc.nombre + " " + rc.apellido + " (funcionario de ${rc.departamento.codigo})"
                            k.value = rc.nombre + " " + rc.apellido + " (" + rc.login + " - " + rc.departamento.codigo + ")"
                            personasRec.add(k)
                        }
                    }
                }
            }
        } else {
            if (tramite?.departamento != tramite?.para?.departamento) {
                Persona.findAllByDepartamento(tramite.para?.departamento).each { r ->
                    if (r.estaActivo) {
                        def n = [:]
                        n.key = r.nombre + " " + r.apellido + " (funcionario de ${r.departamento.codigo})"
                        n.value = r.nombre + " " + r.apellido + " (" + r.login + " - " + r.departamento.codigo + ")"
                        personasRec.add(n)
                    }
                }
            }
        }

        def icon = params.icon
        def msg = params.msg
        def personas = []
        Persona.findAllByDepartamento(tramite.departamento).each { p ->
            if (p.estaActivo) {
                def m = [:]
                m.key = p.nombre + " " + p.apellido + " (funcionario de ${p.departamento.codigo})"
                m.value = p.nombre + " " + p.apellido + " (" + p.login + " - " + p.departamento.codigo + ")"
                personas.add(m)
            }
        }
        def todas = personas + personasRec
        todas = todas.sort { it.value }

        return [tramite: tramite, icon: icon, msg: msg, personas: todas]
    }

    def dialogAnulados() {

        def tramite = Tramite.get(params.id)
        def icon = params.icon
        def msg = params.msg
        def personas = []
        def dep = tramite.departamento
//        println "params: $params, dep: $dep"

        Persona.findAllByDepartamento(dep).each { p ->
            if (p.estaActivo) {
                def m = [:]
                m.key = p.nombre + " " + p.apellido + " (funcionario de ${p.departamento.codigo})"
                m.value = p.nombre + " " + p.apellido + " (" + p.login + ")"
                personas.add(m)
            }
        }

        def personasRec = []

        if (tramite?.departamento != tramite?.para?.departamento) {
            Persona.findAllByDepartamento(tramite.para?.departamento).each { r ->
                if (r.estaActivo) {
                    def n = [:]
                    n.key = r.nombre + " " + r.apellido + " (funcionario de ${r.departamento.codigo})"
                    n.value = r.nombre + " " + r.apellido + " (" + r.login + ")"
                    personasRec.add(n)
                }
            }
        }


        if(session.usuario.puedeAdmin){
            def admin = Persona.get(session.usuario.id)
            def s = [:]
            s.key = admin.nombre + " " + admin.apellido + " (administrador de ${admin.departamento.codigo})"
            s.value = admin.nombre + " " + admin.apellido + " (Administrador (${admin.login})  )"
            personas.add(s)
        }


        def todas = personas + personasRec
        todas = todas.sort { it.value }

//        println("--> " + todas)
//        println("personas Reciben " + personasRec)

        if(params.tipo == '1'){
            def soloUsuario = Persona.get(session.usuario.id)
            def n = [:]
            def filtrados = []
            n.key = soloUsuario.nombre + " " + soloUsuario.apellido + " (funcionario de ${soloUsuario.departamento.codigo})"
            n.value = soloUsuario.nombre + " " + soloUsuario.apellido + " (" + soloUsuario.login + ")"
            filtrados.add(n)
            todas = filtrados
        }

        return [tramite: tramite, icon: icon, msg: msg, personas: todas]

    }

    private String makeNewTreeExtended(Tramite principal) {
        def html = ""
        def tramitePrincipal = principal.tramitePrincipal
        //debe hacer un arbol para cada tramite que tenga tramite.tramitePrincipal = principal.tramitePrincipal
        def tramites
        if (tramitePrincipal > 0) {
            tramites = Tramite.findAllByTramitePrincipal(tramitePrincipal, [sort: "fechaCreacion"])
        } else {
            tramites = [principal]
        }

        tramites.each { p ->
            def type = "tramite"
            if (p.tramitePrincipal == p.id) {
                type += "Principal"
            }
            html += "<li id='t_${p.id}' class='jstree-open' data-jstree='{\"type\":\"${type}\"}' >"
            html += "<b>" + p.codigo + "</b>"
            html += "<ul>"
            html += makeTreeExtended(p)
            html += "</ul>"
        }

        return html
    }

    private String makeTreeExtended(Tramite principal) {
//        println "makeTreeExtended"
        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCc = RolPersonaTramite.findByCodigo("R002")

        def paras = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(principal, rolPara, [sort: "id"])
        def ccs = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(principal, rolCc, [sort: "id"])

        def html = ""

        //esto muestra una hoja por destinatario
        paras.each { para ->
            html += makeLeaf(para)
        }

        //el para y las copias son hermanos
        ccs.each { para ->
            html += makeLeaf(para)
        }
        return html
    }

    private String makeLeaf(PersonaDocumentoTramite pdt) {
        def html = "", clase = "para", rel = "para", data = ""
        if (pdt.rolPersonaTramite.codigo == "R002") {
            rel = "copia"
            clase = "copia"
        }
        clase += " t${pdt.tramite.id}"
        def hijos = Tramite.findAllByAQuienContesta(pdt, [sort: "fechaCreacion", order: "asc"])
        if (hijos.size() > 0) {
            clase += " jstree-open"
        }

        if (pdt.tramite.esRespuestaNueva == "N") {
            if (rel == "para") {
                data += ',"icon":"fa fa-clipboard text-success"'
            } else if (rel == "copia") {
                data += ',"icon":"fa fa-clipboard text-success"'
            }
        }

        def estado = ""
        if (pdt.fechaEnvio) {
            clase += " enviado"
            estado = "Enviado"
        }
        if (pdt.fechaRecepcion) {
            clase += " recibido"
            estado = "Recibido"
        }

        if (pdt.fechaArchivo) {
            clase += " archivado"
            estado = "Archivado"
        }

        if (pdt.fechaAnulacion) {
            clase += " anulado"
            estado = "Anulado"
        }

        if (pdt.tramite.estadoTramiteExterno) {
            clase += " externo"
        }
        if (pdt.tramite.tipoDocumento?.codigo == "CIR") {
            clase += " CIR"

        }
        rel += estado

        if (pdt.tramite.esRespuestaNueva != "S") {
            clase += " agregado"
        }

        def rol = pdt.rolPersonaTramite
        def duenioPrsn = pdt?.tramite?.de?.id
        def duenioDpto = pdt.tramite.deDepartamento?.id
        def paraStr = "Para: "
        if (rol.codigo == "R002") {
            paraStr = "CC: "
        }
        if (pdt.departamento) {
            paraStr += pdt.departamentoNombre
        } else if (pdt.persona) {
            paraStr += pdt.departamentoSigla + ":" + pdt.personaSigla
        }

//        println "paraStr: $paraStr"

        def deStr = "De: " + (pdt.tramite.deDepartamento ? pdt.tramite.departamentoSigla : pdt.tramite?.departamentoSigla + ":" + pdt.tramite.login)

        data += ',"tramite":"' + pdt.tramiteId + '"'
        data += ',"codigo":"' + pdt.tramite.codigo + '"'
        data += ',"de":"' + deStr + '"'
        data += ',"para":"' + paraStr + '"'
        if (pdt.tramite.padre) {
            data += ',"padre":"' + pdt.tramite.padreId + '"'
        }
        if (tramitesService.verificaHijos(pdt, EstadoTramite.findByCodigo("E006"))) {
            //false: no tiene hijos vivos
            clase += " tieneHijos"
        }
//        println "****** " + pdt.tramite + "   " + pdt.tramite.padre
        if (pdt.tramite.padre) {
            clase += " tienePadre"
        }

        if (duenioPrsn == session.usuario.id || duenioDpto == session.usuario.departamento.id) {
            clase += " esMio"
        }

        html += "<li id='${pdt.id}' class='${clase}' data-jstree='{\"type\":\"${rel}\"${data}}' >"
        html += tramiteInfo(pdt)
        html += "\n"
        if (hijos.size() > 0) {
            html += "<ul>" + "\n"
            hijos.each { hijo ->
                html += makeTreeExtended(hijo)
            }
            html += "</ul>" + "\n"
        }
        html += "</li>"
        return html
    }

    private static String tramiteFechas(PersonaDocumentoTramite tramiteParaInfo) {
        def strInfo = ""
        strInfo += "<strong>creado</strong> el " + tramiteParaInfo.tramite.fechaCreacion.format("dd-MM-yyyy HH:mm")
        def clase
        if (tramiteParaInfo.fechaEnvio) {
            clase = tramiteParaInfo.fechaAnulacion ? 'muted' : 'info'
            strInfo += ", <span class='text-${clase}'><strong>enviado</strong> el " + tramiteParaInfo.fechaEnvio.format("dd-MM-yyyy HH:mm") + "</span>"
        }
        if (tramiteParaInfo.fechaRecepcion) {
            clase = tramiteParaInfo.fechaAnulacion ? 'muted' : 'success'
            strInfo += ", <span class='text-${clase}'><strong>recibido</strong> el " + tramiteParaInfo.fechaRecepcion.format("dd-MM-yyyy HH:mm") + "</span>"
        }
        if (tramiteParaInfo.fechaArchivo) {
            clase = tramiteParaInfo.fechaAnulacion ? 'muted' : 'warning'
            strInfo += ", <span class='text-${clase}'><strong>archivado</strong> el " + tramiteParaInfo.fechaArchivo.format("dd-MM-yyyy HH:mm") + "</span>"
        }
        if (tramiteParaInfo.fechaAnulacion) {
            strInfo += ", <span class='text-muted'><strong>anulado</strong> el " + tramiteParaInfo.fechaAnulacion.format("dd-MM-yyyy HH:mm") + "</span>"
        }
        return strInfo
    }

    private static String tramiteInfo(PersonaDocumentoTramite tramiteParaInfo) {
        def paraStr, deStr
        if (tramiteParaInfo.tramite.tipoDocumento.codigo == "OFI") {
            paraStr = tramiteParaInfo.tramite.paraExterno + " (EXT)"
        } else {
            if (tramiteParaInfo.departamento) {
                paraStr = tramiteParaInfo.departamentoNombre
            } else if (tramiteParaInfo.persona) {
                paraStr = tramiteParaInfo.departamentoSigla + ":" + tramiteParaInfo.personaSigla
            } else {
                paraStr = ""
            }
        }
        if (tramiteParaInfo.tramite.tipoDocumento.codigo == "DEX") {
            deStr = tramiteParaInfo.tramite.paraExterno + " (EXT)"
        } else {
            deStr = tramiteParaInfo.tramite.deDepartamento ?
                    tramiteParaInfo.tramite.deDepartamento.codigo :
                    tramiteParaInfo.tramite.de.departamento.codigo + ":" + tramiteParaInfo.tramite.de.login
        }
        def rol = tramiteParaInfo.rolPersonaTramite
        def strInfo = ""
        if (tramiteParaInfo.fechaAnulacion) {
            strInfo += "<span class='text-muted'>"
        }
        if (rol.codigo == "R002") {
            strInfo += "[CC] "
        }
        strInfo += "<strong>${tramiteParaInfo.tramite.codigo} </strong>"
        strInfo += "<small>("
        strInfo += "<strong>DE</strong>: ${deStr}, <strong>${rol.descripcion}</strong>: ${paraStr}, "
        strInfo += tramiteFechas(tramiteParaInfo)
        strInfo += ")</small>"
        if (tramiteParaInfo.fechaAnulacion) {
            strInfo += "</span>"
        }
        if (tramiteParaInfo.tramite.estadoTramiteExterno) {
            strInfo += " - " + tramiteParaInfo.tramite.estadoTramiteExterno.descripcion
        }
        return strInfo
    }

    def desarchivar() {
        def persDocTram = PersonaDocumentoTramite.get(params.id)

        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estados = [estadoAnulado]

        if (estados.contains(persDocTram.estado)) {
            render "NO*el trámite está ${persDocTram.estado.descripcion}, no puede quitar el archivado"
        } else {
            def o = "Archivado originalmente el ${persDocTram.fechaArchivo.format('dd-MM-yyyy HH:mm')}"

            def observacionOriginal = persDocTram.observaciones
            def accion = "Reactivado"
            def solicitadoPor = params.aut
            def usuario = session.usuario.login
            def texto = o
            def nuevaObservacion = params.obs
            persDocTram.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            if (persDocTram.rolPersonaTramite.codigo == "R001") { //PARA
                def obs = "PARA "
                if (persDocTram.departamento) {
                    obs += "el dpto. ${persDocTram.departamento.codigo}"
                } else if (persDocTram.persona) {
                    obs += "el usuario ${persDocTram.persona.login}"
                }
                obs += ", " + o
                observacionOriginal = persDocTram.tramite.observaciones
                texto = obs
                persDocTram.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            } else if (persDocTram.rolPersonaTramite.codigo == "R002") { //CC
                def obs = "COPIA para "
                if (persDocTram.departamento) {
                    obs += "el dpto. ${persDocTram.departamento.codigo}"
                } else if (persDocTram.persona) {
                    obs += "el usuario ${persDocTram.persona.login}"
                }
                obs += ", " + o
                observacionOriginal = persDocTram.tramite.observaciones
                texto = obs
                persDocTram.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            }
            persDocTram.fechaArchivo = null
            persDocTram.estado = EstadoTramite.findByCodigo("E004")  // RECIBIDO
            if (persDocTram.save(flush: true)) {
                if (!persDocTram.tramite.save(flush: true)) {
                    println "error al guardar observaciones del tramite: " + persDocTram.tramite.errors
                }
                render "OK"
            } else {
                render "NO*" + renderErrors(bean: persDocTram)
            }
        }
    }

    def desrecibir() {
        def persDocTram = PersonaDocumentoTramite.get(params.id)

        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estados = [estadoAnulado, estadoArchivado]

        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCopia = RolPersonaTramite.findByCodigo("R002")

        def hijosVivos = 0

        Tramite.findAllByPadre(persDocTram.tramite).each { tr ->
            def prtr = PersonaDocumentoTramite.withCriteria {
                eq("tramite", tr)
                ne("estado", estadoAnulado)
                inList("rolPersonaTramite", [rolPara, rolCopia])
            }
            hijosVivos += prtr.size()
        }

//        println("tiene hijos " + hijosVivos)

        if (hijosVivos > 0) {
            render "NO*Este trámite ya tiene respuesta en una de sus copias."
            return
        }

        if (estados.contains(persDocTram.estado)) {
            render "NO*el trámite está ${persDocTram.estado.descripcion}, no puede quitar el recibido"
        } else {
            def o = " Recibido originalmente el ${persDocTram.fechaRecepcion.format('dd-MM-yyyy HH:mm')}"

            def observacionOriginal = persDocTram.observaciones
            def accion = "Quitado el Recibido"
            def solicitadoPor = params.aut
            def usuario = session.usuario.login
            def texto = o
            def nuevaObservacion = params.texto
            persDocTram.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            if (persDocTram.rolPersonaTramite.codigo == "R001") { //PARA
                def obs = "PARA "
                if (persDocTram.departamento) {
                    obs += "el dpto. ${persDocTram.departamento.codigo}"
                } else if (persDocTram.persona) {
                    obs += "el usuario ${persDocTram.persona.login}"
                }
                obs += ", " + o
                observacionOriginal = persDocTram.tramite.observaciones
                texto = obs
                persDocTram.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

            } else if (persDocTram.rolPersonaTramite.codigo == "R002") { //CC
                def obs = "COPIA para "
                if (persDocTram.departamento) {
                    obs += "el dpto. ${persDocTram.departamento.codigo}"
                } else if (persDocTram.persona) {
                    obs += "el usuario ${persDocTram.persona.login}"
                }
                obs += ", " + o
                observacionOriginal = persDocTram.tramite.observaciones
                texto = obs
                persDocTram.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            }
            persDocTram.fechaRecepcion = null
            persDocTram.fechaLimiteRespuesta = null
            persDocTram.estado = EstadoTramite.findByCodigo("E003")  // ENVIADO
            if (persDocTram.save(flush: true)) {
                if (!persDocTram.tramite.save(flush: true)) {
                    println "error al guardar observaciones del tramite: " + persDocTram.tramite.errors
                }
                if (persDocTram.rolPersonaTramite.codigo == "R001") { //PARA
                    def estadoEnviado = EstadoTramite.findByCodigo("E003")
                    persDocTram.tramite.estadoTramite = estadoEnviado
                    if (!persDocTram.tramite.save(flush: true)) {
                        println "Error al cambiar el estado del tramite: " + persDocTram.tramite.errors
                    }
                }
                render "OK"
            } else {
                render "NO*" + renderErrors(bean: persDocTram)
            }
        }
    }

    def anularCircular() {
        def persDocTram = PersonaDocumentoTramite.get(params.id)
        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estados = [estadoArchivado]
        if (estados.contains(persDocTram.estado)) {
            render "NO*el trámite está ${persDocTram.estado.descripcion}, no puede anular el trámite archivado"

        } else {
            def funcion = { objeto ->
                println "anulando " + objeto.id + " " + objeto.rolPersonaTramite.descripcion + "  " + objeto.tramite
                def anulado = EstadoTramite.findByCodigo("E006")
                objeto.estado = anulado
                objeto.fechaAnulacion = new Date()
                def nuevaObs = "Anulado"
                if (params.texto.trim() != "") {
                    nuevaObs += ": " + params.texto
                }
                def observacionOriginal = objeto.observaciones
                def accion = "Anulación"
                def solicitadoPor = params.aut
                def usuario = session.usuario.login
                def texto = ""
                def nuevaObservacion = params.texto
                objeto.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                if (objeto.rolPersonaTramite.codigo == "R002") {
                    nuevaObs = "COPIA para "
                    if (objeto.departamento) {
                        nuevaObs += "el dpto. ${objeto.departamento.codigo}"
                    } else if (objeto.persona) {
                        nuevaObs += "el usuario ${objeto.persona.login}"
                    }

                    observacionOriginal = objeto.tramite.observaciones
                    texto = nuevaObs
                    objeto.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                }
                if (objeto.rolPersonaTramite.codigo == "R001") {
                    nuevaObs = "PARA "
                    if (objeto.departamento) {
                        nuevaObs += "el dpto. ${objeto.departamento.codigo}"
                    } else if (objeto.persona) {
                        nuevaObs += "el usuario ${objeto.persona.login}"
                    }
                    observacionOriginal = objeto.tramite.observaciones
                    texto = nuevaObs
                    objeto.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                }
                objeto.tramite.save(flush: true)
                if (!objeto.save(flush: true)) {
                    println "error en el save anular " + objeto.errors
                } else {
                    /*alertas*/
                    def alerta
                    if (objeto.departamento) {
                        alerta = Alerta.findAllByTramiteAndDepartamento(objeto.tramite, objeto.departamento)
                        alerta.each { a ->
                            if (a.fechaRecibido == null) {
                                a.fechaRecibido = new Date();
                                a.save(flush: true)
                            }
                        }
                    }
                    if (objeto.persona) {

                        alerta = Alerta.findAllByTramiteAndPersona(objeto.tramite, objeto.persona)
                        alerta.each { a ->
                            if (a.fechaRecibido == null) {
                                a.fechaRecibido = new Date();
                                a.save(flush: true)
                            }
                        }
                    }
                }
            }
            /*aqui especial para circular*/
            def rolCopia = RolPersonaTramite.findByCodigo("R002")
            def pdt = PersonaDocumentoTramite.get(params.id)
            if (pdt.tramite.tipoDocumento?.codigo != "CIR") {
                response.sendError(403)
            }
            def pdts = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(pdt.tramite, rolCopia)
            pdts.each { p ->
                getCadenaDown(p, funcion)
            }
            if (pdt.tramite.aQuienContesta) {
                if (pdt.tramite.aQuienContesta.fechaRecepcion) {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E004")
                } else if (pdt.tramite.aQuienContesta.fechaEnvio) {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E003")
                } else {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E001")
                }
                pdt.tramite.aQuienContesta.fechaAnulacion = null
                pdt.tramite.aQuienContesta.fechaArchivo = null
                def nuevaObs = "Reactivado por anulación de: ${persDocTram.tramite.codigo}"
                def observacionOriginal = pdt.tramite.aQuienContesta.observaciones
                def accion = "Reactivación por anulación de trámite derivado"
                def solicitadoPor = params.aut
                def usuario = session.usuario.login
                def texto = nuevaObs
                def nuevaObservacion = params.texto
                pdt.tramite.aQuienContesta.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                pdt.tramite.aQuienContesta.save(flush: true)
                nuevaObs = "Trámite ${pdt.tramite.aQuienContesta.rolPersonaTramite.descripcion}"
                if (pdt.tramite.aQuienContesta.departamento) {
                    nuevaObs += " el dpto. ${pdt.tramite.aQuienContesta.departamento.codigo}"
                } else if (pdt.tramite.aQuienContesta.persona) {
                    nuevaObs += " el usuario ${pdt.tramite.aQuienContesta.persona.login}"
                }
                nuevaObs += " reactivado al anularse ${persDocTram.tramite.codigo}"
                observacionOriginal = pdt.tramite.aQuienContesta.tramite.observaciones
                texto = nuevaObs
                nuevaObservacion = params.texto
                pdt.tramite.aQuienContesta.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            }

            render "OK"
        }
    }

    def anular() {

//        println("params " + params)

        def persDocTram

        /* se obtiene la PersonaDocumentoTramite a anularse */
        if(params.tipo == '1'){
            def trm = Tramite.get(params.id)
            def rol = RolPersonaTramite.findByCodigo('R001')
            persDocTram = PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(trm, rol)
        }else{
            persDocTram = PersonaDocumentoTramite.get(params.id)
        }

        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estados = [estadoArchivado, estadoAnulado]

        if (persDocTram == null) {
            render "NO*el trámite no se puede anular"
            return
        }

        if (estados.contains(persDocTram?.estado)) {
            render "NO*No puede anular el trámite, se encuentra en estado ${persDocTram.estado.descripcion} "

        } else {
            def funcion = { objeto ->
//                println "anulando " + objeto.id + " " + objeto.rolPersonaTramite.descripcion + "  " + objeto.tramite
                def anulado = EstadoTramite.findByCodigo("E006")
                objeto.estado = anulado
                objeto.fechaAnulacion = new Date()
                def nuevaObs = "Anulado"
                if (params.texto.trim() != "") {
                    nuevaObs += ": " + params.texto
                }
                def observacionOriginal = objeto.observaciones
                def accion = "Anulado"
                def solicitadoPor = params.aut
                def usuario = session.usuario.login
                def texto = ""
                def nuevaObservacion = params.texto
                objeto.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                if (objeto.rolPersonaTramite.codigo == "R002") {
                    nuevaObs = "COPIA para "
                    if (objeto.departamento) {
                        nuevaObs += "el dpto. ${objeto.departamento.codigo}"
                    } else if (objeto.persona) {
                        nuevaObs += "el usuario ${objeto.persona.login}"
                    }
                    observacionOriginal = objeto.tramite.observaciones
                    texto = nuevaObs
                    objeto.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                }
                if (objeto.rolPersonaTramite.codigo == "R001") {
                    nuevaObs = "PARA "
                    if (objeto.departamento) {
                        nuevaObs += "el dpto. ${objeto.departamento.codigo}"
                    } else if (objeto.persona) {
                        nuevaObs += "el usuario ${objeto.persona.login}"
                    }
                    observacionOriginal = objeto.tramite.observaciones
                    texto = nuevaObs
                    objeto.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                }
                objeto.tramite.save(flush: true)
                if (!objeto.save(flush: true)) {
                    println "error en el save anular " + objeto.errors
                } else {
                    /*alertas*/
                    def alerta
                    if (objeto.departamento) {
                        alerta = Alerta.findAllByTramiteAndDepartamento(objeto.tramite, objeto.departamento)
                        alerta.each { a ->
                            if (a.fechaRecibido == null) {
                                a.fechaRecibido = new Date();
                                a.save(flush: true)
                            }
                        }
                    }
                    if (objeto.persona) {
                        alerta = Alerta.findAllByTramiteAndPersona(objeto.tramite, objeto.persona)
                        alerta.each { a ->
                            if (a.fechaRecibido == null) {
                                a.fechaRecibido = new Date();
                                a.save(flush: true)
                            }
                        }
                    }
                }
            }

            def rolCopia = RolPersonaTramite.findByCodigo("R002")
            def pdt

            if(params.tipo == '1'){
                def tm = Tramite.get(params.id)
                def rolP = RolPersonaTramite.findByCodigo('R001')
                pdt = PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(tm, rolP)
            }else{
                pdt = PersonaDocumentoTramite.get(params.id)
            }

            def esPara = pdt.rolPersonaTramite.codigo == "R001"
            def esPrincipal = pdt.tramite.tramitePrincipal > 0

            def listaAnular = [pdt.tramite]
            if (esPara && esPrincipal) {
                listaAnular = Tramite.findAllByTramitePrincipal(pdt.tramite.tramitePrincipal)
            }

            listaAnular.each { tramite ->
                def pxt
                if (tramite.id == pdt.tramiteId) {
                    pxt = pdt
                } else {
                    pxt = PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(tramite, RolPersonaTramite.findByCodigo("R001"))
                }
                if (pxt) {
                    getCadenaDown(pxt, funcion)
                    if (esPara) {
                        def copias = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(pxt.tramite, rolCopia)
                        if (copias.size() > 0) {
                            copias.each { cp ->
                                getCadenaDown(cp, funcion)
                            }
                        }
                    }
                }
            }
            /*** reactiva trámite si no está archivado ni anulado ***/
            if (pdt.tramite.aQuienContesta && (!pdt.tramite.aQuienContesta.fechaArchivo) && !pdt.tramite.aQuienContesta.fechaAnulacion) {

                if (pdt.tramite.aQuienContesta.fechaRecepcion) {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E004")   // recibido
                } else if (pdt.tramite.aQuienContesta.fechaEnvio) {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E003")   // enviado
                } else {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E001")   // por enviar
                }

                def nuevaObs = "Reactivado por anulación de: ${persDocTram.tramite.codigo}"
                def observacionOriginal = pdt.tramite.aQuienContesta.observaciones
                def accion = "Reactivado por anulación de trámite derivado"
                def solicitadoPor = params.aut
                def usuario = session.usuario.login
                def texto = nuevaObs
                def nuevaObservacion = params.texto
                pdt.tramite.aQuienContesta.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                pdt.tramite.aQuienContesta.save(flush: true)
                nuevaObs = "Trámite ${pdt.tramite.aQuienContesta.rolPersonaTramite.descripcion}"
                if (pdt.tramite.aQuienContesta.departamento) {
                    nuevaObs += " el dpto. ${pdt.tramite.aQuienContesta.departamento.codigo}"
                } else if (pdt.tramite.aQuienContesta.persona) {
                    nuevaObs += " el usuario ${pdt.tramite.aQuienContesta.persona.login}"
                }
                nuevaObs += " reactivado al anularse ${persDocTram.tramite.codigo}"
                observacionOriginal = pdt.tramite.aQuienContesta.tramite.observaciones
                texto = nuevaObs
                nuevaObservacion = params.texto
                pdt.tramite.aQuienContesta.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            }
            render "OK"
        }
    }

    def anularSalida() {

//        println("params " + params)

        def persDocTram

        if(params.tipo == '1'){
            def trm = Tramite.get(params.id)
            persDocTram = PersonaDocumentoTramite.findByTramite(trm)
        }else{
            persDocTram = PersonaDocumentoTramite.get(params.id)
        }

        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estados = [estadoArchivado]

        if (persDocTram == null) {
            render "NO*el trámite no se puede anular"
            return
        }

        if (estados.contains(persDocTram?.estado)) {
            render "NO*el trámite está ${persDocTram.estado.descripcion}, no puede anular el trámite archivado"

        } else {
            def funcion = { objeto ->
//                println "anulando " + objeto.id + " " + objeto.rolPersonaTramite.descripcion + "  " + objeto.tramite
                def anulado = EstadoTramite.findByCodigo("E006")
                objeto.estado = anulado
                objeto.fechaAnulacion = new Date()
                def nuevaObs = "Anulado"
                if (params.texto.trim() != "") {
                    nuevaObs += ": " + "" + params.texto
                }
                def observacionOriginal = objeto.observaciones
                def accion = "Anulado"
                def solicitadoPor = " el dueño del tramite " + params.aut + " desde bandeja de salida"
                def usuario = session.usuario.login
                def texto = ""
                def nuevaObservacion = params.texto
                objeto.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                if (objeto.rolPersonaTramite.codigo == "R002") {
                    nuevaObs = "COPIA para "
                    if (objeto.departamento) {
                        nuevaObs += "el dpto. ${objeto.departamento.codigo}"
                    } else if (objeto.persona) {
                        nuevaObs += "el usuario ${objeto.persona.login}"
                    }
                    observacionOriginal = objeto.tramite.observaciones
                    texto = nuevaObs
                    objeto.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                }
                if (objeto.rolPersonaTramite.codigo == "R001") {
                    nuevaObs = "PARA "
                    if (objeto.departamento) {
                        nuevaObs += "el dpto. ${objeto.departamento.codigo}"
                    } else if (objeto.persona) {
                        nuevaObs += "el usuario ${objeto.persona.login}"
                    }
                    observacionOriginal = objeto.tramite.observaciones
                    texto = nuevaObs
                    objeto.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                }
                objeto.tramite.save(flush: true)
                if (!objeto.save(flush: true)) {
                    println "error en el save anular " + objeto.errors
                } else {
                    /*alertas*/
                    def alerta
                    if (objeto.departamento) {
                        alerta = Alerta.findAllByTramiteAndDepartamento(objeto.tramite, objeto.departamento)
                        alerta.each { a ->
                            if (a.fechaRecibido == null) {
                                a.fechaRecibido = new Date();
                                a.save(flush: true)
                            }
                        }
                    }
                    if (objeto.persona) {
                        alerta = Alerta.findAllByTramiteAndPersona(objeto.tramite, objeto.persona)
                        alerta.each { a ->
                            if (a.fechaRecibido == null) {
                                a.fechaRecibido = new Date();
                                a.save(flush: true)
                            }
                        }
                    }
                }
            }

            def rolCopia = RolPersonaTramite.findByCodigo("R002")
            def pdt

            if(params.tipo == '1'){
                def tm = Tramite.get(params.id)
                pdt = PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(tm, RolPersonaTramite.findByCodigo('R001'))
            }else{
                pdt = PersonaDocumentoTramite.get(params.id)
            }

            def esPara = pdt.rolPersonaTramite.codigo == "R001"
            def esPrincipal = pdt.tramite.tramitePrincipal > 0 && pdt.tramite.tramitePrincipal.toLong() == pdt.tramite.tramitePrincipal

            def listaAnular = [pdt.tramite]
            if (esPara && esPrincipal) {
                listaAnular = Tramite.findAllByTramitePrincipal(pdt.tramite.tramitePrincipal)
            }

            listaAnular.each { tramite ->
                def pxt
                if (tramite.id == pdt.tramiteId) {
                    pxt = pdt
                } else {
                    pxt = PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(tramite, RolPersonaTramite.findByCodigo("R001"))
                }

                if (pxt) {
                    getCadenaDown(pxt, funcion)
                    if (esPara) {
                        def copias = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(pxt.tramite, rolCopia)
                        if (copias.size() > 0) {
                            copias.each { cp ->
                                getCadenaDown(cp, funcion)
                            }
                        }
                    }
                }
            }
            /*** reactiva trámite si no está archivado ni anulado ***/
            if (pdt.tramite.aQuienContesta && (!pdt.tramite.aQuienContesta.fechaArchivo) && !pdt.tramite.aQuienContesta.fechaAnulacion) {

                if (pdt.tramite.aQuienContesta.fechaRecepcion) {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E004")   // recibido
                } else if (pdt.tramite.aQuienContesta.fechaEnvio) {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E003")   // enviado
                } else {
                    pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E001")   // por enviar
                }
                def nuevaObs = "Reactivado por anulación de: ${persDocTram.tramite.codigo}"
                def observacionOriginal = pdt.tramite.aQuienContesta.observaciones
                def accion = "Reactivado por anulación de trámite derivado"
                def solicitadoPor = params.aut
                def usuario = session.usuario.login
                def texto = nuevaObs
                def nuevaObservacion = params.texto
                pdt.tramite.aQuienContesta.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                pdt.tramite.aQuienContesta.save(flush: true)
                nuevaObs = "Trámite ${pdt.tramite.aQuienContesta.rolPersonaTramite.descripcion}"
                if (pdt.tramite.aQuienContesta.departamento) {
                    nuevaObs += " el dpto. ${pdt.tramite.aQuienContesta.departamento.codigo}"
                } else if (pdt.tramite.aQuienContesta.persona) {
                    nuevaObs += " el usuario ${pdt.tramite.aQuienContesta.persona.login}"
                }
                nuevaObs += " reactivado al anularse ${persDocTram.tramite.codigo}"
                observacionOriginal = pdt.tramite.aQuienContesta.tramite.observaciones
                texto = nuevaObs
                nuevaObservacion = params.texto
                pdt.tramite.aQuienContesta.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            }
            render "OK"
        }
    }

    def anularNuevo() {
//        println "anularNuevo $params"
        def cn = dbConnectionService.getConnection()
        def sql = ""
        def fcha = new Date().format('yyyy-MM-dd HH:mm:ss.SSS')

        def pdt
        /* se obtiene la PersonaDocumentoTramite a anularse */
        if(params.tipo == '1'){
            def trm = Tramite.get(params.id)
            def rol = RolPersonaTramite.findByCodigo('R001')
//            persDocTram = PersonaDocumentoTramite.findByTramite(trm)
            pdt = PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(trm, rol)
        }else{
            pdt = PersonaDocumentoTramite.get(params.id)
        }

        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadoAnulado = EstadoTramite.findByCodigo("E006")
        def estadoPorEnviar = EstadoTramite.findByCodigo("E001")
        def estados = [estadoArchivado, estadoAnulado]
        def copia = RolPersonaTramite.findByCodigo("R002")

        if (pdt == null) {
            render "NO*el trámite no se puede anular"
            return
        }

        if (estados.contains(pdt?.estado)) {
            render "NO*No puede anular el trámite, se encuentra en estado ${pdt.estado.descripcion} "

        } else {
            def accion = "Anulado"
            def solicitadoPor = params.aut
            def usuario = session.usuario.login
            def nuevaObservacion = params.texto

//            println "---> prtr: ${pdt.id} anterior: ${pdt.observaciones}"
            def obsr = tramitesService.observaciones(pdt.observaciones, accion, solicitadoPor, usuario, "", nuevaObservacion)
//            println "---> $obsr \n prtr__id: ${pdt.id}"

            sql = "update prtr set edtr__id = 9, prtrobsr = '${obsr}', prtrfcan = '${fcha}' " +
                    "where prtr__id in (select prtr__id from prtr_cadena(${pdt.id.toInteger()})) and " +
                    "coalesce(edtr__id, 0) != 9"
//            println "sql1: $sql"
            cn.execute(sql.toString())
            sql = "update trmt set trmtobsr = '${obsr}' " +
                    "where trmt__id in (select distinct trmt__id from prtr_cadena(${pdt.id.toInteger()}))"
//            println "sql2: $sql"
            cn.execute(sql.toString())

            /* si el trámite a anularse tiene contestación nueva viva no es necesario reactivar */
            if(pdt.tramite.aQuienContesta) {
                sql = "select count(*) cnta from trmt, prtr " +
                        "where prtrcnts = ${pdt.tramite.aQuienContesta.id} and trmtpdre = ${pdt.tramite.padre.id} and " +
                        "prtr.trmt__id = trmt.trmt__id and rltr__id in (1,2) and coalesce(prtr.edtr__id,0) not in (9) and trmtesrn = 'S'"
            } else { /* es un trámite principal */
                sql = "select count(*) cnta from trmt, prtr " +
                        "where trmtpdre = ${pdt.tramite.id} and " +
                        "prtr.trmt__id = trmt.trmt__id and rltr__id in (1,2) and coalesce(prtr.edtr__id,0) not in (9) and trmtesrn = 'S'"
            }
//            println "sql: $sql"
            def vivos = cn.rows(sql.toString())[0].cnta
//            println "contestación viva: ${vivos}"

            /* solo que este como trámite vivo del padre 0> reactivar padre */
            if (vivos < 1 && (pdt.rolPersonaTramite.id != 2)) {
                def nuevaObs = "Reactivado por anulación de: ${pdt.tramite.codigo}"
                def observacionOriginal = pdt.tramite.aQuienContesta?.observaciones
                accion = "Reactivado por anulación de trámite derivado"
                solicitadoPor = params.aut
                usuario = session.usuario.login
//                def texto = nuevaObs
                nuevaObservacion = params.texto

                if(pdt.tramite.aQuienContesta) {
//                    println "se reactiva: ${pdt.tramite.aQuienContesta?.tramite?.codigo} prtr: ${pdt.tramite.aQuienContesta.id}"
                    if(pdt.tramite.aQuienContesta.fechaRecepcion) {  // se reactiva si tiene fecha de recepción
                        pdt.tramite.aQuienContesta.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, nuevaObs, nuevaObservacion)
                        pdt.tramite.aQuienContesta.estado = EstadoTramite.findByCodigo("E004")   // recibido
                        pdt.tramite.aQuienContesta.save(flush: true)
                    }
                }
            }

            /* si el trámite a anularse es un "para", sus copias se anulan incluyendo cadena */
//            println "evalua: ${pdt.rolPersonaTramite?.id == 1}"
            if (pdt.rolPersonaTramite.id == 1) {
                accion = "Anulado"
                solicitadoPor = params.aut
                usuario = session.usuario.login
                nuevaObservacion = params.texto

                def copias = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramite(pdt.tramite, copia)
//                println "hay copias: ${copias?.size()}"
                copias.each { pr ->
                    cn.eachRow("select prtr__id, trmt__id, trmtcdgo from prtr_cadena(${pr.id.toInteger()})") { d ->
                        obsr = tramitesService.observaciones(pr.observaciones, accion, solicitadoPor, usuario, "", nuevaObservacion)
//                        println "Anular copias ---> $obsr"
                        sql = "update prtr set edtr__id = 9, prtrobsr = '${obsr}', prtrfcan = '${fcha}' " +
                                "where prtr__id in (select prtr__id from prtr_cadena(${pr.id.toInteger()})) and " +
                                "coalesce(edtr__id,0) != 9"
//                        println "sql1: $sql"
                        cn.execute(sql.toString())
                        sql = "update trmt set trmtobsr = '${obsr}' " +
                                "where trmt__id in (select distinct trmt__id from prtr_cadena(${pr.id.toInteger()}))"
//                        println "sql2: $sql"
                        cn.execute(sql.toString())
//                        println "Anula copia: ${d.trmtcdgo}"
                    }
                }
                /* each copias .. anular si no están anuladas */
            }
            render "OK"
        }
    }

    def desanularPdt(PersonaDocumentoTramite pdt) {
        def estadoPorEnviar = EstadoTramite.findByCodigo("E001")
        def estadoEnviado = EstadoTramite.findByCodigo("E003")
        def estadoRecibido = EstadoTramite.findByCodigo("E004")
        def estadoArchivado = EstadoTramite.findByCodigo("E005")
        def estadoAnulado = EstadoTramite.findByCodigo("E006")

        if (!pdt.fechaEnvio) {
            pdt.estado = estadoPorEnviar
        }
        if (pdt.fechaEnvio) {
            pdt.estado = estadoEnviado
        }
        if (pdt.fechaRecepcion) {
            pdt.estado = estadoRecibido
        }
        if (pdt.fechaArchivo) {
            pdt.estado = estadoArchivado
        }

        def observacionOriginal = pdt.observaciones
        def accion = "Reactivado"
        def solicitadoPor = params.aut
        def usuario = session.usuario.login
        def texto = ""
        def nuevaObservacion = params.texto
        pdt.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

        pdt.fechaAnulacion = null
        if (pdt.rolPersonaTramite.codigo == "R002") {
            def nuevaObs = "COPIA para"
            if (pdt.departamento) {
                nuevaObs += " el dpto. ${pdt.departamento.codigo}"
            } else if (pdt.persona) {
                nuevaObs += " el usuario ${pdt.persona.login}"
            }
//            nuevaObs += " reactivada"
            nuevaObs += " "
            observacionOriginal = pdt.tramite.observaciones
            texto = nuevaObs
            pdt.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
        }
        if (pdt.rolPersonaTramite.codigo == "R001") {
            def nuevaObs = "PARA"
            if (pdt.departamento) {
                nuevaObs += " el dpto. ${pdt.departamento.codigo}"
            } else if (pdt.persona) {
                nuevaObs += " el usuario ${pdt.persona.login}"
            }
//            nuevaObs += " reactivado"
            nuevaObs += " "
            observacionOriginal = pdt.tramite.observaciones
            texto = nuevaObs
            pdt.tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
        }
        pdt.tramite.save(flush: true)
        if (pdt.save(flush: true)) {
            return true
        } else {
            println "erros " + pdt.errors
            return false
        }
    }

    def desanular() {

//        println("params " + params)

        def pdt = PersonaDocumentoTramite.get(params.id)
        def tramite = pdt.tramite
        def copias = tramite.allCopias
        def ok = true
        def listaDesanular = [pdt]

        if(Tramite.get(tramite.id)?.padre){
            def tramitePadre = Tramite.get(tramite.id).padre
            def rol = RolPersonaTramite.findByCodigo("R001")
            def prtrPadre = PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(tramitePadre, rol)
            def fechaRecibidoPadre = prtrPadre.fechaRecepcion
            def fechaEnviadoPadre = prtrPadre.fechaEnvio

            def fechaEnvioOriginal = tramite.fechaCreacion

            println("recibido " + fechaRecibidoPadre?.format("dd-MM-yyyy HH:mm"))
            println("enviado padre " + fechaEnviadoPadre?.format("dd-MM-yyyy HH:mm"))
            println("fecha envio " + fechaEnvioOriginal?.format("dd-MM-yyyy HH:mm"))

            if(fechaEnviadoPadre?.getTime() <= fechaEnvioOriginal?.getTime()){
                println("entro 1")
                listaDesanular.each { p ->
                    println "desanular: " + p.rolPersonaTramite.descripcion
                    if (!desanularPdt(p)) {
                        ok = false
                    }
                }
            }else{
                println("entro 2")
                ok = false
            }

        }else{
            println("entro 3")
            listaDesanular.each { p ->
                println "desanular: " + p.rolPersonaTramite.descripcion
                if (!desanularPdt(p)) {
                    ok = false
                }
            }
        }

        render ok ? "OK" : "NO"
    }

    def getCadenaDown(pdt, funcion) {
        def res = []
        def tramites = Tramite.findAll("from Tramite where aQuienContesta=${pdt.id}")
//        println "* tramites " + tramites + "     " + tramites.codigo
        def roles = [RolPersonaTramite.findByCodigo("R002"), RolPersonaTramite.findByCodigo("R001")]
        def lvl
        funcion pdt
        if (tramites.size() > 0) {
            tramites.each { tramite ->
                def tmp = [:]
                tmp.put("nodo", tramite)
                tmp.put("tipo", "tramite")
                def pdts = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInList(tramite, roles)
                tmp.put("hijos", [])

                pdts.each {
                    def r = getHijos(it, roles, funcion)
                    if (r.size() > 0) {
                        tmp["hijos"] += r
                    }
                }
                tmp.put("origen", pdt)
                res.add(tmp)
                res = getHermanos(tramite, res, roles, funcion)
            }

        } else {
            return []
        }
    }

    def getHermanos(tramite, res, roles, funcion) {
        def lvl
        def hermanos = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInList(tramite, roles)
        while (hermanos.size() > 0) {
            def nodo = hermanos.pop()
            def tmp = [:]
            tmp.put("nodo", nodo)
            tmp.put("hijos", getHijos(nodo, roles, funcion))
            tmp.put("tipo", "pdt")
            funcion nodo
            res.add(tmp)

        }
        return res
    }

    def getHijos(pdt, roles, funcion) {
        def res = []
        def t = Tramite.findByAQuienContesta(pdt)
        if (t) {
            def tmp = [:]
            tmp.put("nodo", t)
            tmp.put("tipo", "tramite")
            tmp.put("hijos", [])
            def pdts = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInList(t, roles)
            tmp.put("hijos", [])
            pdts.each {
                def r = getHijos(it, roles, funcion)
                if (r.size() > 0) {
                    tmp["hijos"] += r
                }
            }
            res = getHermanos(t, res, roles, funcion)
            res.add(tmp)
        }
        return res
    }

    def observaciones_ajax () {

    }

}
