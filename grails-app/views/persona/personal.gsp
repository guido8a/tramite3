
<html>
    <head>
        <meta name="layout" content="main">
        <title>Configuración personal</title>

        <style type="text/css">
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

        </style>

    </head>

    <body>
        <div class="form-group">
            <div class="alert alert-info" style="font-size: 14px">
               <i class="fa fa-user fa-2x"></i> Datos del usuario: <strong>${usuario.nombre} ${usuario.apellido}</strong>
            </div>
        </div>

        <div class="panel-group" id="accordion">

            <g:set var="abierto" value="${false}"/>

            <g:if test="${!usuario.connect || utilitarios.Parametros.list().first().validaLDAP == 0}">
                <g:set var="abierto" value="${true}"/>
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" data-parent="#accordion" href="#collapsePass">
                               <i class="fa fa-key"></i> Cambiar contraseña
                            </a>
                        </h4>
                    </div>

                    <div id="collapsePass" class="panel-collapse collapse  ${params.tipo == 'foto' ? '' : 'in'}">
                        <div class="panel-body">
                            <g:form class="form-horizontal" name="frmPass" role="form" action="savePass_ajax" method="POST">
                                <div class="form-group required">
                                    <span class="form-grup col-md-3">
                                        <label for="password_actual" class="control-label text-info">
                                            Contraseña actual
                                        </label>

                                        <div class="input-group">
                                            <g:passwordField name="password_actual" class="form-control required"/>
                                            <span class="input-group-addon"><i class="fa fa-unlock"></i></span>
                                        </div>
                                    </span>

                                    <span class="form-grup col-md-3">
                                        <label for="password" class="control-label text-info">
                                            Nueva contraseña
                                        </label>
                                        <div class="input-group">
                                            <g:passwordField name="password" class="form-control required"/>
                                            <span class="input-group-addon"><i class="fa fa-lock"></i></span>
                                        </div>
                                    </span>
                                    <span class="form-grup col-md-3">
                                        <label for="password_again" class="control-label text-info">
                                            Confirme la contraseña
                                        </label>
                                        <div class="input-group">
                                            <g:passwordField name="password_again" class="form-control required" equalTo="#password"/>
                                            <span class="input-group-addon"><i class="fa fa-lock"></i></span>
                                        </div>
                                    </span>

                                    <div class="col-md-2" style="margin-top: 20px;">
                                        <a href="#" class="btn btn-success" id="btnPass">
                                            <i class="fa fa-save"></i> Guardar
                                        </a>
                                    </div>
                                </div>
                            </g:form>
                        </div>
                    </div>
                </div>
            </g:if>
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title">
                        <a data-toggle="collapse" data-parent="#accordion" href="#collapseTelf">
                            <i class="fa fa-phone"></i> Teléfono
                        </a>
                    </h4>
                </div>

                <div id="collapseTelf" class="panel-collapse collapse ">
                    <div class="panel-body">
                        <g:form class="form-horizontal frmTelf" name="frmTelf" role="form" action="saveTelf" method="POST">
                            <div class="form-group required">
                                <span class="form-grup col-md-3">
                                    <label for="telefono" class="control-label text-info">
                                        Número de teléfono
                                    </label>

                                    <div class="input-group">
                                        <g:textField name="telefono" id="telefono" class="form-control digits required" value="${seguridad.Persona.get(session.usuario.id)?.telefono}"/>
                                        <span class="input-group-addon"><i class="fa fa-phone"></i></span>
                                    </div>
                                </span>

                                <div class="col-md-2" style="margin-top: 20px;">
                                    <a href="#" class="btn btn-success" id="btnTelf">
                                        <i class="fa fa-save"></i> Guardar
                                    </a>
                                </div>
                            </div>
                        </g:form>
                    </div>
                </div>
            </div>

            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title">
                        <a data-toggle="collapse" data-parent="#accordion" href="#collapseAcceso">
                            <i class="fa fa-user-clock"></i> Ausentismo: permisos y vacaciones
                        </a>
                    </h4>
                </div>

                <div id="collapseAcceso" class="panel-collapse collapse" style="padding: 10px; min-height: 350px">
                    <div class="panel-body">
                        <h4>Agregar ausentismo</h4>

                        <p style="margin-bottom: 0px">
                            El usuario se hallará ausente entre las fechas seleccionadas (inclusive).
                        </p>
                        <g:form class="form-horizontal" name="frmAccesos" role="form" action="saveAccesos_ajax" method="POST" style="margin-top: -10px">
                            <div class="form-group required" style="margin-top: 0px;margin-left: 0px">
                                <g:if test="${usuario.esTrianguloOff() && triangulos.size() < 2}">
                                    <h3 style="font-size: 16px;color:#3A87AD">Debe asignar las funciones de Recepción a otro usuario dentro de su departamento</h3>
                                </g:if>
                                <div class="row">
                                    <span class="grupo">
                                        <label class="col-md-1 xs control-label text-info">
                                            Desde
                                        </label>

                                        <div class="col-md-2">
