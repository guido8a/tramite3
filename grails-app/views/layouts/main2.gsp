<!doctype html>
<html lang="en" class="no-js">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>

    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <asset:link rel="icon" href="favicon.ico" type="image/x-ico"/>

    <title><g:layoutTitle default="trámites3"/></title>

    <asset:stylesheet src="/bootstrap-3.3.2/dist/css/bootstrap.css"/>
    <asset:stylesheet src="/bootstrap-3.3.2/dist/css/bootstrap-theme.css"/>

    <asset:stylesheet src="/jquery/jquery-ui-1.10.3.custom.min.css"/>
    <asset:stylesheet src="/apli/jquery-ui.css"/>
    <asset:stylesheet src="/apli/jquery-ui.structure.css"/>
    <asset:stylesheet src="/apli/jquery-ui.theme.css"/>
    <asset:stylesheet src="/apli/custom.css"/>
    <asset:stylesheet src="/apli/lzm.context-0.5.css"/>
    <asset:stylesheet src="/apli/jquery.pnotify.js"/>
    <asset:stylesheet src="/apli/jquery.pnotify.default.css"/>
    <asset:stylesheet src="/apli/font-awesome.min.css"/>
    <asset:stylesheet src="/apli/CustomSvt.css"/>
    <asset:stylesheet src="/apli/tulpen/stylesheet.css"/>
    <asset:stylesheet src="/jquery/jquery.countdown.css"/>

    <asset:stylesheet src="/fonts/fontawesome-webfont.woff"/>
    <asset:stylesheet src="/apli/bootstrap-datetimepicker.min.css"/>

    <asset:javascript src="/jquery/jquery-2.2.4.js"/>
    <asset:javascript src="/jquery/jquery-ui.js"/>
    <asset:javascript src="/jquery/ui.js"/>

    <asset:javascript src="/apli/moment.js"/>
    <asset:javascript src="/apli/moment-with-locales.js"/>

    <asset:javascript src="/apli/funciones.js"/>
    <asset:javascript src="/apli/functions.js"/>
    <asset:javascript src="/apli/loader.js"/>
    <asset:javascript src="/apli/bootbox.js"/>
    <asset:javascript src="/apli/lzm.context-0.5.js"/>

    <asset:javascript src="/jquery-validation-1.11.1/js/jquery.validate.min.js"/>
    <asset:javascript src="/jquery-validation-1.11.1/js/jquery.validate.js"/>
    <asset:javascript src="/jquery-validation-1.11.1/localization/messages_es.js"/>

    <asset:javascript src="/apli/jquery.pnotify.js"/>
    <asset:javascript src="/apli/fontawesome.all.min.js"/>

    <asset:javascript src="/apli/bootstrap-datetimepicker.min.js"/>
    <asset:javascript src="/apli/bootstrap-maxlength.min.js"/>

    <asset:javascript src="/bootstrap-3.3.2/dist/js/bootstrap.min.js"/>
    <asset:javascript src="/jquery/jquery.countdown.js"/>

    <asset:javascript src="/jquery/date.js"/>

%{--    <!-- Custom styles -->--}%
%{--    <link href="${resource(dir: 'css', file: 'custom/loader.css')}" rel="stylesheet">--}%
%{--    <link href="${resource(dir: 'css', file: 'custom/modals.css')}" rel="stylesheet">--}%
%{--    <link href="${resource(dir: 'css', file: 'custom/tablas.css')}" rel="stylesheet">--}%
%{--    <link href="${resource(dir: 'css', file: 'custom/datepicker.css')}" rel="stylesheet">--}%
%{--    <link href="${resource(dir: 'css', file: 'custom/context.css')}" rel="stylesheet">--}%
%{--    <link href='${resource(dir: "css", file: "custom/pnotify.css")}' rel='stylesheet' type='text/css'>--}%

    <script type="text/javascript">
    var spinner = $('<asset:image src="apli/spinner32.gif" style="padding: 40px;"/>');
    var spinnerSquare64 = $('<asset:image src="/spinner_64.GIF" style="padding: 40px;"/>');

    %{--var spinner24Url = "${resource(dir:'images/spinners', file:'spinner_24.GIF')}";--}%
        %{--var spinner64Url = "${resource(dir:'images/spinners', file:'spinner_64.GIF')}";--}%

        %{--var spinnerSquare64Url = "${resource(dir: 'images/spinners', file: 'loading_new.GIF')}";--}%

        %{--var spinner = $("<img src='" + spinner24Url + "' alt='Cargando...'/>");--}%
        %{--var spinner64 = $("<img src='" + spinner64Url + "' alt='Cargando...'/>");--}%
        %{--var spinnerSquare64 = $("<img src='" + spinnerSquare64Url + "' alt='Cargando...'/>");--}%
    </script>

    <g:layoutHead/>

