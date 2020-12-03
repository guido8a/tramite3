
<g:set var="now" value="${new Date()}"/>
<g:if test="${rows.size() == 0}">
    <tr>
        <td colspan="9" class="info text-center">
            <h4 class="text-info">
                <i class="fa icon-ghost fa-2x text-shadow"></i>
                No se encontraron
                <g:if test="${busca}">
                    resultados para su búsqueda
                </g:if>
                <g:else>
                    trámites en su bandeja de entrada
                </g:else>
            </h4>
        </td>
    </tr>
</g:if>
<g:else>
    <g:each in="${rows}" var="row">
        <g:set var="clase" value=""/>

        <g:if test="${row.trmtfcrc}">%{-- fecha de recepcion --}%
            <g:if test="${row.trmtfclr < now}">%{-- fecha limite respuesta --}%
                <g:set var="clase" value="retrasado"/>
            </g:if>
            <g:else>
                <g:set var="clase" value="recibido"/>
            </g:else>
        </g:if>
        <g:else>
            <g:if test="${row.trmtfcbq && row.trmtfcbq < now}">%{-- fecha bloqueo --}%
                <g:set var="clase" value="sinRecepcion"/>
            </g:if>
            <g:else>
                <g:set var="clase" value="blanco porRecibir"/>
            </g:else>
        </g:else>

        <g:if test="${row.trmtanxo == 1 && row.trmtdctr > 0}">%{-- anexo y DocumentoTramite.count --}%
            <g:set var="clase" value="${clase + ' conAnexo'}"/>
        </g:if>
        <g:else>
            <g:set var="clase" value="${clase + ' sinAnexo'}"/>
        </g:else>

        <g:set var="clase" value="${clase + ' ' + row.rltrcdgo}"/>%{-- rol codigo --}%

        <g:if test="${row.edtxcdgo}">%{-- estado tramite externo --}%
            <g:set var="clase" value="${clase + ' estadoExterno'}"/>
        </g:if>

        <g:set var="de" value=""/>
        <g:if test="${row.tpdccdgo == 'DEX'}">%{-- tipo doc codigo --}%
            <g:set var="de" value="E_${row.trmt__id}"/> %{-- tramite id --}%
            <g:set var="clase" value="${clase + ' dex'}"/>
        </g:if>
        <g:else>
            <g:if test="${row.dedp__id}">%{-- de departamento id --}%
                <g:set var="de" value="D_${row.dedp__id}"/>
            </g:if>
            <g:else>
                <g:set var="de" value="P_${row.depr__id}"/>%{-- de persona id --}%
            </g:else>
        </g:else>

        <g:if test="${row.trmthijo == 1}">
            <g:set var="clase" value="${clase + ' tieneHijos'}"/>
        </g:if>

        <g:set var="paraLbl"/>
        <g:set var="paraTitle"/>
        <g:if test="${row.prtrprsn}">%{--para persona--}%
            <g:set var="paraLbl" value="${row.prtrprsn}"/>
            <g:set var="paraTitle" value="${row.prtrprsn} (${row.prtrdpto})"/>
        </g:if>
        <g:else>
            <g:set var="paraLbl" value="${row.prtrdpto}"/>%{-- para dpto cdgo--}%
            <g:set var="paraTitle" value="${row.prtrdpds}"/> %{--para dpto descripcion--}%
        </g:else>
        <tr data-id="${row.trmt__id}"
            class="doc ${clase}" de="${de}"
            codigo="${row.trmtcdgo}" departamento="${row.deprdpto}" %{-- tramite cdgo y de.dpto.cdgo--}%
            prtr="${row.prtr__id}" style="width: 100%">%{-- id pers doc tram--}%

            <td class="codigo" title="${row.trmtasnt}" style="width: 13%; font-weight: bold">%{-- asunto--}%
                <g:if test="${row.tptrcdgo == 'C'}">%{-- tipo tramite cdgo --}%
                    <i class="fa fa-eye-slash" style="margin-left: 10px"></i>
                </g:if>
                <g:if test="${row.trmtdctr > 0}">%{-- DocumentoTramite.count --}%
                    <i class="fa fa-paperclip"></i>
                </g:if>
                ${row.trmtcdgo}%{-- tramite cdgo --}%
            <a href="#" name="informacion" class="btn btn-info btn-xs btnInfo" data-asn="${row.trmtasnt}" data-cd="${row.trmtcdgo}" style="float: right"><i class="fa fa-exclamation"></i></a>
            </td>
            <td style="width: 11%" class="envio" style="width: 115px;">${row.trmtfcen?.format('dd-MM-yyyy HH:mm')}</td>%{-- fecha envio --}%
            <td style="width: 11%" class="recepcion" style="width: 115px;">${row.trmtfcrc?.format('dd-MM-yyyy HH:mm')}</td>%{-- fecha recepcion --}%
            <td style="width: 9%" class="dpto" title="${row.deprdpds}">${row.deprdpto}</td>%{-- de.dpto descripcion y cdgo --}%
            <td style="width: 11%" class="de" title="${row.deprdscr}">${row.deprlogn ?: row.deprdscr}</td>%{-- de nombres y login--}%
            <td style="width: 11%" class="para" title="${paraTitle}">${paraLbl}</td>
            <td style="width: 11%" class="prioridad">${row.trmttppd}</td>%{-- prioridad --}%
            <td style="width: 11%" class="limiteRes">${row.trmtfclr?.format('dd-MM-yyyy HH:mm')}</td>%{-- fecha limite respuesta --}%
            <td style="width: 10%"  class="rol">${row.rltrdscr}</td>%{-- rol --}%
        </tr>
    </g:each>
    <script type="text/javascript">

        $(".btnInfo").click(function () {
            var asunto = $(this).data("asn");
            var tramite = $(this).data("cd");
            bootbox.alert('<strong>' + tramite + '</strong>' + '<br>' + '<strong>' + 'ASUNTO: ' + '</strong>' + asunto)
        });

        $(function () {
            $("tr.doc").contextMenu({
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
</g:else>