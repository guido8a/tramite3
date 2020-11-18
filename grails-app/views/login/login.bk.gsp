<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="login">

    <title>Login</title>

    <style type="text/css">
    .archivo {
        width: 100%;
        float: left;
        margin-top: 60px;
        text-align: center;
    }
    </style>
</head>

<body>

<div style="text-align: center; margin-top: 22px; height: ${(flash.message) ? '640' : '570'}px;" class="well">

    <h1 class="titl" style="font-size: 24px; color: #06a">Monitor del COVID</h1>
    <h1 class="titl" style="font-size: 16px; color: #06a">Semáforos y Documentación Generada por la Emergencia del COVID-19</h1>
    <elm:flashMessage tipo="${flash.tipo}" icon="${flash.icon}"
                      clase="${flash.clase}">${flash.message}</elm:flashMessage>

    <div class="dialog ui-corner-all" style="height: 295px;padding: 10px;width: 910px;margin: auto;margin-top: 5px">
        <a href= "${createLink(controller:'provincia', action: 'mapa', id:-1)}" style="text-decoration: none">
            <div>
                <asset:image src="apli/portada.png" style="padding: 10px;"/>
            </div>
            <div style="margin-top: -30px"><h3>Ir al mapa de semáforos</h3></div>
        </a>

%{--
        <div style="width: 100%;height: 40px;float: left; margin-bottom:5px; text-align: center">
            <a href="${createLink(controller:'provincia', action: 'mapa', id:-1)}" class="btn btn-warning" style="width: 120px; margin: auto">
                Sin usuario <i class="fas fa-user-times"></i></a>
        </div>
--}%


        <div>
            Para mayor información puede consultar el
            <a href="${createLink(controller: 'descargas', action: 'manual')}">
                <asset:image src="apli/pdf_pq.png" style="padding: 10px;"/> manual del usuario</a>

            <a href="#" id="ingresar" class="btn btn-primary btn-sm" style="width: 160px; margin-left: 200px;">
                Administrador <i class="fas fa-user-check"></i></a>
        </div>


%{--        <p class="text-info pull-right" style="font-size: 10px; margin-top: -80px">--}%
        <p class="text-info" style="font-size: 10px; margin-top: -85px; float: right">
            <a href="http://www.tedein.com.ec">Desarrollado y auspiciado por: <strong>Tedein S.A.</strong>
                <asset:image src="logo tedein pq.jpeg" style="height: 22px; width: 22px; margin-left: 10px"/>
            </a>
        </p>
        <p class="text-info pull-left" style="font-size: 10px; margin-top: -80px; float: left">
            Versión ${message(code: 'version', default: '1.1.0x')}
        </p>
    </div>


<div class="modal fade" id="modal-ingreso" tabindex="-1" role="dialog" aria-labelledby=""
     aria-hidden="true">
    <div class="modal-dialog" id="modalBody" style="width: 380px;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Ingreso al Sistema</h4>
            </div>

            <div class="modal-body" style="width: 280px; margin: auto">
                <g:form name="frmLogin" action="validar" class="form-horizontal">
                    <div class="form-group">
                        <label class="col-md-5" for="login">Usuario</label>

                        <div class="controls col-md-5">
                            %{--<input type="text" id="login" placeholder="Usuario">--}%
                            <input name="login" id="login" type="text" class="form-control required"
                                   placeholder="Usuario" required autofocus style="width: 160px;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="col-md-5" for="pass">Contraseña</label>

                        <div class="controls col-md-5">
                            %{--<input type="password" id="pass" placeholder="Usuario">--}%
                            <input name="pass" id="pass" type="password" class="form-control required"
                                   placeholder="Contraseña" required style="width: 160px;">
                        </div>
                    </div>

                    <div class="divBtn" style="width: 100%">
                        <a href="#" class="btn btn-primary btn-lg btn-block" id="btn-login"
                           style="width: 140px; margin: auto">
                            <i class="fa fa-lock"></i> Validar
                        </a>
                    </div>

                </g:form>
            </div>
        </div>
    </div>
</div>

<div id="cargando" class="text-center hidden">
    <img src="${resource(dir: 'images', file: 'spinner32.gif')}" alt='Cargando...' width="32px" height="32px"/>
</div>

<script type="text/javascript">
    var $frm = $("#frmLogin");
    var recargar = true

    function timedRefresh(timeoutPeriod) {
        if(recargar) {
            setTimeout("location.reload(true);",timeoutPeriod);
        }
        recargar = false
    }


    function doLogin() {
        if ($frm.valid()) {
            // $("#cargando").removeClass('hidden');
            cargarLoader("Cargando...");
            $(".btn-login").replaceWith($("#cargando"));
            $("#frmLogin").submit();
        }
    }

    function doPass() {
        if ($("#frmPass").valid()) {
            $("#btn-pass").replaceWith(spinner);
            $("#frmPass").submit();
        }
    }

    $(function () {

        $("#ingresar").click(function () {
            var initModalHeight = $('#modal-ingreso').outerHeight();
            //alto de la ventana de login: 270
            console.log("ventana")
            $("#modalBody").css({'margin-top': ($(document).height() / 2 - 135)}, {'margin-left': $(window).width() / 2});
            console.log("antes modeal")
            $("#modal-ingreso").modal('show');
            console.log("luego modeal")
            setTimeout(function () {
                $("#login").focus();
            }, 500);

        });

        $("#btnOlvidoPass").click(function () {
            $("#recuperarPass-dialog").modal("show");
            $("#modal-ingreso").modal("hide");
        });

        // $frm.validate();
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

        // window.onload = timedRefresh(5000);

    });

</script>

</body>
</html>