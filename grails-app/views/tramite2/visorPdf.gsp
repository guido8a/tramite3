<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="layout" content="main">
    <title>Firmar PDF</title>
    <style>

    canvas{border: 1px solid #000}

    .cursor {
        position: fixed;
        width: 300px;
        height: 100px;
        left: -100px;
        cursor: none;
        pointer-events: none;
    }

    </style>
</head>
<body>

<img src="${resource(dir: '/assets/images', file: 'fe2.png')}" alt="Cursor" class="cursor" />

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
    <canvas id="cnv"></canvas>
</div>

<asset:javascript src="/apli/pdf.min.js"/>

<script type="text/javascript">

    $(function () {
        $("#cnv").mousemove(function (e) {
            $(".cursor").show().css({
                "left": e.clientX,
                "top": e.clientY
            });
        }).mouseout(function () {
            $(".cursor").hide();
        });
    });

    $("#btnRegresar").click(function () {
        location.href="${createLink(controller: 'tramite2', action: 'bandejaSalida')}"
    });

    var targetElement = document.getElementById("cnv");

    targetElement.addEventListener("mouseover", function () {
        targetElement.style.cursor = "url(${resource(dir: '/assets/images', file: 'fe.png')}), pointer";
    });

    targetElement.addEventListener("mouseout", function () {
        targetElement.style.cursor = "default";
    });

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
            GeneratePDF(numPage);
            clicPDF(numPage);
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

        function clicPDF (numPage){
            var viewport;

            pdfDoc.getPage(numPage).then( function (page) {
                viewport = page.getViewport({ scale: scale });
                paginaActual = numPage
            });

            canvas.addEventListener('click', function(event) {
                var rect = canvas.getBoundingClientRect();
                var mouseX = event.clientX - rect.left;
                var mouseY = event.clientY - rect.top;
                var coordenadasPDF = viewport.convertToPdfPoint(mouseX, mouseY);
                // console.log("coordenadas " + mouseX + " " + mouseY);
                // console.log("coord. pdf " + coordenadasPDF);

                firmarPDF('${id}', paginaActual, coordenadasPDF)
            });
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
        %{--PDFStart(src="${resource(dir: '/assets/images', file: '1875928.pdf', absolute: true)}");--}%
        PDFStart(src="${createLink(controller: 'tramite2', action: 'downloadFile', id: id)}");
        %{--PDFStart(src="${createLink(controller: 'tramite2', action: 'downloadFileFirmado', id: id)}");--}%
    }

    window.addEventListener('load', startPdf);

    %{--document.addEventListener("click", function (event) {--}%
    %{--    firmarPDF('${id}')--}%
    %{--});--}%

    function firmarPDF(id, pagina, coordenadas){
        $.ajax({
            type:'POST',
            url: '${createLink(controller: 'tramite2', action: 'passwordFirma_ajax')}',
            data:{
                id: id
            },
            success: function (msg1){
                var b = bootbox.dialog({
                    id      : "dlgPassFirma",
                    title   : "Contraseña de la firma electrónica",
                    class: 'modal-sm',
                    message : msg1,
                    buttons : {
                        cancelar : {
                            label     : '<i class="fa fa-times"></i> Cancelar',
                            className : 'btn-danger',
                            callback  : function () {
                            }
                        },
                        aceptar  : {
                            label     : '<i class="fa fa-check"></i> Aceptar',
                            className : 'btn-success',
                            callback  : function () {
                                var passwordFirma = $("#password").val();
                                if(passwordFirma !== ''){
                                    var cl = cargarLoader("Firmando...");
                                    $.ajax({
                                        type: 'POST',
                                        url: '${createLink(controller: 'firmapdf', action: 'firmarTramite')}',
                                        async: true,
                                        data: {
                                            id: id,
                                            persona: '${persona?.id}',
                                            password: passwordFirma,
                                            coordenadas: coordenadas,
                                            pagina: pagina
                                        },
                                        success: function (msg) {
                                            cl.modal("hide");
                                            var parts = msg.split("_");
                                            if (parts[0] === "ok") {
                                                bootbox.alert("<strong style='font-size: 16px'> <i class='fa fa-check-circle text-success' style='font-size: 20px'></i>" + parts[1]  + "</strong>");
                                                setTimeout(function () {
                                                    location.href="${createLink(controller: 'tramite2', action: 'visorPdfFirmado')}?id=" + id
                                                }, 1000)
                                            } else {
                                                bootbox.alert("<strong style='font-size: 16px'> <i class='fa fa-exclamation-triangle text-danger' style='font-size: 20px'></i>" + parts[1]  + "</strong>")
                                            }
                                        }
                                    });
                                }else{
                                    bootbox.alert("<strong style='font-size: 16px'> <i class='fa fa-exclamation-triangle text-danger' style='font-size: 20px'></i>" + "Ingrese una contraseña"  + "</strong>")
                                }
                            }
                        }
                    }
                })
            }
        })
    }




</script>
</body>
</html>