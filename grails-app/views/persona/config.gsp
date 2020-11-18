<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title>Perfiles de Usuario</title>

    <style type="text/css">

    @keyframes glowing {
        0% { box-shadow: 0 0 -10px #ff4517; }
        40% { box-shadow: 0 0 20px #ff4517; }
        60% { box-shadow: 0 0 20px #ff4517; }
        100% { box-shadow: 0 0 -10px #ff4517; }
    }

    .button-glow {
        animation: glowing 1000ms infinite;
    }


    /*.glow-on-hover {*/
    /*    !*width: 220px;*!*/
    /*    !*height: 50px;*!*/
    /*    border: none;*/
    /*    outline: none;*/
    /*    color: #fff;*/
    /*    background: #78b665;*/
    /*    cursor: pointer;*/
    /*    position: relative;*/
    /*    z-index: 0;*/
    /*    border-radius: 10px;*/
    /*}*/

    /*.glow-on-hover:before {*/
    /*    content: '';*/
    /*    background: linear-gradient(45deg, #ff0000, #ff7300, #fffb00, #48ff00, #00ffd5, #002bff, #7a00ff, #ff00c8, #ff0000);*/
    /*    position: absolute;*/
    /*    top: -2px;*/
    /*    left:-2px;*/
    /*    background-size: 400%;*/
    /*    z-index: -1;*/
    /*    filter: blur(5px);*/
    /*    width: calc(100% + 4px);*/
    /*    height: calc(100% + 4px);*/
    /*    animation: glowing 20s linear infinite;*/
    /*    opacity: 0;*/
    /*    transition: opacity .3s ease-in-out;*/
    /*    border-radius: 10px;*/
    /*}*/

    /*.glow-on-hover:active {*/
    /*    color: #78b665*/
    /*}*/

    /*.glow-on-hover:active:after {*/
    /*    background: transparent;*/
    /*}*/

    /*.glow-on-hover:hover:before {*/
    /*    opacity: 1;*/
    /*}*/

    /*.glow-on-hover:after {*/
    /*    z-index: -1;*/
    /*    content: '';*/
    /*    position: absolute;*/
    /*    width: 100%;*/
    /*    height: 100%;*/
    /*    background: #78b665;*/
    /*    left: 0;*/
    /*    top: 0;*/
    /*    border-radius: 10px;*/
    /*}*/

    /*@keyframes glowing {*/
    /*    0% { background-position: 0 0; }*/
    /*    50% { background-position: 400% 0; }*/
    /*    100% { background-position: 0 0; }*/
    /*}*/

    </style>

</head>

<body>

<div class="btn-group" style="margin-bottom: 15px">
    <g:link class="btn btn-primary" controller="persona" action="list"><i class="fa fa-arrow-left"></i> Regresar</g:link>
</div>

<div class="panel-group" id="accordion">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                Configuración de perfiles del usuario: <strong>${usuario.nombre} ${usuario.apellido}</strong>
            </h4>
        </div>

        <div id="collapsePerfiles" class="panel-collapse collapse in">
            <div class="panel-body">
                <p>
                    <a href="#" class="btn btn-warning " id="nonePerf"><i class="fa fa-exclamation-triangle"></i> Quitar todos los perfiles</a>
                    <a href="#" class="btn btn-success glow-on-hover" id="btnPerfiles">
                        <i class="fa fa-save"></i> Guardar
                    </a>
                </p>
                <g:form name="frmPerfiles" action="savePerfiles_ajax">
                    <ul class="fa-ul">
                        <g:each in="${seguridad.Prfl.list([sort: 'nombre'])}" var="perfil">
                            <li class="perfil">
                                <g:checkBox class="c2" name="c1" data-id="${perfil?.id}" value="${perfilesUsu.contains(perfil.id)}" checked="${perfilesUsu.contains(perfil.id) ? 'true' : 'false'}"/>
                                <span>${perfil.nombre} ${perfil.observaciones ? '(' + perfil.observaciones + ')' : ''}</span>
                            </li>
                        </g:each>
                    </ul>
                </g:form>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">


    $("#btnPerfiles").click(function () {
        verificarPerfiles();
    });

    function verificarPerfiles () {
        var usuario = '${usuario?.id}';
        var perfiles = [];

        $(".c2").each(function () {
            var id = $(this).data("id");

            if($(this).is(':checked')){
                perfiles += parseInt(id) + "_"
            }
        });

        if(perfiles != ''){
            guardarPerfiles(usuario, perfiles)
        }else{
            bootbox.confirm("<i class='fa fa-exclamation-triangle fa-3x pull-left text-danger text-shadow'></i><p style='font-size: 12px'>No ha seleccionado ningún perfil. El usuario no podrá ingresar al sistema. ¿Desea continuar?.</p>", function (result) {
                if (result) {
                    guardarPerfiles(usuario, perfiles)
                }
            })
        }
    }

    function guardarPerfiles (id, perfiles) {
        var dialog = cargarLoader("Guardando...");
        $.ajax({
            type: 'POST',
            url: '${createLink(controller: 'persona', action: 'guardarPerfiles_ajax')}',
            data:{
                perfiles: perfiles,
                id: id
            },
            success:function (msg) {
                dialog.modal('hide');
                var parts = msg.split("_");
                if(parts[0] == 'ok'){
                    log("Perfiles guardados correctamente","success");
                    setTimeout(function () {
                        location.reload(true);
                    }, 1000);
                }else{
                    if(parts[0] == 'er'){
                        bootbox.alert({
                            message: '<i class="fa fa-exclamation-triangle text-danger fa-3x"></i> ' + '<strong style="font-size: 12px">' + parts[1] + '</strong>',
                            callback: function () {
                                var dialog2 = cargarLoader("Cargando...");
                                location.reload(true);
                            }
                        });
                        return false;
                    }else{
                        log("Error al guardar los perfiles","error")
                    }
                }
            }
        });
    }

    $("#nonePerf").click(function () {
        // $(".c2").prop('checked', false);
        $(".c2").attr('checked', false);
        $("#btnPerfiles").addClass("button-glow");
        return false;
    });


    %{--function loadAccesos() {--}%
    %{--    var $div = $("#divAccesos");--}%
    %{--    $div.html(spinnerSquare64);--}%
    %{--    $.ajax({--}%
    %{--        type    : "POST",--}%
    %{--        url     : "${createLink(action:'accesos')}",--}%
    %{--        data    : {--}%
    %{--            id : "${usuario.id}"--}%
    %{--        },--}%
    %{--        success : function (msg) {--}%
    %{--            $div.html(msg);--}%
    %{--        }--}%
    %{--    });--}%
    %{--}--}%
    %{--function loadPermisos() {--}%
    %{--    var $div = $("#divPermisos");--}%
    %{--    $div.html(spinnerSquare64);--}%
    %{--    $.ajax({--}%
    %{--        type    : "POST",--}%
    %{--        url     : "${createLink(action:'permisos')}",--}%
    %{--        data    : {--}%
    %{--            id : "${usuario.id}"--}%
    %{--        },--}%
    %{--        success : function (msg) {--}%
    %{--            $div.html(msg);--}%
    %{--        }--}%
    %{--    });--}%
    %{--}--}%

    // function validarFechasAcceso($elm, e) {
    //     var fecha = e.date;
    //     var $hasta = $("#accsFechaFinal_input");
    //     if ($hasta.datepicker('getDate') < fecha) {
    //         $hasta.datepicker('setDate', fecha);
    //     }
    //     $hasta.datepicker('setStartDate', fecha);
    // }
    //
    // function validarFechasPermiso($elm, e) {
    //     var fecha = e.date;
    //     var $hasta = $("#fechaFin_input");
    //     if ($hasta.datepicker('getDate') < fecha) {
    //         $hasta.datepicker('setDate', fecha);
    //     }
    //     $hasta.datepicker('setStartDate', fecha);
    // }



    // $(function () {
        // var $btnPerfiles = $("#btnPerfiles");
        // var $btnPermisos = $("#btnPermisos");
        // var $btnAccesos = $("#btnAccesos");
        //
        // loadPermisos();
        // loadAccesos();
        //
        // $("#frmAccesos, #frmPermisos").validate({
        //     errorClass     : "help-block",
        //     errorPlacement : function (error, element) {
        //         if (element.parent().hasClass("input-group")) {
        //             error.insertAfter(element.parent());
        //         } else {
        //             error.insertAfter(element);
        //         }
        //         element.parents(".grupo").addClass('has-error');
        //     },
        //     success        : function (label) {
        //         label.parents(".grupo").removeClass('has-error');
        //     }
        // });

        // function doSave(url, data) {
        //     console.log(url, data);
        //     $btnPerfiles.hide().after(spinner);
        //     openLoader("Grabando");
        //     $.ajax({
        //         type    : "POST",
        //         url     : url,
        //         data    : data,
        //         success : function (msg) {
        //             closeLoader();
        //             var parts = msg.split("_");
        //             log(parts[1], parts[0] == "OK" ? "success" : "error");
        //             spinner.remove();
        //             $btnPerfiles.show();
        //         }
        //     });
        // }




        //
        // $(".perfil .fa-li, .perfil span").click(function () {
        //     var ico = $(this).parent(".perfil").find(".fa-li");
        //     var perf = ico.data("cd");
        //     var ok = true;
        //     if (ok) {
        //         if (ico.hasClass("fa-check-square")) { //descheckear
        //             ico.removeClass("fa-check-square").addClass("fa-square-o");
        //         } else { //checkear
        //             ico.removeClass("fa-square-o").addClass("fa-check-square");
        //         }
        //     } else {
        //         bootbox.alert("<i class='fa fa-warning fa-3x pull-left text-warning text-shadow'></i><p>No puede asignar a la vez el perfil de JEFE y el de DIRECTOR a la misma persona</p>");
        //     }
        // });

        %{--$btnPerfiles.click(function () {--}%
        %{--    var $frm = $("#frmPerfiles");--}%
        %{--    var url = $frm.attr("action");--}%
        %{--    var data = "id=${usuario.id}";--}%
        %{--    var band = false;--}%
        %{--    $(".perfil .fa-li").each(function () {--}%
        %{--        var ico = $(this);--}%
        %{--        if (ico.hasClass("fa-check-square")) {--}%
        %{--            data += "&perfil=" + ico.data("id");--}%
        %{--            band = true;--}%
        %{--        }--}%
        %{--    });--}%
        %{--    if (!band) {--}%
        %{--        bootbox.confirm("<i class='fa fa-warning fa-3x pull-left text-warning text-shadow'></i><p>No ha seleccionado ningún perfil. El usuario no podrá ingresar al sistema. ¿Desea continuar?.</p>", function (result) {--}%
        %{--            if (result) {--}%
        %{--                doSave(url, data);--}%
        %{--            }--}%
        %{--        })--}%
        %{--    } else {--}%
        %{--        doSave(url, data);--}%
        %{--    }--}%
        %{--    return false;--}%
        %{--});--}%

        %{--$btnPermisos.click(function () {--}%
        %{--    var $frm = $("#frmPermisos");--}%
        %{--    if ($frm.valid()) {--}%
        %{--        var url = $frm.attr("action");--}%
        %{--        var data = "persona.id=${usuario.id}";--}%
        %{--        data += "&" + $frm.serialize();--}%
        %{--        $btnPermisos.hide().after(spinner);--}%
        %{--        $.ajax({--}%
        %{--            type    : "POST",--}%
        %{--            url     : url,--}%
        %{--            data    : data,--}%
        %{--            success : function (msg) {--}%
        %{--                var parts = msg.split("_");--}%
        %{--                log(parts[1], parts[0] == "OK" ? "success" : "error");--}%
        %{--                spinner.remove();--}%
        %{--                $btnPermisos.show();--}%
        %{--                $frm.find("input, textarea").val("");--}%
        %{--                $("#fechaInicio").val("date.struct");--}%
        %{--                $("#fechaFin").val("date.struct");--}%
        %{--                loadPermisos();--}%
        %{--            }--}%
        %{--        });--}%
        %{--    }--}%
        %{--    return false;--}%
        %{--});--}%

        %{--$btnAccesos.click(function () {--}%
        %{--    var $frm = $("#frmAccesos");--}%
        %{--    if ($frm.valid()) {--}%
        %{--        var url = $frm.attr("action");--}%
        %{--        var data = "usuario.id=${usuario.id}";--}%
        %{--        data += "&" + $frm.serialize();--}%
        %{--        $btnAccesos.hide().after(spinner);--}%
        %{--        $.ajax({--}%
        %{--            type    : "POST",--}%
        %{--            url     : url,--}%
        %{--            data    : data,--}%
        %{--            success : function (msg) {--}%
        %{--                var parts = msg.split("_");--}%
        %{--                log(parts[1], parts[0] == "OK" ? "success" : "error");--}%
        %{--                spinner.remove();--}%
        %{--                $btnAccesos.show();--}%
        %{--                $frm.find("input, textarea").val("");--}%
        %{--                $("#accsFechaInicial").val("date.struct");--}%
        %{--                $("#accsFechaFinal").val("date.struct");--}%
        %{--                loadAccesos();--}%
        %{--            }--}%
        %{--        });--}%
        %{--    }--}%

        %{--    return false;--}%
        %{--});--}%

    // });
</script>

</body>
</html>