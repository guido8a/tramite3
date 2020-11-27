<%@ page import="tramites.RolPersonaTramite; tramites.PersonaDocumentoTramite; tramites.EstadoTramite" %>

%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.js')}"></script>--}%
%{--<script type="text/javascript" src="${resource(dir: 'js/plugins/lzm.context/js', file: 'lzm.context-0.5.js')}"></script>--}%
%{--<link href="${resource(dir: 'js/plugins/lzm.context/css', file: 'lzm.context-0.5.css')}" rel="stylesheet">--}%

%{--<script type="text/javascript" src="${resource(dir: 'js/plugins/fixed-header-table-1.3', file: 'jquery.fixedheadertable.min.js')}"></script>--}%
%{--<link href="${resource(dir: 'js/plugins/fixed-header-table-1.3/css', file: 'defaultTheme.css')}" rel="stylesheet">--}%

<style type="text/css">
table {
    font-size : 9pt;
}

.clearfix:after {

    content: ".";

    display: block;

    clear: both;

    visibility: hidden;

    line-height: 0;

    height: 0;
}

.clearfix {

    display: inline-block;
}

html[xmlns] .clearfix {

    display: block;
}

* html .clearfix {

    height: 1%;
}
</style>


<div class="clearfix" style="width: 100%;"><util:renderHTML html="${msje}"/></div>

<table class="table table-bordered table-condensed table-hover" style="width: 100%;">
    <thead>
    <tr>
        <th class="alinear" style="width: 10%">Documento</th>
        <th class="alinear" style="width: 10%">Creación</th>
        <th class="alinear" style="width: 10%">De</th>
        <th class="alinear" style="width: 10%">Para</th>
        <th class="alinear" style="width: 24%">Asunto</th>
        <th class="alinear" style="width: 6%">Prioridad</th>
        <th class="alinear" style="width: 10%">Envia</th>
        <th class="alinear" style="width: 10%">Envio</th>
        <th class="alinear" style="width: 10%">Recepción</th>
    </tr>
    </thead>
</table>

