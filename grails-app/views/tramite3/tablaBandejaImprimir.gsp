<%@ page import="tramites.DocumentoTramite" %>

%{--<script type="text/javascript" src="${resource(dir: 'js/plugins/lzm.context/js', file: 'lzm.context-0.5.js')}"></script>--}%
%{--<link href="${resource(dir: 'js/plugins/lzm.context/css', file: 'lzm.context-0.5.css')}" rel="stylesheet">--}%

<table class="table table-bordered  table-condensed table-hover">
    <thead>
        <tr>
            <th class="cabecera">Documento</th>
            <th>De</th>
            <th class="cabecera">Fec. Creación</th>
            <th class="cabecera">Para</th>
            <th class="cabecera">Destinatario</th>
            <th class="cabecera">Prioridad</th>
            <th class="cabecera">Fecha Envío</th>
            <th class="cabecera">F. Límite Recepción</th>
            <th class="cabecera">Estado</th>
            <th class="cabecera">Enviar</th>
        </tr>
    </thead>
    <tbody id="tabla_salida">
        <g:each in="${tramites}" var="tramite">

            <g:set var="limite" value="${tramite.getFechaBloqueo()}"/>
            <g:set var="padre" value=""/>

            <g:set var="para" value="${tramite.getPara()}"/>
            <g:set var="copias" value="${tramite.getCopias()}"/>

            <g:set var="esImprimir" value="${false}"/>
            <g:if test="${(tramites.PersonaDocumentoTramite.findAllByPersonaAndTramite(session.usuario, tramite).findAll {
                it.rolPersonaTramite.codigo == 'I005'
            }).size() > 0}">
                <g:set var="esImprimir" value="${true}"/>
            </g:if>

            <g:if test="${tramite?.anexo == 1 && tramites.DocumentoTramite.countByTramite(tramite) > 0}">
                <g:set var="anexo" value="${'conAnexo'}"/>
            </g:if>
            <g:else>
                <g:set var="anexo" value="${'sinAnexo'}"/>
            </g:else>

            <g:if test="${tramite?.tipoDocumento?.codigo == 'SUM'}">
                <g:set var="clase" value="${'sumilla' + ' ' + anexo}"/>
            </g:if>
            <g:else>
                <g:set var="clase" value="${'sinSumilla' + ' ' + anexo}"/>
            </g:else>

            <g:if test="${tramite.padre}">
                <g:set var="clase" value="${clase + ' conPadre'}"/>
                <g:set var="padre" value="${tramite.padreId}"/>
            </g:if>

            <tr id="${tramite?.id}" data-id="${tramite?.id}"
                class="${esImprimir ? 'imprimir' : ''}
                ${(limite) ? ((limite < new Date()) ? 'alerta' + ' ' + clase : tramite.estadoTramite.codigo) : tramite.estadoTramite.codigo + ' ' + clase}
                ${tramite.fechaEnvio /*&& tramite.noRecibido*/ ? 'desenviar' + ' ' + clase : ''}  ${tramite.estadoTramiteExterno ? 'estado' : ''} ${tramite?.tipoDocumento?.codigo} ${tramite.externo == '1' ? ((tramite.tipoDocumento.codigo == 'DEX') ? 'DEX' : 'externo') : ''}  "
                estado="${tramite.estadoTramite.codigo}" de="${tramite.de.id}" codigo="${tramite.codigo}"
                departamento="${tramite.de?.departamento?.codigo}" anio="${tramite.fechaCreacion.format('yyyy')}" padre="${padre}">
                <td>
                    <g:if test="${tramite?.tipoTramite?.codigo == 'C'}">
                        <i class="fa fa-eye-slash"></i>
                    </g:if>
                    <g:if test="${tramite?.anexo == 1 && DocumentoTramite.countByTramite(tramite) > 0}">
                        <i class="fa fa-paperclip"></i>
                    </g:if>
                    ${tramite?.codigo}
                </td>
                <td title="${tramite.de.departamento}">${(tramite.deDepartamento) ? tramite.deDepartamento.codigo : tramite.de}</td>
                <td style="width: 115px;">${tramite.fechaCreacion?.format("dd-MM-yyyy HH:mm")}</td>
                <td>
                    <g:if test="${tramite.tipoDocumento.codigo == 'OFI'}">
                        EXT
                    </g:if>
                    <g:else>
                        <g:if test="${para?.departamento}">
                            ${para?.departamento?.codigo}
                        </g:if>
                        <g:else>
                            ${para?.persona?.departamento?.codigo}
                        </g:else>
                    </g:else>
                </td>
                <g:set var="infoExtra" value=""/>

                <g:each in="${[para] + copias}" var="pdt">
                    <g:if test="${pdt}">
                        <g:if test="${infoExtra != ''}">
                            <g:set var="infoExtra" value="${infoExtra + '<br/>'}"/>
                        </g:if>
                        <g:set var="infoExtra" value="${infoExtra + pdt.rolPersonaTramite?.descripcion}: "/>
                        <g:if test="${pdt.departamento}">
                            <g:set var="infoExtra" value="${infoExtra + pdt.departamento?.codigo}"/>
                        </g:if>
                        <g:else>
                            <g:set var="infoExtra" value="${infoExtra + pdt.persona?.login}"/>
                        </g:else>
                        <g:if test="${pdt.fechaEnvio}">
                            <g:if test="${pdt.fechaRecepcion}">
                                <g:set var="infoExtra" value="${infoExtra + ' (recibido el ' + pdt.fechaRecepcion.format('dd-MM-yyyy HH:mm') + ')'}"/>
                            </g:if>
                            <g:else>
                                <g:set var="infoExtra" value="${infoExtra + ' (no recibido)'}"/>
                            </g:else>
                        </g:if>
                    </g:if>
                </g:each>
                <td title="${infoExtra}">
                    <g:set var="dest" value="${0}"/>
                    <g:if test="${tramite.tipoDocumento.codigo == 'OFI'}">
                        ${tramite.paraExterno}
                        <g:set var="dest" value="${tramite.paraExterno ? 1 : 0}"/>
                    </g:if>
                    <g:else>
                        <g:if test="${para}">
                            <g:if test="${para.persona}">
                                ${para?.persona}
                                <g:set var="dest" value="${1}"/>
                            </g:if>
                            <g:else>
                                <g:if test="${para?.departamento?.triangulos}">
                                    <span class="small">
                                        <g:each in="${para?.departamento?.triangulos}" var="t" status="i">
                                            <g:set var="dest" value="${dest + 1}"/>
                                            <i class="fa fa-download"></i>
                                            ${t.nombre} ${t.apellido}${i < para?.departamento?.triangulos.size() - 1 ? ', ' : ''}
                                        </g:each>
                                    </span>
                                </g:if>
                            </g:else>
                        </g:if>
                        <span class="small">
                            <g:each in="${copias}" var="copia" status="i">
                                <g:set var="dest" value="${dest + 1}"/>
                                [CC] ${copia.persona ? copia.persona.login : copia.departamento?.codigo}
                                <g:if test="${i < copias.size() - 1}">
                                    ,
                                </g:if>
                            </g:each>
                        </span>
                    </g:else>
                    <g:if test="${dest == 0}">
                        <span class="label label-danger" style="margin-top: 3px;">
                            <i class="fa fa-warning"></i> Sin destinatario ni copias
                        </span>
                    </g:if>
                </td>
                <td>${tramite?.prioridad.descripcion}</td>
                <td>${tramite.fechaEnvio?.format("dd-MM-yyyy HH:mm")}</td>
                <td>${limite ? limite.format("dd-MM-yyyy HH:mm") : ''}</td>
                <td>
                    ${tramite?.estadoTramite.descripcion}
                    <g:if test="${tramite.nota && tramite.nota != ''}">
                        <span class="badge pull-right">
                            <g:link controller="tramite" action="redactar" id="${tramite.id}" title="Con notas de revisión">
                                <i class="fa fa-pencil text-white"></i>
                            </g:link>
                        </span>
                    </g:if>
                </td>
                <td id="${tramite?.id}" class="ck text-center">
                    <g:if test="${tramite.estadoTramite.codigo == 'E001'}">
                        <g:checkBox name="porEnviar" tramite="${tramite?.id}" style="margin-left: 20px" class="form-control combo" checked="false"/>
                    </g:if>
                </td>
            </tr>
        </g:each>
    </tbody>
</table>

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
    });
</script>
