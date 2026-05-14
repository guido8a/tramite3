<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    %{--    <meta name="viewport" content="width=device-width, initial-scale=1.0">--}%
    <meta name="layout" content="main">
    <title>Document</title>
    <style>canvas{border: 1px solid #000}
    </style>
</head>
<body>
<button id="prev">Prev</button>
<button id="next">Next</button>
<span id="npages">not yet</span>
<div><canvas id="cnv"></canvas></div>

<asset:javascript src="/apli/pdf.min.js"/>

<script type="text/javascript">

    var PDFStart = function (nameroute) {

        var loadingTask = pdfjsLib.getDocument(nameroute),
            pdfDoc = null,
            canvas = document.querySelector('#cnv'),
            ctx = canvas.getContext('2d'),
            scale = 1.5,
            numPage = 1;

        loadingTask.promise.then(function (pdfDoc_) {
            pdfDoc = pdfDoc_;
            document.querySelector('#npages').innerHTML = pdfDoc.numPages;
            GeneratePDF(numPage);
        });

        var GeneratePDF = function (numPage) {
            pdfDoc.getPage(numPage).then( function (page) {
                var viewport = page.getViewport({ scale: scale });
                canvas.height = viewport.height;
                canvas.width = viewport.width;
                var renderContext = {
                    canvasContext : ctx,viewport:  viewport};



                // var canvas = document.getElementById('cnv');

                canvas.addEventListener('click', function(event) {
                    // 1. Obtener la posición del clic relativa a la pantalla del navegador
                    var rect = canvas.getBoundingClientRect();
                    var mouseX = event.clientX - rect.left;
                    var mouseY = event.clientY - rect.top;

                    console.log("coordenadas " + mouseX + " " + mouseY);

                    var a = viewport.convertToPdfPoint(mouseX, mouseY);

                    console.log("coord pdf " + a)

                    %{--// 2. Traducir a espacio de coordenadas internas del PDF--}%
                    %{--// Necesitas el objeto 'page' devuelto por PDF.js (ej. pdfDoc.getPage(1))--}%
                    %{--var viewport = page.getViewport({ scale: 1.0 });--}%

                    %{--// Convertir de pixeles de pantalla a puntos de coordenadas nativas del PDF--}%
                    %{--const [pdfX, pdfY] = viewport.convertToPdfPoint(mouseX, mouseY);--}%

                    %{--console.log(`Coordenadas oficiales del PDF: X=${pdfX.toFixed(2)}, Y=${pdfY.toFixed(2)}`);--}%
                });




                page.render(renderContext);});



            document.querySelector('#npages').innerHTML = numPage;}
    };


    var startPdf = function () {
        PDFStart(src="${resource(dir: '/assets/images', file: '1779311.pdf', absolute: true)}");
    };

    window.addEventListener('load', startPdf);


    %{--// Suponiendo que tienes una referencia al canvas y a la página del PDF--}%
    %{--var canvas = document.getElementById('cnv');--}%

    %{--canvas.addEventListener('click', function(event) {--}%
    %{--    // 1. Obtener la posición del clic relativa a la pantalla del navegador--}%
    %{--    var rect = canvas.getBoundingClientRect();--}%
    %{--    var mouseX = event.clientX - rect.left;--}%
    %{--    var mouseY = event.clientY - rect.top;--}%

    %{--    console.log("c " + mouseX + " " + mouseY);--}%

    %{--    --}%%{--// 2. Traducir a espacio de coordenadas internas del PDF--}%
    %{--    --}%%{--// Necesitas el objeto 'page' devuelto por PDF.js (ej. pdfDoc.getPage(1))--}%
    %{--    --}%%{--var viewport = page.getViewport({ scale: 1.0 });--}%

    %{--    --}%%{--// Convertir de pixeles de pantalla a puntos de coordenadas nativas del PDF--}%
    %{--    --}%%{--const [pdfX, pdfY] = viewport.convertToPdfPoint(mouseX, mouseY);--}%

    %{--    --}%%{--console.log(`Coordenadas oficiales del PDF: X=${pdfX.toFixed(2)}, Y=${pdfY.toFixed(2)}`);--}%
    %{--});--}%





</script>
%{--<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.4.456/pdf.min.js"></script>--}%

%{--<script src="./app.js">--}%

%{--</script>--}%
</body>
</html>