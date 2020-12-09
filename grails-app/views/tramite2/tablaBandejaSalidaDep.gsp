
<g:set var="now" value="${new Date()}"/>
<g:if test="${rows.size() == 0}">
    <tr>
        <td colspan="10" class="info text-center">
            <h4 class="text-info">
                <i class="fa icon-ghost fa-2x text-shadow"></i>
                No se encontraron
                <g:if test="${busca}">
                    resultados para su búsqueda
                </g:if>
                <g:else>
                    trámites en su bandeja de salida
                </g:else>
            </h4>
        </td>
    </tr>
</g:if>
<g:else>
%{--${rows}--}%
    <g:each in="${rows}" var="row">
        <g:set var="clase" value="${row.tpdccdgo}"/> %{--tipo documento codigo--}%
        <g:if test="${row.trmtimpr && row.trmtimpr > 0}">%{--es imprimir o no--}%
            <g:set var="clase" value="${clase + ' imprimir'}"/>
        </g:if>

        <g:if test="${row.trmtfcbq && row.trmtfcbq < now}">%{--fecha bloqueo--}%
            <g:set var="clase" value="${clase + ' alerta'}"/>
        </g:if>
        <g:else>
            <g:set var="clase" value="${clase + ' ' + row.edtrcdgo}"/>%{--estado tramite codigo--}%
        </g:else>

        <g:if test="${row.trmtfcen}">%{--fecha de envio--}%
            <g:set var="clase" value="${clase + ' desenviar'}"/>
        </g:if>

        <g:if test="${row.edtxcdgo}">%{--estado externo--}%
            <g:set var="clase" value="${clase + ' estado'}"/>
        </g:if>

        <g:if test="${row.trmtextr?.toInteger() == 1}">%{--es externo--}%
            <g:if test="${row.tpdccdgo == 'DEX'}">%{--tipo doc. codigo--}%
                <g:set var="clase" value="${clase + ' DEX'}"/>
            </g:if>
            <g:else>
                <g:set var="clase" value="${clase + ' externo'}"/>
            </g:else>
        </g:if>

        <g:if test="${row.copiextr?.toInteger() > 0}">%{--cantidad de copias a dptos. externos--}%
            <g:set var="clase" value="${clase + ' externoCC'}"/>
        </g:if>

        <g:if test="${row.trmtanxo?.toInteger() == 1 || row.trmtdctr?.toInteger() > 0}">%{--anexo y cant. de documentos anexos--}%
            <g:set var="clase" value="${clase + ' conAnexo'}"/>
        </g:if>
        <g:else>
            <g:set var="clase" value="${clase + ' sinAnexo'}"/>
        </g:else>

        <g:if test="${row.tpdccdgo == 'SUM'}">
            <g:set var="clase" value="${clase + ' sumilla'}"/>
        </g:if>
        <g:else>
            <g:set var="clase" value="${clase + ' sinSumilla'}"/>
        </g:else>

        <g:if test="${row.trmtpdre}">
            <g:set var="clase" value="${clase + ' conPadre'}"/>
        </g:if>

        <tr style="width: 100%;" id="${row.trmt__id}" data-id="${row.trmt__id}"
            class="trTramite ${clase}"
            estado="${row.edtrcdgo}" %{--estado tramite codigo--}%
            de="${row.depr__id}" %{--id de la persona q crea el tram.--}%
            codigo="${row.trmtcdgo}" %{--codigo del tramite--}%
            ern="${row.trmtesrn}" %{--es respuesta nueva--}%
            departamento="${row.deprdpto}" %{--dpto. de la pers. q crea el tramite--}%
            anio="${row.trmtfccr.format('yyyy')}" %{--fecha de creacion--}%
            padre="${row.trmtpdre}" %{--padre--}%>
            <td title="${row.trmtasnt}" style="width: 12%;">
                <g:if test="${row.tptrcdgo == 'C'}">
                    <i class="fa fa-eye-slash" style="margin-left: 10px"></i>
                </g:if>
                <g:if test="${row.trmtdctr > 0}">
                    <i class="fa fa-paperclip"></i>
                </g:if>
                ${row.trmtcdgo}
                <a href="#" name="informacion" class="btn btn-info btn-xs btnInfo" data-asn="${row.trmtasnt}" data-cd="${row.trmtcdgo}" style="float: right"><i class="fa fa-exclamation"></i></a>
            </td>
            <td style="width: 4%;">
                ${row.deprdpto}
            </td>
            <td style="width: 10%">
                ${row.trmtfccr.format("dd-MM-yyyy HH:mm")}
            </td>
            <td style="width: 4%;">
                <g:if test="${row.tpdccdgo == 'OFI'}">
                    EXT
                </g:if>
                <g:else>
                    ${row.prtrdpto}
                </g:else>
            </td>
            <td style="width: 30%;" class="titleEspecial" title="<div style='max-height:150px; overflow-y:auto;'>${row.paratitl}</div>">%{--el title con los destinatarios y si recibieron o no--}%
                <span class="para">
                    <g:if test="${row.prtrprsn}">%{--para persona (squi guarda la persona, interna o externa)--}%
                        ${row.prtrprsn}
                    </g:if>
                    <g:else>
                        <g:set var="triangulos" value="${row.paradpto.split(',')}"/>
                        <g:each in="${triangulos}" var="t" status="i">%{--para dpto--}%
                            <i class="fa fa-download"></i>
                            ${t}${i < triangulos.size() - 1 ? ', ' : ''}
                        </g:each>
                    </g:else>
                </span>
                <span class="copias">
                    ${row.copidpto.replaceAll('cc: *', '[CC] ')}${row.copidpto && row.copidpto != "" && row.copiprsn && row.copiprsn != "" ? ', ' : ''}
                    ${row.copiprsn.replaceAll('cc: *', '[CC] ')}
                </span>

                <g:if test="${!((row.prtrprsn && row.prtrprsn != '') ||
                        (row.paradpto && row.paradpto != '') ||
                        (row.copidpto && row.copidpto != '') ||
                        (row.copiprsn && row.copiprsn != ''))}">
                    <span class="label label-danger" style="margin-top: 3px;">
                        <i class="fa fa-warning"></i> Sin destinatario ni copias
                    </span>
                </g:if>
            </td>
            <td style="width: 7%;">
                ${row.trmttppd}
            </td>
            <td style="width: 10%;">
                ${row.trmtfcen?.format('dd-MM-yyyy HH:mm')}
            </td>
            <td style="width: 10%;">
                ${row.trmtfcbq?.format('dd-MM-yyyy HH:mm')}
            </td>
            <td style="width: 8%;">
                ${row.edtrdscr}
            </td>
            <td style="width: 5%;">
                <g:if test="${row.edtrcdgo == 'E001' && !esEditor}">
                    <div class="form-check form-check-inline">
                        <input class="form-check-input combo" type="checkbox" id="porEnviar" name="porEnviar" tramite="${row.trmt__id}">
                    </div>
                </g:if>
            </td>
        </tr>
    </g:each>
</g:else>

<script type="text/javascript">

    $(".btnInfo").click(function () {
        var asunto = $(this).data("asn");
        var tramite = $(this).data("cd");
        bootbox.alert('<strong>' + tramite + '</strong>' + '<br>' + '<strong>' + 'ASUNTO: ' + '</strong>' + asunto)
    });


    $.switcher('input[type=checkbox]');

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