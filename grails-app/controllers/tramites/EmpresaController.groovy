package tramites

import seguridad.Persona
import seguridad.Prfl
import seguridad.Sesn


class EmpresaController {

    def dbConnectionService

    def list(){
        params.max = 15
        if(session.usuario.puedeAdmin) {
            def empresas = Empresa.list().sort{it.nombre}
            return [empresas: empresas, empresaInstanceCount: empresas.size(), params: params]
        }else{
            flash.message="Está tratando de ingresar a un pantalla restringida para su perfil"
            response.sendError(403)
        }
    }

    def form_ajax(){

        def empresa

        if(params.id){
            empresa = Empresa.get(params.id)
        }else{
            empresa = new Empresa()
        }

        return[empresa: empresa]
    }

    def show_ajax(){
        def empresa = Empresa.get(params.id)
        return[empresa: empresa]
    }

    def save_ajax(){

        def empresa
        def ruc

        if(params.id){
            empresa = Empresa.get(params.id)
            ruc = Empresa.findAllByRucAndIdNotEqual(params.ruc, empresa.id)
        }else{
            ruc = Empresa.findAllByRuc(params.ruc)
        }

        if(ruc){
            render "er"
        }else{
            if(params.id){
                empresa = Empresa.get(params.id)
            }else{
                empresa = new Empresa()
                empresa.fechaInicio = new Date()
            }

            params.sigla = params.sigla.toUpperCase()
            params.codigo = params.codigo.toUpperCase()
            empresa.properties = params

            if(!empresa.save(flush:true)){
                println("error al crear la empresa " + empresa.errors)
                render "no"
            }else{
                render "ok"
            }
        }
    }

    def validarRuc_ajax() {
        println ("params vruc " + params)
        params.ruc = params.ruc.toString().trim()
        def ruc
        def empresa

        if(params.id){
            empresa = Empresa.get(params.id)
            ruc = Empresa.findAllByRucAndIdNotEqual(params.ruc, empresa.id)
        }else{
            ruc = Empresa.findAllByRuc(params.ruc)
        }

        if(ruc){
            render false
        }else{
            render true
        }
    }//validador unique

    def delete_ajax(){

        def empresa = Empresa.get(params.id)

        try{
            empresa.delete(flush:true)
            render "ok"
        }catch(e){
            println("error al borrar la empresa " + empresa.errors)
            render "no"
        }
    }

    def administradores(){
        def empresa = Empresa.get(params.id)
        return[empresa: empresa]
    }

    def tablaUsuarios_ajax(){
        //        println "tablaUsuarios_ajax: $params"

        def empresa = Empresa.get(params.empresa)

        def tipo
        def estado
        def perfil

        switch(params.tipo) {
            case '0':
                tipo = 'usrologn'
                break;
            case '1':
                tipo = 'usronmbr'
                break;
            case '2':
                tipo = 'usroapll'
                break;
        }

        switch(params.estado) {
            case '0':
                estado = ''
                break;
            case '1':
                estado = ' and usroetdo = 1 '
                break;
            case '2':
                estado = ' and usroetdo = 0 '
                break;
        }


        if(params.perfil == '0'){
            perfil = ''
        }else{
            perfil = "and usroprfl ilike '%${params.perfil}%' "
        }


        def cn = dbConnectionService.getConnection()
        def sql = "select * from usuarios(${empresa?.id}) where ${tipo} ilike '%${params.texto}%' ${estado} ${perfil} order by usroapll limit 30"
        def usuarios = cn.rows(sql.toString())

//        println("sql " + sql)

        return[usuarios: usuarios]
    }

    def perfiles() {
        def empresa = Empresa.get(params.empresa)
        def usu = Persona.get(params.id)
        def perfilesUsu = Sesn.findAllByUsuario(usu)
        def pers = []
        perfilesUsu.each {
            if (it.estaActivo) {
                pers.add(it.perfil.id)
            }
        }
        def permisosUsu = PermisoUsuario.findAllByPersona(usu).permisoTramite.id
        def perfiles = Prfl.findAllByIdNotEqual(15, [sort: 'nombre'])
        return [usuario: usu, perfilesUsu: pers, permisosUsu: permisosUsu, perfiles: perfiles, empresa: empresa]
    }
}
