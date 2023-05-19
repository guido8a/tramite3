<!DOCTYPE HTML>
<html>
<head>
    <meta name="layout" content="main2">
    <title>Redactar trámite</title>
    <ckeditor:resources/>

%{--    <script src="https://ckeditor.com/apps/ckfinder/3.5.0/ckfinder.js"></script>--}%

    <style type="text/css">

    .hoja {
        margin : auto;
        /*float  : right;*/
        width  : 70%;
        margin-left: 200px;
    }

    .nota {
        position           : absolute;
        left               : 15px;
        top                : 150px;
        padding            : 10px;
        background         : #BCCCDC;
        border             : solid 1px #867722;
        width              : 28%;
        z-index            : 1;

        -webkit-box-shadow : 7px 7px 5px 0px rgba(50, 50, 50, 0.75);
        -moz-box-shadow    : 7px 7px 5px 0px rgba(50, 50, 50, 0.75);
        box-shadow         : 7px 7px 5px 0px rgba(50, 50, 50, 0.75);
    }

    .card {
        width: 100%;
        -webkit-box-shadow : 7px 7px 5px 0px rgba(50, 50, 50, 0.75);
        -moz-box-shadow    : 7px 7px 5px 0px rgba(50, 50, 50, 0.75);
        box-shadow         : 7px 7px 5px 0px rgba(50, 50, 50, 0.75);
    }

    .nota .contenido {
        overflow   : auto;
    }

    .nota:after {
        position : absolute;
        top      : -10px;
        left     : 40%;
        z-index  : 2;
        display  : block;
        width    : 16px;
        height   : 16px;
    }

    .padre {
        background   : #BCCCDC;
        border-color : #2C5E8F;
        width        : 290px;
    }

    .nota.padre .contenido {
    }

    .padre h4 {
        font-size     : 15px;
        margin-top    : 0;
        margin-bottom : 5px;
        height        : 40px;
        overflow      : auto;
    }

    .btn-editar {
        position : absolute;
        right    : 10px;
        top      : 32px;
    }

    .membrete {
        cursor                : pointer;
        margin-top            : 2px;
        margin-left           : 15px !important;
        font-size             : 15px;
        padding               : 3px 8px;
        -webkit-border-radius : 5px;
        -moz-border-radius    : 5px;
        border-radius         : 5px;
    }

    .cambiado {
        background : #A0BF99;
    }
    </style>
</head>

<body>

<g:if test="${tramite.nota && tramite.nota.trim() != ''}">
    <div class="nota ui-corner-all">
        <div class="contenido">
            ${tramite.nota}
        </div>
    </div>
</g:if>
<g:if test="${tramite.padre}">
    <g:if test="${tramite.padre.personaPuedeLeer(session.usuario)}">
        <div class="nota ui-corner-all" id="divInfo" style="height: 600px; width: 355px; overflow: auto; resize: horizontal">
            <div class="text-info">
                <div><div style="width: 30%; float: left">Documento:</div>
                    <div style="float: left; width: 65%; display: inline">${tramite.padre.codigo}</div>
                </div>
                <div><div style="width: 30%; float: left">ASUNTO:</div>
                    <div style="float: left; width: 65%; display: inline">${tramite.padre.asunto}</div>
                </div>
            </div>

            <div id="divInfoContenido" style="margin-top: 20px; width: 95%">
                <util:renderHTML html="${tramite.padre.texto}"/>
            </div>
        </div>
    </g:if>
</g:if>

