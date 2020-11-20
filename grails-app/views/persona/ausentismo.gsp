<%--
  Created by IntelliJ IDEA.
  User: luz
  Date: 1/16/14
  Time: 12:48 PM
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <meta name="layout" content="main">
        <title>Ausentismo</title>

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
                <g:link class="btn btn-default col-md-1" controller="persona" action="list"><i class="fa fa-arrow-left"></i> Regresar</g:link>
                <span class="col-md-11" style="text-align: center">
                    <div class="panel panel-default" style="margin-left: 30px;">
                        <div class="panel-heading">Ausentismo: permisos y vacaciones de: <strong>${usuario.nombre} ${usuario.apellido}</strong>
                        </div>
                    </div>
                </span>
            </div>
        </div>

        <div class="panel-group" id="accordion">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title">
                        Ausentismo <small>Permisos, vacaciones, etc.</small>
                    </h4>
                </div>

                <div id="collapseAcceso" class="panel-collapse collapse in">
                    <div class="panel-body">
                        <h4>Agregar ausentismo</h4>

                        <p>
                            El usuario se hallará ausente entre las fechas seleccionadas (inclusive).
                        </p>
                        <g:form class="form-horizontal" name="frmAccesos" role="form" action="saveAccesos_ajax" method="POST">
                            <div class="form-group required">
                                <span class="grupo">
                                    <label for="accsFechaInicial" class="col-md-1 xs control-label text-info">
                                        Desde
                                    </label>

                                    <div class="col-md-2">
                                        <elm:datepicker name="accsFechaInicial" title="desde"
                                                        class="datepicker form-control required" daysOfWeekDisabled="0,6"
                                                        onChangeDate="validarFechasAcceso"/>
                                    </div>
                                </span>

                                <span class="grupo">
                                    <label for="accsFechaFinal" class="col-md-1 xs control-label text-info">
                                        Hasta
                                    </label>

                                    <div class="col-md-2">
                                        <elm:datepicker name="accsFechaFinal" title="hasta"
                                                        class="datepicker form-control required" daysOfWeekDisabled="0,6"/>
                                    </div>
                                </span>

                                <span class="grupo">
                                    <label for="accsObservaciones" class="col-md-1 xs control-label text-info">
                                        Obs.
                                    </label>

                                    <div class="col-md-4">
                                        <g:textField class=" form-control" name="accsObservaciones" style="width:100%;"/>
                                    </div>
                                </span>

                                <div class="col-md-2 text-center">
                                    <a href="#" class="btn btn-success" id="btnAccesos">
                                        <i class="fa fa-plus"></i> Agregar
                                    </a>
                                </div>
                            </div>
                        </g:form>
                        <div id="divAccesos"></div>
                    </div>
                </div>
            </div>

        </div>

        <script type="text/javascript">

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
            function loadPermisos() {
                var $div = $("#divPermisos");
                $div.html(spinnerSquare64);
                $.ajax({
                    type    : "POST",
                    url     : "${createLink(action:'permisos')}",
                    data    : {
                        id : "${usuario.id}"
                    },
                    success : function (msg) {
                        $div.html(msg);
                    }
                });
            }

            function validarFechasAcceso($elm, e) {
                var fecha = e.date;
                var $hasta = $("#accsFechaFinal_input");
                if ($hasta.datepicker('getDate') < fecha) {
                    $hasta.datepicker('setDate', fecha);
                }
                $hasta.datepicker('setStartDate', fecha);
            }

            function validarFechasPermiso($elm, e) {
                var fecha = e.date;
                var $hasta = $("#fechaFin_input");
                if ($hasta.datepicker('getDate') < fecha) {
                    $hasta.datepicker('setDate', fecha);
                }
                $hasta.datepicker('setStartDate', fecha);
            }

            $(function () {
                var $btnPerfiles = $("#btnPerfiles");
                var $btnPermisos = $("#btnPermisos");
                var $btnAccesos = $("#btnAccesos");

                loadPermisos();
                loadAccesos();

                $("#frmAccesos, #frmPermisos").validate({
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

                function doSave(url, data) {
                    $btnPerfiles.hide().after(spinner);
                    openLoader("Grabando");
                    $.ajax({
                        type    : "POST",
                        url     : url,
                        data    : data,
                        success : function (msg) {
                            closeLoader();
                            var parts = msg.split("_");
                            log(parts[1], parts[0] == "OK" ? "success" : "error");
                            spinner.remove();
                            $btnPerfiles.show();
                        }
                    });
                }

                $("#allPerf").click(function () {
                    $(".perfil .fa-li").removeClass("fa-square-o").addClass("fa-check-square");
                    return false;
                });

                $("#nonePerf").click(function () {
                    $(".perfil .fa-li").removeClass("fa-check-square").addClass("fa-square-o");
                    return false;
                });

                $(".perfil .fa-li, .perfil span").click(function () {
                    var ico = $(this).parent(".perfil").find(".fa-li");
                    if (ico.hasClass("fa-check-square")) { //descheckear
                        ico.removeClass("fa-check-square").addClass("fa-square-o");
                    } else { //checkear
                        ico.removeClass("fa-square-o").addClass("fa-check-square");
                    }
                });

                $btnPerfiles.click(function () {
                    var $frm = $("#frmPerfiles");
                    var url = $frm.attr("action");
                    var data = "id=${usuario.id}";
                    var band = false;
                    $(".perfil .fa-li").each(function () {
                        var ico = $(this);
                        if (ico.hasClass("fa-check-square")) {
                            data += "&perfil=" + ico.data("id");
                            band = true;
                        }
                    });
                    if (!band) {
                        bootbox.confirm("<i class='fa fa-warning fa-3x pull-left text-warning text-shadow'></i><p>No ha seleccionado ningún perfil. El usuario no podrá ingresar al sistema. ¿Desea continuar?.</p>", function (result) {
                            if (result) {
                                doSave(url, data);
                            }
                        })
                    } else {
                        doSave(url, data);
                    }
                    return false;
                });

                $btnPermisos.click(function () {
                    var $frm = $("#frmPermisos");
                    if ($frm.valid()) {
                        var url = $frm.attr("action");
                        var data = "persona.id=${usuario.id}";
                        data += "&" + $frm.serialize();
                        $btnPermisos.hide().after(spinner);
                        $.ajax({
                            type    : "POST",
                            url     : url,
                            data    : data,
                            success : function (msg) {
                                var parts = msg.split("_");
                                log(parts[1], parts[0] == "OK" ? "success" : "error");
                                spinner.remove();
                                $btnPermisos.show();
                                $frm.find("input, textarea").val("");
                                $("#fechaInicio").val("date.struct");
                                $("#fechaFin").val("date.struct");
                                loadPermisos();
                            }
                        });
                    }
                    return false;
                });

                $btnAccesos.click(function () {
                    var $frm = $("#frmAccesos");
                    if ($frm.valid()) {
                        var url = $frm.attr("action");
                        var data = "usuario.id=${usuario.id}";
                        data += "&" + $frm.serialize();
                        $btnAccesos.hide().after(spinner);
                        $.ajax({
                            type    : "POST",
                            url     : url,
                            data    : data,
                            success : function (msg) {
                                var parts = msg.split("_");
                                log(parts[1], parts[0] == "OK" ? "success" : "error");
                                spinner.remove();
                                $btnAccesos.show();
                                $frm.find("input, textarea").val("");
                                $("#accsFechaInicial").val("date.struct");
                                $("#accsFechaFinal").val("date.struct");
                                loadAccesos();
                            }
                        });
                    }

                    return false;
                });

            });
        </script>

    </body>
</html>