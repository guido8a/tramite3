import seguridad.Prms

class MenuTagLib {
    static namespace = "mn"
    def dbConnectionService

    def menu_old = { attrs ->

        def items = [:]
        def usuario = session.usuario
        def perfil = session.perfil
        def prfl = session.perfil.toString().size() < 20 ? session.perfil.toString() : session.perfil.toString()[0..17] + ".."
        def dpto = session.departamento
        def strItems = ""
        if (!attrs.title) {
            attrs.title = "Bitácora"
        }
        if (usuario) {



            def acciones = seguridad.Prms.findAllByPerfil(perfil).accion.sort { it.modulo.orden }

            acciones.each { ac ->
                if(ac.tipo.id==1){
                    if (!items[ac.modulo.nombre]) {
                        items.put(ac.modulo.nombre, [ac.accnDescripcion, g.createLink(controller: ac.control.ctrlNombre, action: ac.accnNombre)])
                    } else {
                        items[ac.modulo.nombre].add(ac.accnDescripcion)
                        items[ac.modulo.nombre].add(g.createLink(controller: ac.control.ctrlNombre, action: ac.accnNombre))
                    }
                }

            }
            items.each { item ->
                for (int i = 0; i < item.value.size(); i += 2) {
                    for (int j = 2; j < item.value.size() - 1; j += 2) {
                        def val = item.value[i].trim().compareTo(item.value[j].trim())
                        if (val > 0 && i < j) {
                            def tmp = [item.value[j], item.value[j + 1]]
                            item.value[j] = item.value[i]
                            item.value[j + 1] = item.value[i + 1]
                            item.value[i] = tmp[0]
                            item.value[i + 1] = tmp[1]
                        }

                    }
                }
            }
        } else {
            items = ["Inicio": ["Prueba", "linkPrueba", "Test", "linkTest"]]
        }

        items.each { item ->
            strItems += '<li class="dropdown">'
            strItems += '<a href="#" class="dropdown-toggle" data-toggle="dropdown">' + item.key + '<b class="caret"></b></a>'
            strItems += '<ul class="dropdown-menu">'

            (item.value.size() / 2).toInteger().times {
                strItems += '<li><a href="' + item.value[it * 2 + 1] + '">' + item.value[it * 2] + '</a></li>'
            }
            strItems += '</ul>'
            strItems += '</li>'
        }
        def alertas ="("
        def count = monitor.Alerta.countByPersonaAndFechaRecibidoIsNull(usuario)

        alertas += count
        alertas+=")"
        def html = ""
        html += '<nav class="navbar navbar-fixed-top navbar-inverse hidden-print ">'
        html += '<div class="container" style="min-width: 600px !important;">'
        html += '<div class="navbar-header">'
        html += '<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#happy-navbar-collapse">'
        html += '<span class="sr-only">Toggle navigation</span>'
        html += '<span class="icon-bar"></span>'
        html += '<span class="icon-bar"></span>'
        html += '<span class="icon-bar"></span>'
        html += '</button>'
        html += '<a class="navbar-brand" href="' + g.createLink(controller: 'inicio', action: 'index') +
                '" style="margin-top:-10px;font-size: 11px !important;width:220px;color:white;cursor:default;margin-left:-10px">'
        html += '<img src="'+g.resource(dir: 'images/apli',file: 'logo.png')+'" height="38px" style="float:left" >'
        html += '<div style="width:130px !important;float:left;height:40px;margin-left:5px;font-weight:bold;text-align:center">'
        html += '<span class= "text-warning" style="font-size:1.6em;">Bitácora</span><br> Conocimiento y Agenda'
        html += '</div>'
        html += '</a>'
        html += '</div>'
        html += '<div class="collapse navbar-collapse" id="happy-navbar-collapse">'
        html += '<ul class="nav navbar-nav">'
        html += strItems
        html += '</ul>'

        html += '<ul class="nav navbar-nav navbar-right">'
//        html += '<li><a href="' + g.createLink(controller: 'alertas', action: 'list') + '" '+((count>0)?' ' +
//                'style="color:#FFAB19" class="annoying"':"")+'><i class="fa fa-exclamation-triangle"></i> ' +
//                'Alertas '+alertas+'</a></li>'

        html += '<li class="dropdown">'
        html += '<a href="#" class="dropdown-toggle" data-toggle="dropdown">' + usuario?.login+' ('+ prfl+')' +
                ' <b class="caret"></b></a>'
        html += '<ul class="dropdown-menu">'
        html += '<li><a href="' + g.createLink(controller: 'persona', action: 'personal') +
                '"><i class="fa fa-cogs"></i> Configuración</a></li>'
        html += '<li class="divider"></li>'
        html += '<li><a href="' + g.createLink(controller: 'login', action: 'logout') +
                '"><i class="fa fa-power-off"></i> Salir</a></li>'
        html += '</ul>'
        html += '</li>'

        html += '</ul>'
        html += '</div><!-- /.navbar-collapse -->'
        html += '</div>'
        html += '</nav>'

        out << html
    } //menu