%{--                                            <elm:datepicker name="accsFechaInicial" title="desde" minDate="+0" onChangeDate="validaFechas"--}%
%{--                                                            class="datepicker form-control required" daysOfWeekDisabled="0,6"/>--}%
                                            <input name="accsFechaInicial" id='datetimepicker1' type='text' class="form-control" onChangeDate="validaFechas"/>
                                        </div>
                                    </span>

                                    <span class="grupo">
                                        <label class="col-md-1 xs control-label text-info">
                                            Hasta
                                        </label>

                                        <div class="col-md-2">
%{--                                            <elm:datepicker name="accsFechaFinal" title="hasta" minDate="+0"--}%
%{--                                                            class="datepicker form-control required" daysOfWeekDisabled="0,6"/>--}%
                                            <input name="accsFechaFinal" id='datetimepicker2' type='text' class="form-control" onChangeDate="validaFechas"/>
                                        </div>
                                    </span>

                                    <span class="grupo">
                                        <label for="accsObservaciones" class="col-md-1 xs control-label text-info">
                                            Obsr.
                                        </label>

                                        <div class="col-md-3">
                                            <g:textField class=" form-control" name="accsObservaciones" style="width:100%;"/>
                                        </div>
                                    </span>
                                    <g:if test="${!usuario.esTrianguloOff() || triangulos.size() > 1}">
                                        <div class="col-md-2 text-center">
                                            <a href="#" class="btn btn-success" id="btnAccesos">
                                                <i class="fa fa-plus"></i> Agregar
                                            </a>
                                        </div>
                                    </g:if>
                                </div>

                                <div class="row">
                                    <g:if test="${usuario.esTrianguloOff() && triangulos.size() < 2}">
                                        <span class="grupo">
                                            <label for="accsObservaciones" class="col-md-3 xs control-label text-info" style="text-align: left">
                                                Nuevo usuario para recepción de tramites:
                                            </label>

                                            <div class="col-md-3">
                                                <g:select name="nuevoTriangulo" from="${personas}" id="nuevo-triangulo" class="requires form-control" optionKey="id"/>
                                            </div>
                                        </span>

                                        <div class="col-md-2 text-center">
                                            <a href="#" class="btn btn-success" id="btnAccesos-svt">
                                                <i class="fa fa-plus"></i> Agregar
                                            </a>
                                        </div>
                                    </g:if>
                                </div>

                            </div>
                        </g:form>
                        <div id="divAccesos"></div>
                    </div>
                </div>
            </div>
        </div>

        <script type="text/javascript">

            $(function () {
                $('#datetimepicker1, #datetimepicker2').datetimepicker({
                    locale: 'es',
                    format: 'DD-MM-YYYY',
                    daysOfWeekDisabled: [0, 6],
                    // inline: true,
                    // sideBySide: true,
                    showClose: true,
                    icons: {
                        close: 'closeText'
                    }
                });
            });

