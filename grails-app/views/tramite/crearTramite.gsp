<%@ page import="tramites.TipoPrioridad; tramites.Tramite" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main2">
    <title>
        <g:if test="${tramite.id}">
            Modificar datos del trámite
        </g:if>
        <g:else>
            Creación de trámites o documentos principales
        </g:else>
    </title>
    <style>

    option.selected {
        background : #DDD;
        color      : #999;
    }

    .selectable li {
        cursor        : pointer;
        border-bottom : solid 1px #0088CC;
        margin-left   : 20px;
    }

    .selectable li:hover {
        background : #B5D1DF;
    }

    .selectable li.selected {
        background : #81B5CF;
        color      : #0A384F;
    }

    .divFieldsListas {
        height     : 280px;
        width      : 970px;
        overflow-x : auto;
    }

    .fieldLista {
        width   : 450px;
        height  : 250px;
        border  : 1px solid #0088CC;
        margin  : 10px 10px 20px 10px;
        padding : 15px;
        float   : left;
    }

    .divBotones {
        width      : 30px;
        height     : 130px;
        margin-top : 75px;
        float      : left;
    }

    .vertical-container {
        padding-bottom : 10px;;
    }

    .texto {
        max-height : 80px;
        overflow   : auto;
        background : #EFE4D1;
        padding    : 3px;
    }

    .claseMin {
        max-height : 60px;
        overflow   : auto;
    }

        .cv{
            color: #67a153;
        }
    </style>
</head>

<body>
<elm:flashMessage tipo="${flash.tipo}" clase="${flash.clase}">${flash.message}</elm:flashMessage>

<!-- botones -->
<div class="btn-toolbar toolbar">
    <div class="btn-group">
        <g:link action="redactar" class="btn btn-success btnSave">
            <i class="fa fa-save"></i> Guardar %{--y empezar a redactar--}%
        </g:link>
        <g:if test="${tramite.padre || tramite.id}">
            <a href="#" class="btn btn-primary" id="btnDetalles">
                <i class="fa fa-search"></i> Detalles
            </a>
        </g:if>
        <g:link action="bandejaEntrada" class="btn btn-warning btnRegresar">
            <i class="fa fa-times"></i> Cancelar
        </g:link>
    </div>
</div>

<g:form class="frmTramite" controller="tramite3" action="save">
    <g:hiddenField name="tramite.padre.id" value="${padre?.id}"/>
    <g:hiddenField name="tramite.id" value="${tramite?.id}"/>
    <g:hiddenField name="tramite.hiddenCC" id="hiddenCC" value="${cc}"/>
    <g:hiddenField name="tramite.aQuienContesta.id" value="${pxt}"/>
    <g:hiddenField name="tramite.esRespuesta" value="${params.esRespuesta}"/>
    <g:hiddenField name="tramite.esRespuestaNueva" value="${params.esRespuestaNueva}"/>
    <g:hiddenField name="tramite.tramitePrincipal" value="${tramite.tramitePrincipal}"/>
    <g:hiddenField name="tramite.agregadoA.id" value="${tramite.agregadoA?.id}"/>

    <g:if test="${tramite.tramitePrincipal > 0}">
        <g:set var="principal" value="${tramites.Tramite.get(tramite.tramitePrincipal)}"/>
    </g:if>

    <g:if test="${padre || principal}">
        <g:if test="${principal?.id != tramite.id}">
            <div style="margin-top: 30px; min-height: 100px;font-size: 11px" class="vertical-container">

                <p class="css-vertical-text">D. Principal</p>

                <div class="linea"></div>

                <div class="row">
                    <span class="col-xs-1 badge bg-primary">Documento:</span>
                    <div class="col-xs-2">${principal.codigo}</div>
%{--                    <div class="col-xs-1 negrilla cv" style="width: 55px">Fecha:</div>--}%
                    <span class="col-xs-1 badge bg-primary">Fecha:</span>
                    <div class="col-xs-2">${principal.fechaCreacion.format("dd-MM-yyyy")}</div>