    def menu = { attrs ->
        def cn = dbConnectionService.getConnection()
        def sql = ''
        def txt = ""
        def inicio = "${createLink(controller:'login', action: 'login')}"
        def items = [:]
        def usuario, perfil, dpto
        if (session.usuario) {
            usuario = session.usuario
            perfil = session.perfil
            dpto = session.departamento
        }
        def strItems = ""
        if (!attrs.title) {
            attrs.title = "Monitor"
        }
//        attrs.title = attrs.title.toUpperCase()
        if (usuario) {

            sql = "select accn.accn__id, tpac__id, accnnmbr, accndscr, ctrlnmbr, mdlonmbr " +
                    "from prms, accn, ctrl, mdlo " +
                    "where prfl__id = ${perfil.id} and accn.accn__id = prms.accn__id and " +
                    "ctrl.ctrl__id = accn.ctrl__id and ctrlnmbr != 'No Asignado' and " +
                    "mdlo.mdlo__id = accn.mdlo__id and tpac__id = 1 " +
                    "order by mdloordn, accndscr"
            println "sqlMenu: $sql"

            cn.eachRow(sql.toString()) { d ->
                if (!items[d.mdlonmbr]) {
                    items.put(d.mdlonmbr, [d.accndscr, g.createLink(controller: d.ctrlnmbr, action: d.accnnmbr)])
                } else {
                    items[d.mdlonmbr].add(d.accndscr)
                    items[d.mdlonmbr].add(g.createLink(controller: d.ctrlnmbr, action: d.accnnmbr))
                }
            }



//            def acciones = Prms.findAllByPerfil(perfil).accion.sort { it.modulo.orden }
//
//            acciones.each { ac ->
//                if(ac.modulo.nombre != "noAsignado"){
//                    if (ac.tipo.id == 1) {
//                        if (!items[ac.modulo.nombre]) {
//                            items.put(ac.modulo.nombre, [ac.accnDescripcion, g.createLink(controller: ac.control.ctrlNombre, action: ac.accnNombre)])
//                        } else {
//                            items[ac.modulo.nombre].add(ac.accnDescripcion)
//                            items[ac.modulo.nombre].add(g.createLink(controller: ac.control.ctrlNombre, action: ac.accnNombre))
//                        }
//                    }
//                }
//            }
//            items.each { item ->
//                for (int i = 0; i < item.value.size(); i += 2) {
//                    for (int j = 2; j < item.value.size() - 1; j += 2) {
//                        def val = item.value[i].trim().compareTo(item.value[j].trim())
//                        if (val > 0 && i < j) {
//                            def tmp = [item.value[j], item.value[j + 1]]
//                            item.value[j] = item.value[i]
//                            item.value[j + 1] = item.value[i + 1]
//                            item.value[i] = tmp[0]
//                            item.value[i + 1] = tmp[1]
//                        }
//                    }
//                }
//            }
        } else {
            items = ["Inicio": ["Abandonar el Sistema", inicio]]
        }

        items.each { item ->
            strItems += '<li class="dropdown">'
            strItems += '<a href="#" class="dropdown-toggle" data-toggle="dropdown">' + item.key + '<b class="caret"></b></a>'
            strItems += '<ul class="dropdown-menu">'

            (item.value.size() / 2).toInteger().times {
                strItems += '<li><a href="' + item.value[it * 2 + 1] + '">' + item.value[it * 2] + '</a></li>'
            }
            strItems += '</ul>'
            strItems += '</li>'
        }

        def alertas = "("
        def count = alertas.Alerta.countByPersonaAndFechaRecibidoIsNull(usuario)
        alertas += count
        alertas += ")"

        def html = "<nav class=\"navbar navbar-default navbar-fixed-top navbar-inverse\" role=\"navigation\">"

        html += "<div class=\"container-fluid\">"

        // Brand and toggle get grouped for better mobile display
        html += '<div class="navbar-header">'
        html += '<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">'
        html += '<span class="sr-only">Toggle navigation</span>'
        html += '<span class="icon-bar"></span>'
        html += '<span class="icon-bar"></span>'
        html += '<span class="icon-bar"></span>'
        html += '</button>'
        html += '<a class="navbar-brand navbar-logo" href="' + g.createLink(controller: 'inicio', action: 'index') +
                '"> <img src="' + g.assetPath(src: 'apli/logo.png') + '" style="float:left; height:40px">' + '</a>'

        html += '</div>'

        // Collect the nav links, forms, and other content for toggling
        html += '<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">'
        html += '<ul class="nav navbar-nav">'
        html += strItems
        html += '</ul>'

        if(usuario) {
            html += '<ul class="nav navbar-nav navbar-right">'
//        html += '<ul class="nav navbar-nav">'
//        html += '<li><a href="' + g.createLink(controller: 'alerta', action: 'list') + '" ' + ((count > 0) ? ' style="color:#ab623a" class="annoying"' : "") + '><i class="fa fa-exclamation-triangle"></i> Alertas ' + alertas + '</a></li>'
            html += '<li class="dropdown">'
            html += '<a href="#" class="dropdown-toggle" data-toggle="dropdown">' + usuario?.login + ' (' + session?.perfil + ')' + ' <b class="caret"></b></a>'
            html += '<ul class="dropdown-menu">'
            html += '<li><a href="' + g.createLink(controller: 'persona', action: 'personal') + '"><i class="fa fa-cogs"></i> Configuración</a></li>'
            html += '<li class="divider"></li>'
            html += '<li><a href="' + g.createLink(controller: 'login', action: 'logout') + '"><i class="fa fa-power-off"></i> Salir</a></li>'
        } else {
            html += "<p class='text-info pull-right' style='font-size: 14px; margin-top: 20px'> " +
                    "<a href='http://www.tedein.com.ec\'>Auspiciado y Desarrollado por <strong>Tedein S.A.</strong></a></p>"
        }
        html += '</ul>'
        html += '</li>'
        html += '</ul>'

        html += '</div><!-- /.navbar-collapse -->'

        html += "</div>"

        html += "</nav>"

//        println "---> $txt"

        out << html
    }

}
