<%@ page contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <link href="${resource(dir: 'bootstrap-3.0.1/css', file: 'bootstrap.spacelab.css')}" rel="stylesheet">

        <meta name="layout" content="login">
        <title>Login</title>

        <style type="text/css">
        .archivo {
            width      : 100%;
            float      : left;
            margin-top : 30px;
            text-align : center;
        }

        .creditos p {
            text-align : justify;
        }
        </style>

    </head>

    <body>

        <div style="text-align: center; margin-top: 10px; height: ${(flash.message) ? '700' : '630'}px;" class="well">
            <div class="page-header" style="margin-top: 10px;">
                <h1>Trámites</h1>
                <h3>
                    <p class="text-info">GOBIERNO AUTÓNOMO DESCENTRALIZADO PROVINCIA DE ...</p>

                    <p class="text-info">Sistema de Administración de Documentos</p>
                </h3>
            </div>

            <elm:flashMessage tipo="${flash.tipo}" icon="${flash.icon}"
                              clase="${flash.clase}">${flash.message}</elm:flashMessage>

            <div class="dialog ui-corner-all" style="height: 295px;padding: 10px;width: 910px;margin: auto;margin-top: 5px">
                <div style="text-align: center; margin-top: 10px; color: #810;">
                    <asset:image src="apli/portada.png" style="padding: 10px; width: 500px"/>
                </div>

                <div style="width: 100%;height: 20px;float: left;margin-top: 20px;text-align: center">
                    <a href="#" id="ingresar" class="btn btn-primary" style="width: 360px; margin: auto">
                        <i class="icon-off"></i>Ingresar</a>
                </div>

                <div class="archivo">
                    Le recomendamos descargar y leer el
                    <asset:image src="apli/pdf_pq.png" style="padding: 10px;"/> manual del usuario</a>
                </div>


                <p class="pull-left" style="font-size: 10px;">
                    <a href="#" id="aCreditos">
                        www.tedein.com.ec
                    </a>
                </p>

                <p class="text-info pull-right" style="font-size: 10px;">
                    Desarrollado por: TEDEIN S.A. Versión ${message(code: 'version', default: '1.1.0x')}
                </p>
            </div>
        </div>

    <div class="modal fade" id="modal-ingreso" tabindex="-1" role="dialog" aria-labelledby=""
             aria-hidden="true">
            <div class="modal-dialog" id="modalBody" style="width: 380px;">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                        <h4 class="modal-title">Ingreso a Trámites</h4>
                    </div>

                    <div class="modal-body" style="width: 280px; margin: auto">
                        <g:form name="frmLogin" action="validar" class="form-horizontal">
                            <div class="form-group">
                                <label class="col-md-5" for="login">Usuario</label>

                                <div class="controls col-md-5">
                                    <input name="login" id="login" type="text" class="form-control required"
                                           placeholder="Usuario" required autofocus style="width: 160px;">
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-md-5" for="pass">Contraseña</label>

                                <div class="controls col-md-5">
                                    <input name="pass" id="pass" type="password" class="form-control required"
                                           placeholder="Contraseña" required style="width: 160px;">
                                </div>
                            </div>

                            <div class="divBtn" style="width: 100%">
                                <a href="#" class="btn btn-primary btn-lg btn-block" id="btn-login"
                                   style="width: 140px; margin: auto">
                                    <i class="fa fa-lock"></i> Ingresar
                                </a>
                            </div>

                        </g:form>
                    </div>
                </div>
            </div>
        </div>

        <div id="divCreditos" class="hidden">
            <div class="creditos">
                <p>
                    El Sistema de Administración de Documentos plataforma Web (SADW) es propiedad del
                    Gobierno de la Provincia de Pichincha, contratado bajo consultoría con la empresa TEDEIN S.A.
                    Sistema Desarrollado en base a la primera versión del SAD y con la asesoría técnica de la Gestión
                    de Sistemas y Tecnologías de Información del GADPP.
                </p>

                <p>
                    Los derechos de Autor de este software y los programas fuentes son de propiedad del Gobierno
                    de la Provincia de Pichincha por lo que toda reproducción parcial o total del mismo está
                    prohibida para el contratista y/o terceras personas ajenas.
                </p>
            </div>
        </div>

        <script type="text/javascript">
            var $frm = $("#frmLogin");
            function doLogin() {
                if ($frm.valid()) {
                    // $("#btn-login").replaceWith(spinner);
                    cargarLoader("Cargando...");
                    $("#frmLogin").submit();
                }
            }

            function doPass() {
                if ($("#frmPass").valid()) {
                    // $("#btn-pass").replaceWith(spinner);
                    cargarLoader("Cargando...");
                    $("#frmPass").submit();
                }
            }

            $(function () {

                $("#aCreditos").click(function () {
                    bootbox.dialog({
                        title   : "Créditos",
                        message : $("#divCreditos").html(),
                        buttons : {
                            aceptar : {
                                label     : "Cerrar",
                                className : "btn-primary",
                                callback  : function () {
                                }
                            }
                        }
                    });
                    return false;
                });

                $("#ingresar").click(function () {
                    var initModalHeight = $('#modal-ingreso').outerHeight();
                    //alto de la ventana de login: 270
                    $("#modalBody").css({'margin-top' : ($(document).height() / 2 - 135)}, {'margin-left' : $(window).width() / 2});
                    $("#modal-ingreso").modal('show');

                    setTimeout(function () {
                        $("#login").focus();
                    }, 500);

                });

                $("#btnOlvidoPass").click(function () {
                    $("#recuperarPass-dialog").modal("show");
                    $("#modal-ingreso").modal("hide");
                });

                $frm.validate();
                $("#btn-login").click(function () {
                    doLogin();
                });

                $("#btn-pass").click(function () {
                    doPass();
                });

                $("input").keyup(function (ev) {
                    if (ev.keyCode == 13) {
                        doLogin();
                    }
                })
            });


        </script>

    </body>
</html>