<div class="row-fluid"  style="width: 99.7%;height: 405px;overflow-y: auto;float: right; margin-top: -20px">
    <table class="table table-bordered table-condensed table-hover" style="width: 100%;">
        <tbody>
        <g:set var="estadoAnulado" value="${tramites.EstadoTramite.findByCodigo('E006')}"/>
        <g:set var="estadoRecibido" value="${EstadoTramite.findByCodigo('E004')}"/>

        <g:set var="rolRecibe" value="${tramites.RolPersonaTramite.findByCodigo('E003')}"/>
        <g:set var="rolEnvia" value="${RolPersonaTramite.findByCodigo('E004')}"/>
        <g:set var="rolPara" value="${RolPersonaTramite.findByCodigo('R001')}"/>

        <g:each in="${tramites}" var="tramite" status="z">

            <g:set var="recibe" value="${tramites.PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(tramite, rolRecibe)}"/>
            <g:set var="envia" value="${PersonaDocumentoTramite.findByTramiteAndRolPersonaTramite(tramite, rolEnvia)}"/>
            <g:set var="receptoresAnulados" value="${(tramite.allCopias + tramite.para).findAll {
                it?.estado == estadoAnulado
            }}"/>

            <g:set var="padre" value=""/>
            <g:set var="clase" value="${'nada'}"/>
            <g:set var="de" value="${tramite?.deDepartamentoId ?: tramite?.de?.departamentoId}"/>

            <g:if test="${tramite.de?.id == session.usuario.id ||
                    tramite.deDepartamento?.id == session.usuario.departamentoId ||
                    (session.usuario.esTriangulo && de == session.usuario.departamentoId)}">
                <g:set var="clase" value="${'principal'}"/>
                <g:if test="${tramite.padre}">
                    <g:set var="padre" value="${tramite.padre?.id}"/>
                    <g:set var="clase" value="${'padre'}"/>
                </g:if>
            </g:if>

            <g:if test="${tramite.anexo == 1}">
                <g:set var="clase" value="${clase + ' conAnexo'}"/>
            </g:if>

            <g:if test="${recibe && recibe.fechaRecepcion}">
                <g:set var="clase" value="${clase + ' recibido'}"/>
            </g:if>

            <g:set var="copiasExternas" value="${tramite.copias.findAll { it.departamento?.externo == 1 }}"/>
            <g:set var="externo" value=""/>
            <g:if test="${tramite.externo == '1' || tramite.tipoDocumento.codigo == 'DEX'}">
                <g:set var="externo" value="externo"/>
            </g:if>

            <g:if test="${copiasExternas.estado.codigo.contains('E003')}">
                <g:set var="externo" value="${externo} externoCC"/>
            </g:if>
        %{--            <g:if test="${(params.dgsg == 'DGSG') || tramite?.deId == session.usuario.id || (tramite?.departamento?.id == session.departamento.id && session.usuario.esTriangulo)}">--}%
        %{--                <g:set var="clase" value="${clase + ' mio'}"/>--}%
        %{--            </g:if>--}%

            <g:set var="para" value="${tramite.para?.persona ? tramite.para?.persona?.departamentoId : tramite.para?.departamentoId}"/>
            <g:each in="${tramite.copias}" var="copia">
                <g:set var="para" value="${para + ',' + (copia?.persona ? copia?.persona?.departamentoId : copia?.departamentoId)}"/>
            </g:each>

            <g:set var="respuestas" value="${tramite.respuestas.size()}"/>

            <g:if test="${tramite.fechaEnvio}">
                <g:set var="clase" value="${clase + ' enviado'}"/>
            </g:if>

            <g:if test="${tramite?.estadoTramite?.codigo == 'E001'}">
                <g:set var="clase" value="${clase + ' E001'}"/>
            </g:if>

            <tr id="${tramite?.id}" data-id="${tramite?.id}" padre="${padre}" class="${clase} ${externo}" anulados="${receptoresAnulados.size()}"
                dep="${tramite?.de?.departamentoId}" principal="${tramite.tramitePrincipal}" para="${para}" respuestas="${respuestas}"
                de="${tramite.tipoDocumento.codigo == 'DEX' ? 'E_' + tramite?.id :
                        (tramite.deDepartamento ? 'D_' + tramite.deDepartamento?.id : 'P_' + tramite.de?.id)}" style="width: 100%">
                <td class="codigo" style="width: 10%">
                    <g:if test="${tramite?.tipoTramite?.codigo == 'C'}">
                        <i class="fa fa-eye-slash"></i>
                    </g:if>
                    <g:if test="${tramite?.anexo == 1 && DocumentoTramite.countByTramite(tramite) > 0}">
                        <i class="fa fa-paperclip"></i>
                    </g:if>
                    ${tramite?.codigo}
                    <g:if test="${tramite.externo == '1' || tramite.tipoDocumento.codigo == 'DEX'}">
                        (ext)
                    </g:if>
                </td>

                <td class="creacion" style="width: 10%">
                    ${tramite.fechaCreacion.format('dd-MM-yyyy HH:mm')}
                </td>

                <td class="de" style="width: 10%">
                    <g:if test="${tramite.tipoDocumento.codigo == 'DEX'}">
                        ${tramite.paraExterno} (ext)
                    </g:if>
                    <g:else>
                        <g:if test="${tramite.deDepartamento}">
                            ${tramite.departamentoNombre}
                        </g:if>
                        <g:elseif test="${tramite.de}">
                            ${tramite.persona} (${tramite.departamentoSigla})
                        </g:elseif>
                    </g:else>
                </td>

                <td class="para" style="width: 10%">
                    <g:if test="${tramite.tipoDocumento.codigo == 'OFI'}">
                        ${tramite.paraExterno} (ext)
                    </g:if>
                    <g:else>
                        <g:if test="${tramite.para}">
                            <g:if test="${tramite.para.persona}">
                                ${tramite.para.personaNombre} (${tramite.para.departamentoSigla})
                            </g:if>
                            <g:elseif test="${tramite.para.departamento}">
                                ${tramite.para.departamentoNombre}
                            </g:elseif>
                        </g:if>
                        <g:if test="${!tramite?.para && !tramite?.para?.departamento}">
                            <i class="fa fa-user-times text-warning"> Sin Destinatario:</i>
                            <span style="color: #800">
                                No visible en la cadena.<br/> Consulte al Administra- dor del Sistema</span>
                        </g:if>
                        <g:if test="${tramite.copias && tramite.copias.size() > 0}">
                            <span class="small">
                                <strong>CC:</strong>
                                <g:each in="${tramite.copias}" var="c" status="i">
                                    <g:if test="${c.persona}">
                                        ${c.persona.nombre} ${c.persona.apellido} (${c.persona.departamento?.codigo})${i < tramite.copias.size() - 1 ? ', ' : ''}
                                    </g:if>
                                    <g:elseif test="${c.departamento}">
                                        ${c.departamento.codigo}${i < tramite.copias.size() - 1 ? ', ' : ''}
                                    </g:elseif>
                                </g:each>
                            </span>
                        </g:if>
                    </g:else>
                </td>

                <td class="asunto" style="width: 24%">
                    ${tramite.asunto}
                </td>

                <td class="prioridad" style="width: 6%">
                    ${tramite.prioridad.descripcion}
                </td>

                <td class="envia" style="width: 10%">
                    <g:if test="${envia}">
                        ${envia.persona.nombre} ${envia.persona.apellido}
                    </g:if>
                </td>
                <td class="envio" style="width: 10%">
                    <g:if test="${tramite.fechaEnvio}">
                        ${tramite.fechaEnvio.format('dd-MM-yyyy HH:mm')}
                    </g:if>
                </td>

                <td class="recepcion" style="width: 10%">
                    <g:if test="${recibe && recibe.fechaRecepcion && tramite.estadoTramite == estadoRecibido}">
                        ${recibe.fechaRecepcion.format('dd-MM-yyyy HH:mm')}
                    </g:if>
                </td>
            </tr>
        </g:each>

        </tbody>
    </table>
</div>

<script type="text/javascript">
    $(function () {
        $("tr").contextMenu({
            items  : createContextMenu,
            onShow : function ($element) {
                $element.addClass("trHighlight");
            },
            onHide : function ($element) {
                $(".trHighlight").removeClass("trHighlight");
            }
        });

        %{--$('.table').fixedHeaderTable({--}%
        %{--    height : ${msg == '' ? 550 : 500}--}%
        %{--});--}%
    });
</script>