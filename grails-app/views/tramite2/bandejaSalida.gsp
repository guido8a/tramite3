
<%@ page import="tramites.EstadoTramite; org.apache.commons.lang.WordUtils;" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main2">
    <title>Bandeja de Salida</title>

    <style type="text/css">

    body {
        background-color : #F0F0FD;
    }

    .etiqueta {
        float       : left;
        margin-left : 5px;
    }

    .alertas {
        float       : left;
        margin-left : 20px;
        padding     : 10px;
        cursor      : pointer;
    }

    .alert-blanco {
        color            : #666;
        background-color : #ffffff;
        border-color     : #d0d0d0;
    }

    th {
        text-align : center;
    }

    .cabecera {
        font-size : 13px;
    }

    .cabecera.sortable {
        cursor : pointer;
    }

    .container-celdas {
        width    : 1070px;
        height   : 310px;
        float    : left;
        overflow : auto;
    }

    .table-hover tbody tr:hover td, .table-hover tbody tr:hover th {
        background-color : #FFBD4C;
    }

    .enviado {
        background-color : #e0e0e0;
        border           : 1px solid #a5a5a5;
    }

    .borrador {
        background-color : #FFFFCC;
        border           : 1px solid #eaeab7;
    }

    tr.E002, tr.revisadoColor td {
        background-color : #DFF0D8 ! important;
    }

    tr.E001, tr.borrador td {
        background-color : #FFFFCC ! important;
    }

    tr.E003, tr.enviado td {
        background-color : #e0e0e0 ! important;
    }

    tr.alerta, tr.alerta td {
        background-color : #f2c1b9;
        font-weight      : bold;
    }

    .letra {
        background-color : #8fc6f3;
    }

    .para {
        font-weight : bold;
        font-size   : 9pt;
    }

    .copias {
        font-size : 8pt;
    }
    </style>
</head>

<body>
<div class="row" style="margin-top: 0; margin-left: 1px">
    <span class="grupo">
        <label class="well well-sm letra text-info" style="text-align: center">
            <i class="fa fa-hand-point-left fa-2x text-info"></i> BANDEJA DE SALIDA PERSONAL
        </label>
    </span>

    <span class="grupo">
        <label class="well well-sm" style="text-align: center">
            <strong class="text-success">Usuario:</strong>   ${persona?.nombre + " " + persona?.apellido}
        </label>
    </span>
    <span class="grupo">
        <label class="well well-sm" style="text-align: center;">
            <strong class="text-success">Departamento:</strong> ${persona?.departamento?.descripcion}
        </label>
    </span>
</div>

<elm:flashMessage tipo="${flash.tipo}" clase="${flash.clase}">${flash.message}</elm:flashMessage>

<div class="btn-toolbar toolbar" style="margin-top: 10px !important">
    <div class="btn-group">
        <a href="#" class="btn btn-primary btnBuscar"><i class="fa fa-search"></i> Buscar</a>

        <g:link action="" class="btn btn-info btnActualizar">
            <i class="fa fa-sync-alt"></i> Actualizar
        </g:link>
        <g:if test="${!esEditor}">
            <g:link action="" class="btn btn-success btnEnviar">
                <i class="fa fa-paper-plane"></i> Enviar
            </g:link>
        </g:if>
    </div>

    <div style="float: right">
        <div data-type="" class="alert borrador alertas" clase="E001">
            <span id="numBor" class="badge badge-light"></span>
            ${WordUtils.capitalizeFully(tramites.EstadoTramite.findByCodigo('E001').descripcion)}
        </div>

        <div data-type="enviado" class="alert enviado alertas" clase="E003">
            <span id="numEnv" class="badge badge-light"></span>
            ${WordUtils.capitalizeFully(EstadoTramite.findByCodigo('E003').descripcion)}
        </div>

        <div data-type="noRecibido" class="alert alert-danger alertas" clase="alerta" title="No incluye copias">
            <span id="numNoRec" class="badge badge-light"></span>
            Sin Recepción
        </div>
    </div>
</div>