</head>

<body>
<div id="modalTabelGray"></div>

<div id="modalDiv" class="ui-corner-all">
    <div class="loading-title">Procesando</div>
    <img src="${resource(dir: 'images/spinners', file: 'loading_new.GIF')}">

    <div class="loading-footer">Espere por favor</div>
</div>
<mn:menu title="${g.layoutTitle(default: 'Happy')}"/>
<g:if test="${session.departamento.estado == 'B' && session.usuario.esTriangulo()}">
    <div id="bloqueo-warning" class="bloqueo ui-corner-all alert alert-danger " style="z-index: 200001; width: 240px; height: 190px;">
        <div class="titulo-bloqueo">
            <i class="fa fa-exclamation-circle"></i>
            Alerta de bloqueo
            <a href="#" class="cerrar-bloqueo" style="float: right;text-align: right;color: black;width: 20px;height: 30px;line-height: 30px" title="cerrar">
                <i class="fa fa-times"></i>
            </a>
        </div>

        <div class="texto-bloqueo">
            Varias funciones del departamento ${session.departamento} están bloqueadas temporalmente debido a trámites no recibidos.
        </div>
        <a href="${g.createLink(controller: 'tramite3', action: 'bandejaEntradaDpto')}" class="" style="margin-top: 30px">Ver trámites no recibidos</a>
    </div>
</g:if>
<g:if test="${session.departamento.estado == 'W' && session.usuario.esTriangulo()}">
    <div id="bloqueo-warning" class="bloqueo ui-corner-all alert alert-warning " style="width: 240px; height: 150px;" style="z-index: 200001; ">
        <div class="titulo-bloqueo">
            <i class="fa fa-exclamation-circle"></i>
            Aviso: Trámites No Recibidos
            <a href="#" class="cerrar-bloqueo" style="float: right;text-align: right;color: black;width: 20px;height: 30px;line-height: 30px" title="cerrar">
                <i class="fa fa-times"></i>
            </a>
        </div>

        <div class="texto-bloqueo">
            El departamento ${session.departamento}, tiene trámites que no le han recibido.
        </div>
    </div>
</g:if>
<g:if test="${!session.usuario.esTriangulo()}">
    <g:if test="${session.usuario.estado == 'B'}">
        <div id="bloqueo-warning" class="bloqueoUsu ui-corner-all alert alert-danger " style="z-index: 200001; width: 240px; height: 190px;">
            <div class="titulo-bloqueo">
                <i class="fa fa-exclamation-circle"></i>
                Alerta de bloqueo
                <a href="#" class="cerrar-bloqueo" style="float: right;text-align: right;color: black;width: 20px;height: 30px;line-height: 30px" title="cerrar">
                    <i class="fa fa-times"></i>
                </a>
            </div>

            <div class="texto-bloqueo">
                Varias funciones del usuario ${session.usuario} están bloqueadas temporalmente debido a trámites no recibidos.
            </div>
            <a href="${g.createLink(controller: 'tramite', action: 'bandejaEntrada')}" class="" style="margin-top: 30px">Ver trámites no recibidos</a>
        </div>
    </g:if>
    <g:if test="${session.usuario.estado == 'W'}">
        <div id="bloqueo-warning" class="bloqueoUsu  ui-corner-all alert alert-warning " style="width: 240px; height: 150px;" style="z-index: 200001">
            <div class="titulo-bloqueo">
                <i class="fa fa-exclamation-circle"></i>
                Alerta de Trámites No Recibidos
                <a href="#" class="cerrar-bloqueo" style="float: right;text-align: right;color: black;width: 20px;height: 30px;line-height: 30px" title="cerrar">
                    <i class="fa fa-times"></i>
                </a>
            </div>

            <div class="texto-bloqueo">