//             function validaFechas($elm, e) {
// //                var $ini = $("#accsFechaInicial_input");
//                 var $ini = $elm;
//                 // var $fin = $("#accsFechaFinal_input");
//                 var $fin = $("#accsFechaFinal");
// //                var ini = $ini.datepicker('getDate');
//                 var ini = e.date;
//                 var fin = $fin.datepicker('getDate');
//
//                 //si la fecha de fin es anterior a la de inicio se cambia a la de inicio
//                 // if (fin.compareTo(ini) == -1) {
//                 //     setDatepicker($fin, ini);
//                 // }
//                 // cambio el min date de la fecha final para q sea la fecha de inicio
//                 $fin.datepicker('setStartDate', ini);
//             }

            function loadAccesos() {
                var $div = $("#divAccesos");
                $div.html(spinnerSquare64);
                $.ajax({
                    type    : "POST",
                    url     : "${createLink(action:'accesos')}",
                    data    : {
                        id : "${usuario.id}"
                    },
                    success : function (msg) {
                        $div.html(msg);
                    }
                });
            }

            $(function () {
                var $btnAccesos = $("#btnAccesos");
                var $frmAccesos = $("#frmAccesos");
                var $btnPass = $("#btnPass");
                var $frmPass = $("#frmPass");

                $("#password_actual").val("");

                function submitPass() {
                    var url = $frmPass.attr("action");
                    var data = $frmPass.serialize();
                    $btnPass.hide().after(spinner);
                    $.ajax({
                        type    : "POST",
                        url     : url,
                        data    : data,
                        success : function (msg) {
                            var parts = msg.split("_");
                            log(parts[1], parts[0] == "OK" ? "success" : "error");
                            spinner.remove();
                            $btnPass.show();
                            $frmPass.find("input").val("");
                            validatorPass.resetForm();
                        }
                    });
                }

                loadAccesos();
                // loadFoto();

                $frmPass.find("input").keyup(function (ev) {
                    if (ev.keyCode == 13) {
                        submitPass();
                    }
                });
                var validatorTelf = $(".frmTelf").validate({
                    errorClass     : "help-block",
                    errorPlacement : function (error, element) {
                        if (element.parent().hasClass("input-group")) {
                            error.insertAfter(element.parent());
                        } else {
                            error.insertAfter(element);
                        }
                        element.parents(".grupo").addClass('has-error');
                    },

                    success : function (label) {
                        label.parents(".grupo").removeClass('has-error');
                    }
                });
                var validatorPass = $frmPass.validate({
                    errorClass     : "help-block",
                    errorPlacement : function (error, element) {
                        if (element.parent().hasClass("input-group")) {
                            error.insertAfter(element.parent());
                        } else {
                            error.insertAfter(element);
                        }
                        element.parents(".grupo").addClass('has-error');
                    },
                    rules          : {
                        password_actual : {
                            remote : {
                                url  : "${createLink(action:'validarPass_ajax')}",
                                type : "post"
                            }
                        }
                    },
                    messages       : {
                        password_actual : {
                            remote : "El password actual no coincide"
                        }
                    },
                    success        : function (label) {
                        label.parents(".grupo").removeClass('has-error');
                    }
                });
                $btnPass.click(function () {
                    submitPass();
                });
                $("#btnTelf").click(function () {
                    var url = $(".frmTelf").attr("action");
                    var data = $(".frmTelf").serialize();
                    if ($(".frmTelf").valid()) {
                        $("#btnTelf").hide().after(spinner);
                        $.ajax({
                            type    : "POST",
                            url     : url,
                            data    : data,
                            success : function (msg) {

                                var parts = msg.split("_");
                                log(parts[1], parts[0] == "OK" ? "success" : "error");
                                spinner.remove();
                                $("#btnTelf").show();
                                validatorTelf.resetForm();
                            }
                        });
                    }

                });

                $frmAccesos.validate({
                    errorClass     : "help-block",
                    errorPlacement : function (error, element) {
                        if (element.parent().hasClass("input-group")) {
                            error.insertAfter(element.parent());
                        } else {
                            error.insertAfter(element);
                        }
                        element.parents(".grupo").addClass('has-error');
                    },
                    success        : function (label) {
                        label.parents(".grupo").removeClass('has-error');
                    }
                });
                $btnAccesos.click(function () {
                    if ($frmAccesos.valid()) {
                        var url = $frmAccesos.attr("action");
                        var data = "usuario.id=${usuario.id}";
                        data += "&" + $frmAccesos.serialize();
                        $btnAccesos.hide().after(spinner);
                        $.ajax({
                            type    : "POST",
                            url     : url,
                            data    : data,
                            success : function (msg) {
                                var parts = msg.split("_");
                                if (parts.length == 3) {
                                    log(parts[1] + ". Usted será desconectado del sistema en 5 segundos", parts[0] == "OK" ? "success" : "error");
                                    spinner.remove();
                                    $("#btnAccesos-svt").show();
                                    $frmAccesos.find("input, textarea").val("");
                                    // $("#accsFechaInicial").val("date.struct");
                                    $("#datetimepicker1").val();
                                    // $("#accsFechaFinal").val("date.struct");
                                    $("#datetimepicker2").val();
                                    loadAccesos();
                                    setInterval(function () {
                                        location.href = "${g.createLink(controller: 'login',action: 'logout')}"
                                    }, 5000);
                                } else {
                                    log(parts[1], parts[0] == "OK" ? "success" : "error");
                                    spinner.remove();
                                    $("#btnAccesos-svt").show();
                                    $frmAccesos.find("input, textarea").val("");
                                    $("#datetimepicker1").val();
                                    $("#datetimepicker2").val();
                                    loadAccesos();
                                }
                            }
                        });
                    }
                    return false;
                });

                $("#btnAccesos-svt").click(function () {
                    if ($frmAccesos.valid()) {
                        if ($("#nuevo-triangulo").val() != "" && !isNaN($("#nuevo-triangulo").val())) {
                            var url = $frmAccesos.attr("action");
                            var data = "usuario.id=${usuario.id}";
                            data += "&" + $frmAccesos.serialize();
                            $("#btnAccesos-svt").hide().after(spinner);
                            $.ajax({
                                type    : "POST",
                                url     : url,
                                data    : data,
                                success : function (msg) {
                                    var parts = msg.split("_");

                                    if (parts.length == 3) {
                                        log(parts[1] + ". Usted será desconectado del sistema en 5 segundos", parts[0] == "OK" ? "success" : "error");
                                        spinner.remove();
                                        $("#btnAccesos-svt").show();
                                        $frmAccesos.find("input, textarea").val("");
                                        $("#datetimepicker1").val();
                                        $("#datetimepicker2").val();
                                        loadAccesos();
                                        setInterval(function () {
                                            location.href = "${g.createLink(controller: 'login',action: 'logout')}"
                                        }, 5000);
                                    } else {
                                        log(parts[1], parts[0] == "OK" ? "success" : "error");
                                        spinner.remove();
                                        $("#btnAccesos-svt").show();
                                        $frmAccesos.find("input, textarea").val("");
                                        $("#datetimepicker1").val();
                                        $("#datetimepicker2").val();
                                        loadAccesos();
                                    }
                                }
                            });
                        } else {
                            bootbox.alert("Debe escoger un usuario para asignarle las funciones de recepcón, en caso de no haber usuarios activos comuniquese con el administrador del sistema.")
                        }
                    }
                    return false;
                });
            });
        </script>
    </body>
</html>