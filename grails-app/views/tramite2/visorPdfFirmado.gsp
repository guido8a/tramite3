%{--<div style="text-align: center">--}%
%{--    <embed src="${createLink(controller: 'tramite2', action: 'downloadFileFirmado', id: id)}" style="width: 100%; height: 800px" type='application/pdf' id="divPDF" >--}%
%{--</div>--}%

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="layout" content="main">
    <title>PDF Firmado</title>
    <style>

    canvas{border: 1px solid #000}

    </style>
</head>
<body>


<div class="col-md-12">
    <div class="col-md-1"></div>
    <div class="col-md-2 row btn-group" style="margin-bottom: 10px">
        <a href="#" class="btn btn-success" id="btnAceptar"><i class="fa fa-check"></i> Aceptar el PDF firmado </a></div>
    <div class="col-md-2 row btn-group" style="margin-bottom: 10px">
        <a href="#" class="btn btn-danger" id="btnBorrarFirma"><i class="fa fa-times"></i> Firma incorrecta </a>
    </div>
    <div class="col-md-1"></div>
    <div class="col-md-3 row btn-group" style="margin-bottom: 10px;">
        <button class="btn btn-info" id="prev"> <i class="fa fa-arrow-left"></i> Anterior</button>
        <button class="btn btn-info" id="next"> Siguiente <i class="fa fa-arrow-right"></i></button>
    </div>

    <div class="col-md-3" style="margin-top: 15px;">
        <span style="font-size: 12px; font-weight: bold">Página número: </span>
        <span  style="font-size: 16px; font-weight: bold" class="breadcrumb" id="npages">0</span>
        / <span  style="font-size: 16px; font-weight: bold" class="breadcrumb" id="totalPages">0</span>
    </div>
</div>

<div style="text-align: center">
    <canvas id="cnv"></canvas>
</div>

<asset:javascript src="/apli/pdf.mjs"/>
<asset:javascript src="/apli/pdf.worker.min.js"/>

<script type="text/javascript">

    $("#btnAceptar").click(function () {
        documentoFirmadoCorrectamente();
    });

    $("#btnBorrarFirma").click(function () {
        documentoFirmadoIncorrectamente();
    });

    var targetElement = document.getElementById("cnv");

    function PDFStart (nameroute) {

        var loadingTask = pdfjsLib.getDocument(nameroute),
            pdfDoc = null,
            canvas = document.querySelector('#cnv'),
            ctx = canvas.getContext('2d'),
            scale = 1.5,
            numPage = 1,
            paginaActual = 1;
        loadingTask.promise.then(function (pdfDoc_) {
            pdfDoc = pdfDoc_;
            document.querySelector('#npages').innerHTML = pdfDoc.numPages;
            document.querySelector('#totalPages').innerHTML = pdfDoc.numPages;
            GeneratePDF(numPage);
            // clicPDF(numPage);
        });

        function GeneratePDF(numPage) {
            pdfDoc.getPage(numPage).then( function (page) {
                var viewport = page.getViewport({ scale: scale });
                canvas.height = viewport.height;
                canvas.width = viewport.width;
                var renderContext = {
                    canvasContext : ctx,
                    viewport:  viewport
                };

                page.render(renderContext);
            });

            paginaActual = numPage;

            document.querySelector('#npages').innerHTML = numPage;
        }

        document.querySelector('#prev').addEventListener('click', PrevPage);
        document.querySelector('#next').addEventListener('click', NextPage);

        function PrevPage () {
            if(numPage === 1){
                return
            }
            numPage--;
            GeneratePDF(numPage);
        }

        function NextPage () {
            if(numPage >= pdfDoc.numPages){
                return
            }
            numPage++;
            GeneratePDF(numPage);
        }

    }

    function  startPdf() {
        <g:if test="${tramite?.firmados != 1}">
        PDFStart(src="${createLink(controller: 'tramite2', action: 'downloadFileFirmado', id: id)}");
        </g:if>
        <g:else>
        PDFStart(src="${createLink(controller: 'tramite2', action: 'downloadFile', id: id)}");
        </g:else>
    }

    window.addEventListener('load', startPdf);

    function documentoFirmadoCorrectamente() {
        bootbox.dialog({
            title: "<i class='fa fa-exclamation-triangle fa-2x pull-left text-info text-shadow'></i> Alerta",
            message: "<p style='font-weight: bold; font-size: 14px'> Está seguro que la firma electrónica está correcta en el documento?  </br> La firma <strong> NO </strong> podrá ser modificada posteriormente.</p>",
            buttons: {
                cancelar: {
                    label: "Cancelar",
                    className: "btn-primary",
                    callback: function () {
                    }
                },
                aceptar: {
                    label: "<i class='fa fa-check'></i> Aceptar",
                    className: "btn-success",
                    callback: function () {
                        var v = cargarLoader("Cargando...");
                        location.href="${createLink(controller: 'tramite2', action: 'bandejaSalida')}"
                    }
                }
            }
        });
    }

    function documentoFirmadoIncorrectamente() {
        bootbox.dialog({
            title: "<i class='fa fa-exclamation-triangle fa-2x pull-left text-info text-shadow'></i> Alerta",
            message: "<p style='font-weight: bold; font-size: 14px'> Está seguro que la firma electrónica NO está correcta en el documento?  </br> Volverá a la pantalla de firma electrónica.</p>",
            buttons: {
                cancelar: {
                    label: "Cancelar",
                    className: "btn-primary",
                    callback: function () {
                    }
                },
                aceptar: {
                    label: "<i class='fa fa-check'></i> Aceptar",
                    className: "btn-success",
                    callback: function () {
                        var v = cargarLoader("Cargando...");
                        $.ajax({
                            type    : "POST",
                            url     : "${g.createLink(controller: 'tramite2',action: 'quitarFirma_ajax')}",
                            data    : {
                                id : '${id}'
                            },
                            success : function (msg) {
                                v.modal("hide");
                                var parts = msg.split("_");
                                if(parts[0] ==="ok"){
                                    if(parts[1] === '1'){
                                        location.href="${createLink(controller: 'tramite2', action: 'visorPdf')}?id=" + '${id}' + "&persona=" + '${persona?.id}'
                                    }else{
                                        location.href="${createLink(controller: 'tramite2', action: 'firmarPdf')}?id=" + '${id}' + "&persona=" + '${persona?.id}'
                                    }
                                }else{
                                    bootbox.alert("<strong style='font-size: 16px'> <i class='fa fa-exclamation-triangle text-danger' style='font-size: 20px'></i>" + "Error al borrar el pdf firmado"  + "</strong>")
                                }
                            }
                        });
                    }
                }
            }
        });
    }

</script>
</body>
</html>