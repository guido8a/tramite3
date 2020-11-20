<%@ page import="tramites.TipoDocumento" contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <title>Tipo de documentos</title>

        <style type="text/css">
        .tipoDoc .fa-li, .tipoDoc span, .permiso .fa-li, .permiso span {
            cursor : pointer;
        }

        .table {
            font-size     : 13px;
            width         : auto !important;
            margin-bottom : 0 !important;
        }

        .container-celdasAcc {
            max-height : 200px;
            width      : 804px; /*554px;*/
            overflow   : auto;
        }

        .container-celdasPerm {
            max-height : 200px;
            width      : 1030px;
            overflow   : auto;
        }

        .col100 {
            width : 100px;
        }

        .col200 {
            width : 250px;
        }

        .col300 {
            width : 304px;
        }

        .col-md-1.xs {
            width : 45px;
        }

        .fecha {
            width : 160px;
        }

        </style>

    </head>

    <body>

        %{--<div class="well well-sm">--}%
%{--        <div class="form-group keeptogether">--}%
%{--            <div>--}%
%{--                <span class="col-md-10" style="text-align: center">--}%
%{--                    <div class="panel panel-default" style="margin-left: 30px;">--}%
%{--                        <div class="panel-heading panel-success"><strong>Departamento: ${departamentoInstance.descripcion}</strong>--}%
%{--                        </div>--}%
%{--                    </div>--}%
%{--                </span>--}%
%{--            </div>--}%
%{--        </div>--}%

        <div class="panel panel-default">
            <h4 class="panel-default" style="text-align: center">
                Tipo de Documentación para el departamento: ${departamentoInstance.descripcion}
            </h4>

            <div id="collapseTipoDocs" class="panel-collapse collapse in">
                <div class="panel panel-default">
                    <p style="text-align: center; margin-top: 5px">
                        <a href="#" class="btn btn-info btn-sm" id="allPerf"><i class="fa fa-check-circle"></i> Asignar todos los tipos</a>
                        <a href="#" class="btn btn-warning btn-sm" id="nonePerf"><i class="fa fa-circle"></i> Quitar todos los tipos</a>
                    </p>
                    <g:form name="frmTipoDocumentos" action="savetipoDoc_ajax">
                        <ul class="fa-ul">
                            <g:each in="${tramites.TipoDocumento.list([sort: 'descripcion'])}" var="tipoDoc">
                                <li class="tipoDoc">
                                    <i data-id="${tipoDoc.id}"
                                       class="fa-li fa ${permisos.contains(tipoDoc?.id) ? "fa-check-square" : "fa-square"}"></i>
                                    <span>${tipoDoc.descripcion}</span>
                                </li>
                            </g:each>
                        </ul>
                    </g:form>
                </div>
            </div>
        </div>


        <script type="text/javascript">


            $(function () {

                $("#allPerf").click(function () {
                    $(".tipoDoc .fa-li").removeClass("fa-square").addClass("fa-check-square");
                    return false;
                });

                $("#nonePerf").click(function () {
                    $(".tipoDoc .fa-li").removeClass("fa-check-square").addClass("fa-square");
                    return false;
                });

                $(".fa")

                $(".tipoDoc .fa-li, .tipoDoc span").click(function () {
                    var ico = $(this).parent(".tipoDoc").find(".fa-li");
                    if (ico.hasClass("fa-check-square")) { //descheckear
                        ico.removeClass("fa-check-square").addClass("fa-square");
                    } else { //checkear
                        ico.removeClass("fa-square").addClass("fa-check-square");
                    }
                });
            });
        </script>

    </body>
</html>