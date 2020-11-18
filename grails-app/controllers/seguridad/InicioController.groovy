package seguridad

class InicioController {

    def dbConnectionService
    def diasLaborablesService

    def index() {
/*
        if (session.usuario.getPuedeDirector()) {
            redirect(controller: "retrasadosWeb", action: "reporteRetrasadosConsolidadoDir", params: [dpto: Persona.get(session.usuario.id).departamento.id, inicio: "1", dir: "1"])
        } else {
            if (session.usuario.getPuedeJefe()) {
                redirect(controller: "retrasadosWeb", action: "reporteRetrasadosConsolidado", params: [dpto: Persona.get(session.usuario.id).departamento.id, inicio: "1"])
            } else {
            }

        }
*/

//        def fcha = new Date()
//        def fa = new Date(fcha.time - 2*60*60*1000)
//        def fb = new Date(fcha.time + 25*60*60*1000)
//        println "fechas: fa: $fa, fb: $fb"
//        def nada = diasLaborablesService.tmpoLaborableEntre(fa,fb)

    }

    def parametros = {

    }


    /** carga datos desde un CSV - utf-8: si ya existe lo actualiza
     * */
    def leeCSV() {
//        println ">>leeCSV.."
        def contador = 0
        def cn = dbConnectionService.getConnection()
        def estc
        def rgst = []
        def cont = 0
        def repetidos = 0
        def procesa = 5
        def crea_log = false
        def inserta
        def fcha
        def magn
        def sqlp
        def directorio
//        def tipo = 'prueba'
        def tipo = 'prod'

        if (grails.util.Environment.getCurrent().name == 'development') {
            directorio = '/home/guido/proyectos/monitor/data/'
        } else {
            directorio = '/home/obras/data/'
        }

        if (tipo == 'prueba') { //botón: Cargar datos Minutos
            procesa = 5
            crea_log = false
        } else {
            procesa = 100000000000
            crea_log = true
        }

        def nmbr = ""
        def arch = ""
        def cuenta = 0
        def fechas = []
        new File(directorio).traverse(type: groovy.io.FileType.FILES, nameFilter: ~/.*\.csv/) { ar ->
            nmbr = ar.toString() - directorio
            arch = nmbr.substring(nmbr.lastIndexOf("/") + 1)

            /*** procesa las 5 primeras líneas del archivo  **/
            def line
            cont = 0
            repetidos = 0
            ar.withReader('UTF-8') { reader ->
                print "Cargando datos desde: $ar "
                while ((line = reader.readLine()) != null) {
                    println ">>${line}"
                    if(cuenta == 0){
                        rgst = line.split('\t')
                        rgst = rgst*.trim()
//                        println "ultimo: ${rgst[-1]}"
                        fechas = poneFechas(rgst)
                        cuenta++
                    } else if(cuenta < procesa && line?.size() > 20) {
                        rgst = line.split('\t')
                        rgst = rgst*.trim()
                        println "***** $rgst"
                        if(rgst[6]) {
                            inserta = cargaData(rgst, fechas)
                            cont += inserta.insertados
                            repetidos += inserta.repetidos
                            cuenta++
                        }
                    } else {
                        break
                    }
                }
            }
            println "---> archivo: ${ar.toString()} --> cont: $cont, repetidos: $repetidos"
        }
//        return "Se han cargado ${cont} líneas de datos y han existido : <<${repetidos}>> repetidos"
        render "Se han cargado ${cont} líneas de datos y han existido : <<${repetidos}>> repetidos"
    }


