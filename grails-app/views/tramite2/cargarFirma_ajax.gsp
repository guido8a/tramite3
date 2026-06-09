<div class="row">
    <div class="col-md-12">
        <span class="col-md-10">
            <span class="col-md-8">
                <g:uploadForm action="uploadCertificadoFirma" method="post" name="frmUpload" enctype="multipart/form-data">
                    <g:hiddenField name="id" value="${tramite?.id}"/>
                    <div class="fieldcontain required">
                        <b>Cargar archivo:</b>
                        <input type="file" id="file" name="file" class="required" multiple accept=".p12"/>

                        <div class="btn-group" style="margin-top: 20px;">
                            <a href="#" id="submitArchivoFirma" class="btn btn-success">
                                <i class="fa fa-save"></i> Cargar
                            </a>
                        </div>
                    </div>
                </g:uploadForm>
            </span>

%{--            <span class="col-md-12">--}%
%{--                <g:if test="${empresa?.firma}">--}%
%{--                    <div class=" alert alert-success" style="margin-top: 10px">--}%
%{--                        <i class="fa fa-check-circle fa-2x"></i>  <strong style="font-size: 14px"> Un certificado de firma electronica está cargado.</strong>--}%
%{--                    </div>--}%
%{--                    <div class="btn-group">--}%
%{--                        <a href="#" class="btn btn-danger btnBorrarArchivoFirma">--}%
%{--                            <i class="fa fa-trash"></i> Borrar--}%
%{--                        </a>--}%
%{--                    </div>--}%
%{--                </g:if>--}%
%{--                <g:else>--}%
%{--                    <div class="alert alert-info" style="margin-top: 10px; font-size: 16px">--}%
%{--                        <i class="fa fa-exclamation-triangle fa-2x"></i>--}%
%{--                        No existe un certificado cargado.--}%
%{--                    </div>--}%
%{--                </g:else>--}%
%{--            </span>--}%

        </span>
    </div>
</div>

<script type="text/javascript">

    $("#submitArchivoFirma").click(function () {
        return submitFormFirma();
    });

    function submitFormFirma() {
        var $form = $("#frmUpload");
        var formData = new FormData($("#frmUpload")[0]);
        var dialog = cargarLoader("Guardando...");
        $.ajax({
            type    : "POST",
            url     : $form.attr("action"),
            data    : formData,
            processData: false,
            contentType: false,
            success : function (msg) {
                dialog.modal('hide');
                var parts = msg.split("_");
                if(parts[0] === 'ok'){
                    log(parts[1], "success");
                    cerrarCargarCertificado();
                    firmarPDF('${tramite?.id}', '${paginaActual}', '${coordenadasX}', '${coordenadasY}')
                }else{
                    bootbox.alert('<i class="fa fa-exclamation-triangle text-danger fa-3x"></i> ' + '<strong style="font-size: 14px">' + parts[1] + '</strong>');
                    return false;
                }
            }
        });
    }

    %{--$(".btnBorrarArchivoFirma").click(function () {--}%
    %{--    var id = '${empresa?.id}';--}%
    %{--    borrarArchivo(id)--}%
    %{--});--}%

    %{--function borrarArchivo(id) {--}%
    %{--    bootbox.dialog({--}%
    %{--        title   : "<i class='fa fa-trash text-danger text-shadow'></i> Alerta",--}%
    %{--        message : "<strong style='font-size: 16px'> Está seguro que desea borrar este certificado de firma electrónica?" + "<br/>" + "Esta acción no se puede deshacer.</strong>",--}%
    %{--        buttons : {--}%
    %{--            cancelar : {--}%
    %{--                label     : "Cancelar",--}%
    %{--                className : "btn-primary",--}%
    %{--                callback  : function () {--}%
    %{--                }--}%
    %{--            },--}%
    %{--            eliminar : {--}%
    %{--                label     : "<i class='fa fa-trash'></i> Eliminar",--}%
    %{--                className : "btn-danger",--}%
    %{--                callback  : function () {--}%
    %{--                    var v = cargarLoader("Eliminando...");--}%
    %{--                    $.ajax({--}%
    %{--                        type    : "POST",--}%
    %{--                        url     : '${createLink(controller: 'empresa',  action:'borrarArchivoFirma_ajax')}',--}%
    %{--                        data    : {--}%
    %{--                            id : id--}%
    %{--                        },--}%
    %{--                        success : function (msg) {--}%
    %{--                            v.modal("hide");--}%
    %{--                            var parts = msg.split("_");--}%
    %{--                            if(parts[0] === 'ok'){--}%
    %{--                                log(parts[1],"success");--}%
    %{--                                cerrarCargarCertificado();--}%
    %{--                            }else{--}%
    %{--                                log(parts[1],"error")--}%
    %{--                            }--}%
    %{--                        }--}%
    %{--                    });--}%
    %{--                }--}%
    %{--            }--}%
    %{--        }--}%
    %{--    });--}%
    %{--}--}%

    function firmarPDF(id, pagina, coordenadasX, coordenadasY){
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
                                        url: '${createLink(controller: 'firmapdf', action: 'firmaSecundaria')}',
                                        async: true,
                                        data: {
                                            id: id,
                                            persona: '${persona?.id}',
                                            password: passwordFirma,
                                            coordenadasX: coordenadasX,
                                            coordenadasY: coordenadasY,
                                            pagina: pagina
                                        },
                                        success: function (msg) {
                                            cl.modal("hide");
                                            var parts = msg.split("_");
                                            if (parts[0] === "ok") {
                                                bootbox.alert("<strong style='font-size: 16px'> <i class='fa fa-check-circle text-success' style='font-size: 20px'></i>" + parts[1]  + "</strong>");
                                                setTimeout(function () {
                                                    location.href="${createLink(controller: 'tramite2', action: 'visorPdfFirmado')}?id=" + id + "&persona=" + '${persona?.id}'
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
