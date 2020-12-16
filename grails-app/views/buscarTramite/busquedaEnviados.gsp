
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <meta name="layout" content="main">
        <title>Búsqueda de Trámites Enviados</title>

        <style type="text/css">

        .container-celdas {
            width    : 1070px;
            height   : 310px;
            float    : left;
            overflow : auto;
        }

        .alinear {
            text-align : center !important;
        }

        </style>
    </head>

    <body>

        <div style="margin-top: 5px;" class="vertical-container">

            <p class="css-vertical-text" style="margin-top: -10px;">Buscar</p>

            <div class="linea"></div>

            <div style="margin-bottom: 20px">
                <div class="col-md-2">
                    <label>Documento</label>
                    <g:textField name="memorando" value="" maxlength="15" class="form-control allCaps"/>
                </div>

                <div class="col-md-2">
                    <label>Asunto</label>
                    <g:textField name="asunto" value="" style="width: 300px" maxlength="30" class="form-control"/>
                </div>

                <div class="col-md-2" style="margin-left: 150px">
                    <label>Enviados Desde</label>
                    <input name="fechaRecepcion" id='datetimepicker1' type='text' class="form-control"/>
                </div>

                <div class="col-md-2" style="margin-left: 15px">
                    <label>Enviados Hasta</label>
                    <input name="fechaBusqueda" id='datetimepicker2' type='text' class="form-control"/>
                </div>

                <div style="padding-top: 25px">
                    <a href="#" name="busqueda" class="btn btn-success btnBusqueda btn-ajax"><i
                            class="fa fa-search"></i> Buscar</a>

                    <a href="#" name="borrar" class="btn btn-primary btnBorrar"><i
                            class="fa fa-eraser"></i> Limpiar</a>
                </div>
            </div>
        </div>

        %{--//bandeja--}%

        <div style="margin-top: 30px; min-height: 460px" class="vertical-container" id="divBandeja">
            <p class="css-vertical-text">Resultado - Buscar Trámites Enviados</p>

            <div class="linea"></div>

            <div id="bandeja">

            </div>
        </div>

        <div><strong>Nota</strong>: Si existen muchos registros que coinciden con el criterio de búsqueda, se retorna como máximo 20
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
                var cellWidth = 150;
                var celHegth = 25;
                var select = null;
                var headerTop = $(".header-columnas");

                $(".h-A").resizable({
                    handles    : "e",
                    minWidth   : 30,
                    alsoResize : ".A"
                });
                $(".container-celdas").scroll(function () {
                    $("#container-cols").scrollLeft($(".container-celdas").scrollLeft());
                });

            });

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

            $(".btnBusqueda").click(function () {
                buscarEnviados();
            });

            $("input").keyup(function (ev) {
                if (ev.keyCode == 13) {
                    buscarEnviados();
                }
            });

            function buscarEnviados(){
                $("#bandeja").html("").append($("<div style='width:100%; text-align: center;'/>").append(spinnerSquare64));
                var memorando = $("#memorando").val();
                var asunto = $("#asunto").val();
                var fecha = $("#datetimepicker1").val();
                var fechaRecepcion = $("#datetimepicker2").val();

                var datos = "memorando=" + memorando + "&asunto=" + asunto + "&fechaDesde=" + fechaRecepcion + "&fechaHasta=" + fecha
                $.ajax({
                    type    : "POST",
                    url     : "${g.createLink(controller: 'buscarTramite', action: 'tablaBusquedaEnviados')}",
                    data    : datos,
                    success : function (msg) {
                        $("#bandeja").html(msg);
                    }
                });
            }

            var padre

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

                var porRecibir = $tr.hasClass("porRecibir");
                var sinRecepcion = $tr.hasClass("sinRecepcion");
                var recibido = $tr.hasClass("recibido");
                var retrasado = $tr.hasClass("retrasado");
                var conAnexo = $tr.hasClass("conAnexo");
                var conPadre = $tr.hasClass("padre");

                var enviado = $tr.hasClass("estado");
                var esMio = $tr.hasClass("mio");

                var tienePrincipal = $tr.attr("principal").toString() != '0' && $tr.attr("principal").toString() != $tr.attr("id");

                var arbol = {
                    label  : 'Cadena del trámite',
                    icon   : "fa fa-sitemap",
                    action : function (e) {
                        location.href = '${createLink(controller: 'tramite3', action: 'arbolTramite')}/' + id + "?b=bqe"
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

                var administrar = {
                    label  : "Administrar trámite",
                    icon   : "fa fa-cogs",
                    action : function () {
                        location.href = '${createLink(controller: "tramiteAdmin", action: "arbolAdminTramite")}?id=' + id;
                    }
                };

                var copia = {
                    separator_before : true,
                    label            : "Crear Copia",
                    icon             : "fa fa-paste",
                    action           : function () {
                        $.ajax({
                            type    : "POST",
                            url     : "${createLink(controller: 'tramiteAdmin', action:'copiaParaLista_ajax')}",
                            data    : {
                                tramite : id
                            },
                            success : function (msg) {
                                bootbox.dialog({
                                    id      : "dlgCopiaPara",
                                    title   : '<i class="fa fa-paste"></i> Copia para',
                                    // class   : "long",
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
                                                        } else if (msg == 'NO') {
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

                items.header.label = "Acciones";
                <g:if test="${session.usuario.getPuedeVer()}">
                items.detalles = detalles;
                items.arbol = arbol;
                </g:if>
                <g:if test="${session.usuario.getPuedeAdmin()}">
                items.administrar = administrar;
                </g:if>

                if (esMio) {
                    if (padre) {
                        items.crearHermano = crearHermano;
                    } else {
                        items.crearHijo = crearHijo;
                    }
                }

                <g:if test="${session.usuario.getPuedeCopiar()}">
                items.copia = copia;
                </g:if>

                return items
            }

            $(".btnBorrar").click(function () {
                $("#memorando").val("");
                $("#asunto").val("");
                $("#datetimepicker1").val('');
                $("#datetimepicker2").val('')
            });

        </script>
    </body>
</html>