<div class="buscar" hidden="hidden" style="margin-bottom: 20px">

    <fieldset>
        <legend>Búsqueda</legend>

        <div>
            <div class="col-md-2">
                <label>Documento</label>
                <g:textField name="memorando" value="" maxlength="15" class="form-control allCaps"/>
            </div>

            <div class="col-md-2">
                <label>Asunto</label>
                <g:textField name="asunto" value="" style="width: 300px" maxlength="30" class="form-control"/>
            </div>

            <div class="col-md-2" style="margin-left: 130px">
                <label>Fecha Envío</label>
                <input name="fechaBusqueda" id='datetimepicker1' type='text' class="form-control"/>
            </div>

            <div style="padding-top: 25px">
                <a href="#" name="busqueda" class="btn btn-primary btnBusqueda"><i
                        class="fa fa-search"></i> Buscar</a>

                <a href="#" name="salir" class="btn btn-danger btnSalir"><i class="fa fa-times"></i> Cerrar</a>
            </div>

        </div>

    </fieldset>

</div>

<div id="" style=";height: 600px;overflow: auto;position: relative">
    <div class="modalTabelGray" id="bloqueo-salida"></div>

    <div id="bandeja">
        <table class="table table-bordered  table-condensed table-hover">
            <thead>
            <tr style="width: 100%">
                <th style="width: 12%" class="cabecera sortable ${params.sort == 'trmtcdgo' ? (params.order + ' sorted') : ''}" data-sort="trmtcdgo" data-order="${params.order}">Documento</th>
                <th style="width: 9%">De</th>
                <th style="width: 10%" class="cabecera sortable ${params.sort == 'trmtfccr' ? (params.order + ' sorted') : ''}" data-sort="trmtfccr" data-order="${params.order}">Fec. Creación</th>
                <th style="width: 4%" class="cabecera sortable ${params.sort == 'prtrdpto' ? (params.order + ' sorted') : ''}" data-sort="prtrdpto" data-order="${params.order}">Para</th>
                <th style="width: 24%">Destinatario</th>
                <th style="width: 7%" class="cabecera sortable ${params.sort == 'trmttppd' ? (params.order + ' sorted') : ''}" data-sort="trmttppd" data-order="${params.order}">Prioridad</th>
                <th style="width: 10%" class="cabecera sortable ${params.sort == 'trmtfcen' ? (params.order + ' sorted') : ''}" data-sort="trmtfcen" data-order="${params.order}">Fecha Envío</th>
                <th style="width: 10%" class="cabecera sortable ${params.sort == 'trmtfcbq' ? (params.order + ' sorted') : ''}" data-sort="trmtfcbq" data-order="${params.order}">F. Límite Recepción</th>
                <th style="width: 8%" class="cabecera sortable ${params.sort == 'edtrdscr' ? (params.order + ' sorted') : ''}" data-sort="edtrdscr" data-order="${params.order}">Estado</th>
                <th style="width: 6%">Enviar</th>
                <th style="width: 1%"></th>
            </tr>
            </thead>
        </table>
        <div style="width: 99.7%;height: 350px; overflow-y: auto; margin-top: -20px">
            <table class="table-bordered table-condensed table-hover" width="100%">
                <tbody id="tabla_bandeja">

                </tbody>
            </table>
        </div>
    </div>
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

    $(function () {
        $('#datetimepicker1').datetimepicker({
            locale: 'es',
            format: 'DD-MM-YYYY',
            showClose: true,
            icons: {
                close: 'closeText'
            }
        });
    });

    function cargarBandeja() {
        var memorando = $("#memorando").val();
        var asunto = $("#asunto").val();
        var fecha = $("#fechaBusqueda").val();
        var $sorted = $(".sorted");
        var sort = $sorted.data("sort");
        var order = $sorted.data("order");

        // $(".qtip").hide();
        $("#tabla_bandeja").html("").append($("<div style='width:100%; text-align: center;'/>").append(spinnerSquare64));

        var datos = {
            memorando : memorando,
            asunto    : asunto,
            fecha     : fecha,
            sort      : sort,
            order     : order
        };

        $.ajax({
            type    : "POST",
            url     : "${g.createLink(controller: 'tramite2',action:'tablaBandejaSalida')}",
            data    : datos,
            success : function (msg) {
                $("#tabla_bandeja").html(msg);
                cargarAlertas();
            }
        });
    }

    function cargarAlertas() {
        $("#numRev").html($(".E002").size()); //revisados
        $("#numEnv").html($(".E003").size()); //enviados
        $("#numNoRec").html($(".alerta").size()); //no recibidos
        $("#numBor").html($(".E001").size()); //borradores
    }

    function doEnviar(imprimir, strIds) {
        var cl3 = cargarLoader("Enviando...");
        $.ajax({
            type    : "POST",
            url     : "${g.createLink(controller: 'tramite2',action: 'enviarVarios')}",
            data    : {
                ids    : strIds,
                enviar : '1',
                type   : 'download'
            },
            success : function (msg) {
                cl3.modal("hide")
                var parts = msg.split("_");
                if (parts[0] == 'ok') {
                    log('Trámites Enviados' + parts[1], 'success');
                    cargarBandeja(true);
                    if (imprimir) {
                        location.href = "${g.createLink(controller: 'tramiteExport' ,action: 'imprimirGuia')}?ids=" +
                            strIds + "&departamento=" + '${persona?.departamento?.descripcion}';
                    }
                } else {
                    log('Ocurrió un error al enviar los trámites seleccionados!<br>' + parts[1], 'error');
                }
                cargarBandeja();
            }
        });
    }

    function createContextMenu(node) {
        var $tr = $(node);

        var items = {
            header : {
                label  : "Sin Acciones",
                header : true
            }
        };

        <g:if test="${!bloqueo}">
        var id = $tr.data("id");
        var codigo = $tr.attr("codigo");
        var estado = $tr.attr("estado");
        var padre = $tr.attr("padre");
        var de = $tr.attr("de");
        var archivo = $tr.attr("departamento") + "/" + $tr.attr("anio") + "/" + $tr.attr("codigo");

        var porEnviar = $tr.hasClass("E001"); //por enviar
        var revisado = $tr.hasClass("E002"); //revisado
        var enviado = $tr.hasClass("E003"); //enviado
        var recibido = $tr.hasClass("E004"); //recibido

        var esSumilla = $tr.hasClass("sumilla");
        var esExterno = $tr.hasClass("externo");
        var esOficio = $tr.hasClass("OFI");
        var tieneEstado = $tr.hasClass("estado");
        var esDex = $tr.hasClass("DEX");
        var tienePadre = $tr.hasClass("conPadre");
        var tieneAlerta = $tr.hasClass("alerta");
        var tieneAnexo = $tr.hasClass("conAnexo");

        var puedeImprimir = $tr.hasClass("imprimir");
        var puedeDesenviar = $tr.hasClass("desenviar");

        var esRespuestaNueva = $tr.attr("ern");
        var esExternoCC = $tr.hasClass("externoCC");

        var copia = {
            separator_before : true,
            label            : "Copia para",
            icon             : "fa fa-copy",
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
                                        title   : '<i class="fa fa-copy"></i> Copia para',
                                        class   : "modal-lg",
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
                                                    var cl4 = cargarLoader("Enviando...");
                                                    var cc = "";
                                                    $("#ulSeleccionados li").not(".disabled").each(function () {
                                                        cc += $(this).data("id") + "_";
                                                    });
                                                    $.ajax({
                                                        type    : "POST",
                                                        url     : "${createLink(controller: 'tramiteAdmin', action:'enviarCopias_ajax')}",
                                                        data    : {
                                                            tramite : id,
                                                            copias  : cc
                                                        },
                                                        success : function (msg) {
                                                            cl4.modal("hide");
                                                            var parts = msg.split("*");
                                                            if (parts[0] == 'OK') {
                                                                log("Copias enviadas exitosamente", 'success');
                                                                setTimeout(function () {
                                                                    location.reload(true);
                                                                }, 500);
                                                            } else if (msg == 'NO') {
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

                        } else {
                            bootbox.alert("El documento esta anulado, por favor refresque su bandeja de salida.")
                        }
                    }
                });
            }
        };

        var recibirExterno = {
            label  : 'Confirmar recepción destinatarios externos',
            icon   : "fa fa-user-check",
            action : function (e) {
                $.ajax({
                    type    : "POST",
                    url     : '${createLink(action:'recibirExternoLista_ajax')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        //s.indexOf("oo") > -1
                        var buttons = {};
                        if (msg.indexOf("No puede") > -1) {
                            buttons.aceptar = {
                                label     : "Aceptar",
                                className : "btn-primary",
                                callback  : function () {
                                    openLoader();
                                    location.reload(true);
                                }
                            }
                        } else {
                            buttons.cancelar = {
                                label     : "Cancelar",
                                className : "btn-primary",
                                callback  : function () {
                                }
                            };
                            buttons.desenviar = {
                                label     : "<i class='fa fa-check'></i> Confirmar recepción",
                                className : "btn-success",
                                callback  : function () {
                                    var ids = "";
                                    $(".chkOne").each(function () {
                                        if ($(this).hasClass("fa-check-square")) {
                                            if (ids != "") {
                                                ids += "_"
                                            }
                                            ids += $(this).attr("id");
                                        }
                                    });
                                    if (ids) {
                                        openLoader("");
                                        $.ajax({
                                            type    : "POST",
                                            url     : '${createLink(controller: 'externos', action:'recibirTramitesExternos_ajax')}',
                                            data    : {
                                                id  : id,
                                                ids : ids
                                            },
                                            success : function (msg) {
                                                var parts = msg.split("_");
                                                log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                                                if (parts[0] == "OK") {
                                                    setTimeout(function () {
                                                        $("#bloqueo-warning").hide();
                                                        location.href = "${createLink(controller: "tramite2", action: "bandejaSalida")}";
                                                    }, 1000);
                                                    cargarBandeja();
                                                } else {
                                                    closeLoader();
                                                }
                                            }
                                        });
                                    } else {
                                        log('No seleccionó ninguna persona', 'error');
                                    }
                                }
                            };
                        }

                        bootbox.dialog({
                            title   : "Alerta",
                            message : msg,
                            buttons : buttons
                        });
                    }
                });
            } //action
        };

        var permisoImprimir = {
            label  : "Permiso de Imprimir",
            icon   : "fa fa-cog",
            action : function () {
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'tramite2', action: 'permisoImprimir_ajax')}/' + id,
                    success : function (msg) {
                        bootbox.dialog({
                            id      : "dlgImprimir",
                            title   : "Permiso de impresión para el trámite:  " + codigo,
                            message : msg,
                            buttons : {
                                cancelar : {
                                    label     : '<i class="fa fa-times"></i> Cancelar',
                                    className : 'btn-danger',
                                    callback  : function () {
                                    }
                                },
                                guardar  : {
                                    id        : 'btnSave',
                                    label     : '<i class="fa fa-save"></i> Aceptar',
                                    className : "btn-success",
                                    callback  : function () {
                                        var cl1 = cargarLoader("Guardando...");
                                        $.ajax({
                                            type    : 'POST',
                                            url     : '${createLink(action: 'permisoImprimir')}/' + id,
                                            data    : {
                                                persona       : $("#iden").val(),
                                                observaciones : $("#observImp").val()
                                            },
                                            success : function (msg) {
                                                cl1.modal("hide");
                                                var parts = msg.split("_");
                                                if(parts[0] == 'ok'){
                                                    log(parts[1],"success")
                                                }else{
                                                    if(parts[0] == 'er'){
                                                        bootbox.alert('<span class="text-warning"><i class="fa fa-exclamation-triangle"></i>' + parts[1])
                                                    }else{
                                                        log(parts[1],"error")
                                                    }
                                                }

                                            }
                                        });
                                    }
                                }
                            }
                        });
                    }
                }); //ajax
            }
        }; //imprimir

        var ver = {
            label  : "Ver - Imprimir",
            icon   : "fa fa-print",
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
                            location.href = "${createLink(controller:'tramiteExport',action:'crearPdf')}?id=" + id + "&type=download" + "&enviar=1" + "&timestamp=" + timestamp}

                        else
                            bootbox.alert("El documento esta anulado, por favor refresque su bandeja de salida.")
                    }
                });
            }
        }; //ver

        /* completar todo **/
        var firmar = {
            label  : "Firma electrónica",
            icon   : "fa fa-lock",
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
                            location.href = "${createLink(controller:'tramiteExport',action:'crearPdf')}?id=" + id + "&type=download" + "&enviar=1" + "&timestamp=" + timestamp}

                        else
                            bootbox.alert("El documento esta anulado, por favor refresque su bandeja de salida.")
                    }
                });
            }
        }; //firmar

        var detalles = {
            label  : "Detalles",
            icon   : "fa fa-search",
            action : function () {
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
        }; //detalles

        var arbol = {
            label : "Cadena del trámite",
            icon  : "fa fa-sitemap",
            url   : '${createLink(controller: 'tramite3', action: 'arbolTramite')}/' + id + "?b=bsp"
        }; //arbol

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
                            bootbox.alert("No puede agregar documentos a este trámite");
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
                            bootbox.alert("No puede agregar documentos a este trámite");
                        }
                    }
                });
            }
        };

        var editar = {
            label : "Editar",
            icon  : "fa fa-edit",
            url   : "${g.createLink(action: 'redactar',controller: 'tramite')}/" + id
        }; //editar

        var editarSumilla = {
            label : "Editar",
            icon  : "fa fa-pencil",
            url   : "${g.createLink(action: 'crearTramite',controller: 'tramite')}/" + id + "?esRespuestaNueva=" + esRespuestaNueva
        }; //editar sumilla

        var anexos = {
            label : "Anexos",
            icon  : "fa fa-paperclip",
            url   : '${createLink(controller: 'documentoTramite', action: 'verAnexos')}/' + id
        }; //anexos

        var anular = {
            label  : 'Anular trámite',
            icon   : "fa fa-ban",
            action: function () {
                $.ajax({
                    type: 'POST',
                    url: "${createLink(controller: 'tramite2', action: 'revisarHijos')}",
                    data:{
                        id: id
                    },
                    success: function (msg){
                        if(msg == 'ok'){
                            bootbox.alert('<i class="fa fa-exclamation-triangle fa-2x text-danger"></i> No se puede anular el trámite, ya que posee trámites derivados');
                        }else{
                            $.ajax({
                                type    : "POST",
                                url     : "${createLink(controller: 'tramiteAdmin', action: 'dialogAnulados')}",
                                data    : {
                                    id   : id,
                                    tipo: 1,
                                    msg  : "<p class='lead'> El trámite está por ser anulado. Está seguro?</p>",
                                    icon : "fa-ban"
                                },
                                success : function (msg) {
                                    bootbox.dialog({
                                        id      : "dlgAnular",
                                        title   : '<span class="text-danger"><i class="fa fa-ban"></i> Anular Tramite</span>',
                                        message : msg,
                                        buttons : {
                                            cancelar : {
                                                label     : '<i class="fa fa-times"></i> Cancelar',
                                                className : 'btn-danger',
                                                callback  : function () {
                                                }
                                            },
                                            anular   : {
                                                id        : 'btnArchivar',
                                                label     : '<i class="fa fa-check"></i> Anular',
                                                className : "btn-success",
                                                callback  : function () {
                                                    var cl2 = cargarLoader("Anulando...");
                                                    var $txt = $("#aut");
                                                    if (validaAutorizacion($txt)) {
                                                        $.ajax({
                                                            type    : 'POST',
                                                            url     : '${createLink(controller: "tramiteAdmin", action: "anularNuevo")}',
                                                            data    : {
                                                                id    : id,
                                                                tipo : 1,
                                                                texto : $("#observacion").val(),
                                                                aut   : $txt.val()
                                                            },
                                                            success : function (msg) {
                                                                cl2.modal("hide");
                                                                var parts = msg.split("*");
                                                                if (parts[0] == 'OK') {
                                                                    log("Trámite anulado correctamente", 'success');
                                                                    setTimeout(function () {
                                                                        location.href = "${createLink(controller: "tramite2", action: "bandejaSalida")}";
                                                                    }, 500);
                                                                } else if (parts[0] == 'NO') {
                                                                    log(parts[1], 'error');
                                                                    setTimeout(function () {
                                                                        location.href = "${createLink(controller: "tramite2", action: "bandejaSalida")}";
                                                                    }, 600);
                                                                }
                                                            }
                                                        });
                                                    } else {
                                                        return false;
                                                    }
                                                }
                                            }
                                        }
                                    });
                                }
                            });
                        }
                    }
                });
            }
        };//anular

        var desenviar = {
            label  : "Quitar el enviado",
            icon   : "fa fa-magic text-danger",
            action : function () {
                $.ajax({
                    type    : "POST",
                    url     : '${createLink(action:'desenviarLista_ajax')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        if(msg == 'error'){
                            bootbox.alert('<strong>' + "No se puede quitar el enviado del trámite, debido a que posee trámites derivados." + '</strong>')
                        }else{
                            var buttons = {};
                            if (msg.indexOf("No puede quitar el enviado") > -1) {
                                buttons.aceptar = {
                                    label     : "Aceptar",
                                    className : "btn-primary",
                                    callback  : function () {
                                        openLoader();
                                        location.reload(true);
                                    }
                                }
                            } else {
                                buttons.cancelar = {
                                    label     : "Cancelar",
                                    className : "btn-primary",
                                    callback  : function () {
                                    }
                                };
                                buttons.desenviar = {
                                    label     : "<i class='fa fa-magic'></i> Quitar enviado",
                                    className : "btn-danger",
                                    callback  : function () {
                                        var ids = "";
                                        $(".chkOne").each(function () {
                                            if ($(this).hasClass("fa-check-square")) {
                                                if (ids != "") {
                                                    ids += "_"
                                                }
                                                ids += $(this).attr("id");
                                            }
                                        });
                                        if (ids) {
                                            openLoader("Quitando enviado");
                                            $.ajax({
                                                type    : "POST",
                                                url     : '${createLink(action:'desenviar_ajax')}',
                                                data    : {
                                                    id  : id,
                                                    ids : ids
                                                },
                                                success : function (msg) {
                                                    var parts = msg.split("_");
                                                    log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                                                    if (parts[0] == "OK") {
                                                        setTimeout(function () {
                                                            $("#bloqueo-warning").hide();
                                                            location.href = "${createLink(controller: "tramite2", action: "bandejaSalida")}";
                                                        }, 1000);
                                                        cargarBandeja();
                                                    } else {
                                                        log("Envío del trámite cancelado", 'error');
                                                        closeLoader();
                                                    }
                                                }
                                            });
                                        } else {
                                            log('No seleccionó ninguna persona', 'error');
                                        }
                                    }
                                };
                            }

                            bootbox.dialog({
                                title   : "Alerta",
                                message : msg,
                                buttons : buttons
                            });
                        }
                    }
                });
            }
        };

        var observaciones = {
            label  : 'Añadir observaciones al trámite',
            icon   : "fa fa-eye",
            action : function (e) {
                $.ajax({
                    type:'POST',
                    url: '${createLink(controller: 'tramite2', action: 'observaciones_ajax')}',
                    data:{
                        id: id
                    },
                    success: function (msg1){
                        var b = bootbox.dialog({
                            id      : "dlgJefe",
                            title   : "Añadir observaciones al trámite",
                            message : msg1,
                            buttons : {
                                cancelar : {
                                    label     : '<i class="fa fa-times"></i> Cancelar',
                                    className : 'btn-danger',
                                    callback  : function () {
                                    }
                                },
                                recibir  : {
                                    id        : 'btnEnviar',
                                    label     : '<i class="fa fa-save"></i> Guardar',
                                    className : 'btn-success',
                                    callback  : function () {
                                        var cl = cargarLoader("Guardando...");
                                        var obs = $("#txaObsJefe").val();
                                        $.ajax({
                                            type    : 'POST',
                                            url     : '${createLink(controller: 'tramite3', action: 'enviarTramiteJefe')}',
                                            data    : {
                                                id  : id,
                                                obs : obs
                                            },
                                            success : function (msg) {
                                                cl.modal("hide");
                                                var parts = msg.split("_");
                                                cargarBandeja();
                                                log(parts[1], parts[0] == "NO" ? "error" : "success");
                                            }
                                        });
                                    }
                                }
                            }
                        })
                    }
                })


            }
        };

        items.header.label = "Acciones";
        if (!esSumilla) {
            items.ver = ver;
            items.firmar = firmar;
        }
        <g:if test="${session.usuario.getPuedeVer()}">
        items.detalles = detalles;
        items.arbol = arbol;
        </g:if>

        if (porEnviar) {
            if (esSumilla || esDex) {
                items.editar = editarSumilla;
            } else {
                items.editar = editar;
            }
        }
        <g:if test="${!esEditor}">
        if (tienePadre) {
            items.hermano = crearHermano;
        } else {
            if(!porEnviar){
                items.hijo = crearHijo;
            }
        }
        </g:if>
        %{--if (porEnviar) {--}%
        %{--    <g:if test="${!esEditor}">--}%
        %{--    items.imprimir = permisoImprimir;--}%
        %{--    </g:if>--}%
        %{--}--}%
        if (tieneAnexo) {
            items.anexos = anexos;
        }
        if ((enviado || tieneAlerta) && puedeDesenviar) {
            items.desenviar = desenviar;
        }

        if ((esExterno && (enviado || tieneAlerta)) || esExternoCC) {
            items.recibirExterno = recibirExterno
        }

        if (enviado || tieneAlerta) {
            <g:if test="${session.usuario.getPuedeCopiar()}">
            items.copia = copia;
            </g:if>
        }

        if(porEnviar){
            items.anular = anular
        }

        if (esOficio) {
            delete items.copia;
        }
        items.observaciones = observaciones;
        </g:if>

        return items;
    }

    $(function () {
        cargarBandeja();

        $("input").keyup(function (ev) {
            if (ev.keyCode == 13) {
                cargarBandeja();
            }
        });

        $(".cabecera").click(function () {
            var $col = $(this);
            $(".sorted").each(function () {
                $(this).removeClass("asc").removeClass("desc");
            }).removeClass("sorted");
            $col.addClass("sorted");
            var order = "";
            if ($col.data("order") == "asc") {
                order = "desc";
                $col.data("order", "desc");
                $col.removeClass("asc").addClass("desc");
            } else if ($col.data("order") == "desc") {
                order = "asc";
                $col.data("order", "asc");
                $col.removeClass("desc").addClass("asc");
            }
            cargarBandeja();
        });

        <g:if test="${bloqueo}">
        $("#bloqueo-salida").show();
        </g:if>

        $(".btnBuscar").click(function () {
            $(".buscar").attr("hidden", false)
        });

        $(".btnSalir").click(function () {
            $(".buscar").attr("hidden", true);
            $("#memorando").val("");
            $("#asunto").val("");
            $("#datetimepicker1").val("");
            // $("#fechaBusqueda_day").val("");
            // $("#fechaBusqueda_month").val("");
            // $("#fechaBusqueda_year").val("");
            cargarBandeja();
        });

        $(".btnActualizar").click(function () {
            cargarBandeja();
            return false;
        });

        $(".alertas").click(function () {
            var clase = $(this).attr("clase");
            $("tr").each(function () {
                if ($(this).hasClass(clase)) {
                    if ($(this).hasClass("trHighlight"))
                        $(this).removeClass("trHighlight");
                    else
                        $(this).addClass("trHighlight")
                } else {
                    $(this).removeClass("trHighlight")
                }
            });
        });

        $(".btnEnviar").click(function () {
            var trId = [];
            var strIds = "";
            $(".combo").each(function () {
                if ($(this).prop('checked') == false) {
                } else {
                    trId.push($(this).attr('tramite'));
                    if (strIds != "") {
                        strIds += ",";
                    }
                    strIds += $(this).attr('tramite');
                }
            });
            if (strIds == '') {
                bootbox.alert('<i class="fa fa-exclamation-triangle fa-3x text-warning"></i> No se ha seleccionado ningun trámite')
            } else {
                var id;
                var b = bootbox.dialog({
                    id      : "dlgGuia",
                    title   : '<i class="fa fa-print"></i> Impresión de la guía de envío de trámites',
                    message : '<span class="warning"><i class="fa fa-print fa-2x text-info"></i> Desea imprimir la guía de envío para los trámites seleccionados?',
                    buttons : {
                        cancelar : {
                            label : '<i class="fa fa-times"></i> Cerrar',
                            className : 'btn-primary'
                        },
                        no       : {
                            label    : '<i class="fa fa-paper-plane"></i> No Imprimir',
                            className : 'btn-success',
                            callback : function () {
                                doEnviar(false, strIds);
                            }
                        },
                        si       : {
                            label    : '<i class="fa fa-print" title="Se imprime y se envía el trámite"></i> Imprimir',
                            className : 'btn-success',
                            callback : function () {
                                doEnviar(true, strIds);
                            }
                        }
                    }
                });
            }
            return false;
        });

        $(".btnBusqueda").click(function () {
            cargarBandeja();
            return false;
        });
    });
</script>
</body>
</html>