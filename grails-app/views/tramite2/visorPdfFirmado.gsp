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
    <div class="col-md-4"></div>
    <div class="col-md-3 row btn-group" style="margin-bottom: 10px">
        <a href="#" class="btn btn-success" id="btnAceptar"><i class="fa fa-check"></i> Aceptar el PDF firmado </a></div>
    <div class="col-md-3 row btn-group" style="margin-bottom: 10px">
        <a href="#" class="btn btn-danger" id="btnBorrar"><i class="fa fa-trash"></i> Borrar el PDF firmado </a>
    </div>
</div>

%{--<div style="text-align: center">--}%
%{--    <canvas id="cnv2"></canvas>--}%
%{--</div>--}%

<div style="text-align: center">
    <embed src="${createLink(controller: 'tramite2', action: 'downloadFileFirmado', id: id)}" style="width: 100%; height: 800px" type='application/pdf' id="divPDF" >
</div>





<script type="text/javascript">

    %{--$("#btnRegresar").click(function () {--}%
    %{--    location.href="${createLink(controller: 'tramite2', action: 'bandejaSalida')}"--}%
    %{--});--}%

    %{--function PDFStart (nameroute) {--}%

    %{--    var loadingTask = pdfjsLib.getDocument(nameroute),--}%
    %{--        pdfDoc = null,--}%
    %{--        canvas = document.querySelector('#cnv2'),--}%
    %{--        ctx = canvas.getContext('2d'),--}%
    %{--        scale = 1.5,--}%
    %{--        numPage = 1,--}%
    %{--        paginaActual = 1;--}%
    %{--    loadingTask.promise.then(function (pdfDoc_) {--}%
    %{--        pdfDoc = pdfDoc_;--}%
    %{--        document.querySelector('#npages').innerHTML = pdfDoc.numPages;--}%
    %{--        GeneratePDF(numPage);--}%
    %{--    });--}%

    %{--    function GeneratePDF(numPage) {--}%
    %{--        pdfDoc.getPage(numPage).then( function (page) {--}%
    %{--            var viewport = page.getViewport({ scale: scale });--}%
    %{--            canvas.height = viewport.height;--}%
    %{--            canvas.width = viewport.width;--}%
    %{--            var renderContext = {--}%
    %{--                canvasContext : ctx,--}%
    %{--                viewport:  viewport--}%
    %{--            };--}%

    %{--            page.render(renderContext);--}%
    %{--        });--}%

    %{--        paginaActual = numPage;--}%

    %{--        document.querySelector('#npages').innerHTML = numPage;--}%
    %{--    }--}%

    %{--    document.querySelector('#prev').addEventListener('click', PrevPage);--}%
    %{--    document.querySelector('#next').addEventListener('click', NextPage);--}%

    %{--    function PrevPage () {--}%
    %{--        if(numPage === 1){--}%
    %{--            return--}%
    %{--        }--}%
    %{--        numPage--;--}%
    %{--        GeneratePDF(numPage);--}%
    %{--    }--}%

    %{--    function NextPage () {--}%
    %{--        if(numPage >= pdfDoc.numPages){--}%
    %{--            return--}%
    %{--        }--}%
    %{--        numPage++;--}%
    %{--        GeneratePDF(numPage);--}%
    %{--    }--}%

    %{--}--}%

    %{--function  startPdfFirmado() {--}%
    %{--    PDFStart(src="${createLink(controller: 'tramite2', action: 'downloadFile', id: id)}");--}%
    %{--}--}%

    %{--window.addEventListener('load', startPdfFirmado);--}%


</script>
</body>
</html>