%{--                El usuario ${session.usuario}, tiene trámites que no le han recibido.--}%
            </div>
        </div>
    </g:if>
</g:if>
<div class="container" style="min-width: 1000px !important;">
    <g:layoutBody/>
</div>


<!-- Bootstrap core JavaScript
    ================================================== -->
<!-- Placed at the end of the document so the pages load faster -->
%{--<script src="${resource(dir: 'bootstrap-3.0.1/js', file: 'bootstrap.min.js')}"></script>--}%
%{--<elm:bootstrapJs/>--}%

<!-- funciones de ui (tooltips, maxlength, bootbox, contextmenu, validacion en keydown para los numeros) -->
%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.js')}"></script>--}%
<script type="text/javascript">


    $(document).ready(function(){
        initControls();
    });

    /* deshabilita navegación hacia atras */
    function initControls(){

        window.location.hash="no-back-button";
        window.location.hash="Again-No-back-button"; //chrome
        window.onhashchange=function(){window.location.hash="no-back-button";}

    }


   var ot = document.title;

    function resetTimer() {
        var ahora = new Date();
        var fin = ahora.clone().add(5).minute();
        fin.add(1).second()
        $("#countdown").countdown('option', {
            until : fin
        });
        $(".countdown_amount").removeClass("highlight");
        document.title = ot;
    }

    function validarSesion() {
        %{--'${createLink(controller: "login", action: "validarSesion")}',--}%
        %{--'${g.createLink(controller: 'login', action: 'login')}';--}%
    }

    function highlight(periods) {

    }

    $(function () {
        setInterval(function () {
            $(".annoying").hide()
            setTimeout(function () {
                $(".annoying").show()
            }, 500)
            setTimeout(function () {
                $(".annoying").hide()
            }, 1000)
            setTimeout(function () {
                $(".annoying").show()
            }, 1500)
            setTimeout(function () {
                $(".annoying").hide()
            }, 2000)
            setTimeout(function () {
                $(".annoying").show()
            }, 2500)
            setTimeout(function () {
                $(".annoying").hide()
            }, 3000)
            setTimeout(function () {
                $(".annoying").show()
            }, 3500)
            setTimeout(function () {
                $(".annoying").hide()
            }, 4000)
            setTimeout(function () {
                $(".annoying").show()
            }, 4500)
            setTimeout(function () {
                $(".annoying").hide()
            }, 5000)
            setTimeout(function () {
                $(".annoying").show()
            }, 5500)
            setTimeout(function () {
                $(".annoying").hide()
            }, 6000)
            setTimeout(function () {
                $(".annoying").show()
            }, 6500)
            setTimeout(function () {
                $(".annoying").hide()
            }, 7000)
            setTimeout(function () {
                $(".annoying").show()
            }, 7500)
            setTimeout(function () {
                $(".annoying").hide()
            }, 8000)
            setTimeout(function () {
                $(".annoying").show()
            }, 8500)
        }, 60000);

        var ahora = new Date();
        var fin = ahora.clone().add(5).minute();
        fin.add(1).second()

        $('#countdown').countdown({
            until    : fin,
            format   : 'MS',
            compact  : true,
            onExpiry : validarSesion,
            onTick   : highlight
        });

        $(".btn-ajax").click(function () {
            resetTimer();
        });

        $(".bloqueo").draggable()
        $(".cerrar-bloqueo").click(function () {
            $(this).parent().parent().hide("explode")
        })
    });

</script>

</body>
</html>