    def cargaData(rgst, fechas) {
        def errores = ""
        def cnta = 0
        def insertados = 0
        def repetidos = 0
        def cn = dbConnectionService.getConnection()
        def sqlParr = ""
        def sql = ""
        def cntn = 0
        def tx = ""
        def fcds = ""
        def fchs = ""
        def zona = ""
        def nombres
        def nmbr = "", apll = "", login = "", orden = 0
        def id = 0
        def resp = 0

        println "\ninicia cargado de datos para $rgst"
        println "fechas: $fechas"
        cnta = 0
        if (rgst[1].toString().size() > 0) {
            tx = rgst[2]
//            sqlParr = "select parr__id from parr where parrnmbr ilike '%${tx}%'"
            sqlParr = "select cntn__id from cntn, prov where cntnnmbr ilike '%${tx}%' and " +
                    "prov.prov__id = cntn.prov__id and provnmbr ilike '${rgst[0].toString().trim()}'"
            println "sqlParr: $sqlParr"
            cntn = cn.rows(sqlParr.toString())[0]?.cntn__id
//            sql = "select count(*) nada from unej where unejnmbr = '${rgst[3].toString().trim()}'"
//            println "parr: $parr"
            if (!cntn) {
                sqlParr = "select prov__id from prov where provnmbr ilike '%${rgst[0]}%'"
                def prov = cn.rows(sqlParr.toString())[0]?.prov__id
                if (prov) {
                    sqlParr = "insert into cntn(cntn__id, prov__id, cntnnmbr, cntnnmro) " +
                            "values (default, ${prov}, '${rgst[2]}', '${rgst[1]}') returning cntn__id"
                    cn.eachRow(sqlParr.toString()) { d ->
                        cntn = d.cntn__id
                    }
                    println "cntn --> $cntn"
                }
                println "no existe cantón: ${rgst[0]} ${rgst[3]} ${tx} --> cntn: ${cntn}"
//                println "sql: $sqlParr"
            }
            sql = "select count(*) nada from smfr where cntn__id = '${cntn}'"
            cnta = cn.rows(sql.toString())[0]?.nada

            if (cntn && (cnta == 0)) {
                def i = 0
                fechas.each { f ->
                    tx = f.split(' ')
                    fcds = new Date().parse("yyyy-MM-dd", tx[0]).format('yyyy-MM-dd')
                    fchs = new Date().parse("yyyy-MM-dd", tx[1]).format('yyyy-MM-dd')
                    sql = "insert into smfr (smfr__id, cntn__id, smfrcolr, smfrdsde, smfrhsta) " +
                        "values(default, '${cntn}', ${rgst[4+i]}, '${fcds}', '${fchs}') "
                        "returning smfr__id"
                    println "sql ---> ${sql}"

                    try {
                        cn.eachRow(sql.toString()) { d ->
                            id = d.smfr__id
                            insertados++
                            orden++
                        }
                        println "---> id: ${id}"
                    } catch (Exception ex) {
                        repetidos++
                        println "Error principal $ex"
                        println "sql: $sql"
                    }
                    i++
                }

            }
        }
        cnta++
        return [errores: errores, insertados: insertados, repetidos: repetidos]
    }

    def poneFechas(rgst) {
        def fechas = rgst[(4..-1)]
        def ddds = 0, mmds = 0, ddhs = 0, mmhs = 0, data = []
        def lsFecha = []
//        println "==>${fechas}"
        fechas.each {f ->
            data = f.split(' ')
            ddds = data[0]
            mmds = meses(data[1])
            ddhs = data[3]
            mmhs = meses(data[4])
            def fcin = new Date().parse("dd-MM-yyyy", "${ddds}-${mmds}-2020")
            def fcfn = new Date().parse("dd-MM-yyyy", "${ddhs}-${mmhs}-2020")
            lsFecha.add("${fcin.format('yyyy-MM-dd')} ${fcfn.format('yyyy-MM-dd')}")
//            println "..${fcin.format('yyyy-MM-dd')} - ${fcfn.format('yyyy-MM-dd')}"
        }
        return lsFecha
    }

