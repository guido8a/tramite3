<%@ page import="tramites.Tramite" %>
<style type="text/css">
table {
    font-size : 9pt;
}
</style>


<div style="height: 450px" class="container-celdas">
    <span class="grupo">
        <table class="table table-bordered table-condensed table-hover">
            <thead>
            <tr>
                <th class="cabecera" style="width: 100px">Documento</th>
                <th class="cabecera" style="width: 190px">De</th>
                <th class="cabecera" style="width: 200px">Para</th>
                <th class="cabecera" style="width: 200px">Asunto</th>
                <th class="cabecera" style="width: 115px">Fecha Envio</th>
                <th class="cabecera" style="width: 110px">Doc. Padre</th>
                <th class="cabecera" style="width: 86px">Estado</th>
            </tr>
            </thead>
        </table>
        <div style="width: 99.7%;height: 350px; overflow-y: auto; margin-top: -20px">
            <table class="table-bordered table-condensed table-hover" width="100%">

                <tbody>
                <g:each in="${tramites}" var="tramite">
                    <tr id="${tramite?.tramite?.id}" data-id="${tramite?.tramite?.id}">
                        <td style="width: 100px">
                            <g:if test="${tramite?.tramite?.tipoTramite?.codigo == 'C'}">
                                <i class="fa fa-eye-slash"></i>
                            </g:if>
                            <g:if test="${tramite?.tramite?.anexo == 1 && DocumentoTramite?.countByTramite(tramite.tramite) > 0}">
                                <i class="fa fa-paperclip"></i>
                            </g:if>
                            ${tramite?.tramite?.codigo}
                        </td>
                        <td style="width: 190px">
                            <g:if test="${tramite?.tramite?.deDepartamento}">
                                ${tramite?.tramite?.deDepartamento?.descripcion}
                            </g:if>
                            <g:else>
                                ${tramite?.tramite?.de?.nombre + " " + tramite?.tramite?.de?.apellido}
                            </g:else>
                        </td>
                        <td style="width: 200px">
                            <g:if test="${tramite?.departamento}">
                                ${tramite?.departamento?.descripcion + ' [' + tramite?.rolPersonaTramite?.descripcion + '] '}
                            </g:if>
                            <g:else>
                                ${tramite?.persona?.nombre + " " + tramite?.persona?.apellido + ' [' + tramite?.rolPersonaTramite?.descripcion + ' ] '}
                            </g:else>
                        </td>
                        <td style="width: 205px">${tramite?.tramite?.asunto}</td>
                        <td style="width: 115px">${tramite?.fechaEnvio?.format('dd-MM-yyyy HH:mm')}</td>
                        <td style="width: 110px">
                            <g:if test="${tramite?.rolPersonaTramite?.codigo == 'R002'}">
                                <g:if test="${tramite?.tramite?.tramitePrincipal}">
                                    ${tramites.Tramite.get(tramite?.tramite?.tramitePrincipal).codigo}
                                </g:if>
                            </g:if>
                            <g:else>
                                <g:if test="${tramite?.tramite?.padre}">
                                    ${tramite?.tramite?.padre?.codigo}
                                </g:if>
                                <g:else>
                                    Trámite Padre
                                </g:else>
                            </g:else>
                        </td>
                        <td style="width: 67px">${tramite?.estado?.descripcion}</td>
                    </tr>
                </g:each>
                </tbody>
            </table>
        </div>
    </span>
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
    });
</script>
