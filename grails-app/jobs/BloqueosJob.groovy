package tramites

import groovy.time.TimeCategory
import seguridad.Persona
import utilitarios.Parametros


class BloqueosJob {

    def diasLaborablesService
    def dbConnectionService
    def bloqueado = "B"     /*** poner "B" para habilitar bloqueos y comentar componeEstado() ***/

    static triggers = {
        null    // no ejecuta los bloqueos
        simple name: 'bloqueoBandejaSalida', startDelay: 1000 * 60 * 1, repeatInterval: 1000 * 60 * 5 /* cada 5 min */
//        simple name: 'bloqueoBandejaSalida', startDelay: 1000 * 10, repeatInterval: 1000 * 60 * 3
    }

    def execute() {   /*********** execute job ************/

        /*** *** nuevo *** ***/
        println "inicia bloqueo nuevo: ${new Date().format('dd mm:ss')}"
        def cn = dbConnectionService.getConnection()
        def sql = 'select * from bloqueos()'
        cn.execute(sql.toString())
        println "fin bloqueo nuevo: ${new Date().format('dd mm:ss')}"
        /*** fin nuevo ***/

    }

    def borraBloqueos() {
        def cn = dbConnectionService.getConnection()
        def sql = "delete from blqo"
        cn.execute(sql.toString())
    }

    def registraBloqueo(trmt, dpto, prsn, fcha, rltr, cdgo) {
        def fecha
        if(fcha) fecha = fcha.format('yyyy-MM-dd hh:mm:ss')
        def cn = dbConnectionService.getConnection()
        def sql = "insert into blqo(dpto__id, prsn__id, trmt__id, trmtfcen, rltr__id, trmtcdgo) " +
                "values(${dpto}, $prsn, $trmt, '$fecha', $rltr, '${cdgo}')"
        cn.execute(sql.toString())
    }


    def componeEstado() {
        def cnta = 0
        Departamento.findAllByEstado("B").each { dep ->
            dep.estado = bloqueado
            cnta++
            if (!dep.save(flush: true)) {
                println "error estado a C " + dep.errors
            }
        }
        println "compuesto dpto $cnta"
        cnta = 0
        Persona.findAllByEstado("B").each { pr ->
            pr.estado = bloqueado
            cnta++
            if (!pr.save(flush: true)) {
                println "error prsn estado a C " + pr.errors
            }
        }
        println "compuesto prsn $cnta"
    }

}