    def meses(mes) {
        def mess = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre',
          'noviembre', 'diciembre']
        return mess.indexOf(mes) + 1
    }

    def verifica() {
        def prsn = Persona.list()
        println "personas ok"
        def unej = UnidadEjecutora.list()
        println "Unidades ok"
        def dtor = convenio.DatosOrganizacion.list()
        println "DatosOrganizacion ok"
        render "ok"
    }

    def insertaEtor(unej, raza, nmro) {
        def cn = dbConnectionService.getConnection()
        def sql = "insert into etor (etor__id, unej__id, raza__id, etornmro) " +
                "values(default, ${unej}, ${raza}, ${nmro})"
        println "sql2: $sql"
        try {
            cn.execute(sql.toString())
        } catch (Exception ex) {
            println "Error insertaEtor $ex"
            println "Error sql: $sql"
        }
    }

    def insertaCtgr(unej, tpct, vlor) {
        def cn = dbConnectionService.getConnection()
        def sql = "insert into ctgr (ctgr__id, unej__id, tpct__id, ctgrvlor) " +
                "values(default, ${unej}, ${tpct}, '${vlor}')"
//        println "insertaCtgr: $sql"
        try {
            cn.execute(sql.toString())
        } catch (Exception ex) {
            println "Error insertaCtgr $ex"
            println "Error sql: $sql"
        }
    }

    def insertaNecd(unej, ndfr) {
        def cn = dbConnectionService.getConnection()
        def sql = "insert into necd (necd__id, unej__id, ndfr__id) " +
                "values(default, ${unej}, ${ndfr})"
//        println "insertaNecd: $sql"
        try {
            cn.execute(sql.toString())
        } catch (Exception ex) {
            println "Error insertaNecd $ex"
            println "Error sql: $sql"
        }
    }

    def hallaResponsable(nmbr) {
        def apll = nmbr.split(' ').last()
        def cn = dbConnectionService.getConnection()
        def sql = "select prsn__id from prsn where prsnapll ilike '%${apll.toString().toLowerCase()}%' "
//        println "sql2: $sql"
        cn.rows(sql.toString())[0].prsn__id
    }


    /** carga datos desde un CSV - utf-8: si ya existe lo actualiza
     * */
    def leeTalleres() {
        println ">>leeTalleres.."
        def contador = 0
        def cn = dbConnectionService.getConnection()
        def estc
        def rgst = []
        def cont = 0
        def repetidos = 0
        def procesa = 5
        def crea_log = false
        def inserta
        def fcha
        def magn
        def sqlp
        def directorio
//        def tipo = 'prueba'
        def tipo = 'prod'

        if (tipo == 'prueba') { //botón: Cargar datos Minutos
            procesa = 5
            crea_log = false
        } else {
            procesa = 100000000000
            crea_log = true
        }

        def nmbr = ""
        def arch = new File('/home/guido/proyectos/FAREPS/data/talleres.csv')
        def cuenta = 0
        def line
        arch.withReader { reader ->
            while ((line = reader.readLine()) != null) {
                if (cuenta > 0 && cuenta < procesa) {

                    rgst = line.split('\t')
                    rgst = rgst*.trim()
//                    println "****(${cuenta}) $rgst"

                    inserta = cargaTaller(rgst)
                    cont += inserta.insertados
                    repetidos += inserta.repetidos

                    cuenta++
                } else {
                    cuenta++
                }
            }
            println "---> archivo: ${arch.toString()} --> cont: $cont, repetidos: $repetidos"
//        return "Se han cargado ${cont} líneas de datos y han existido : <<${repetidos}>> repetidos"
            render "Se han cargado ${cont} líneas de datos y han existido : <<${repetidos}>> repetidos"
        }
    }

    def cargaTaller(rgst) {
        def errores = ""
        def cnta = 0
        def insertados = 0
        def repetidos = 0
        def cn = dbConnectionService.getConnection()
        def sqlParr = ""
        def sql = ""
        def parr = 0, cmnd = 0
        def tx = ""
        def fcha = ""
        def zona = ""
        def nombres
        def nmbr = "", apll = "", unej = "", tptl = "", raza = 0, inas = [], inst = 0
        def id = 0
        def resp = 0

//        println "\n inicia cargado de datos para $rgst"
        cnta = 0
        if (rgst[1].toString().size() > 0) {
            tx = rgst[4].split('-').last()
//            sqlParr = "select parr__id from parr where parrnmbr ilike '%${tx}%'"
            sqlParr = "select parr__id from parr, cntn, prov where parrnmbr ilike '%${tx}%' and " +
                    "cntn.cntn__id = parr.cntn__id and prov.prov__id = cntn.prov__id and " +
                    "provnmbr ilike '${rgst[2].toString().trim()}'"
//            println "sqlParr: $sqlParr"
            parr = cn.rows(sqlParr.toString())[0]?.parr__id

//            println "parr: $parr"
            if (!parr) {
                sqlParr = "select cntn__id from cntn where cntnnmbr ilike '%${rgst[3]}%'"
                def cntn = cn.rows(sqlParr.toString())[0]?.cntn__id
                println "no existe parroquia: ${tx} --> cntn: ${cntn}"

                if (cntn) {
                    sqlParr = "insert into parr(parr__id, cntn__id, parrnmbr) " +
                            "values (default, ${cntn}, '${tx}') returning parr__id"
                    println "--> $sqlParr"
                    cn.eachRow(sqlParr.toString()) { d ->
                        parr = d.parr__id
                    }
                    println "parr --> $parr"
                }
            }

            def unejnmbr = rgst[8][rgst[8].indexOf(' ') + 1..-1]
            def tllrfcha

            def comilla = rgst[22] ? "'" : ""

            sql = "select unej__id from unej where unejnmbr ilike '%${unejnmbr.trim()}%'"
            unej = cn.rows(sql.toString())[0]?.unej__id
            sql = "select tptl__id from tptl where tptldscr ilike '%${rgst[19]}%'"
            tptl = cn.rows(sql.toString())[0]?.tptl__id

            rgst[20] = rgst[20] ?: ''
            if (rgst[20]?.size() > 6) {
                tllrfcha = new Date().parse("dd/MM/yyyy", rgst[20]).format('yyyy-MM-dd')
                sql = "select count(*) nada from tllr where tllrfcha = '${tllrfcha}' and unej__id = ${unej}"
            } else {
                tllrfcha = rgst[0]
                sql = "select count(*) nada from tllr where tllrnmbr ilike '%${tllrfcha}%' and unej__id = ${unej}"
            }
            cnta = cn.rows(sql.toString())[0]?.nada

//            println "unej: ${unej} --> ${rgst[8]}, cnta: ${cnta}, tptl: ${tptl}, fcha: '${tllrfcha}'"

            if (parr && (cnta == 0)) {
                /* crea la UNEJ*/
                sql = "insert into tllr (tllr__id, parr__id, unej__id, unej_eps, tptl__id, tllrnmbr, " +
                        "tllrobjt, tllrfcha, tllrobsr) " +
                        "values(default, '${parr}', '${unej}', 2, ${tptl}, 'Taller ${tllrfcha}', " +
                        "'${rgst[19]}', '${tllrfcha}', ${comilla}${rgst[22] ?: null}${comilla}) " +
                        "returning tllr__id"
//                println "sql ---> ${sql}"

                try {
                    cn.eachRow(sql.toString()) { d ->
                        id = d.tllr__id
                        insertados++
                    }
                } catch (Exception ex) {
                    repetidos++
//                    println "Error taller $ex"
                    println "Error taller ${rgst[8]}"
//                    println "sql: $sql"
                }
            } else {
                sql = "select tllr__id from tllr where tllrnmbr ilike '%${tllrfcha}%' and unej__id = ${unej}"
                id = cn.rows(sql.toString())[0]?.tllr__id

//                    println "---> id: ${id}"

                /********** crea PRSN ***********/

                if (rgst[15]) {
                    sqlParr = "select cmnd__id from cmnd where parr__id = '${parr}' and " +
                            "cmndnmbr ilike '${rgst[15].toString().trim()}'"
//                    println "sqlParr: $sqlParr"
                    cmnd = cn.rows(sqlParr.toString())[0]?.cmnd__id

//                    println "cmnd: $cmnd"
                    if (!cmnd) {
                        sqlParr = "insert into cmnd(cmnd__id, parr__id, cmndnmbr, cmndnmro) " +
                                "values (default, ${parr}, '${rgst[15]}', 0) returning cmnd__id"
                        cn.eachRow(sqlParr.toString()) { d ->
                            cmnd = d.cmnd__id
                        }
                        println "cmnd --> $cmnd"
                    }

                } else {
                    cmnd = null
                }

                sql = "select raza__id from raza where razadscr ilike '%${rgst[12].trim()}%'"
                raza = cn.rows(sql.toString())[0]?.raza__id
//                println "raza: $raza"

                sql = "insert into prtl (prtl__id, tllr__id, cmnd__id, parr__id, raza__id, " +
                        "prtlcdla, prtlnmbr, prtlapll, prtlcrgo, prtlsexo, " +
                        "prtledad, prtlmail, prtltelf, prtlcell) " +
                        "values(default, ${id}, ${cmnd ?: null}, ${parr}, ${raza}, " +
                        "'${rgst[7] ?: "0000"}', '${rgst[5]}', '${rgst[6]}', '${rgst[10]}', '${rgst[11][1]}', " +
                        "${rgst[13] ?: 0}, '${rgst[18].toString().toLowerCase()}', '${rgst[17]}', '${rgst[16]}')"
//                println "sql2: $sql"

                try {
                    cn.execute(sql.toString())
                    insertados++

                    if (rgst[21]?.size() > 2) {
                        inas = rgst[21].split('/')
                        inas.each { d ->
                            sql = "select inst__id from inst where instdscr ilike '%${d.trim()}%'"
                            inst = cn.rows(sql.toString())[0]?.inst__id
                            sql = "insert into inas(tllr__id, inst__id) values (${id}, ${inst})"
                            cn.execute(sql.toString())
                        }
                    }

                } catch (Exception ex) {
                    repetidos++
                    println "Error prtl $ex"
                    println "sql: $sql"
                }
            }


//            println "sql: $sql"


        }

        cnta++
        return [errores: errores, insertados: insertados, repetidos: repetidos]
    }

    def grafico() {

    }

}