<div class="hoja">

    <div class="btn-toolbar toolbar">
        <div class="btn-group">
            <a href="#" class="btn btn-sm btn-success btnSave">
                <i class="fa fa-save"></i> Guardar texto
            </a>
        </div>
        <div class="btn-group">
            <a href="#" class="btn btn-sm btn-primary btnPrint">
                <i class="fa fa-print"></i> ver PDF
            </a>
        </div>

        <div class="btn-group">
            <g:if test="${tramite.deDepartamento && !esEditor}">
                <g:link controller="tramite2" action="bandejaSalidaDep" class="btnBandeja leave btn btn-sm btn-azul btnRegresar">
                    <i class="fa fa-list-ul"></i> Guardar texto y Salir
                </g:link>
            </g:if>
            <g:else>
                <g:link controller="tramite2" action="bandejaSalida" class="btnBandeja leave btn btn-sm btn-azul btnRegresar">
                    <i class="fa fa-share-square"></i> Guardar texto y Salir
                </g:link>
            </g:else>
            <g:if test="${!esEditor}">
                <g:if test="${tramite.deDepartamento}">
                    <g:link controller="tramite2" action="crearTramiteDep" id="${tramite.id}"
                            params="[esRespuesta: tramite.esRespuesta, esRespuestaNueva: tramite.esRespuestaNueva]"
                            class="leave btn-editar btn btn-sm btn-primary btnRegresar" title="Editar encabezado">
                        <i class="fa fa-edit"></i> Editar encabezado
                    </g:link>
                </g:if>
                <g:else>
                    <g:link action="crearTramite" id="${tramite.id}"
                            params="[esRespuesta: tramite.esRespuesta, esRespuestaNueva: tramite.esRespuestaNueva]"
                            class="leave btn-editar btn btn-sm btn-primary btnRegresar" title="Editar encabezado">
                        <i class="fa fa-edit"></i> Editar encabezado
                    </g:link>
                </g:else>
            </g:if>
        </div>

        %{--        <div class="btn-group membrete" data-con="${tramite.conMembrete ?: '0'}">--}%
        %{--            <g:if test="${tramite.conMembrete == '1'}">--}%
        %{--                <i class="fa fa-check"></i> Membrete--}%
        %{--            </g:if>--}%
        %{--            <g:else>--}%
        %{--                <i class="fa fa-square"></i> Membrete--}%
        %{--            </g:else>--}%
        %{--        </div>--}%

        <div class="col-md-3 negrilla" style="">
            <div class="col-md-7">
                <label for="membreteId">
                    <i class="fa fa-newspaper"></i> Membrete
                </label>
            </div>
            <div class="col-md-2">
                <div class="form-check form-check-inline">
                    <input class="form-check-input membrete" data-con="${tramite.conMembrete ?: '0'}" type="checkbox" id="membreteId" name="membreteId" ${tramite.conMembrete == '1' ? 'checked' : ''}>
                </div>
            </div>
        </div>

    </div>
    <elm:headerTramite tramite="${tramite}"/>

    <div class="card">
        <textarea id="editorTramite" class="editor" rows="100" cols="80">${tramite.texto}</textarea>
    </div>

%{--    <div id="editor">--}%
%{--        <p>This is some sample content.</p>--}%
%{--    </div>--}%

</div>



<script type="text/javascript">

