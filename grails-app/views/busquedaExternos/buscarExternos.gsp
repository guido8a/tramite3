
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="noMenu">
    <title>Buscar Trámites Externos</title>

    <style type="text/css">

    .css-vertical-text {
        /*position          : absolute;*/
        left              : 5px;
        bottom            : 5px;
        color             : #0088CC;
        border            : 0px solid red;
        writing-mode      : tb-rl;
        -webkit-transform : rotate(270deg);
        -moz-transform    : rotate(270deg);
        -o-transform      : rotate(270deg);
        white-space       : nowrap;
        display           : block;
        width             : 20px;
        height            : 20px;
        font-family       : 'Tulpen One', cursive;
        font-weight       : bold;
        font-size         : 35px;
    }

    .tituloChevere {
        color       : #0088CC;
        border      : 0px solid red;
        white-space : nowrap;
        display     : block;
        height      : 25px;
        font-family : 'open sans condensed';
        font-weight : bold;
        font-size   : 16px;
        line-height : 18px;
    }

    .container-celdas {
        width      : 1000px;
        height     : 150px;
        float      : left;
        overflow   : auto;
    }

    .table-hover tbody tr:hover td, .table-hover tbody tr:hover th {
        background-color : #FFBD4C;
    }

    .negrilla {
        font-weight : bold;

    }
    </style>

</head>

<body>

<div style="text-align: center; margin-top: 5px; height: ${(flash.message) ? '650' : '830'}px;" class="well">
    <div class="page-header" style="margin-top: -10px;">
        %{--                <div style="position: fixed; margin-left: 20px; width: 100px">--}%
        %{--                    <img src="${resource(dir: 'images', file: 'logo_gadpp_reportes.png')}"/>--}%
        %{--                    EFICIENCIA Y SOLIDARIDAD--}%
        %{--                </div>--}%
        <h1>S.A.D. Web</h1>

        <h3>
            %{--            <p class="text-info">GAD</p>--}%
            <p class="text-info">Sistema de Administración de Documentos</p>
        </h3>
        <h3><p class="text-info">Consulta de Trámites Externos</p></h3>
    </div>
    <elm:flashMessage tipo="${flash.tipo}" icon="${flash.icon}"
                      clase="${flash.clase}">${flash.message}</elm:flashMessage>

    <div class="dialog ui-corner-all" style="height: 295px;padding: 10px;width: 910px;margin: auto;margin-top: 5px">

        <div class="buscar" style="margin-bottom: 20px">

            <fieldset>

                <div >
                    <div class="col-md-2" style="text-align: left">
                        <label for="codigo">Código del trámite</label>
                    </div>

                    <div class="col-md-2" style="margin-left: -20px;">
                        <g:textField name="codigo" value="" maxlength="20" class="form-control allCaps" style="width: 160px"/>
                        <a href="#" name="busqueda" class="btn btn-success btnBusqueda" style="margin-top: 22px"><i class="fa fa-search"></i> Buscar</a>
                    </div>
                    <div class="col-md-7" style="text-align: left; margin-left: 30px; margin-top: -5px; width: 580px;">
                        Ingrese el código del trámie en el formato: <strong>DEX - # - OFI - AÑO</strong>

                        <ul>
                            <li>
                                <strong>DEX</strong> es el prefijo para todos los trámites,
                            </li>
                            <li>
                                <strong>#</strong> representa el número del trámite
                            </li>
                            <li>
                                <strong>OFI</strong> son las siglas de la oficina
                            </li>
                            <li>
                                <strong>AÑO</strong> es los dos dígitos del año
                            </li>
                            <li>
                                <span style="color: #448"> Ejemplo: DEX-43-DPT-14</span>
                            </li>
                            <li>
                                <p class="text-warning"> Si desconoce el número o código del trámite, por favor comuníquese  al teléfono: <strong>${parametros?.telefono}</strong></p>
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="col-md-10">

                </div>

            </fieldset>
        </div>

        <div id="tabla">

        </div>

    </div>
</div>

<div class="modal fade " id="dialog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Detalles</h4>
            </div>

            <div class="modal-body" id="dialog-body" style="padding: 15px">

            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>

<script type="text/javascript">

    function buscar() {
        $("#tabla").html("Buscando...").prepend(spinner);
        var codigo = $("#codigo").val().toUpperCase();
        $.ajax({
            type    : "POST",
            url     : "${g.createLink(controller: 'busquedaExternos', action: 'tablaBusquedaExternos')}",
            data    : {
                codigo      : codigo
            },
            success : function (msg) {
                $("#tabla").html(msg);
            }
        });
    }

    $(".btnBusqueda").click(function () {
        buscar();
    });

    $("input").keyup(function (ev) {
        if (ev.keyCode == 13) {
            buscar();
        }
    });
</script>
</body>
</html>