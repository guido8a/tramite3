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

        <div class="panel panel-default">
            <h4 class="panel-default" style="text-align: center">
                Tipo de Documentación para el departamento: ${departamentoInstance.descripcion}
            </h4>

            <div id="collapseTipoDocs" class="panel-collapse collapse in">
%{--                <div class="panel panel-default">--}%
%{--                    <p style="text-align: center; margin-top: 5px">--}%
%{--                        <a href="#" class="btn btn-info btn-sm" id="allPerf"><i class="fa fa-check-circle"></i> Asignar todos los tipos</a>--}%
%{--                        <a href="#" class="btn btn-warning btn-sm" id="nonePerf"><i class="fa fa-circle"></i> Quitar todos los tipos</a>--}%
%{--                    </p>--}%
                    <div style="margin-left: 50px">
                    <g:form name="frmTipoDocumentos" action="savetipoDoc_ajax">
%{--                        <ul class="fa-ul">--}%
%{--                            <g:each in="${tramites.TipoDocumento.list([sort: 'descripcion'])}" var="tipoDoc">--}%
%{--                                <li class="tipoDoc">--}%
%{--                                    <i data-id="${tipoDoc.id}"--}%
%{--                                       class="fa-li fa ${permisos.contains(tipoDoc?.id) ? "fa-check-square" : "fa-square"}"></i>--}%
%{--                                    <span>${tipoDoc.descripcion}</span>--}%
%{--                                </li>--}%
%{--                            </g:each>--}%

                            <g:each in="${tramites.TipoDocumento.list([sort: 'descripcion'])}" var="tipoDoc">
                                <div class="form-check form-check-inline" style="margin-top: 2px">
                                    <input class="form-check-input tipo" type="checkbox" data-id="${tipoDoc?.id}" name="tipo_name" id="tipoId" ${tipoDoc?.id in permisos ? 'checked' : ''}>
                                    ${tipoDoc.descripcion}
                                </div>
                            </g:each>

%{--                        </ul>--}%
                    </g:form>
                    </div>
%{--                </div>--}%
            </div>
        </div>

        <script type="text/javascript">

            $.switcher('input[type=checkbox]');

            $(".tipo").click(function () {
                var id = $(this).data("id");
                var checked = $(this).is(":checked");
                if (checked) {
                    guardarTipo('si',id)
                } else {
                    guardarTipo('no',id)
                }
            });

            function guardarTipo(tipo,id){
                var cl = cargarLoader("Guardando...");
                $.ajax({
                    type: 'POST',
                    url: '${createLink(controller: 'departamento', action: 'guardarTipoDocumento_ajax')}',
                    data:{
                        tipo: tipo,
                        id: id,
                        departamento: '${departamentoInstance?.id}'
                    },
                    success: function (msg) {
                      cl.modal("hide");
                      var parts = msg.split("_");
                        if(parts[0] == 'ok'){
                            log(parts[1],"success")
                        }else{
                            log(parts[1],"error")
                        }
                    }
                })
            }

            // $(function () {
            //
            //     $("#allPerf").click(function () {
            //         $(".tipoDoc .fa-li").removeClass("fa-square").addClass("fa-check-square");
            //         return false;
            //     });
            //
            //     $("#nonePerf").click(function () {
            //         $(".tipoDoc .fa-li").removeClass("fa-check-square").addClass("fa-square");
            //         return false;
            //     });
            //
            //     $(".fa")
            //
            //     $(".tipoDoc .fa-li, .tipoDoc span").click(function () {
            //         var ico = $(this).parent(".tipoDoc").find(".fa-li");
            //         if (ico.hasClass("fa-check-square")) { //descheckear
            //             ico.removeClass("fa-check-square").addClass("fa-square");
            //         } else { //checkear
            //             ico.removeClass("fa-square").addClass("fa-check-square");
            //         }
            //     });
            // });

        </script>

    </body>
</html>