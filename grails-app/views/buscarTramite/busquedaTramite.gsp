<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title>Búsqueda de Trámites</title>

    <style type="text/css">

    .esconder {
        visibility: hidden;
    }

    .largo {
        min-height: 140px !important;
    }

    </style>

</head>

<body>

<div style="min-height: 85px; margin-top: -15px;" class="vertical-container contenedor">
    <p class="css-vertical-text" style="margin-top: -10px;">Buscar</p>

    <div class="linea"></div>
    <div style="width: 100%">
        <div style="margin-bottom: 20px">
            <div class="col-xs-2">
                <label>Documento</label>
                <g:textField name="memorando" value="" maxlength="20" class="form-control allCaps"
                             style="width: 170px"/>
            </div>

            <div class="col-xs-2">
                <label>Asunto</label>
                <g:textField name="asunto" value=""  maxlength="30" class="form-control" style="width: 180px"/>
            </div>

            <div class="col-xs-2" style="margin-left: 10px">
                <label>Fecha Desde</label>
                <input name="fechaDsde" id='datetimepicker1' type='text' class="form-control"/>
            </div>

            <div class="col-xs-2" style="margin-left: -25px">
                <label>Fecha Hasta</label>
                <input name="fechaHsta" id='datetimepicker2' type='text' class="form-control"/>
            </div>
            <div class="col-xs-2" style="padding-top: 5px; height: 63px;">
                <div class="form-check form-check-inline">
                    <input class="form-check-input combo" type="checkbox" id="externo" name="externo"> <label class="text-info">Buscar externos</label>
                </div>

                <a href="#" name="busqueda" class="btn btn-success btn-ajax" id="btnBusqueda"><i
                        class="fa fa-search"></i> Buscar</a>
                <a href="#" name="borrar" class="btn btn-warning btnBorrar btn-sm" title="Borrar criterios">
                    <i class="fa fa-eraser"></i></a>
                <a href="#" name="excel_name" class="btn btn-primary btnExcel btn-sm" title="Exportar resultado a excel"><i
                        class="fa fa-file-excel"></i></a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div style="margin-left: 5px; display: inline-block; vertical-align: top; margin-top: -5px; float:left; color: #67a153" class="row">
            <g:radioGroup name="registros" labels="['Hasta 20 registros', 'Hasta 100 registros']" values="['20', '100']" value="20">
                <g:message code="${it.label}"/>: ${it.radio} <span style="margin-left: 20px"></span>
            </g:radioGroup>
        </div>

    </div>

    <div class="col-md-4">
        <div style="float: left; margin-left: 5px; margin-top: -5px; color: #ff8f5b">
            <g:radioGroup name="fechas" labels="['Fecha de creación', 'Fecha de envío']" values="['fccr', 'fcen']" value="fccr">
                <g:message code="${it.label}"/>: ${it.radio} <span style="margin-left: 20px"></span>
            </g:radioGroup>
        </div>
    </div>


    <div class="divExternos esconder text-info" style="width: 96%; margin-top: 10px; float: left" >
        <div class="col-xs-1">
            <label>Institución:</label>
        </div>
        <div class="col-xs-3" style="margin-left:-10Px">
            <g:textField name="institucion" value="" maxlength="30" class="form-control allCaps form-sm"/>
        </div>
        <div class="col-xs-1">
            <label>Documento Número:</label>
        </div>
        <div class="col-xs-3" style="margin-left:-10Px">
            <g:textField name="docExterno" value=""  maxlength="30" class="form-control allCaps"/>
        </div>
        <div class="col-xs-1">
            <label>Contacto:</label>
        </div>
        <div class="col-xs-3" style="margin-left:-10Px">
            <g:textField name="contacto" value="" maxlength="30" class="form-control allCaps"/>
        </div>
    </div>

</div>

<div style="margin-top: 5px; min-height: 525px" class="vertical-container" id="divBandeja">
    <p class="css-vertical-text">Resultado - Buscar trámites</p>
    <div class="linea"></div>

    <div id="bandeja">
    </div>
</div>