/*
    ClassicEditor.create( document.querySelector( '#editor' ), {
        // toolbar: [ 'heading', '|', 'bold', 'italic', 'link', 'bulletedList', 'numberedList', 'blockQuote', 'imageUpload' ],
        // plugins: ["CKFinder"],
        toolbar: {
            items: [
                'heading',
                '|',
                'alignment',
                'bold',
                'italic',
                'link',
                'bulletedList',
                'numberedList',
                'imageUpload',
                'blockQuote',
                'undo',
                'redo'
            ]
        },
        ckfinder: {
            // uploadUrl: 'https://example.com/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images&responseType=json',
            uploadUrl: '${createLink(controller: 'tramiteImagenes', action: 'subir_ajax')}',
            options: {
                resourceType: 'Images'
            },
            openerMethod: 'popup'
        },
        heading: {
            options: [
                { model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph' },
                { model: 'heading1', view: 'h1', title: 'Heading 1', class: 'ck-heading_heading1' },
                { model: 'heading2', view: 'h2', title: 'Heading 2', class: 'ck-heading_heading2' }
            ]
        }
    } );
*/

    $.switcher('input[type=checkbox]');

    function arreglarTexto(texto) {
        texto = $.trim(texto);
        texto = texto.replace(/(?:\&)/g, "&amp;");
        texto = texto.replace(/(?:<)/g, "&lt;");
        texto = texto.replace(/(?:>)/g, "&gt;");
        texto = texto.replace(/(?:\r\n|\r|\n)/g, '');
        return texto;
    }

    var textoInicial = "${tramite.texto}";

    function doSave(url) {

        var b = cargarLoader("Guardando...");
        var texto = CKEDITOR.instances.editorTramite.getData();

        $.ajax({
            type     : "POST",
            url      : '${createLink(controller:"tramite", action: "saveTramite")}',
            data     : {
                id            : "${tramite.id}",
                editorTramite : texto,
                para          : $("#para").val(),
                asunto        : $("#asunto").val()
            },
            success  : function (msg) {
                b.modal("hide");
                var parts = msg.split("_");
                if (parts[0] == "OK") {
                    textoInicial = arreglarTexto(texto);
                }
                log(parts[1], parts[0] == "NO" ? "error" : "success");
                if (url) {
                    location.href = url;
                }
            },
            complete : function () {
                resetTimer();
            }
        });
    }

    $(function () {

        $(".membrete").click(function () {
            var esto = $(this);
            if (esto.data("con") == '0') {
                esto.data("con", '1').html('<i class="fa fa-check-square-o"></i> Membrete');
            } else {
                esto.data("con", '0').html('<i class="fa fa-square-o"></i> Membrete');
            }

            $.ajax({
                type    : "POST",
                url     : "${createLink(controller:'tramite',action:'cambiarMembrete')}",
                data    : {
                    id       : "${tramite.id}",
                    membrete : esto.data("con")
                },
                success : function (msg) {
                    var parts = msg.split("*");
                    log(parts[1], parts[0] == "OK" ? 'success' : "error");
                }
            });
        });

        $(".header-tramite").append($(".btn-editar"));

        $("#divInfo").resizable({
            maxWidth  : 650,
            maxHeight : 800,
            resize    : function (event, ui) {
                var $div = ui.element;
                var $also = ui.element.find("#divInfoContenido");
                var divH = ui.size.height;
                var divW = ui.size.width;

                var nw = divW - 20;
                var nh = divH - 10;

                $also.css({
                    width     : nw,
                    height    : nh-10,
                    maxHeight : nh

                });
            }
        });

        $("#btnInfoPara").click(function () {
            var para = $("#para").val();
            var paraExt = $("#paraExt").val();
            var id;
            var url = "";
            if (para) {
                if (parseInt(para) > 0) {
                    url = "${createLink(controller: 'persona', action: 'show_ajax')}";
                    id = para;
                } else {
                    url = "${createLink(controller: 'departamento', action: 'show_ajax')}";
                    id = parseInt(para) * -1;
                }
            }
            if (paraExt) {
                url = "${createLink(controller: 'origenTramite', action: 'show_ajax')}";
                id = paraExt;
            }
            $.ajax({
                type    : "POST",
                url     : url,
                data    : {
                    id : id
                },
                success : function (msg) {
                    bootbox.dialog({
                        title   : "Información",
                        message : msg,
                        buttons : {
                            aceptar : {
                                label     : "Aceptar",
                                className : "btn-primary",
                                callback  : function () {
                                }
                            }
                        }
                    });
                }
            });
            return false;
        });

        $(".btnTerminar").click(function () {
            var texto = CKEDITOR.instances.editorTramite.getData();
            bootbox.confirm("Está seguro de querer terminar este trámite? <br/>Esto enviará y recibirá automáticamente el trámite y no podrá ser editado.", function (res) {
                if (res) {
                    var b1 = cargarLoader("Guardando...");
                    $.ajax({
                        type    : "POST",
                        url     : '${createLink(action: "saveDEX")}',
                        data    : {
                            id            : "${tramite.id}",
                            editorTramite : texto
                        },
                        success : function (msg) {
                            b1.modal("hide")
                            var parts = msg.split("*");
                            if (parts[0] == "OK") {
                                textoInicial = texto;
                                location.href = parts[1];
                            } else {
                                bootbox.alert(parts[1]);
                            }
                        }
                    });
                }
            });
            return false;
        });

        $(".btnSave").click(function () {
            doSave();
            return false;
        });

        $(".btnBandeja").click(function () {
            var url = $(this).attr("href");
            doSave(url);
            return false;
        });

        function imprimir() {
            var texto = CKEDITOR.instances.editorTramite.getData();
            var p = cargarLoader("Generando PDF...");

            var url = '${createLink(controller:"tramiteExport", action: "crearPdf")}';
            var data = {
                id            : "${tramite.id}",
                editorTramite : texto,
                para          : $("#para").val(),
                asunto        : $("#asunto").val(),
                type          : "download",
                enviar        : 1,
                timestamp     : new Date().getTime()
            };
            $.ajax({
                type     : "POST",
                url      : url,
                data     : data,
                success  : function (msg) {
                    p.modal("hide");
                    textoInicial = arreglarTexto(texto);
                    location.href = "${createLink(controller:'tramiteExport',action:'crearPdf')}?id=" + id + "&type=download" + "&enviar=1" + "&timestamp=" + timestamp
                },
                complete : function () {
                    resetTimer();
                }
            });

            var id  = "${tramite.id}";
            var timestamp = new Date().getTime();
            var para = $("#para").val();
            var asunto = $("#asunto").val();
            var e = texto;
        }

        $(".btnPrint").click(function () {
            imprimir();
            return false;
        });

        //  Checks whether CKEDITOR is defined or not
        %{--if (typeof CKEDITOR != "undefined") {--}%
        %{--    $('textarea.editor').ckeditor({--}%
        %{--        height                  : 600,--}%
        %{--        filebrowserBrowseUrl    : '${createLink(controller: "tramiteImagenes", action: "browser")}',--}%
        %{--        filebrowserUploadUrl    : '${createLink(controller: "tramiteImagenes", action: "uploader")}',--}%
        %{--        filebrowserWindowWidth  : 950,--}%
        %{--        filebrowserWindowHeight : 500,--}%

        %{--        toolbar                 : [--}%
        %{--            ['Font', 'FontSize', 'Scayt', '-', 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo'],--}%
        %{--            ['Find', 'Replace', '-', 'SelectAll'],--}%
        %{--            ['Table', 'HorizontalRule', 'PageBreak'],--}%
        %{--            ['Image'/*, 'Timestamp'*/, '-', 'TextColor', 'BGColor', '-', 'About'],--}%
        %{--            '/',--}%
        %{--            ['Bold', 'Italic', 'Underline', /*'Strike', */'Subscript', 'Superscript'/*, '-', 'RemoveFormat'*/],--}%
        %{--            ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-']--}%
        %{--        ]--}%
        %{--    });--}%
        %{--}--}%

        CKEDITOR.replace( 'editorTramite', {
            height: "600px",
            // customConfig: 'config.js',
            filebrowserBrowseUrl    : '${createLink(controller: "tramiteImagenes", action: "browser")}',
            filebrowserUploadUrl    : '${createLink(controller: "tramiteImagenes", action: "uploader")}',
            // extraPlugins: 'imageuploader',
            toolbar                 : [
                ['Font', 'FontSize', 'Scayt', '-', 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo'],
                ['Find', 'Replace', '-', 'SelectAll'],
                ['Table', 'HorizontalRule', 'PageBreak'],
                ['Image'/*, 'Timestamp'*/, '-', 'TextColor', 'BGColor', '-', 'About'],
                '/',
                ['Bold', 'Italic', 'Underline', /*'Strike', */'Subscript', 'Superscript'/*, '-', 'RemoveFormat'*/],
                ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-']
            ]
        });

        CKEDITOR.on('instanceReady', function (ev) {
            // Prevent drag-and-drop.
            ev.editor.document.on('drop', function (ev) {
                ev.data.preventDefault(true);
            });
        });
    });
</script>
</body>
</html>
