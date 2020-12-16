
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <meta name="layout" content="main">
        <title>Reportes personales</title>

        <style type="text/css">
        .info {
            font-weight : bold;
            font-size   : larger;
        }

        .alert-info {
            font-size : larger;
        }
        </style>
    </head>

    <body>
        <div class="panel-group" id="accordion">
            <div class="panel panel-default">
                <g:set var="reporte" value="retrasados"/>
                <div class="panel-heading">
                    <h4 class="panel-title">
                        <a data-toggle="collapse" data-parent="#accordion" href="#collapse_${reporte}">
                            Trámites retrasados y sin recepción
                        </a>
                    </h4>
                </div>

                <div id="collapse_${reporte}" class="panel-collapse collapse in">
                    <div class="panel-body">
                        <form class="form-horizontal">
                            <div class="alert alert-info">
                                Se generará un reporte
                                de sus <span class="info">trámites retrasados y sin recepción</span>.
                            </div>

                            <div class="btn-group">
                                <g:link class="btn btn-info" controller="retrasados" action="reporteRetrasadosConsolidado" params="[prsn: persona.id]">
                                    <i class="fa fa-file-pdf"></i> PDF resumen
                                </g:link>
                                <g:link class="btn btn-info" controller="retrasados" action="reporteRetrasadosDetalle" params="[id: persona.id, detalle: 1]">
                                    <i class="fa fa-file-pdf"></i> PDF detallado
                                </g:link>
                            </div>

                            <div class="btn-group">
                                <g:link class="btn btn-success" controller="retrasadosExcel" action="reporteRetrasadosConsolidado" params="[prsn: persona.id]">
                                    <i class="fa fa-file-excel"></i> Excel resumen
                                </g:link>
                                <g:link class="btn btn-success" controller="retrasadosExcel" action="reporteRetrasadosDetalle" params="[id: persona.id, detalle: 1]">
                                    <i class="fa fa-file-excel"></i> Excel detallado
                                </g:link>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="panel panel-default">
                <g:set var="reporte" value="generados"/>
                <div class="panel-heading">
                    <h4 class="panel-title">
                        <a data-toggle="collapse" data-parent="#accordion" href="#collapse_${reporte}">
                            Documentos generados y recibidos
                        </a>
                    </h4>
                </div>

                <div id="collapse_${reporte}" class="panel-collapse collapse">
                    <div class="panel-body">
                        <form class="form-horizontal">
                            <div class="alert alert-info">
                                Se generará un reporte
                                de sus <span class="info">documentos generados y recibidos</span>
                            </div>

                            <div class="row">
                                <div class="col-md-1">
                                    <p class="form-control-static">Desde</p>
                                </div>

                                <div class="col-md-2">
%{--                                    <elm:datepicker name="desde_${reporte}" class="form-control date" value="${new Date() - 15}" maxDate="+0"--}%
%{--                                                    extra="data-tipo='desde' data-reporte='${reporte}'" onChangeDate="updateFecha"/>--}%
                                    <input name="desde_${reporte}" id='datetimepicker1' type='text' class="form-control"/>
                                </div>

                                <div class="col-md-1">
                                    <p class="form-control-static">Hasta</p>
                                </div>

                                <div class="col-md-2">
%{--                                    <elm:datepicker name="hasta_${reporte}" class="form-control date" value="${new Date()}" maxDate="+0"--}%
%{--                                                    extra="data-tipo='hasta' data-reporte='${reporte}'" onChangeDate="updateFecha"/>--}%
                                    <input name="hasta_${reporte}" id='datetimepicker2' type='text' class="form-control"/>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="btn-group">
                                        <g:link class="btn btn-info generar" controller="documentosGenerados" action="reporteGeneralPdf" params="[id: persona.id]">
                                            <i class="fa fa-file-pdf"></i> PDF resumen
                                        </g:link>
                                        <g:link class="btn btn-info generar" controller="documentosGenerados" action="reporteDetalladoPdf" params="[id: persona.id]">
                                            <i class="fa fa-file-pdf"></i> PDF detallado
                                        </g:link>
                                    </div>

                                    <div class="btn-group">
                                        <g:link class="btn btn-success generar" controller="documentosGenerados" action="reporteGeneralXlsx" params="[id: persona.id]">
                                            <i class="fa fa-file-excel"></i> Excel resumen
                                        </g:link>
                                        <g:link class="btn btn-success generar" controller="documentosGenerados" action="reporteDetalladoXlsx" params="[id: persona.id]">
                                            <i class="fa fa-file-excel"></i> Excel detallado
                                        </g:link>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script type="application/javascript">

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


            function updateFecha($elm, e) {
                var tipo = $elm.data("tipo");
                var valor = $elm.val();
                var reporte = $elm.data("reporte");
                $("#" + reporte + "_" + tipo).text(valor);
                if($elm.attr("id") == "datetimepicker1"){
                    var fecha = e.date;
                    var $hasta = $("#datetimepicker2");
                    if ($hasta.datepicker('getDate') < fecha) {
                        $hasta.datepicker('setDate', fecha);
                    }
                    $hasta.datepicker('setStartDate', fecha);
                }
            }

            $(function () {
                $(".date").each(function () {
                    var tipo = $(this).data("tipo");
                    var valor = $(this).val();
                    var reporte = $(this).data("reporte");
                    $("#" + reporte + "_" + tipo).text(valor);
               });

                $(".generar").click(function () {
                    var params = "?desde=" + $("#datetimepicker1").val() + "&hasta=" + $("#datetimepicker2").val() + "&tipo=prsn";
                    var url = $(this).attr("href");
                    location.href = url + params;
                    return false;
                });
            });
        </script>

    </body>
</html>