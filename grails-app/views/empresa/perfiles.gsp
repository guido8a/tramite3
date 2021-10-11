<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 07/10/21
  Time: 15:53
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title>Configurar usuario</title>

    <style type="text/css">
    .perfil .fa-li, .perfil span, .permiso .fa-li, .permiso span {
        cursor : pointer;
    }

    .table {
        font-size     : 13px;
        width         : auto !important;
        margin-bottom : 0 !important;
    }

    .container-celdasAcc {
        max-height : 200px;
        width      : 804px; /*554px;*/
        overflow   : auto;
    }

    .container-celdasPerm {
        max-height : 200px;
        width      : 1030px;
        overflow   : auto;
    }

    .col100 {
        width : 100px;
    }

    .col200 {
        width : 250px;
    }

    .col300 {
        width : 304px;
    }

    .col-md-1.xs {
        width : 45px;
    }

    .fecha {
        width : 160px;
    }

    </style>

</head>

<body>

<div class="form-group keeptogether">
    <div>
        <g:link class="btn btn-default col-md-1" controller="empresa" action="administradores" id="${empresa?.id}"><i class="fa fa-arrow-left"></i> Regresar</g:link>
    </div>
</div>

<div class="panel-group" id="accordion">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                Perfiles del usuario: <strong>${usuario.nombre} ${usuario.apellido}</strong>
            </h4>
        </div>

        <div id="collapsePerfiles" class="panel-collapse collapse in">
            <div class="panel-body">
                <g:form name="frmPerfiles" action="savePerfiles_ajax">
                    <g:each in="${perfiles}" var="perfil">
                        <div class="form-check form-check-inline" style="margin-top: 7px">
                            <input class="form-check-input perfil" type="checkbox" data-id="${perfil?.id}" name="perfil_name" id="perfilId" ${perfil?.id in perfilesUsu ? 'checked' : ''}>
                            ${perfil.nombre} ${perfil.observaciones ? '(' + perfil.observaciones + ')' : ''}
                        </div>
                    </g:each>
                </g:form>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">

    $.switcher('input[type=checkbox]');

    $(".perfil").click(function () {
        var id = $(this).data("id");
        var checked = $(this).is(":checked");
        if (checked) {
            guardarPerfil('si',id)
        } else {
            guardarPerfil('no',id)
        }
    });

    function guardarPerfil(estado, id){

        bootbox.confirm({
            message: "<i class='fa fa-cogs fa-3x pull-left text-info text-shadow'></i>  " +
                "<p style='text-align: center; font-size: 14px; font-weight: bold'>  Está seguro de activar/desactivar el perfil seleccionado?</p>",
            buttons: {
                confirm: {
                    label: "<i class='fa fa-save'></i> Aceptar",
                    className: 'btn-success'
                },
                cancel: {
                    label: "<i class='fa fa-times'></i> Cancelar",
                    className: 'btn-primary'
                }
            },
            callback: function (result) {
                if (result) {
                    var cl1 = cargarLoader("Guardando...");
                    var data = "id=${usuario.id}";
                    $(".perfil").each(function () {
                        if ($(this).is(":checked")) {
                            data += "&perfil=" + $(this).data("id");
                        }
                    });

                    if(verificarPerfiles()){
                        if(verificarJefe()){
                            savePerfil(data,cl1)
                        }else{
                            cl1.modal("hide");
                            bootbox.confirm({
                                message: "<i class='fa fa-exclamation-triangle fa-3x pull-left text-warning text-shadow'></i>  " +
                                    "<p style='margin-left: 10px'>  No puede asignar a la vez el perfil de JEFE y el de DIRECTOR a la misma persona</p>",
                                buttons: {
                                    confirm: {
                                        label: "<i class='fa fa-times'></i> Aceptar",
                                        className: 'btn-success'
                                    },
                                    cancel: {
                                        label: "<i class='fa fa-times'></i> Cancelar",
                                        className: 'btn-primary hidden'
                                    }
                                },
                                callback: function (result) {
                                    if (result) {
                                        var cl2 = cargarLoader("Cargando...");
                                        location.reload(true);
                                    }
                                }
                            });
                        }
                    }else{
                        cl1.modal("hide");
                        bootbox.confirm({
                            message: "<i class='fa fa-exclamation-triangle fa-3x pull-left text-warning text-shadow'></i>  " +
                                "<p style='margin-left: 10px'>  No ha seleccionado ningún perfil. El usuario no podrá ingresar al sistema. ¿Desea continuar?.</p>",
                            buttons: {
                                confirm: {
                                    label: "<i class='fa fa-save'></i> Aceptar",
                                    className: 'btn-success'
                                },
                                cancel: {
                                    label: "<i class='fa fa-times'></i> Cancelar",
                                    className: 'btn-primary'
                                }
                            },
                            callback: function (result) {
                                if (result) {
                                    savePerfil(data,cl1)
                                }else{
                                    location.reload(true);
                                }
                            }
                        });
                    }
                }else{
                    var cl3 = cargarLoader("Cargando...");
                    location.reload(true);
                }
            }
        });

    }

    function verificarPerfiles(){
        var band = 0;
        $(".perfil").each(function () {
            if ($(this).is(":checked")) {
                band += 1
            }
        });

        if(band == 0){
            return false
        }else{
            return true
        }
    }

    function verificarJefe() {
        var jefe = 0;
        var director = 0;
        $(".perfil").each(function () {
            if ($(this).is(":checked")) {
                if($(this).data("id") == '9'){
                    director +=1
                }else{
                    if($(this).data("id") == '8'){
                        jefe += 1
                    }
                }
            }
        });

        if(jefe != 0 && director != 0){
            return false
        }else{
            return true
        }
    }

    function savePerfil(data,cl1) {
        $.ajax({
            type: 'POST',
            url: '${createLink(controller: 'persona', action: 'savePerfiles_ajax')}',
            data:data,
            success: function (msg) {
                cl1.modal("hide");
                var parts = msg.split("_");
                if(parts[0] == 'ok'){
                    log(parts[1],"success")
                }else{
                    log("Error al asignar el perfil","error")
                }
            }
        });
    }

    $(function () {
        var $btnPerfiles = $("#btnPerfiles");

        $(".perfil .fa-li, .perfil span").click(function () {
            var ico = $(this).parent(".perfil").find(".fa-li");
            var perf = ico.data("cd");
            var ok = true;

            if (ok) {
                if (ico.hasClass("fa-check-square")) { //descheckear
                    ico.removeClass("fa-check-square").addClass("fa-square");
                } else { //checkear
                    ico.removeClass("fa-square").addClass("fa-check-square");
                }
            } else {
                bootbox.alert("<i class='fa fa-warning fa-3x pull-left text-warning text-shadow'></i><p></p>");


            }
        });

    });
</script>

</body>
</html>