%{--                    <div class="col-xs-1 negrilla cv" style="width: 32px">De:</div>--}%
                    <span class="col-xs-1 badge bg-primary">De:</span>
                    <div class="col-xs-3">
                        <g:if test="${principal.tipoDocumento.codigo == 'DEX'}">
                            <td>${principal.paraExterno}</td>
                        </g:if>
                        <g:else>
                            ${principal.deDepartamento ? principal.deDepartamento.codigo : "" + principal.de.departamento.codigo + ":" + principal.de.nombre + ' ' + principal.de.apellido}
                        </g:else>
                    </div>
                </div>

                <div class="row claseMin">
                        <div class="col-md-1 negrilla">Destinatarios:</div>
                        <div class="col-xs-11">
                            <g:set var="tt" value="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(principal, rolesNo, [sort: 'rolPersonaTramite']).size()}"/>
                            <g:if test="${tt > 3}">
                                <g:set var="pdt" value="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(principal, rolesNo, [sort: 'rolPersonaTramite'])}"/>
                                <span style="font-weight: bold">${pdt.rolPersonaTramite.descripcion[0]}:</span>
                                <span style="margin-right: 10px">
                                    ${(pdt.departamento[0]) ? pdt.departamento[0] : "" + pdt.persona.departamento.codigo[0] + ":" + pdt.persona[0]}
                                    ${pdt.fechaRecepcion[0] ? "(" + pdt.fechaRecepcion[0].format("dd-MM-yyyy") + ")" : ""}
                                </span>
                                <a href="#" name="destinatarios" title="Copias" class="btn btn-success btn-sm btnDestPadre" data-padre="${principal?.id}"><i class="fa fa-users"></i> Copias</a>
                            </g:if>
                            <g:else>
                                <g:each in="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(principal, rolesNo, [sort: 'rolPersonaTramite'])}" var="pdt" status="j">
                                    <span style="font-weight: bold">${pdt.rolPersonaTramite.descripcion}:</span>
                                    <span style="margin-right: 10px">
                                        ${(pdt.departamento) ? pdt.departamento : "" + pdt.persona.departamento.codigo + ":" + pdt.persona}
                                        ${pdt.fechaRecepcion ? "(" + pdt.fechaRecepcion.format("dd-MM-yyyy") + ")" : ""}
                                    </span>
                                </g:each>
                            </g:else>
                        </div>
                </div>

                <div class="row">
                    <div class="col-md-1 negrilla">Asunto:</div>
                    <div class="col-md-11" style="font-size: 14px; font-weight: bold">${principal.asunto}</div>
                </div>
                <g:if test="${principal.personaPuedeLeer(session.usuario) && principal.texto?.trim()?.size() > 0}">
                    <div class="row">
                        <div class="col-md-1 negrilla">Texto:</div>
                        <div class="col-md-11 texto">
                            <util:renderHTML html="${principal.texto}"/>
                        </div>
                    </div>
                </g:if>

                <g:if test="${principal.observaciones && principal.observaciones?.trim()?.size() > 0}">
                    <div class="row claseMin">
                        <div class="col-md-1 negrilla">Observaciones:</div>
                        <g:set var="cc" value="${principal.observaciones.trim().split("\\s+")}"/>
                        <g:if test="${cc.length >= 30}">
                            <div class="col-md-11">${principal.observaciones[0..199]}<a href="#" name="observaciones" title="Observaciones" data-id="${principal.id}" class="btn btn-success btn-sm btnInfo"><i class="fa fa-exclamation"></i></a></div>
                        </g:if>
                        <g:else>
                            <div class="col-md-11">${principal.observaciones}</div>
                        </g:else>
                    </div>
                </g:if>
            </div>
        </g:if>
        <g:if test="${padre && padre != principal}">
            <div style="margin-top: 30px; min-height: 100px;font-size: 11px" class="vertical-container">

                <p class="css-vertical-text">Contesta a</p>

                <div class="linea"></div>

                <div class="row">
                    <span class="col-xs-1 badge bg-primary">Documento:</span>
                    <div class="col-xs-2">${padre.codigo}</div>
                    <span class="col-xs-1 badge bg-primary">Fecha:</span>
                    <div class="col-xs-2">${padre.fechaCreacion.format("dd-MM-yyyy")}</div>
                    <span class="col-xs-1 badge bg-primary">De:</span>

                    <div class="col-xs-3">
                        <g:if test="${padre.tipoDocumento.codigo == 'DEX'}">
                            <td>${padre.paraExterno}</td>
                        </g:if>
                        <g:else>
                            ${padre.deDepartamento ? padre.deDepartamento.codigo : "" + padre.de.departamento.codigo + ":" + padre.de.nombre + ' ' + padre.de.apellido}
                        </g:else>
                    </div>
                </div>

                <div class="row ">
                    <div class="col-md-1 negrilla">Destinatarios:</div>
                    <div class="col-xs-11">
                        <g:set var="tt1" value="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(padre, rolesNo, [sort: 'rolPersonaTramite']).size()}"/>
                        <g:if test="${tt1 > 3}">
                            <g:set var="pad" value="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(padre, rolesNo, [sort: 'rolPersonaTramite'])}"/>
                                <span style="font-weight: bold">${pad.rolPersonaTramite.descripcion[0]}:</span>
                                <span style="margin-right: 10px">
                                    ${(pad.departamento[0]) ? pad.departamento[0] : "" + pad.persona.departamento.codigo[0] + ":" + pad.persona[0]}
                                    ${pad.fechaRecepcion[0] ? "(" + pad.fechaRecepcion[0].format("dd-MM-yyyy") + ")" : ""}
                                </span>
                            <a href="#" name="destinatarios1" title="Copias" class="btn btn-success btn-sm btnDestPadre" data-padre="${padre?.id}"><i class="fa fa-users"></i> Copias</a>
                        </g:if>
                        <g:else>
                            <g:each in="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(padre, rolesNo, [sort: 'rolPersonaTramite'])}" var="pdt" status="j">
                                <span style="font-weight: bold">${pdt.rolPersonaTramite.descripcion}:</span>
                                <span style="margin-right: 10px">
                                    ${(pdt.departamento) ? pdt.departamento : "" + pdt.persona.departamento.codigo + ":" + pdt.persona}
                                    ${pdt.fechaRecepcion ? "(" + pdt.fechaRecepcion.format("dd-MM-yyyy") + ")" : ""}
                                </span>
                            </g:each>
                        </g:else>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-1 negrilla">Asunto:</div>
                    <div class="col-md-11" style="font-size: 14px; font-weight: bold">${padre.asunto}</div>
                </div>

                <g:if test="${padre.personaPuedeLeer(session.usuario) && padre.texto?.trim()?.size() > 0}">
                    <div class="row">
                        <div class="col-md-1 negrilla">Texto:</div>

                        <div class="col-md-11 texto">
                            <util:renderHTML html="${padre.texto}"/>
                        </div>
                    </div>
                </g:if>

                <g:if test="${padre.observaciones && padre.observaciones?.trim()?.size() > 0}">
                    <div class="row claseMin">
                        <div class="col-md-1 negrilla">Observaciones:</div>
                        <g:set var="cc1" value="${padre.observaciones.trim().split("\\s+")}"/>
                        <g:if test="${cc1.length >= 30}">
                            <div class="col-md-11">${padre.observaciones[0..199]}<a href="#" name="observaciones1" title="Observaciones" data-id="${padre.id}" class="btn btn-success btn-sm btnInfo"><i class="fa fa-exclamation"></i></a></div>
                        </g:if>
                        <g:else>
                            <div class="col-md-11">${padre.observaciones}</div>
                        </g:else>
                   </div>
                </g:if>
            </div>
        </g:if>
    </g:if>

    <div style="margin-top: 30px;" class="vertical-container">

        <p class="css-vertical-text">Trámite</p>

        <div class="linea"></div>

        <div class="row">
            <div class="col-xs-4">
                <b>De:</b>
            </div>
        </div>

        <div class="row">
            <div class="col-xs-4">
                <g:set var="nombre" value="${de.nombre + " " + de.apellido}"/>

                <g:if test="${nombre.size() <= 36}">
                    <div class="uneditable-input label-shared" id="de"
                         title="${de?.departamento?.descripcion}">
                        ${de.nombre} ${de.apellido}
                    </div>
                </g:if>
                <g:else>
                    <div class="uneditable-input label-shared" id="de"
                         title="${de?.departamento?.descripcion}">
                        ${nombre.substring(0, 33) + "..."}
                    </div>
                </g:else>

            </div>

            <div class="col-xs-3" style="margin-top: -25px">
                <b>Tipo de documento:</b>

                <elm:comboTipoDoc id="tipoDocumento" name="tramite.tipoDocumento.id" class="many-to-one form-control required"
                                  value="${tramite.tipoDocumentoId ?: tramites.TipoDocumento.findByCodigo('MEM').id}"
                                  tramite="${tramite}" tipo="pers"/>
            </div>

            <div class="col-xs-4 negrilla hide" id="divPara" style="margin-top: -10px"></div>
        </div>

        <div class="row">
            <div class="col-xs-12 ">
                <span class="grupo">
                    <b>Adicional Para:</b>
                    <input type="text" name="textoPara" class="form-control" id="textoPara" maxlength="1023"
                           style="width: 850px;display: inline" value="${tramite?.textoPara}"/>
                </span>
            </div>
        </div>

        <div class="row">

            <div class="col-xs-2 ">
                <b>Prioridad:</b>
                <elm:select name="tramite.prioridad.id" id="prioridad" class="many-to-one form-control required" from="${tramites.TipoPrioridad.list()}"
                            value="${tramite.prioridadId ?: 3}" optionKey="id" optionValue="descripcion" optionClass="tiempo"/>
            </div>

            <div class="col-xs-2 ">
                <b>Creado el:</b>
                <input type="text" name="tramite.fecha" class="form-control required label-shared" id="creado" maxlength="30"
                       value="${tramite.fechaCreacion.format('dd-MM-yyyy HH:mm')}" disabled style="width: 150px"/>
            </div>

            <div class="col-xs-2 ">
                <b>Respuesta esperada:</b>
                <span id="respuesta" class="uneditable-input">FECHA</span>
            </div>

            <div class="col-xs-2 negrilla" style="margin-top: 10px; width: 100px;" id="divCc">
                <label for="cc">
                    <i class="fa fa-paste"></i> Con copia
                </label>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="cc" name="cc" ${tramite.id && tramite.copias.size() != 0 ? 'checked' : ''}>
                </div>
            </div>

            <div class="col-xs-2 negrilla hide" id="divConfidencial" style="margin-top: 10px;width: 110px;">
                <label for="confi">
                    <i class="fa fa-user-secret"></i>  Confidencial
                </label>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="confi" name="confi" ${tramite.tipoTramite?.codigo == 'C' ? 'checked' : ''}>
                </div>
            </div>

            <div class="col-xs-2 negrilla hide" id="divAnexos" style="margin-top: 10px; width: 110px;">
                <label for="anexo">
                    <i class="fa fa-paperclip"></i> Con anexos
                </label>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="anexo" name="anexo" ${tramite.id && tramite.anexo == 1 ? 'checked' : ''}>
                </div>
            </div>

        </div>

        <div class="row">
            <div class="col-xs-12 ">
                <span class="grupo">
                    <b>Asunto:</b>
                    <input type="text" name="tramite.asunto" class="form-control required" id="asunto" maxlength="1023"
                           style="width: 900px;display: inline" value="${tramite.asunto}"/>
                </span>
            </div>
        </div>
    </div>

    <div style="float: left;width: 100%" class="vertical-container hide" id="divOrigen">
        <p class="css-vertical-text" style="bottom: -10px;">Origen</p>

        <div class="linea"></div>

        <div class="row">

            <div class="col-xs-3 ">
                <span class="grupo">
                    <b>Institución/Remitente:</b>
                    <g:textField name="paraExt3" id="paraExt3" class="form-control required" maxlength="127"
                                 value="${tramite.paraExterno}"/>
                </span>
            </div>

            <div class="col-xs-3 ">
                <span class="grupo">
                    <b>Núm. doc. ext.:</b>
                    <g:textField id="numeroDocExterno" name="tramite.numeroDocExterno" class="form-control " maxlength="35"
                                 value="${tramite.numeroDocExterno}"/>
                </span>
            </div>

            <div class="col-xs-2 ">
                <span class="grupo">
                    <b>Teléfono:</b>

                    <div class="input-group">
                        <g:textField id="telefonoExt" name="tramite.telefono" class="form-control telefono required" maxlength="15"
                                     value="${tramite?.telefono}"/>
                        <span class="input-group-addon"><i class="fa fa-phone"></i></span>
                    </div>
                </span>
            </div>

            <div class="col-xs-3 ">
                <span class="grupo">
                    <b>Contacto:</b>
                    <g:textField id="contacto" name="tramite.contacto" class="form-control required" maxlength="31"
                                 value="${tramite.contacto}"/>
                </span>
            </div>
        </div>
    </div>
