package tramites

import seguridad.Persona

class DepartamentoController {
    def tramitesService
    def dbConnectionService

    static allowedMethods = [save: "POST", delete: "POST", save_ajax: "POST", delete_ajax: "POST"]

    def activar_ajax() {
        def dpto = Departamento.get(params.id)
        dpto.activo = 1
        if (dpto.save(flush: true)) {
            render "OK_Cambio efectado exitosamente"
        } else {
            render "NO_Ocurrió un error: " + renderErrors(bean: dpto)
        }
    }

    /* cambia todos los trámites el departamento actual por el nuevo NO DEBE USARSE */
    def desactivar_ajaxNo() {
        def dpto = Departamento.get(params.id)
        def dptoNuevo = Departamento.get(params.nuevo)


        def rolPara = RolPersonaTramite.findByCodigo('R001');
        def rolCopia = RolPersonaTramite.findByCodigo('R002');
        def rolImprimir = RolPersonaTramite.findByCodigo('I005');

        def pxtPara = PersonaDocumentoTramite.withCriteria {
            eq("departamento", dpto)
            eq("rolPersonaTramite", rolPara)
            isNotNull("fechaEnvio")
            tramite {
                or {
                    eq("estadoTramite", EstadoTramite.findByCodigo("E003")) //enviado
                    eq("estadoTramite", EstadoTramite.findByCodigo("E007")) //enviado al jefe
                    eq("estadoTramite", EstadoTramite.findByCodigo("E004")) //recibido
                }
            }
        }
        def pxtCopia = PersonaDocumentoTramite.withCriteria {
            eq("departamento", dpto)
            eq("rolPersonaTramite", rolCopia)
            isNotNull("fechaEnvio")
            tramite {
                or {
                    eq("estadoTramite", EstadoTramite.findByCodigo("E003")) //enviado
                    eq("estadoTramite", EstadoTramite.findByCodigo("E007")) //enviado al jefe
                    eq("estadoTramite", EstadoTramite.findByCodigo("E004")) //recibido
                }
            }
        }
        def pxtImprimir = PersonaDocumentoTramite.withCriteria {
            eq("departamento", dpto)
            eq("rolPersonaTramite", rolImprimir)
            isNotNull("fechaEnvio")
            tramite {
                or {
                    eq("estadoTramite", EstadoTramite.findByCodigo("E003")) //enviado
                    eq("estadoTramite", EstadoTramite.findByCodigo("E007")) //enviado al jefe
                    eq("estadoTramite", EstadoTramite.findByCodigo("E004")) //recibido
                }
            }
        }
        def pxtTodos = pxtPara
        pxtTodos += pxtCopia
        pxtTodos += pxtImprimir

        def errores = "", ok = 0
        pxtTodos.each { pr ->
            if (pr.rolPersonaTramite.codigo == "I005") {
                pr.delete(flush: true)
            } else {
                pr.departamento = dptoNuevo
                def tramite = pr.tramite
                def observacionOriginal = pr.observaciones
                def accion = "Desactivación de departamento"
                def solicitadoPor = ""
                def usuario = session.usuario.login
                def texto = "Trámite antes dirigido a " + dpto.codigo + " " + dpto.descripcion
                def nuevaObservacion = ""
                pr.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
                observacionOriginal = tramite.observaciones
                tramite.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)

                if (tramite.save(flush: true)) {
                } else {
                    errores += renderErrors(bean: tramite)
                    println "desactivar_ajax:" + tramite.errors
                }
                if (pr.save(flush: true)) {
                    ok++
                } else {
                    println pr.errors
                    errores += renderErrors(bean: pr)
                }
            }
        }
        def trmts = Tramite.findAllByDeDepartamento(dpto)
        trmts.each { dp ->
            dp.deDepartamento = dptoNuevo
            def observacionOriginal = dp.observaciones
            def accion = "Desactivación de departamento"
            def solicitadoPor = ""
            def usuario = session.usuario.login
            def texto = "Trámite antes enviado por " + dpto.codigo + " " + dpto.descripcion
            def nuevaObservacion = ""
            observacionOriginal = dp.observaciones
            dp.observaciones = tramitesService.observaciones(observacionOriginal, accion, solicitadoPor, usuario, texto, nuevaObservacion)
            if (!dp.save(flush: true)) {
                errores += renderErrors(bean: dp)
                println dp.errors
            }
        }
        if (errores != "") {
            println "NOPE: " + errores
            render "NO_Han ocurrido los siguientes errores por lo que no se pudo desactivar el departamento. Por favor intente nuwevamente o contáctese con un administrador. " + errores
        } else {
            dpto.activo = 0
            if (dpto.save(flush: true)) {
                render "OK_Cambio realizado exitosamente"
            } else {
                render "NO_Ha ocurrido un error al desactivar el departamento.<br/>" + renderErrors(bean: dpto)
            }
        }
    }

    def desactivar_ajax() {

//        println "desactivar_ajax... $params"

        def dpto = Departamento.get(params.id)
        def cn = dbConnectionService.getConnection()

        def sqlPersona = "select count(*) from prsn where dpto__id = ${dpto?.id} and prsnactv = 1;"
        def sqlDepart = "select count(*) from dpto where dpto__id in (select dpto__id from dpto \n" +
                "  where dptopdre = ${dpto?.id} and dptoactv = 1); "

        def res = cn.rows(sqlPersona.toString())
        def res2 = cn.rows(sqlDepart.toString())

        if(res == 0){
            if(res2 == 0){
                dpto.activo = 0
                if (dpto.save(flush: true)) {
                    render "OK_Cambio realizado exitosamente"
                } else {
                    render "NO_Ha ocurrido un error al desactivar el departamento.<br/>" + renderErrors(bean: dpto)
                }
            }else{
                render "NO_No se puede desactivar el departamento.<br/> contiene departamentos activos"
            }
        }else{
            render "NO_No se puede desactivar el departamento.<br/> contiene usuarios activos"
        }

    }

    /* pasa bandejas y desactiva triangulo:
     * 1. Halla triángulo y procede, si no muestra error: "no hay triánguilo" */
    def desactivar_dpto_ajax() {
//        println "desactivar_dpto_ajax... $params"
        def dpto = Departamento.get(params.id)
        def nuevo = Departamento.get(params.nuevo)
        def triangulo = dpto.triangulos
        def cn = dbConnectionService.getConnection()
        println "se pasa a: ${nuevo.codigo}: ${nuevo.descripcion}"
        if(triangulo.size() == 1) {
            def prsn = Persona.get(triangulo[0].id)
            def sql = "update prtr set dpto__id = ${nuevo.id} where prtr__id in (select prtr__id " +
                    "from entrada_dpto(${prsn.id}));"
            println "sql: $sql"
            cn.execute(sql.toString())
            sql = "update trmt set dpto__de = ${nuevo.id} where trmt__id in (select trmt__id " +
                    "from  salida_dpto(${prsn.id}))"
            println "sql: $sql"
            cn.execute(sql.toString())
            prsn.activo = 0
            prsn.save(flush: true)
            render "OK_Trámites enviados a ${nuevo.codigo}: ${nuevo.descripcion}} exitosamente"
        } else {
            render "NO_No se ha encontrado un triángulo único en este departamento"
        }
    }

    def arbolSearch_ajax() {
        def search = params.str.trim()
        if (search != "") {

            def deps = Departamento.findAllByCodigoIlikeOrDescripcionIlike("%" + search + "%", "%" + search + "%")

//            println "busca "+search+    "    deps "+deps

            def c = Persona.createCriteria()
            def find = c.list(params) {
                or {
                    ilike("nombre", "%" + search + "%")
                    ilike("apellido", "%" + search + "%")
                    ilike("login", "%" + search + "%")
                    departamento {
                        or {
                            ilike("descripcion", "%" + search + "%")
                            ilike("codigo", "%" + search + "%")
                        }
                    }
                }
            }
            def departamentos = []
            find.each { pers ->
                if (pers.departamento && !departamentos.contains(pers.departamento)) {
                    departamentos.add(pers.departamento)
                    def dep = pers.departamento
                    def padre = dep.padre
                    while (padre) {
                        dep = padre
                        padre = dep.padre
                        if (!departamentos.contains(dep)) {
                            departamentos.add(dep)
                        }
                    }
                }
            }

            deps.each { d ->
                departamentos.add(d)
                def dep = d
                def padre = dep.padre
                while (padre) {
                    dep = padre
                    padre = dep.padre
                    departamentos.add(dep)
                }
            }

            departamentos = departamentos.reverse()

//            println "final     "+departamentos

            def ids = "["
            if (find.size() > 0) {
                ids += "\"#root\","
                departamentos.each { dp ->
                    ids += "\"#lidep_" + dp.id + "\","
                }
                ids = ids[0..-2]
            }
            ids += "]"
//            println "ids    "+ids
            render ids
        } else {
            render ""
        }
    }

    def arbolReportes() {

    }

    def arbol() {
//        println "params: $params"
        return [params: params]
    }

    def loadTreePart() {
        render(makeTreeNode(params))
    }

    def makeTreeNode(params) {
        def actv = params.actv == 'true'
//        println "mkTree: $params, activos: $actv"
        def id = params.id
        if (!params.sort) {
            params.sort = "apellido"
        }
        if (!params.order) {
            params.order = "asc"
        }
        String tree = "", clase = "", rel = ""
        def padre
        def hijos = []

        if (id == "#") {
            //root
//            def hh = Departamento.countByPadreIsNull([sort: "descripcion"])
            def hh = Departamento.countByPadreIsNull()
            if (hh > 0) {
                clase = "hasChildren jstree-closed"
                if (session.usuario.puedeDirector || session.usuario.puedeAdmin) {
                } else if (session.usuario.puedeJefe) {
                } else {
                    clase = ""
                }
            }

            tree = "<li id='root' class='root ${clase}' data-jstree='{\"type\":\"root\"}' level='0' >" +
                    "<a href='#' class='label_arbol'>Estructura</a>" +
                    "</li>"
            if (clase == "") {
                tree = ""
            }
        } else if (id == "root") {

            if (session.usuario.puedeDirector || session.usuario.puedeAdmin) {
                if(actv) {
                    hijos = Departamento.findAllByPadreIsNullAndActivo(1,[sort: "descripcion"])
                } else {
                    hijos = Departamento.findAllByPadreIsNull([sort: "descripcion"])
                }
            } else if (session.usuario.puedeJefe) {
                hijos = [session.usuario.departamento]
            } else {
                hijos = []
            }
        } else {
            def parts = id.split("_")
            def node_id = parts[1].toLong()
            padre = Departamento.get(node_id)
            if (padre) {
                hijos = []
                if(actv) {
                    hijos += Persona.findAllByDepartamentoAndActivo(padre, 1, [sort: params.sort, order: params.order])
                    hijos += Departamento.findAllByPadreAndActivo(padre, 1, [sort: "descripcion"])
                } else {
                    hijos += Persona.findAllByDepartamento(padre, [sort: params.sort, order: params.order])
                    hijos += Departamento.findAllByPadre(padre, [sort: "descripcion"])
                }
            }
        }

        if (tree == "" && (padre || hijos.size() > 0)) {
            tree += "<ul>"
            def lbl = ""

            hijos.each { hijo ->
                def tp = ""
                def data = ""
                if (hijo instanceof Departamento) {
                    lbl = hijo.descripcion
                    if (hijo.codigo) {
                        lbl += " (${hijo.codigo})"
                    }
                    tp = "dep"
                    def hijosH = Departamento.findAllByPadre(hijo, [sort: "descripcion"])
                    def triangulos = hijo.getTriangulos()
                    data = "data-tramites='-1'"


                    rel = (hijosH.size() > 0) ? "padre" : "hijo"
                    hijosH += Persona.findAllByDepartamento(hijo, [sort: "apellido"])

                    clase = (hijosH.size() > 0) ? "jstree-closed hasChildren" : ""
                    if (hijosH.size() > 0) {
                        clase += " ocupado "
                        data += "data-tienehij='${hijosH.size()}'"
                    }

                    if (hijo.externo == 1) {
                        rel += "Externo"
                    }
                    if (hijo.remoto == 1) {
                        rel += "Remoto"
                    }

                    if(triangulos.size() >= 1){
//                        println "dep: ${hijo.descripcion} triangulaos ${triangulos} remoto: ${hijo.remoto}"
                        data += "data-tienetri='${triangulos.size()}'"
                    }

                } else if (hijo instanceof Persona) {
                    switch (params.sort) {
                        case 'apellido':
                            lbl = "${hijo.apellido} ${hijo.nombre} ${hijo.login ? '<strong>' + '(' + hijo.login + ')' + '</strong>' : ''}"
                            break;
                        case 'nombre':
                            lbl = "${hijo.nombre} ${hijo.apellido} ${hijo.login ? '<strong>' + '(' + hijo.login + ')' + '</strong>' : ''}"
                            break;
                        default:
                            lbl = "${hijo.apellido} ${hijo.nombre} ${hijo.login ? '<strong>' + '(' + hijo.login + ')' + '</strong>' : ''}"
                    }

                    tp = "usu"
                    rel = "usuario"
                    clase = "usuario"

                    if (hijo.puedeJefe) {
                        tp = rel = clase = "jefe"
                    }
                    if (hijo.puedeDirector) {
                        tp = rel = clase = "director"
                    }

                    def cantTramSalida = -1, cantTramEntrada = -1
                    if (hijo.activo == 1 && !hijo.estaActivo) {
                        clase += " ausente"
                    }

                    data = "data-tramites='${cantTramEntrada}' data-tramitess='${cantTramSalida}'"
                    data += "data-usuario='${hijo.login}'"
                    if (hijo.esTrianguloOff()) {
                        rel += "Triangulo"
                        data += "data-triangulos=" + (hijo.departamento.triangulos.size())
                    }
                }
                if (hijo.estaActivo) {
                    rel += "Activo"
                } else {
                    rel += "Inactivo"
                }
                tree += "<li id='li${tp}_" + hijo.id + "' class='" + clase + "' ${data} data-jstree='{\"type\":\"${rel}\"}' >"
                tree += "<a href='#' class='label_arbol'>" + lbl + "</a>"
                tree += "</li>"
            }
            tree += "</ul>"
        }
        return tree
    }

    def index() {
        redirect(action: "arbol", params: params)
    } //index

    def getLista(params, all) {
        params = params.clone()
        if (all) {
            params.remove("offset")
            params.remove("max")
        }
        def lista
        if (params.search) {
            def c = Departamento.createCriteria()
            lista = c.list(params) {
                or {
                    ilike("codigo", "%" + params.search + "%")
                    ilike("descripcion", "%" + params.search + "%")
                    tipoDepartamento {
                        or {
                            ilike("codigo", "%" + params.search + "%")
                            ilike("descripcion", "%" + params.search + "%")
                        }
                    }
                }
            }
        } else {
            lista = Departamento.list(params)
        }
        return lista
    }

    def show_ajax() {
        println "show dpto " + params
        def personal = []
        if (params.id) {
            def departamentoInstance = Departamento.get(params.id)
            personal = departamentoInstance.getTriangulos();
            if (!departamentoInstance) {
                notFound_ajax()
                return
            }
            return [departamentoInstance: departamentoInstance, personal: personal, params: params]
        } else {
            notFound_ajax()
        }
    } //show para cargar con ajax en un dialog

    def form_ajax() {
        def departamentoInstance = new Departamento(params)
        def pxtTodos = []
        if (params.id) {
            departamentoInstance = Departamento.get(params.id)
            if (!departamentoInstance) {
                notFound_ajax()
                return
            }

            //cuenta los tramites de la bandeja de entrada de la oficina
            def rolPara = RolPersonaTramite.findByCodigo('R001');
            def rolCopia = RolPersonaTramite.findByCodigo('R002');
            def rolImprimir = RolPersonaTramite.findByCodigo('I005');

            def pxtPara = PersonaDocumentoTramite.withCriteria {
                eq("departamento", departamentoInstance)
                eq("rolPersonaTramite", rolPara)
                isNotNull("fechaEnvio")
                tramite {
                    or {
                        eq("estadoTramite", EstadoTramite.findByCodigo("E003")) //enviado
                        eq("estadoTramite", EstadoTramite.findByCodigo("E007")) //enviado al jefe
                        eq("estadoTramite", EstadoTramite.findByCodigo("E004")) //recibido
                    }
                }
            }
            def pxtCopia = PersonaDocumentoTramite.withCriteria {
                eq("departamento", departamentoInstance)
                eq("rolPersonaTramite", rolCopia)
                isNotNull("fechaEnvio")
                tramite {
                    or {
                        eq("estadoTramite", EstadoTramite.findByCodigo("E003")) //enviado
                        eq("estadoTramite", EstadoTramite.findByCodigo("E007")) //enviado al jefe
                        eq("estadoTramite", EstadoTramite.findByCodigo("E004")) //recibido
                    }
                }
            }
            def pxtImprimir = PersonaDocumentoTramite.withCriteria {
                eq("departamento", departamentoInstance)
                eq("rolPersonaTramite", rolImprimir)
                isNotNull("fechaEnvio")
                tramite {
                    or {
                        eq("estadoTramite", EstadoTramite.findByCodigo("E003")) //enviado
                        eq("estadoTramite", EstadoTramite.findByCodigo("E007")) //enviado al jefe
                        eq("estadoTramite", EstadoTramite.findByCodigo("E004")) //recibido
                    }
                }
            }

            pxtTodos = pxtPara
            pxtTodos += pxtCopia
            pxtTodos += pxtImprimir
        }

        return [departamentoInstance: departamentoInstance, tramites: pxtTodos.size()]
    } //form para cargar con ajax en un dialog

    def tipoDoc_ajax() {
        println params
        def dpto = Departamento.get(params.id)
        def permisos = TipoDocumentoDepartamento.findAllByDepartamentoAndEstado(dpto, 1).tipo.id

        return [departamentoInstance: dpto, permisos: permisos]
    } //form para cargar con ajax en un dialog

    def saveTipoDoc_ajax() {
        def dep = Departamento.get(params.id)
        def tiene = TipoDocumentoDepartamento.findAllByDepartamentoAndEstado(dep, 1).tipo
        def nuevos = []

        def quitar = []
        def agregar = []

        (params.tipoDoc).each { id ->
            nuevos += TipoDocumento.get(id)
        }
        nuevos.each { nuevo ->
            if (!tiene.contains(nuevo)) {
                agregar += nuevo
            }
        }
        tiene.each { old ->
            if (!nuevos.contains(old)) {
                quitar += old
            }
        }

        agregar.each { tp ->
            def old = TipoDocumentoDepartamento.findAllByDepartamentoAndTipo(dep, tp)
            def tipo
            if (old.size() == 0) {
                tipo = new TipoDocumentoDepartamento([
                        departamento: dep,
                        tipo        : tp,
                        estado      : 1
                ])
                if (!tipo.save(flush: true)) {
                    println "Error al guardar tipoDocumentoDepartamento: " + renderErrors(bean: tipo)
                }
            } else if (old.size() == 1) {
                tipo = old.first()
                tipo.estado = 1
                if (!tipo.save(flush: true)) {
                    println "Error al guardar tipoDocumentoDepartamento: " + renderErrors(bean: tipo)
                }
            } else {
                println "Mas de un tipoDocumentoDepartamento para ${dep.descripcion} ${tp.descripcion}: ${old}"
                old.eachWithIndex { o, i ->
                    if (i == 0) {
                        o.estado = 1
                    } else {
                        o.estado = 0
                    }
                    if (!o.save(flush: true)) {
                        println "Error al guardar tipoDocumentoDepartamento: " + renderErrors(bean: o)
                    }
                }
            }
        }

        quitar.each { tp ->
            def old = TipoDocumentoDepartamento.findAllByDepartamentoAndTipo(dep, tp)
            def tipo
            if (old.size() == 0) {
                println "no hay tipoDocumentoDepartamento para ${dep.descripcion} ${tp.descripcion}"
            } else if (old.size() == 1) {
                tipo = old.first()
                tipo.estado = 0
                if (!tipo.save(flush: true)) {
                    println "Error al guardar tipoDocumentoDepartamento: " + renderErrors(bean: tipo)
                }
            } else {
                println "Mas de un tipoDocumentoDepartamento para ${dep.descripcion} ${tp.descripcion}: ${old}"
                old.eachWithIndex { o, i ->
                    o.estado = 0
                    if (!o.save(flush: true)) {
                        println "Error al guardar tipoDocumentoDepartamento: " + renderErrors(bean: o)
                    }
                }
            }
        }
        render "OK_Actualización de tipos de documento exitosa."
    }

    def save_ajax() {

        params.codigo = params.codigo.toString().trim().toUpperCase()

        if (!params.activo) {
            params.activo = 1
        }
        params.each { k, v ->
            if (v != "date.struct" && v instanceof java.lang.String) {
                if (k != "direccion") {
                    params[k] = v.toUpperCase()
                }
            }
        }
        def departamentoInstance = new Departamento()
        if (params.id) {
            departamentoInstance = Departamento.get(params.id)
            if (!departamentoInstance) {
                notFound_ajax()
                return
            }
        } //update
        departamentoInstance.properties = params
        if (!departamentoInstance.save(flush: true)) {
            def msg = "NO_No se pudo ${params.id ? 'actualizar' : 'crear'} Departamento."
            msg += renderErrors(bean: departamentoInstance)
            render msg
            return
        }
        render "OK_${params.id ? 'Actualización' : 'Creación'} de Departamento exitosa."
    } //save para grabar desde ajax

    def delete_ajax() {
        if (params.id) {
            def departamentoInstance = Departamento.get(params.id)
            if (departamentoInstance) {
                def personas = Persona.countByDepartamento(departamentoInstance)
                if (personas == 0) {
                    def tddp = TipoDocumentoDepartamento.findAllByDepartamento(departamentoInstance)
                    if (tddp.size() > 0) {
                        tddp.each { td ->
                            try {
                                td.delete(flush: true)
                            } catch (e) {
                                render "NO_No se pudo eliminar Tipo de Documento por Departamento."
                            }
                        }
                    }
                    try {
                        departamentoInstance.delete(flush: true)
                        render "OK_Eliminación de Departamento exitosa."
                    } catch (e) {
                        render "NO_No se pudo eliminar Departamento."
                    }
                } else {
                    render "NO_No se pudo eliminar el departamento pues tiene ${personas} persona${personas == 1 ? '' : 's'}."
                }
            } else {
                notFound_ajax()
            }
        } else {
            notFound_ajax()
        }
    } //delete para eliminar via ajax

    protected void notFound_ajax() {
        render "NO_No se encontró Departamento."
    } //notFound para ajax

    def validarCodigo_ajax() {
        params.codigo = params.codigo.toString().trim().toUpperCase()
        if (params.id) {
            def dpto = Departamento.get(params.id)
            if (dpto.codigo == params.codigo) {
                render true
                return
            } else {
                render Departamento.countByCodigo(params.codigo) == 0
                return
            }
        } else {
            render Departamento.countByCodigo(params.codigo) == 0
            return
        }
    }

    def buscarHijos () {
//        println("params " + params)
        def dptoPadre = Departamento.get(params.id)
        def dptosHijos = Departamento.findAllByPadreAndActivo(dptoPadre, 1).id
//        println("hijos " + dptosHijos)
        return dptosHijos
    }


    def departamentoPara () {
//        println("params departamento Para " + params)

        def departamento = Departamento.get(params.id)

        def cn = dbConnectionService.getConnection()
        def sql = "select dpto__id from dpto where dptoactv = 1 and dpto__id not in (select dptopara from dpdp " +
                "where dpto__id = ${departamento.id})"
        def ids = cn.rows(sql.toString()).dpto__id
        def filtrado = ids - departamento.id
        def listaDepartamentos = Departamento.findAllByIdInList(filtrado, [sort: 'descripcion'])

        def paras = DepartamentoPara.findAllByDeparatamento(departamento).sort{it.deparatamentoPara.descripcion}

        return [departamento: departamento, disponibles: listaDepartamentos, paras: paras]
    }

    def departamentos_ajax () {
        def cn = dbConnectionService.getConnection()
        def departamento = Departamento.get(params.id)
        def sql = "select dpto__id from dpto where dptoactv = 1 and dpto__id not in (select dptopara from dpdp " +
                "where dpto__id = ${departamento.id})"
//        println "sql: $sql"
        def ids = cn.rows(sql.toString()).dpto__id
//        println "ids: $ids"
        def listaDepartamentos = Departamento.findAllByIdInList(ids, [sort: 'descripcion'])
//        println "dptos: ${listaDepartamentos.id.sort()}"

        return [diferentes: listaDepartamentos - [departamento], departamento: departamento]

    }

    def tablaDepartamentos_ajax () {
        def departamento = Departamento.get(params.id)
        def paras = DepartamentoPara.findAllByDeparatamento(departamento)
        paras.sort{it.deparatamentoPara.descripcion}
        [paras: paras]
    }

    def grabarDepartamento_ajax (){

//        println("params agregar departamento" + params)

        def departamento = Departamento.get(params.id)
        def porAgregar = Departamento.get(params.dpto)

        def para = new DepartamentoPara()
        para.deparatamento = departamento
        para.deparatamentoPara = porAgregar
        para.fechaDesde = new Date()

        try{
            para.save(flush: true)
            render "ok"
        }catch (e){
            render "no"
            println("error al grabar el departamento " + para.errors)
        }
    }

    def borrarDepartamento_ajax () {
//        println "borrarDepartamento_ajax $params"
        def departamento = DepartamentoPara.get(params.id)

        try{
            departamento.delete(flush: true)
            render "ok"
        }catch (e){
            render "no"
        }
    }

    def agregarTodos_ajax () {
        def departamento = Departamento.get(params.id)
        def paras = DepartamentoPara.findAllByDeparatamento(departamento)
        def listaDepartamentosSin = Departamento.list([sort: 'descripcion', order: "asc"]).id
        def prefectura = Departamento.get(11)
        listaDepartamentosSin.removeAll([departamento.id])
        def para
        def listaDepartamentos = Departamento.findAllByIdInList(listaDepartamentosSin, [sort: 'descripcion', order: "asc"])

//        println "a agregar: ${listaDepartamentos.size()}, y sin: ${listaDepartamentosSin.size()}"

        paras.each {p->
            p.delete(flush: true)
        }

        listaDepartamentos.each {l->

            para = new DepartamentoPara()
            para.deparatamento = departamento
            para.deparatamentoPara = l
            para.fechaDesde = new Date()
            try{
                para.save(flush: true)
            }catch (e){
                println("error al grabar todos los departamentos " + para.errors)
            }
        }

        render "ok"

    }


    def eliminarTodos_ajax () {
        def departamento = Departamento.get(params.id)
        def paras = DepartamentoPara.findAllByDeparatamento(departamento)

        paras.each {p ->
            try{
                p.delete(flush: true)
            }catch (e){
                println("error al eliminar los departamentos " + p.errors)
            }
        }
        render "ok"
    }

    def agregarDepartamentos_ajax () {

        def ids = params.sele.split(",")
        def para
        def departamento = Departamento.get(params.id)
        def dpto
        def errores = ''
        ids.each { id->
            if(id != ''){
                dpto = Departamento.get(id)
                para = new DepartamentoPara()
                para.deparatamento = departamento
                para.deparatamentoPara = dpto
                para.fechaDesde = new Date()
                try{
                    para.save(flush: true)
                }catch (e){
                    println("error al grabar los departamentos " + para.errors)
                    errores += e
                }
            }
        }

        if(errores == ''){
            render "ok"
        }else{
            render "no"
        }
    }

    def quitarDepartamentos_ajax () {
//        println("params " + params)
        def ids = params.sele.split(",")
        def para
        def dpto
        def errores = ''
        ids.each { id->
            if(id != ''){
                dpto = DepartamentoPara.get(id)

                try{
                    dpto.delete(flush: true)
                }catch (e){
                    println("error al borrar los departamentos " + dpto.errors)
                    errores += e
                }
            }
        }

        if(errores == ''){
            render "ok"
        }else{
            render "no"
        }
    }

    def departamentoDesde () {

        def departamento = Departamento.get(params.id)
        def departamentosDesde = DepartamentoPara.findAllByDeparatamentoPara(departamento).sort{it.deparatamento.descripcion}

        def cn = dbConnectionService.getConnection()
        def sql = "select dpto__id from dpto where dptoactv = 1 and dpto__id not in (select dpto__id from dpdp " +
                "where dptopara = ${departamento.id})"
        def ids = cn.rows(sql.toString()).dpto__id
        def filtrado = ids - departamento.id
        def listaDepartamentos = Departamento.findAllByIdInList(filtrado, [sort: 'descripcion'])

        return[departamento: departamento, desde: departamentosDesde, disponibles: listaDepartamentos]
    }

    def agregarDepartamentosDesde_ajax () {

        def ids = params.sele.split(",")
        def para
        def departamento = Departamento.get(params.id)
        def dpto
        def errores = ''
        ids.each { id->
            if(id != ''){
                dpto = Departamento.get(id)
                para = new DepartamentoPara()
                para.deparatamento = dpto
                para.deparatamentoPara = departamento
                para.fechaDesde = new Date()
                try{
                    para.save(flush: true)
                }catch (e){
                    println("error al grabar los departamentos " + para.errors)
                    errores += e
                }
            }
        }

        if(errores == ''){
            render "ok"
        }else{
            render "no"
        }
    }

    def agregarTodosDesde_ajax () {

        def departamento = Departamento.get(params.id)

        def cn = dbConnectionService.getConnection()
        def sql = "select dpto__id from dpto where dptoactv = 1 and dpto__id not in (select dpto__id from dpdp " +
                "where dptopara = ${departamento.id})"
        def ids = cn.rows(sql.toString()).dpto__id
        def filtrado = ids - departamento.id

        def listaDepartamentos = Departamento.findAllByIdInList(filtrado, [sort: 'descripcion'])

        def desde
        def errores = ''

        listaDepartamentos.each {l->
            desde = new DepartamentoPara()
            desde.deparatamento = l
            desde.deparatamentoPara = departamento
            desde.fechaDesde = new Date()
            try{
                desde.save(flush: true)
            }catch (e){
                println("error al grabar todos los departamentos " + desde.errors)
                errores += e
            }
        }

        if(errores == ''){
            render "ok"
        }else{
            render "no"
        }
    }

    def eliminarTodosDesde_ajax () {
        def departamento = Departamento.get(params.id)
        def paras = DepartamentoPara.findAllByDeparatamentoPara(departamento)

        def errores = ''

        paras.each {p ->
            try{
                p.delete(flush: true)
            }catch (e){
                println("error al eliminar los departamentos " + p.errors)
                errores += e
            }
        }

        if(errores == ''){
            render "ok"
        }else{
            render "no"
        }
    }
}
