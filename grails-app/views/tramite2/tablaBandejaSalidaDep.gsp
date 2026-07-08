
<g:set var="now" value="${new Date()}"/>
<g:if test="${rows.size() == 0}">
    <tr>
        <td colspan="10" class="info text-center">
            <h4 class="text-info">
                <i class="fa fa-exclamation-circle fa-2x text-shadow"></i>
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
            class="trTramite ${clase}  ${firmados.contains(row.trmt__id) ? 'firmado' : ''}  ${tramites.Tramite.get(row.trmt__id)?.firmados >= 1 ? 'conFirmas' : ''}"
            estado="${row.edtrcdgo}" %{--estado tramite codigo--}%
            de="${row.depr__id}" %{--id de la persona q crea el tram.--}%
            codigo="${row.trmtcdgo}" %{--codigo del tramite--}%
            ern="${row.trmtesrn}" %{--es respuesta nueva--}%
            departamento="${row.deprdpto}" %{--dpto. de la pers. q crea el tramite--}%
            anio="${row.trmtfccr.format('yyyy')}" %{--fecha de creacion--}%
            padre="${row.trmtpdre}" %{--padre--}%>

            <td title="${row.trmtasnt}" style="width: 12%;">
                <g:if test="${row.tptrcdgo == 'C'}">
                    <i class="fa fa-eye-slash"></i>
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
            <td style="width: 28%;" class="titleEspecial" >%{--el title con los destinatarios y si recibieron o no--}%
                <table style="width: 100%">
                    <tr style="width: 100%" id="${row.trmt__id}" data-id="${row.trmt__id}"
                        class="trTramite ${clase}  ${tramites.Tramite.get(row.trmt__id)?.firmados >= 1 ? 'conFirmas' : ''}"
                        estado="${row.edtrcdgo}" %{--estado tramite codigo--}%
                        de="${row.depr__id}" %{--id de la persona q crea el tram.--}%
                        codigo="${row.trmtcdgo}" %{--codigo del tramite--}%
                        ern="${row.trmtesrn}" %{--es respuesta nueva--}%
                        departamento="${row.deprdpto}" %{--dpto. de la pers. q crea el tramite--}%
                        anio="${row.trmtfccr.format('yyyy')}" %{--fecha de creacion--}%
                        padre="${row.trmtpdre}">
                        <td style="width: 80%">
                            <span class="para">
                                <g:if test="${row.prtrprsn}">%{--para persona (squi guarda la persona, interna o externa)--}%
                                    <ul>
                                        <li>
                                            ${row.prtrprsn}
                                        </li>
                                    </ul>
                                </g:if>
                                <g:else>
                                    <g:set var="triangulos" value="${row.paradpto.split(',')}"/>
                                    <ul>
                                        <g:each in="${triangulos}" var="t" status="i">%{--para dpto--}%
                                            <li>
                                                <i class="fa fa-download"></i>
                                                ${t}${i < triangulos.size() - 1 ? ', ' : ''}
                                            </li>
                                        </g:each>
                                    </ul>
                                </g:else>
                                <g:if test="${!((row.prtrprsn && row.prtrprsn != '') ||
                                        (row.paradpto && row.paradpto != '') ||
                                        (row.copidpto && row.copidpto != '') ||
                                        (row.copiprsn && row.copiprsn != ''))}">
                                    <span class="label label-danger" style="margin-top: 3px;">
                                        <i class="fa fa-exclamation-triangle"></i> Sin destinatario ni copias
                                    </span>
                                </g:if>
                            </span>
                        </td>
                        <td style="width: 20%; text-align: right">
                            <span>
                                <g:if test="${row.copidpto && row.copidpto != "" || row.copiprsn && row.copiprsn != ""}">
                                    <a href="#" name="informacion" class="btn btn-info btn-xs btnCopias"
                                       title="Copias"
                                       data-row="${row.copidpto.replaceAll('cc: *', '[CC] ')}"
                                       data-row2="${row.copidpto && row.copidpto != "" && row.copiprsn && row.copiprsn != "" ? ', ' : ''}"
                                       data-row3="${row.copiprsn.replaceAll('cc: *', '[CC] ')}"
                                       data-row4="${row.paratitl}"
                                       style="margin-left: 2px">
                                        <i class="fa fa-info"></i>
                                    </a>
                                </g:if>
                            </span>
                        </td>
                    </tr>
                </table>
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
            <td style="width: 6%;">
                <g:if test="${row.edtrcdgo == 'E001' && !esEditor}">
                    <div class="form-check form-check-inline">
                        <input class="form-check-input combo" type="checkbox" id="porEnviar" name="porEnviar" tramite="${row.trmt__id}">
                    </div>
                </g:if>
            </td>
%{--            <g:if test="${rows.size() < 7}">--}%
                <td style="width: 1%"></td>
%{--            </g:if>--}%
        </tr>
    </g:each>
</g:else>

<script type="text/javascript">

    $(".btnInfo").click(function () {
        var asunto = $(this).data("asn");
        var tramite = $(this).data("cd");
        bootbox.alert('<strong>' + tramite + '</strong>' + '<br>' + '<strong>' + 'ASUNTO: ' + '</strong>' + asunto)
    });

    $(".btnCopias").click(function () {
        var row4 = $(this).data("row4");
        cargarTextoInformacionDepartamento(row4)
    });

    function cargarTextoInformacionDepartamento(texto){
        $.ajax({
            type    : "POST",
            url     : "${createLink(controller: 'tramite2', action:'informacionDepartamento_ajax')}",
            data    : {
                texto: texto
            },
            success : function (msg) {
                var b = bootbox.dialog({
                    id      : "dlgCreateEdit",
                    title   : "Información",
                    // class   : "modal-sm",
                    message : msg,
                    buttons : {
                        cancelar : {
                            label     : "<i class='fa fa-times'></i> Cancelar",
                            className : "btn-primary",
                            callback  : function () {
                            }
                        },
                    } //buttons
                }); //dialog
            } //success
        }); //ajax
    }

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