</g:form>

<div style="float: left;width: 100%" class="vertical-container hide" id="divCopia">
    <p class="css-vertical-text" id="tituloCopia">Con copia / Circular</p>

    <div class="linea"></div>

    <div class="divFieldsListas">
        <fieldset class="ui-corner-all fieldLista">
            <legend style="margin-bottom: 1px">
                Disponibles
            </legend>

            <ul id="ulDisponibles" style="margin-left:0;max-height: 195px; overflow: auto;" class="fa-ul selectable">
                <g:each in="${disponibles}" var="disp">
                    <g:if test="${disp.id.toInteger() < 0}">
                        <li data-id="${disp.id}" class="clickable ${disp.externo ? 'externo' : 'interno'}">
                            <i class="fa fa-li ${disp.externo ? 'fa-paper-plane' : 'fa-building'}"></i> ${disp.label}
                        </li>
                    </g:if>
                    <g:else>
                        <li data-id="${disp.id}" class="clickable interno">
                            <i class="fa fa-li fa-user"></i> ${disp.label}
                        </li>
                    </g:else>
                </g:each>
            </ul>
        </fieldset>

        <div class="divBotones">
            <div class="btn-group-vertical">
                <a href="#" class="btn btn-default" title="Agregar todos" id="btnAddAll">
                    <i class="fa fa-angle-double-right"></i>
                </a>
                <a href="#" class="btn btn-default" title="Agregar seleccionados" id="btnAddSelected">
                    <i class="fa fa-angle-right"></i>
                </a>
                <a href="#" class="btn btn-default" title="Quitar seleccionados" id="btnRemoveSelected">
                    <i class="fa fa-angle-left"></i>
                </a>
                <a href="#" class="btn btn-default" title="Quitar todos" id="btnRemoveAll">
                    <i class="fa fa-angle-double-left"></i>
                </a>
            </div>
        </div>

        <fieldset class="ui-corner-all fieldLista">
            <legend style="margin-bottom: 1px">
                Seleccionados
            </legend>

            <ul id="ulSeleccionados" style="margin-left:0;max-height: 195px; overflow: auto;" class="fa-ul selectable">
                <g:if test="${tramite.id}">
                    <g:each in="${tramite.copias}" var="disp">
                        <g:if test="${disp.persona}">
                            <li data-id="${disp.persona.id}" class="clickable interno">
                                <i class="fa fa-li fa-user"></i> ${disp.persona.toString()}
                            </li>
                        </g:if>
                        <g:else>
                            <li data-id="-${disp.departamento.id}" class="clickable ${disp.departamento.externo == 1 ? 'externo' : 'interno'}">
                                <i class="fa fa-li ${disp.departamento.externo ? 'fa-paper-plane' : 'fa-building'}"></i> ${disp.departamento.descripcion}
                            </li>
                        </g:else>
                    </g:each>
                </g:if>
            </ul>
        </fieldset>
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

    $(".btnInfo").click(function () {
        var id = $(this).data("id");
        $.ajax({
            type: 'POST',
            url: '${createLink(controller: 'tramite', action: 'observaciones_ajax')}',
            data:{
                id: id
            },
            success:function (msg) {
                bootbox.dialog({
                    title   : "Observaciones",
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
    });

    $(".btnObservacionesPadre").click(function () {
        var observaciones = $(this).data("ob");
        bootbox.alert('<strong>' + 'OBSERVACIONES: ' + '</strong>' + observaciones)
    });

    $(".btnDestPadre").click(function () {
        var padre = $(this).data("padre");
        $.ajax({
            type: 'POST',
            url: '${createLink(controller: 'tramite', action: 'destinatariosPadre_ajax')}',
            data:{
                padre: padre
            },
            success:function (msg) {
                bootbox.dialog({
                    title   : "Destinatarios",
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
    });

    $.switcher('input[type=checkbox]');

    function destinatarioExiste(tipo, id) {
        var total = 0;
        $("#ulDestinatarios").children("li").each(function () {
            if ($(this).data("tipo") == tipo && $(this).data("id") == id) {
                total++;
            }
        });
        return total;
    }

    function validarTipoDoc() {
        var $tipoDoc = $("#tipoDocumento");
        var codigoTipoDoc = $tipoDoc.find("option:selected").attr("class");
        var $divPara = $("#divPara");
        var $divCopia = $("#divCopia");
        var $divCc = $("#divCc");
        var $divExterno = $("#divExterno");
        var $divOrigen = $("#divOrigen");
        var $cc = $("#cc");
        var $tituloCopia = $("#tituloCopia");
        var $divConfidencial = $("#divConfidencial");
        var $divAnexos = $("#divAnexos");
        var $divBotonInfo = $("#divBotonInfo");
        var $chkAnexos = $("#anexo");
        var $chkExterno = $("#externo");

        var cod = $tipoDoc.find("option:selected").attr("class");
        $tituloCopia.text("Con copia");
        $divOrigen.addClass("hide");

        $divPara.html(spinner);
        $divBotonInfo.remove();

        switch (codigoTipoDoc) {
//                    case "CIR":
            case "OFI":
                html = $("<div class='col-xs-3 negrilla' id='divPara' style='margin-top: -25px; margin-left:-25px;'></div>");
                html.append("<b>Para:</b>");
                html.append("<input type='text' name='paraExt' id='paraExt' class='form-control label-shared required' " +
                    "value='${tramite?.paraExterno}' style='width: 300px;' maxlength='500' />");
                $divPara.replaceWith(html);
                break;

            case "DEX":
                $divPara.html("");
                break;
            default:
                $.ajax({
                    type    : "POST",
                    url     : "${createLink(controller:'tramite', action:'getParaNuevo_ajax')}",
                    data    : {
                        tramite : "${tramite.id}"
                    },
                    success : function (msg) {
                        $divPara.replaceWith(msg);
                        validarExterno(false);
                    }
                });
                break;
        }

        //removeAllSelected
        <g:if test="${tramite.id}">
        </g:if>
        <g:else>
        removeAll();
        </g:else>

        switch (cod) {
            case "CIR":
                $divCopia.removeClass("hide");
                $divCc.addClass("hide");
                $tituloCopia.text("Circular");
                $divConfidencial.removeClass("hide");
                $divAnexos.addClass("hide");
                $divExterno.removeClass("hide");
                break;

            case "OFI":
                $divCopia.addClass("hide");
                $divCc.removeClass("hide");
                $divConfidencial.removeClass("hide");
                $divAnexos.removeClass("hide");
                $divExterno.removeClass("hide");
                $chkExterno.prop("checked", true);
                break;
            case "DEX":
                $divCopia.addClass("hide");
                $divCc.addClass("hide");
                $divOrigen.removeClass("hide");
                $divConfidencial.removeClass("hide");
                $divAnexos.removeClass("hide");
                $divExterno.removeClass("hide");
                $chkExterno.prop("checked", true);
                break;
            case "SUM":
                $divCopia.addClass("hide");
                $divCc.removeClass("hide");
                $divConfidencial.removeClass("hide");
                $divAnexos.addClass("hide");
                $divExterno.addClass("hide");
                $chkExterno.prop("checked", false);
                break;
            default :
                $divCopia.addClass("hide");
                $divCc.removeClass("hide");
                $divConfidencial.removeClass("hide");
                $divAnexos.removeClass("hide");
                $divExterno.removeClass("hide");
                $chkExterno.prop("checked", false);
        }
        if (!cod) {
            $divCopia.addClass("hide");
            $divCc.addClass("hide");
            $divConfidencial.addClass("hide");
            $divAnexos.addClass("hide");
            $divExterno.addClass("hide");
            $chkExterno.prop("checked", false);
        }
        <g:if test="${!tramite.id || (tramite.id && tramite.copias.size() == 0)}">
        $cc.prop('checked', false);
        </g:if>
        <g:else>
        $cc.prop('checked', true);
        </g:else>
        <g:if test="${tramite.id && tramite.anexo == 1}">
        $chkAnexos.prop('checked', true);
        </g:if>
        <g:else>
        $chkAnexos.prop('checked', false);
        </g:else>
        <g:if test="${tramite.externo=='1'}">
        $chkExterno.prop('checked', true);
        </g:if>
        <g:else>
        if (cod != "DEX" && cod != "OFI") {
            $chkExterno.prop('checked', false);
        }
        </g:else>
    }

    function validarCheck() {
        // var checked = $("#cc").is(":checked") && $("#cc").is(":visible");
        var checked = $("#cc").is(":checked");
        if (checked) {
            $("#divCopia").removeClass("hide");
        } else {
            if (!$("#tipoDocumento option:selected").hasClass("CIR")) {
                $("#divCopia").addClass("hide");
                removeAll();
            }
        }
    }

    function addItem($combo, tipo) {
        var id = $combo.val();
        if (destinatarioExiste(tipo, id) == 0) {
            var $selected = $combo.find("option:selected");
            $selected.addClass("selected");
            var text = $combo.find("option:selected").text();
            var $ul = $("#ulDestinatarios");
            var $del = $('<a href="#" class="btn btn-danger btn-xs pull-right"><i class="fa fa-times"></i></a>');
            var $li = $("<li data-tipo='" + tipo + "' data-id='" + id + "'></li>");
            var icon = "";
            switch (tipo) {
                case "usuario":
                    icon = "<i class='fa-li fa fa-user'></i>";
                    break;
                case "direccion":
                    icon = "<i class='fa-li fa fa-building'></i>";
                    break;
            }
            $li.append(icon);
            $li.append(text);
            $li.append($del);
            $ul.prepend($li);
            $li.effect({
                effect   : "highlight",
                duration : 800
            });
            $del.click(function () {
                $li.hide({
                    effect   : "blind",
                    complete : function () {
                        $li.remove();
                        $selected.removeClass("selected");
                    }
                });
                return false;
            });
        }
    }

    function validarTiempos() {
        $.ajax({
            type    : "POST",
            url     : "${createLink(action:'tiempoRespuestaEsperada_ajax')}",
            data    : {
                fecha     : "${tramite.fechaCreacion.format('dd-MM-yyyy HH:mm')}",
                prioridad : $("#prioridad").val()
            },
            success : function (msg) {
                var parts = msg.split("_");
                if (parts[0] == "OK") {
                    $('#respuesta').text(parts[1]);
                }
            }
        });
    }

    function moveSelected($from, $to, muevePara, override) {
        if (override == undefined) {
            var para = $("#para").val();
            $from.find("li.selected").removeClass("selected").each(function () {
                var id = $(this).data("id");
                if ((id == para && muevePara) || id != para) {
                    $(this).prependTo($to);
                }
            });
        } else {
            if ($("#tipoDocumento").find("option:selected").hasClass("OFI") || ($("#para") && $("#para").is(":visible"))) {
                var para = $("#para").val();
                $from.find("li.selected").removeClass("selected").each(function () {
                    var id = $(this).data("id");
                    if ((id == para && muevePara) || id != para) {
                        $(this).prependTo($to);
                    }
                });
            } else {
                bootbox.alert("Por favor espere a que se cargue el destinatario antes de modificar las copias");
            }
        }
        $("li.selected").removeClass("selected");
    }

    function removeAll(override) {
        var $ul = $("#ulSeleccionados");
        $ul.find("li").addClass("selected");
        moveSelected($ul, $("#ulDisponibles"), true, override);
    }

    function validarExterno(remove) {
        if (remove) {
            removeAll();
        }
        if ($("#externo").is(":checked")) {
            $(".externo").show();
            $(".interno").hide();
            $("#para").val($("#para option:visible:first").val());
        } else {
            $(".externo").show();
            $(".interno").show();
        }
    }

    $(function () {
        <g:if test="${bloqueo}">
        $("#modalTabelGray").css({marginTop : "-20px", zIndex : "999"}).show();
        </g:if>
        var $dir = $("#direccion");
        var $selPrioridad = $("#prioridad");

        $selPrioridad.change(function () {
            validarTiempos();
        }).change();

        $dir.change(function () {
            var id = $(this).val();
            var $div = $("#divBtnDir");
            if (id != "" && $div.children().length == 0) {
                var $btn = $("<a href='#' class='btn btn-xs btn-primary'>Agregar dirección</a>");
                $div.html($btn);

                $btn.click(function () {
                    addItem($dir, "direccion");
                    return false;
                });
            }
            if (id == "") {
                $div.html("");
            }
        });

        $("#externo").click(function () {
            var tipoDoc = $("#tipoDocumento").find("option:checked").attr("class");
            if (tipoDoc == "OFI" || tipoDoc == "DEX") {
                $(this).prop("checked", true);
            }
            if ($(this).is(":checked") && tipoDoc != "OFI" && tipoDoc != "DEX") {
                $("#divParaExt").removeClass("hide");
            } else {
                $("#divParaExt").addClass("hide");
            }
            validarExterno(true);
        });
        validarExterno(false);

        $("#btnDetalles").click(function () {
            $.ajax({
                type    : 'POST',
                url     : '${createLink(controller: 'tramite3', action: 'detalles')}',
                data    : {
                    id : "${tramite.id?:tramite.padreId}"
                },
                success : function (msg) {
                    $("#dialog-body").html(msg)
                }
            });
            $("#dialog").modal("show");
            return false;
        });

        $("#btnInfoPara").click(function () {
            var para = $("#para").val();
            var paraExt = $("#paraExt").val();
            var id;
            var url = "";
            if (para) {
                if (parseInt(para) > 0) {
                    url = "${createLink(controller: 'persona', action: 'show_ajax')}";
                    id = para;
                } else {
                    url = "${createLink(controller: 'departamento', action: 'show_ajax')}";
                    id = parseInt(para) * -1;
                }
            }

            $.ajax({
                type    : "POST",
                url     : url,
                data    : {
                    id : id
                },
                success : function (msg) {
                    bootbox.dialog({
                        title   : "Información",
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
            return false;
        });

        $("#cc").click(function () {
            validarCheck();
        });

        $("#tipoDocumento").change(function () {
            validarTipoDoc();
        }).change();

        $("#cedulaOrigen").blur(function () {
            var ci = $.trim($(this).val());
            $.ajax({
                type    : "POST",
                url     : "${createLink(controller: 'origenTramite', action:'getDatosByCedula_ajax')}",
                data    : {
                    cedula : ci
                },
                success : function (msg) {
                    if (msg == "NO") {
                        $(".origenTram").not("#cedulaOrigen").val("");
                    } else {
                        $.each(msg, function (key, val) {
                            if (key != "tipoPersona") {
                                $("#" + key + "Origen").val(val);
                            } else {
                                $("#tipoPersonaOrigen").val(val.id);
                            }
                        });
                    }
                }
            });
        });

        validarCheck();

        $(".clickable").dblclick(function () {
            $(this).addClass("selected");
            if ($(this).parents("ul").attr("id") == "ulSeleccionados") {
                moveSelected($("#ulSeleccionados"), $("#ulDisponibles"), false, true);
            } else if ($(this).parents("ul").attr("id") == "ulDisponibles") {
                moveSelected($("#ulDisponibles"), $("#ulSeleccionados"), false, true);
            }
        });

        $(".selectable li").click(function () {
            $(this).toggleClass("selected");
        });
        $("#btnAddAll").click(function () {
            var $ul = $("#ulDisponibles");
            $ul.find("li").addClass("selected");
            moveSelected($ul, $("#ulSeleccionados"), false, true);
            return false;
        });
        $("#btnAddSelected").click(function () {
            moveSelected($("#ulDisponibles"), $("#ulSeleccionados"), false, true);
            return false;
        });
        $("#btnRemoveSelected").click(function () {
            moveSelected($("#ulSeleccionados"), $("#ulDisponibles"), true, true);
            return false;
        });

        $("#btnRemoveAll").click(function () {
            removeAll(true);
            return false;
        });
        <g:if test="${!bloqueo}">
        $(".btnSave").click(function () {


            if ($(".frmTramite").valid()) {
                $.ajax({
                    type    : "POST",
                    url     : "${createLink(controller: 'tramite2', action: 'confirmacion_ajax')}",
                    data    : {
                        tipo: $("#tipoDocumento").val(),
                        para: $("#para").val(),
                        asunto: $("#asunto").val(),
                        ext: $("#paraExt").val()
                    },
                    success : function (msg) {
                        bootbox.dialog({
                            title   : "Confirmación de creación de Trámite",
                            message : msg,
                            buttons : {
                                cancelar : {
                                    label     : "<i class='fa fa-times'></i> Cancelar",
                                    className : "btn-primary",
                                    callback  : function () {
                                    }
                                },
                                aceptar : {
                                    label     : "<i class='fa fa-save'></i> Aceptar",
                                    className : "btn-success",
                                    callback  : function () {
                                        var b = cargarLoader("Guardando...");
                                        var cc = "";
                                        $("#ulSeleccionados li").each(function () {
                                            cc += $(this).data("id") + "_";
                                        });
                                        $("#hiddenCC").val(cc);
                                        $(".frmTramite").submit();
                                        $(this).attr("disabled", true);
                                    }
                                }
                            }
                        });
                    }
                });
            }
            return false;
        });
        </g:if>

        var validator = $(".frmTramite").validate({
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
            },
            rules          : {
                cedulaOrigen : {
                    required : {
                        depends : function (element) {
                            return $("#tipoDocumento").find("option:selected").hasClass("DEX");
                        }
                    }
                },
                nombreOrigen : {
                    required : {
                        depends : function (element) {
                            return $("#tipoDocumento").find("option:selected").hasClass("DEX");
                        }
                    }
                }
            }
        });
    });
</script>
</body>
</html>