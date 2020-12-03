
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title>Bandeja de Entrada</title>

    <style type="text/css">

    body {
        background-color : #F0FDF0;
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

    .cabecera.sortable {
        cursor : pointer;
    }

    .container-celdas {
        width      : 1070px;
        height     : 310px;
        float      : left;
        overflow   : auto;
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
            <i class="fa fa-hand-point-right fa-2x text-info"></i>  BANDEJA DE ENTRADA PERSONAL
        </label>
    </span>

    <span class="grupo">
        <label class="well well-sm" style="text-align: center;">
            <strong class="text-success">Usuario:</strong> ${persona?.nombre + " " + persona?.apellido}
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

        <g:link action="" class="btn btn-info btnActualizar">
            <i class="fa fa-sync-alt"></i> Actualizar
        </g:link>

        <g:link action="crearTramite" class="btn btn-success btnCrearTramite" style="margin-left: 10px">
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
            <tr>
                <th class="cabecera sortable ${params.sort == 'trmtcdgo' ? (params.order + ' sorted') : ''}" data-sort="trmtcdgo" data-order="${params.order}">Documento</th>
                <th class="cabecera sortable ${params.sort == 'trmtfcen' ? (params.order + ' sorted') : ''}" data-sort="trmtfcen" data-order="${params.order}">Fecha Envío</th>
                <th class="cabecera sortable ${params.sort == 'trmtfcrc' ? (params.order + ' sorted') : ''}" data-sort="trmtfcrc" data-order="${params.order}">Fecha Recepción</th>
                <th class="cabecera sortable ${params.sort == 'deprdpto' ? (params.order + ' sorted') : ''}" data-sort="deprdpto" data-order="${params.order}">De</th>
                <th class="cabecera sortable ${params.sort == 'deprlogn' ? (params.order + ' sorted') : ''}" data-sort="deprlogn" data-order="${params.order}">Creado por</th>
                <th class="cabecera">Para</th>
                <th class="cabecera sortable ${params.sort == 'trmttppd' ? (params.order + ' sorted') : ''}" data-sort="trmttppd" data-order="${params.order}">Prioridad</th>
                <th class="cabecera sortable ${params.sort == 'trmtfclr' ? (params.order + ' sorted') : ''}" data-sort="trmtfclr" data-order="${params.order}">Fecha Límite</th>
                <th class="cabecera sortable ${params.sort == 'rltrdscr' ? (params.order + ' sorted') : ''}" data-sort="rltrdscr" data-order="${params.order}">Rol</th>
            </tr>
            </thead>
            <tbody id="tabla_bandeja">

            </tbody>
        </table>
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
        // var fecha = $("#fechaBusqueda_input").val();
        var fecha = $("#fechaBusqueda").val();
        var $sorted = $(".sorted");
        var sort = $sorted.data("sort");
        var order = $sorted.data("order");

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
            url     : "${g.createLink(controller: 'tramite',action:'tablaBandeja')}",
            data    : datos,
            success : function (msg) {
                $("#tabla_bandeja").html(msg);
                cargarAlertas();
            }
        });
    }

    function cargarAlertas() {
        $("#numPen").html($(".sinRecepcion").size()); //sinRecepcion
        $("#numRet").html($(".retrasado").size()); //retrasado
        $("#numEnv").html($(".porRecibir").size()); //porRecibir
        $("#numRec").html($(".recibido").size()); //recibido
    }

    //nuevo contextMenu

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
        var externo = $tr.hasClass("1");
        var esExterno = $tr.hasClass("estadoExterno");
        var esCopia = $tr.hasClass("R002");
        var remitenteParts = $tr.attr("de").split("_");
        var remitenteTipo = remitenteParts[0];
        var remitenteId = remitenteParts[1];

        var porRecibir = $tr.hasClass("porRecibir");
        var sinRecepcion = $tr.hasClass("sinRecepcion");
        var recibido = $tr.hasClass("recibido");
        var retrasado = $tr.hasClass("retrasado");
        var conAnexo = $tr.hasClass("conAnexo");
