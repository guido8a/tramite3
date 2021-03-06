<%@ page  contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title>Bandeja de Entrada Departamento</title>

    <style type="text/css">

    body {
        background-color : #e0ede4;
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

    .cabecera {
        text-align : center;
        font-size  : 13px !important;
    }

    .container-celdas {
        width      : 1139px;
        height     : 310px;
        float      : left;
        overflow   : auto;
        overflow-y : auto;
    }

    .cabecera.sortable {
        cursor : pointer;
    }

    .tituloChevere {
        color       : #0088CC;
        border      : 0 solid red;
        white-space : nowrap;
        display     : block;
        height      : 25px;
        font-family : 'open sans condensed';
        font-weight : bold;
        font-size   : 16px;
        line-height : 18px;
    }

    .table-hover tbody tr:hover td, .table-hover tbody tr:hover th {
        background-color : #FFBD4C;
    }

    tr.recibido {
        background-color : #D9EDF7 ! important;
    }

    tr.porRecibir {
        background-color : transparent;
    }

    tr.sinRecepcion {
        background-color : #FC2C04 ! important;
        color            : #ffffff
    }

    tr.retrasado {
        background-color : #F2DEDE ! important;
    }

    .letra {
        background-color : #8fe6c3;
    }
    </style>
</head>

<body>
<div class="row" style="margin-top: 0; margin-left: 1px">

    <span class="grupo">
        <label class="well well-sm letra text-info" style="text-align: center">
            <i class="fa fa-hand-point-right fa-2x text-info"></i>  BANDEJA DE ENTRADA DEPARTAMENTO
        </label>
    </span>

    <span class="grupo">
        <label class="well well-sm" style="text-align: center;">
            <strong class="text-success">Departamento:</strong> ${persona?.departamento?.descripcion}
        </label>
    </span>
</div>

<elm:flashMessage tipo="${flash.tipo}" clase="${flash.clase}">${flash.message}</elm:flashMessage>

<div class="btn-toolbar toolbar">
    <div class="btn-group">
        <a href="#" class="btn btn-primary btnBuscar"><i class="fa fa-search"></i> Buscar</a>
        <a href="#" class="btn btn-info" id="btnActualizar">
            <i class="fa fa-sync-alt"></i> Actualizar
        </a>

        <g:link controller="tramite2" action="crearTramiteDep" class="btn btn-success btnCrearTramite" style="margin-left: 10px">
            <i class="fa fa-edit"></i> Crear Trámite Principal
        </g:link>
    </div>

    <div style="float: right">
        <div data-type="pendiente" class="alert alert-blanco alertas" clase="porRecibir">
            <span id="numEnv" class="badge badge-light"></span>
            Por recibir
        </div>

        <div data-type="pendiente" class="alert alert-otroRojo alertas" clase="sinRecepcion">
            <span id="numPen" class="badge badge-light"></span>
            Sin Recepción
        </div>

        <div data-type="recibido" class="alert alert-info alertas" clase="recibido">
            <span id="numRec" class="badge badge-light"></span>
            Recibidos
        </div>

        <div data-type="retrasado" class="alert alert-danger alertas" clase="retrasado">
            <span id="numRet" class="badge badge-light"></span>
            Retrasados
        </div>
    </div>
</div>

<div class="buscar" hidden="hidden" style="margin-bottom: 20px;">
    <fieldset>
        <legend>Búsqueda de trámites</legend>
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
                <label>Fecha envío</label>
                <input name="fechaBusqueda" id='datetimepicker1' type='text' class="form-control"/>
            </div>

            <div style="padding-top: 25px">
                <a href="#" name="busqueda" class="btn btn-primary btnBusqueda"><i class="fa fa-search"></i> Buscar</a>
                <a href="#" name="salir" class="btn btn-danger btnSalir"><i class="fa fa-times"></i> Cerrar</a>
            </div>
        </div>
    </fieldset>
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

<div id="" style=";height: 600px;overflow: auto;position: relative">
    <div class="modalTabelGray" id="bloqueo-salida"></div>

    <div id="bandeja">
        <table class="table table-bordered  table-condensed table-hover">
            <thead>
            <tr style="width: 100%">
                <th style="width: 13%" class="cabecera sortable ${params.sort == 'trmtcdgo' ? (params.order + ' sorted') : ''}" data-sort="trmtcdgo" data-order="${params.order}">Documento</th>
                <th style="width: 11%" class="cabecera sortable ${params.sort == 'trmtfcen' ? (params.order + ' sorted') : ''}" data-sort="trmtfcen" data-order="${params.order}">Fecha Envío</th>
                <th style="width: 11%" class="cabecera sortable ${params.sort == 'trmtfcrc' ? (params.order + ' sorted') : ''}" data-sort="trmtfcrc" data-order="${params.order}">Fecha Recepción</th>
                <th style="width: 9%" class="cabecera sortable ${params.sort == 'deprdpto' ? (params.order + ' sorted') : ''}" data-sort="deprdpto" data-order="${params.order}">De</th>
                <th style="width: 11%" class="cabecera sortable ${params.sort == 'deprlogn' ? (params.order + ' sorted') : ''}" data-sort="deprlogn" data-order="${params.order}">Creado por</th>
                <th style="width: 11%" class="cabecera">Para</th>
                <th style="width: 11%" class="cabecera sortable ${params.sort == 'trmttppd' ? (params.order + ' sorted') : ''}" data-sort="trmttppd" data-order="${params.order}">Prioridad</th>
                <th style="width: 11%" class="cabecera sortable ${params.sort == 'trmtfclr' ? (params.order + ' sorted') : ''}" data-sort="trmtfclr" data-order="${params.order}">Fecha Límite</th>
                <th style="width: 10%" class="cabecera sortable ${params.sort == 'rltrdscr' ? (params.order + ' sorted') : ''}" data-sort="rltrdscr" data-order="${params.order}">Rol</th>
                <th style="width: 1%"></th>
            </tr>
            </thead>
        </table>
        <div style="width: 99.7%;height: 540px; overflow-y: auto; margin-top: -20px">
            <table class="table-bordered table-condensed table-hover" width="100%">
                <tbody id="tabla_bandeja">

                </tbody>
            </table>
        </div>
    </div>
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

    function cargarAlertas() {
        $("#numPen").html($(".sinRecepcion").size()); //sinRecepcion
        $("#numRet").html($(".retrasado").size()); //retrasado
        $("#numEnv").html($(".porRecibir").size()); //porRecibir
        $("#numRec").html($(".recibido").size()); //recibido
    }

    function cargarBandeja(actualizar) {
        var memorando = $("#memorando").val();
        var asunto = $("#asunto").val();
        var fecha = $("#fechaBusqueda").val();
        var $sorted = $(".sorted");
        var sort = $sorted.data("sort");
        var order = $sorted.data("order");

        $(".qtip").hide();
        $("#tabla_bandeja").html("").append($("<div style='width:100%; text-align: center;'/>").append(spinnerSquare64));

        var datos = {
            memorando : memorando,
            asunto    : asunto,
            fecha     : fecha,
            sort      : sort,
            order     : order,
            actualizar: actualizar
        };

        $.ajax({
            type    : "POST",
            url     : "${g.createLink(controller: 'tramite3', action:'tablaBandejaEntradaDpto')}",
            data    : datos,
            success : function (msg) {
                $("#tabla_bandeja").html(msg);
                cargarAlertas();
                // $("#btnActualizar").show(500);
                $("#btnActualizar").removeClass('disabled')
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

        var id = $tr.data("id");
        var codigo = $tr.attr("codigo");
        var estado = $tr.attr("estado");
        var padre = $tr.attr("padre");
        var de = $tr.attr("de");
        var archivo = $tr.attr("departamento") + "/" + $tr.attr("anio") + "/" + $tr.attr("codigo");
        var idPxt = $tr.attr("prtr");
        var valAnexo = $tr.attr("anexo");
        var remitenteParts = $tr.attr("de").split("_");
        var remitenteTipo = remitenteParts[0];
        var remitenteId = remitenteParts[1];

        var esCopia = $tr.hasClass("R002");
        var esExterno = $tr.hasClass("estadoExterno");
        var porRecibir = $tr.hasClass("porRecibir");
        var sinRecepcion = $tr.hasClass("sinRecepcion");
        var recibido = $tr.hasClass("recibido");
        var retrasado = $tr.hasClass("retrasado");
        var conAnexo = $tr.hasClass("conAnexo");
        var jefe = $tr.hasClass("jefe");

        var esDex = $tr.hasClass("dex");

        var tienehijos = $tr.hasClass("tieneHijos");

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
                        id : remitenteId
                    },
                    success : function (msg) {
                        bootbox.dialog({
                            title   : title,
                            message : msg,
                            class   : "medium",
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
                location.href = '${createLink(controller: 'tramite3', action: 'arbolTramite')}/' + id + "?b=bed"
            }
        };

        var contestar = {
            label  : 'Contestar Documento',
            icon  : "fa fa-envelope-open-text",
            action : function (e) {
                location.href = '${createLink(controller: 'tramite2', action: 'crearTramiteDep')}?padre=' + id + "&pdt=" + idPxt + "&esRespuesta=1&esRespuestaNueva=S";
            }
        };

        var ver = {
            label  : 'Ver',
            icon   : "fa fa-search",
            action : function (e) {
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'tramite' ,action: 'revisarConfidencial')}/' + id,
                    success : function (msg) {
                        if (msg == 'ok') {
                            window.open("${resource(dir:'tramites')}/" + archivo + ".pdf");
                        } else if (msg == 'no') {
                            bootbox.alert('No tiene permiso para ver el PDF de este trámite')
                        }
                    }
                });
            }
        };

        var recibir = {
            label  : 'Recibir Documento',
            icon   : "fa fa-check",
            action : function (e) {
                var cl5 = cargarLoader("Recibiendo...");
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(action: 'recibirTramite', controller: 'tramite3')}/' + id + "?source=bed",
                    success : function (msg) {
                        cl5.modal("hide");
                        var parts = msg.split('_');
                        cargarBandeja(false);
                        if (parts[0] == 'NO') {
                            log(parts[1], "error");
                        } else if (parts[0] == "OK") {
                            log(parts[1], "success")
                        } else if (parts[0] == "ERROR") {
                            bootbox.alert(parts[1]);
                        }
                    }
                });
            }
        };

        var seguimiento = {
            label  : 'Seguimiento Trámite',
            icon   : "fa fa-sitemap",
            action : function (e) {
                location.href = "${g.createLink(controller: 'tramite3', action: 'seguimientoTramite')}/" + id;
            }
        };

        var detalles = {
            label  : 'Detalles',
            icon   : "fa fa-search",
            action : function (e) {
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
                $("#dialog").modal("show")
            }
        };

        var archivar = {
            label  : 'Archivar Documentos',
            icon   : "fa fa-file-archive",
            action : function (e) {
                $.ajax({
                    type    : "POST",
                    url     : "${createLink(controller: 'tramite', action: "revisarHijos")}",
                    data    : {
                        id   : idPxt,
                        tipo : "archivar"
                    },
                    success : function (msg) {
                        var b = bootbox.dialog({
                            id      : "dlgArchivar",
                            title   : 'Archivar Tramite',
                            message : msg,
                            buttons : {
                                cancelar : {
                                    label     : '<i class="fa fa-times"></i> Cancelar',
                                    className : 'btn-danger',
                                    callback  : function () {
                                        cargarBandeja(false);
                                    }
                                },
                                archivar : {
                                    id        : 'btnArchivar',
                                    label     : '<i class="fa fa-check"></i> Archivar',
                                    className : "btn-success",
                                    callback  : function () {
                                        var cl6 = cargarLoader("Archivando...");
                                        var $txt = $("#aut");
                                        $.ajax({
                                            type    : 'POST',
                                            url     : '${createLink(controller:'tramite',action: 'archivar')}/' + idPxt,
                                            data    : {
                                                texto : $("#observacionArchivar").val()
                                            },
                                            success : function (msg) {
                                                cl6.modal("hide");
                                                cargarBandeja(false);
                                                if (msg == 'ok') {
                                                    log("Trámite archivado correctamente", 'success')
                                                } else if (msg == 'no') {
                                                    log("Error al archivar el trámite", 'error')
                                                }
                                            }
                                        });
                                    }
                                }
                            }
                        });
                        setTimeout(function () {
                            if (msg.indexOf("error") > -1) {
                                b.find(".btn-success").remove();
                                b.find(".btn-danger").removeClass("btn-danger").addClass("btn-default").html("Cerrar");
                            }
                        }, 300);
                    }
                });
            }
        };

        var observaciones = {
            label  : 'Añadir observaciones al trámite',
            icon   : "fa fa-eye",
            action : function (e) {
                var b = bootbox.dialog({
                    id      : "dlgJefe",
                    title   : "Añadir observaciones al trámite",
                    message : "¿Está seguro de querer añadir observaciones al trámite <b>" + codigo + "</b>?</br><br/>" +
                        "Escriba las observaciones: " +
                        "<textarea id='txaObsJefe' style='height: 130px;' class='form-control'></textarea>",
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
                                var obs = $("#txaObsJefe").val();
                                $.ajax({
                                    type    : 'POST',
                                    url     : '${createLink(action: 'enviarTramiteJefe')}',
                                    data    : {
                                        id  : id,
                                        obs : obs
                                    },
                                    success : function (msg) {
                                        var parts = msg.split("_");
                                        cargarBandeja(false);
                                        log(parts[1], parts[0] == "NO" ? "error" : "success");
                                    }
                                });
                            }
                        }
                    }
                })
            }
        };

        var anexos = {
            label  : 'Anexos',
            icon   : "fa fa-paperclip",
            action : function (e) {
                location.href = '${createLink(controller: 'documentoTramite', action: 'verAnexos')}/' + id
            }
        };

        var externo = {
            label  : "Cambiar estado",
            icon   : "fa fa-sync-alt",
            action : function () {
                $.ajax({
                    type    : "POST",
                    url     : "${createLink(controller: 'tramiteAdmin', action: 'cambiarEstado')}",
                    data    : {
                        id          : id,
                        tramiteInfo : ""
                    },
                    success : function (msg) {
                        bootbox.dialog({
                            id      : "dlgExterno",
                            title   : '<span class="text-default"><i class="fa fa-sync-alt"></i> Cambiar estado de trámite externo</span>',
                            message : msg,
                            buttons : {
                                cancelar : {
                                    label     : '<i class="fa fa-times"></i> Cancelar',
                                    className : 'btn-danger',
                                    callback  : function () {
                                    }
                                },
                                cambiar  : {
                                    id        : 'btnCambiar',
                                    label     : '<i class="fa fa-check"></i> Cambiar estado',
                                    className : "btn-success",
                                    callback  : function () {
                                        var cl7 = cargarLoader("Guardando...")
                                        var nuevoEstado = $("#estadoExterno").val();
                                        $.ajax({
                                            type    : 'POST',
                                            url     : '${createLink(controller: "tramiteAdmin", action: "guardarEstado")}',
                                            data    : {
                                                id     : id,
                                                prtr   : idPxt,
                                                estado : nuevoEstado
                                            },
                                            success : function (msg) {
                                                cl7.modal("hide")
                                                var parts = msg.split("*");
                                                if (parts[0] == 'OK') {
                                                    log(parts[1], 'success');
                                                    setTimeout(function () {
                                                        location.reload(true);
                                                    }, 500);
                                                } else if (parts[0] == 'NO') {
                                                    log(parts[1], 'error');
                                                    setTimeout(function () {
                                                        location.reload(true);
                                                    }, 700);
                                                }
                                            }
                                        });
                                    }
                                }
                            }
                        });
                    }
                });
            }
        };

        var editarExterno = {
            label : "Editar",
            icon  : "fa fa-pencil",
            url   : "${g.createLink(controller: 'tramite2',action: 'crearTramiteDep')}/" + id
        }; //editar sumilla

        var agregarPadre = {
            label            : "Asociar trámite",
            icon             : "fa fa-gift",
            separator_before : true,
            action           : function () {
                var tramiteCodigo = $.trim($tr.find(".codigo").text());
                var tramiteDe = $.trim($tr.find(".de").text());
                var tramiteRol = $.trim($tr.find(".rol").text());
                var tramitePara = $.trim($tr.find(".para").text());
                var tramiteInfo = "";

                tramiteInfo += tramiteCodigo;
                tramiteInfo += " (DE: " + tramiteDe + ", ";
                tramiteInfo += tramiteRol + " : " + tramitePara + ")";

                var $container = $("<div>");
                $container.append("<i class='fa fa-gift fa-3x pull-left text-shadow'></i>");
                var $p = $("<p class='lead'>");
                $p.html("Está por asociar un trámite al trámite <br/><strong>" + tramiteInfo + "</strong>");
                $container.append($p);

                var $alert = $("<div class='alert alert-info'>");
                $alert.html("Para poder asociar un trámite a otro se deben cumplir las siguientes condiciones:");
                var $ul = $("<ul>");
                $ul.append($("<li>La fecha de creación del trámite " + tramiteCodigo + " debe ser posterior " +
                    "a la fecha de envío del trámite al que se lo quiere asociar.</li>"));
                $alert.append($ul);
                $container.append($alert);

                var $row = $("<div class='row'>");
                var $col = $("<div class='col-md-6'>");
                $col.append("<label for='nuevoPadre'>Código trámite padre:</label>");
                var $inputGroup = $("<div class='input-group'>");
                var $input = $("<input type='text' name='nuevoPadre' id='nuevoPadre' class='form-control allCaps'/>");
                $inputGroup.append($input);
                var $span = $("<span class='input-group-btn'>");
                var $btn = $("<a href='#' class='btn btn-azul' id='btnBuscar'><i class='fa fa-search'></i>&nbsp;</a>");
                $span.append($btn);
                $inputGroup.append($span);
                $col.append($inputGroup);
                $row.append($col);
                $container.append($row);
                var $res = $("<div>").css({
                    marginTop : 5,
                    maxHeight : 200,
                    overflow  : "auto"
                });
                $container.append($res);

                function buscarAsociar() {
                    $res.html(spinner);
                    var np = $.trim($input.val());
                    $.ajax({
                        type    : "POST",
                        url     : "${createLink(controller: 'tramiteAdmin', action:'asociarTramiteExterno_ajax')}",
                        data    : {
                            codigo   : np,
                            original : id
                        },
                        success : function (msg) {
                            $res.html(msg);
                        },
                        error   : function (jqXHR, textStatus, errorThrown) {
                            $res.html("<div class='alert alert-danger'>" + errorThrown + "</div>");
                        }
                    });
                }

                $input.keyup(function (e) {
                    if (e.keyCode == 13) {
                        buscarAsociar();
                    }
                });

                $btn.click(function () {
                    buscarAsociar();
                    return false;
                });

                bootbox.dialog({
                    id      : "dlgAsociar",
                    title   : '<i class="fa fa-gift"></i> Asociar Trámite',
                    message : $container,
                    buttons : {
                        cancelar : {
                            label     : '<i class="fa fa-times"></i> Aceptar',
                            className : 'btn-default',
                            callback  : function () {
                            }
                        }
                    }
                });
            }
        };

        items.header.label = "Acciones";
        items.infoRemitente = infoRemitente;

        <g:if test="${session.usuario.getPuedeVer()}">
        items.detalles = detalles;
        items.arbol = arbol;
        </g:if>

        if (conAnexo && recibido) {
            <g:if test="${session.usuario.puedeJefe || session.usuario.esTriangulo }">
            items.anexo = anexos;
            </g:if>
        }

        if (retrasado || recibido) {
            if (esExterno) {
                items.externo = externo;
            }

            <g:if test="${session.usuario.getPuedeVer()}">
            items.arbol = arbol;
            </g:if>
            items.contestar = contestar;
            <g:if test="${session.usuario.puedeArchivar}">
            if(!tienehijos){
                items.archivar = archivar;
            }
            </g:if>
            <g:else>
            if (esCopia) {
                items.archivar = archivar;
            }
            </g:else>
            items.observaciones = observaciones;
        }
        if (porRecibir || sinRecepcion) {
            items.recibir = recibir;
            <g:if test="${session.usuario.getPuedeVer()}">
            items.arbol = arbol;
            </g:if>

        }
        if (jefe) {
            items.contestar = contestar;
            <g:if test="${session.usuario.puedeVer}">
            items.detalles = detalles;
            items.arbol = arbol;
            </g:if>
        }

        if (esDex) {
            items.editar = editarExterno;

            <g:if test="${puedeAgregarExternos}">
            items.asociarExterno = agregarPadre;
            </g:if>
        }

        return items
    }

    $(function () {

        $("input").keyup(function (ev) {
            if (ev.keyCode == 13) {
                cargarBandeja(false);
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
            cargarBandeja(false);
        });

        $(".btnBuscar").click(function () {
            $(".buscar").attr("hidden", false)
        });

        $("#btnActualizar").click(function () {
            // $("#btnActualizar").hide(2000);
            $("#btnActualizar").addClass('disabled');
            cargarBandeja(true);
            log('Tabla de trámites y alertas actualizadas!', "success");
            return false;
        });

        $(".btnArchivados").click(function () {
            location.href = '${createLink(controller: 'tramite', action: 'archivados')}?dpto=' + 'si';
        });

        cargarBandeja(false);
    });

    $(".btnSalir").click(function () {
        $(".buscar").attr("hidden", true);
        $("#memorando").val("");
        $("#asunto").val("");
        $("#datetimepicker1").val("");
        // $("#fechaBusqueda_day").val("");
        // $("#fechaBusqueda_month").val("");
        // $("#fechaBusqueda_year").val("");
        openLoader();
        cargarBandeja(false);
        closeLoader();
    });

    $(".btnBusqueda").click(function () {
        cargarBandeja(false);
        return false;
    });

</script>
</body>
</html>