%{--<div><span class="text-info" style="margin-left: 30px"><strong> * Se ordena por tipo de documento y fecha</strong></span>--}%
<div><span class="text-info" style="margin-left: 30px"><strong> * Se ordena por fecha de creación del documento,
desde el más reciente hasta el más antiguo</strong></span>
</div>

<div class="modal fade " id="dialog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Detalles</h4>
            </div>

            <div class="modal-body" id="dialog-body" style="padding: 15px">

            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>


<script type="text/javascript">


    $.switcher('input[type=checkbox]');
    $.switcher('input[type=radio]');

    $(function () {
        $('#datetimepicker1, #datetimepicker2').datetimepicker({
            locale: 'es',
            format: 'DD-MM-YYYY',
            // daysOfWeekDisabled: [0, 6],
            // inline: true,
            // sideBySide: true,
            showClose: true,
            icons: {
                close: 'closeText'
            }
        });
    });

    $(".btnExcel").click(function () {

        var memorando = $("#memorando").val();
        var asunto = $("#asunto").val();
        var fecha = $("#datetimepicker1").val();
        var fechaHs = $("#datetimepicker2").val();
        var institucion;
        var doc;
        var contacto;
        var radio = $("[name='fechas']:checked").val()
        var rgst = $("[name='registros']:checked").val()
        var datos;

        if($(".combo").prop('checked') ==  true){
            institucion = $("#institucion").val();
            doc = $("#docExterno").val();
            contacto = $("#contacto").val();

            datos = "codigo=" + memorando + "&asunto=" + asunto + "&fcds=" + fecha + "&fchs=" + fechaHs +
                "&fechas=" + radio + "&institucion=" + institucion + "&doc=" + doc +
                "&registros=" + rgst + "&contacto=" + contacto + "&memo=" + memorando;
        }else{
            datos = "codigo=" + memorando + "&asunto=" + asunto + "&fcds=" + fecha + "&fchs=" + fechaHs +
                "&registros=" + rgst + "&fechas=" + radio + "&memo=" + memorando;
        }


        location.href='${createLink(controller: 'reportesPersonales', action: 'reporteExcelBusqueda')}?datos=' + datos
    });

    $(".combo").click(function () {
        $('.btnBorrar').click();
        // if($(this).prop('checked') ==  true){
        if($("#externo").is(':checked') ==  true){
            $(".contenedor").addClass('largo');
            $(".divExternos").removeClass('esconder')
        }else{
            $(".contenedor").removeClass('largo');
            $(".divExternos").addClass('esconder')
        }
    });

    function loading(div) {
        y = 0;
        $("#" + div).html("<div class='tituloChevere' id='loading'>Cargando, Espere por favor</div>");
        var interval = setInterval(function () {
            if (y == 30) {
                $("#detalle").html("<div class='tituloChevere' id='loading'>Cargando, Espere por favor</div>");
                y = 0
            }
            $("#loading").append(".");
            y++
        }, 500);
        return interval
    }

    var boton;

    $("#btnBusqueda").click(function () {
        // $("#btnBusqueda").hide(1500);
        $("#btnBusqueda").addClass('disabled');
        $("#bandeja").html("").append($("<div style='width:100%; float:left; text-align: center; margin-top:120px;'/>").append(spinnerSquare64));
        var memorando = $("#memorando").val();
        var asunto = $("#asunto").val();
        var fecha = $("#datetimepicker1").val();
        var fechaHs = $("#datetimepicker2").val();
        var institucion;
        var doc;
        var contacto;
        var radio = $("[name='fechas']:checked").val()
        var rgst = $("[name='registros']:checked").val()
        var datos;

        if($(".combo").prop('checked') ==  true){
            institucion = $("#institucion").val();
            doc = $("#docExterno").val();
            contacto = $("#contacto").val();

            datos = "codigo=" + memorando + "&asunto=" + asunto + "&fcds=" + fecha + "&fchs=" + fechaHs +
                "&fechas=" + radio + "&institucion=" + institucion + "&doc=" + doc +
                "&registros=" + rgst + "&contacto=" + contacto;
        }else{
            datos = "codigo=" + memorando + "&asunto=" + asunto + "&fcds=" + fecha + "&fchs=" + fechaHs +
                "&registros=" + rgst + "&fechas=" + radio;
        }

        $.ajax({
            type    : "POST",
            url     : "${g.createLink(controller: 'buscarTramite', action: 'tablaBusquedaTramite')}",
            data    : datos,
            success : function (msg) {
//                clearInterval(interval)
                $("#bandeja").html(msg);
                // $("#btnBusqueda").show(500);
                $("#btnBusqueda").removeClass('disabled');
            },
            error   : function (msg) {
                $("#bandeja").html("Ha ocurrido un error");
                // $("#btnBusqueda").show(500);
                $("#btnBusqueda").removeClass('disabled');
            }
        });

    });

    $("input").keyup(function (ev) {
        if (ev.keyCode == 13) {
            $("#btnBusqueda").click();
            $(":focus").blur()
        }
    });

    function createContextMenu(node) {

        var $tr = $(node);

        var items = {
            header : {
                label  : "Sin Acciones",
                header : true
            }
        };

        var id = $tr.data("id");
        var codigo = $tr.attr("codigo");
        var anulados = $tr.attr("anulados");
        var padre = $tr.attr("padre");
        var de = $tr.attr("de");
        var archivo = $tr.attr("departamento") + "/" + $tr.attr("anio") + "/" + $tr.attr("codigo");
        var idPxt = $tr.attr("prtr");
        var valAnexo = $tr.attr("anexo");

        var dptoId = $tr.data("de");

        var remitenteParts = $tr.attr("de").split("_");
        var remitenteTipo = remitenteParts[0];
        var remitenteId = remitenteParts[1];

        var porRecibir = $tr.hasClass("porRecibir");
        var sinRecepcion = $tr.hasClass("sinRecepcion");
        var recibido = $tr.hasClass("recibido");
        var retrasado = $tr.hasClass("retrasado");
        var externo = $tr.hasClass("externo");
        var externoCC = $tr.hasClass("externoCC");
        var conAnexo = $tr.hasClass("conAnexo");
        var conPadre = $tr.hasClass("padre");
        var esPrincipal = $tr.hasClass("principal");
        var anulado = $tr.hasClass("estado");
        var enviado = $tr.hasClass("enviado"); //enviado
        var porEnviar = $tr.hasClass("E001"); //por enviar

        var esMio = $tr.hasClass("mio");

        var depId = $tr.attr("dep");

        var tienePrincipal = $tr.attr("principal").toString() != '0' && $tr.attr("principal").toString() != $tr.attr("id");

        var paraMiDep = false;
        var para = $tr.attr("para");
        var respuestas = $tr.attr("respuestas");
        var paras = para.split(",");
        for (var i = 0; i < paras.length; i++) {
            var p = parseInt(paras[i]);
            if (p == ${session.usuario.departamentoId}) {
                paraMiDep = true;
            }
        }

        var infoRemitente = {
            label           : 'Información remitente',
            icon            : "fa fa-search",
            separator_afetr : true,
            action          : function (e) {
                var url = "", title = "";
                switch (remitenteTipo) {
                    case "D":
                        url = "${createLink(controller: 'departamento', action: 'show_ajax')}";
                        title = "Información del departamento";
                        break;
                    case "P":
                        url = "${createLink(controller: 'persona', action: 'show_ajax')}";
                        title = "Información de la persona";
                        break;
                    case "E":
                        title = "Información de entidad externa";
                        url = "${createLink(controller:'tramite3', action:'infoRemitente')}";
                        break;
                }
                $.ajax({
                    type    : 'POST',
                    url     : url,
                    data    : {
                        id      : remitenteId,
                        tramite : id
                    },
                    success : function (msg) {
                        bootbox.dialog({
                            title   : title,
                            message : msg,
                            buttons : {
                                aceptar : {
                                    label     : "Aceptar",
                                    className : "btn-primary",
                                    callback  : function () {

                                    }
                                }
                            }
                        });
                    }
                });
            }
        };

        var arbol = {
            label  : 'Cadena del trámite',
            icon   : "fa fa-sitemap",
            action : function (e) {
                location.href = '${createLink(controller: 'tramite3', action: 'arbolTramite')}/' + id + "?b=bqt"
            }
        };


        var parcialDetalle = {
            label  : 'Cadena a partir del trámite',
            icon   : "fa fa-puzzle-piece",
            action : function (e) {
                location.href = '${createLink(controller: 'tramite3', action: 'arbolTramiteParcial')}/' + id + "?b=bqt"
            }
        };


        var detalles = {
            label  : 'Detalles',
            icon   : "fa fa-search",
            action : function (e) {
                $("#dialog-body").html(spinner);
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'tramite3', action: 'detalles')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        $("#dialog-body").html(msg)
                    }
                });
                $("#dialog").modal("show");
            }
        };

        var crearHermano = {
            label  : "Agregar documento al trámite",
            icon   : "fa fa-paste",
            action : function () {
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'buscarTramite', action: 'verificarAgregarDoc')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        if (msg == "OK") {
                            <g:if test="${session.usuario.esTriangulo}">
                            location.href = '${createLink(controller: "tramite2", action: "crearTramiteDep")}?padre=' + padre + "&hermano=" + id + "&buscar=1&esRespuestaNueva=N";
                            </g:if>
                            <g:else>
                            location.href = '${createLink(controller: "tramite", action: "crearTramite")}?padre=' + padre + "&hermano=" + id + "&buscar=1&esRespuestaNueva=N";
                            </g:else>
                        } else {
                            bootbox.alert("No puede agregar documentos a este trámite (hr)");
                        }
                    }
                });
            }
        };

        var crearHijo = {
            label  : "Agregar documento al trámite",
            icon   : "fa fa-paste",
            action : function () {
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'buscarTramite', action: 'verificarAgregarDoc')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        if (msg == "OK") {
                            <g:if test="${session.usuario.esTriangulo}">
                            location.href = '${createLink(controller: "tramite2", action: "crearTramiteDep")}?hermano=' + id + "&buscar=1&esRespuestaNueva=N";
                            </g:if>
                            <g:else>
                            location.href = '${createLink(controller: "tramite", action: "crearTramite")}?hermano=' + id + "&buscar=1&esRespuestaNueva=N";
                            </g:else>
                        } else {
                            bootbox.alert("No puede agregar documentos a este trámite (hi)");
                        }
                    }
                });
            }
        };

        var administrar = {
            label  : "Administrar toda la cadena del trámite",
            icon   : "fa fa-cogs",
            action : function () {
                location.href = '${createLink(controller: "tramiteAdmin", action: "arbolAdminTramite")}?id=' + id;
            }
        };


        var parcialAdmin = {
            label  : 'Administrar a partir del trámite',
            icon   : "fa fa-cog",
            action : function () {
                location.href = '${createLink(controller: "tramiteAdmin", action: "arbolAdminTramiteParcial")}?id=' + id;
            }
        };


        var anexos = {
            label  : 'Anexos',
            icon   : "fa fa-paperclip",
            action : function (e) {
                location.href = '${createLink(controller: 'documentoTramite', action: 'verAnexos')}/' + id
            }
        };

        var ampliarPlazo = {
            label  : "Ampliar plazo",
            icon   : "fa fa-arrows-h",
            action : function (e) {
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'buscarTramite', action: 'ampliarPlazoUI_ajax')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        bootbox.dialog({
                            title   : "Ampliar plazo",
                            message : msg,
                            class   : "long",
                            buttons : {
                                cancelar : {
                                    label     : "Cancelar",
                                    className : "btn-primary",
                                    callback  : function () {
                                    }
                                },
                                guardar  : {
                                    label     : "<i class='fa fa-save'></i> Guardar",
                                    className : "btn-success",
                                    callback  : function () {
                                        var $frm = $("#frm-ampliar");
                                        var $txt = $("#aut");
                                        if ($frm.valid()) {
//                                                    if (validaAutorizacion($txt)) {
                                            openLoader("Ampliando plazo");
                                            $.ajax({
                                                type    : "POST",
                                                url     : $frm.attr("action"),
                                                data    : $frm.serialize(),
                                                success : function (msg) {
                                                    var parts = msg.split("_");
                                                    log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                                                    closeLoader();
                                                }
                                            });
                                        }
                                    }
                                }
                            }
                        });
                    }
                });
            }
        };

        var copia = {
            separator_before : true,
            label            : "Crear Copia",
            icon             : "fa fa-files-o",
            action           : function () {
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'tramite3', action: 'verificarEstado')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        if (msg == "ok") {
                            $.ajax({
                                type    : "POST",
                                url     : "${createLink(controller: 'tramiteAdmin', action:'copiaParaLista_ajax')}",
                                data    : {
                                    tramite : id
                                },
                                success : function (msg) {
                                    bootbox.dialog({
                                        id      : "dlgCopiaPara",
                                        title   : '<i class="fa fa-files-o"></i> Copia para',
                                        class   : "long",
                                        message : msg,
                                        buttons : {
                                            cancelar : {
                                                label     : '<i class="fa fa-times"></i> Cancelar',
                                                className : 'btn-danger',
                                                callback  : function () {
                                                }
                                            },
                                            enviar   : {
                                                id        : 'btnEnviarCopia',
                                                label     : '<i class="fa fa-check"></i> Enviar copias',
                                                className : "btn-success",
                                                callback  : function () {
                                                    var cc = "";
                                                    $("#ulSeleccionados li").not(".disabled").each(function () {
                                                        cc += $(this).data("id") + "_";
                                                    });
                                                    openLoader("Enviando copias");
                                                    $.ajax({
                                                        type    : "POST",
                                                        url     : "${createLink(controller: 'tramiteAdmin', action:'enviarCopias_ajax')}",
                                                        data    : {
                                                            tramite : id,
                                                            copias  : cc
                                                        },
                                                        success : function (msg) {
                                                            var parts = msg.split("*");
                                                            if (parts[0] == 'OK') {
                                                                log("Copias enviadas exitosamente", 'success');
                                                                setTimeout(function () {
                                                                    location.reload(true);
                                                                }, 500);
                                                            } else if (parts[0] == 'NO') {
                                                                closeLoader();
                                                                log(parts[1], 'error');
                                                            }
                                                        }
                                                    });
                                                }
                                            }
                                        }
                                    });
                                }
                            });

                        } else
                            bootbox.alert("El documento esta anulado, por favor refresque su bandeja de salida.")
                    }
                });
            }
        };


        var imprimir = {
            label  : "Ver - Imprimir",
            icon   : "fa fa-search",
            action : function () {
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'tramite3', action: 'verificarEstado')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        if (msg == "ok"){
                            var timestamp = new Date().getTime();
                            location.href = "${createLink(controller:'tramiteExport',action:'crearPdf')}?id=" + id + "&type=download" + "&enviar=1" + "&timestamp=" + timestamp;
                        }
                        else{
                            bootbox.alert("El documento esta anulado, por favor refresque su bandeja de salida.")}
                    }
                });
            }
        }; //ver

        items.infoRemitente = infoRemitente;

        items.header.label = "Acciones";
        <g:if test="${session.usuario.getPuedeVer()}">
        items.detalles = detalles;
        items.arbol = arbol;
        items.parcialDetalle = parcialDetalle;

        </g:if>
        <g:if test="${session.usuario.getPuedeAdmin()}">
        items.administrar = administrar;
        items.parcialAdmin = parcialAdmin;
        </g:if>
        if (esMio) {
            items.imprimir = imprimir;
            if (conPadre) {
                items.crearHermano = crearHermano;
            } else {
                if(!porEnviar){
                    items.crearHijo = crearHijo;

                }
            }
        }


        if (enviado || recibido) {
            <g:if test="${session.usuario.getPuedeCopiar()}">
            if (esMio) {
                items.copia = copia;
            }
            </g:if>
        }

        return items
    }

    $(".btnBorrar").click(function () {
        $("#memorando").val("");
        $("#asunto").val("");
        $("#fechaDsde_input").val('');
        $("#fechaHsta_input").val('');
        $("#contacto").val('');
        $("#docExterno").val('');
        $("#institucion").val('');

    });

    $( document ).ready(function() {
        $('.btnBorrar').click();
        $('#externo').attr('checked', false);
    });

</script>

</body>
</html>