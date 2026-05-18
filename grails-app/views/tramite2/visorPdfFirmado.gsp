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
    <div class="col-md-2 row btn-group" style="margin-bottom: 10px">
        <a href="#" class="btn btn-primary" id="btnRegresar"><i class="fa fa-arrow-left"></i> Regresar </a>
    </div>
    <div class="col-md-3"></div>
    <div class="col-md-4 row btn-group" style="margin-bottom: 10px">
        <button class="btn btn-info" id="prev"> <i class="fa fa-arrow-left"></i> Anterior</button>
        <button class="btn btn-info" id="next"> Siguiente <i class="fa fa-arrow-right"></i></button>

    </div>
    <div class="col-md-2" style="margin-top: 15px">
        <span style="font-size: 12px; font-weight: bold">Página número: </span>
        <span  style="font-size: 16px; font-weight: bold" class="breadcrumb" id="npages">nada cargado</span>
    </div>
</div>

<div style="text-align: center">
    <canvas id="cnv2"></canvas>
</div>

<asset:javascript src="/apli/pdf.min.js"/>

<script type="text/javascript">


    $("#btnRegresar").click(function () {
        location.href="${createLink(controller: 'tramite2', action: 'bandejaSalida')}"
    });

    function PDFStart (nameroute) {

        var loadingTask = pdfjsLib.getDocument(nameroute),
            pdfDoc = null,
            canvas = document.querySelector('#cnv2'),
            ctx = canvas.getContext('2d'),
            scale = 1.5,
            numPage = 1,
            paginaActual = 1;
        loadingTask.promise.then(function (pdfDoc_) {
            pdfDoc = pdfDoc_;
            document.querySelector('#npages').innerHTML = pdfDoc.numPages;
            GeneratePDF(numPage);
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
        PDFStart(src="${createLink(controller: 'tramite2', action: 'downloadFile', id: id)}");
    }

    window.addEventListener('load', startPdf);

</script>
</body>
</html>