//                console.log("por porRecibir",porRecibir)

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
                        id      : remitenteId,
                        tramite : id
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

        var contestar = {
            label : 'Contestar Documento',
            icon  : "fa fa-envelope-open-text",
            url   : "${g.createLink(action: 'crearTramite')}/?padre=" + id + "&pdt=" + idPxt + "&esRespuesta=1&esRespuestaNueva=S"
        };

        var ver = {
            label  : 'Ver',
            icon   : "fa fa-search",
            action : function (e) {

                location.href = "${g.createLink(action: 'verPdf',controller: 'tramiteExport')}/" + id;
                location.href = "${resource(dir:'tramites')}/" + archivo + ".pdf";

                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(action: 'revisarConfidencial')}/' + id,
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
                    url     : '${createLink(controller: 'tramite3', action: 'recibirTramite')}/' + id + "?source=bep",
                    success : function (msg) {
                        cl5.modal("hide");
                        var parts = msg.split('_');
                        cargarBandeja();
                        if (parts[0] == 'NO') {
                            log(parts[1], "error");
                        } else if (parts[0] == "OK") {
                            log(parts[1], "success")
                        } else if (parts[0] == "ERROR") {
                            bootbox.alert(parts[1]);
                        }
                    }
                }); //ajax
            } //action
        };

        var seguimiento = {
            label  : 'Seguimiento Trámite',
            icon   : "fa fa-sitemap",
            action : function (e) {

                location.href = "${g.createLink(controller: 'tramite3', action: 'seguimientoTramite')}/" + id + "?pers=1";
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

        var anexos = {
            label  : 'Anexos',
            icon   : "fa fa-paperclip",
            action : function (e) {
                location.href = '${createLink(controller: 'documentoTramite', action: 'verAnexos')}/' + id
            }
        };

        var arbol = {
            label  : 'Cadena del trámite',
            icon   : "fa fa-sitemap",
            action : function (e) {
                location.href = '${createLink(controller: 'tramite3', action: 'arbolTramite')}/' + id + "?b=bep"
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
                            label     : '<i class="fa fa-thumbs-o-up"></i> Guardar',
                            className : 'btn-success',
                            callback  : function () {
                                var obs = $("#txaObsJefe").val();
                                openLoader();
                                $.ajax({
                                    type    : 'POST',
                                    url     : '${createLink(controller: 'tramite3', action: 'enviarTramiteJefe')}',
                                    data    : {
                                        id  : id,
                                        obs : obs
                                    },
                                    success : function (msg) {
                                        var parts = msg.split("_");
                                        cargarBandeja();
                                        closeLoader();
                                        log(parts[1], parts[0] == "NO" ? "error" : "success");
                                    }
                                });
                            }
                        }
                    }
                })
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
                                        cargarBandeja();
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
                                            url     : '${createLink(action: 'archivar')}/' + idPxt,
                                            data    : {
                                                texto : $("#observacionArchivar").val(),
                                            },
                                            success : function (msg) {
                                                cl6.modal("hide");
                                                cargarBandeja();
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

        var distribuir = {
            label  : 'Distribuir a Jefes',
            icon   : "fa fa-eye",
            action : function (e) {

                $.ajax({
                    type    : "POST",
                    url     : "${createLink(action: 'observaciones')}/" + id,
                    success : function (msg) {
                        var b = bootbox.dialog({
                            id      : "dlgObservaciones",
                            title   : "Distribución al Jefe: Observaciones",
                            message : msg,
                            buttons : {
                                cancelar : {
                                    label     : "Cancelar",
                                    className : 'btn-danger',
                                    callback  : function () {
                                    }
                                },
                                guardar  : {
                                    id        : 'btnSave',
                                    label     : '<i class="fa fa-save"></i> Guardar',
                                    className : "btn-success",
                                    callback  : function () {

                                        $.ajax({
                                            type    : 'POST',
                                            url     : '${createLink(action: 'guardarObservacion')}/' + id,
                                            data    : {
                                                texto : $("#observacion").val()
                                            },
                                            success : function (msg) {
                                                bootbox.alert(msg)
                                            }
                                        });
                                    }
                                }
                            }
                        })
                    }
                });
            }
        };

        items.header.label = "Acciones";
        items.infoRemitente = infoRemitente;

        var idSession = ${session.usuario.id};

        <g:if test="${session.usuario.getPuedeVer()}">
        items.detalles = detalles;
        </g:if>

        <g:if test="${session.usuario.getPuedeVer()}">
        items.arbol = arbol;
        </g:if>

        if (conAnexo && recibido) {
            items.anexo = anexos
        }
        if (retrasado) {
            items.contestar = contestar
        }
        if (sinRecepcion) {
            items.recibir = recibir
        }

        if (porRecibir) {

            items.recibir = recibir
        }

        if (recibido || retrasado) {
            <g:if test="${session.usuario.getPuedeVer()}">
            items.arbol = arbol;
            </g:if>
            items.contestar = contestar;
            <g:if test="${session.usuario.getPuedeArchivar()}">
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

        var estado1 = {
            label  : "Cambiar estado",
            icon   : "fa fa-exchange",
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
                            title   : '<span class="text-default"><i class="fa fa-exchange"></i> Cambiar estado de trámite externo</span>',
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
                                        var nuevoEstado = $("#estadoExterno").val();
                                        openLoader("Cambiando estado");
                                        $.ajax({
                                            type    : 'POST',
                                            url     : '${createLink(controller: "tramiteAdmin", action: "guardarEstado")}',
                                            data    : {
                                                id     : id,
                                                estado : nuevoEstado
                                            },
                                            success : function (msg) {
                                                var parts = msg.split("*");
                                                if (parts[0] == 'OK') {
                                                    log(parts[1], 'success');
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
            }
        };

        if (recibido) {
            if (esExterno) {
                items.externo = estado1
            }
        }

        return items
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

        $(".btnBuscar").click(function () {
            $(".buscar").attr("hidden", false);
        });

        $(".btnSalir").click(function () {
            $(".buscar").attr("hidden", true);
            $("#memorando").val("");
            $("#asunto").val("");
            $("#datetimepicker1").val("");
            // $("#fechaBusqueda_input").val("");
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

        $(".btnBusqueda").click(function () {
            cargarBandeja();
            return false;
        });
    });

</script>

</body>
</html>