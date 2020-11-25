<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 25/11/20
  Time: 10:56
--%>


<div style="width: 100%;height: 600px;overflow: auto; margin-top: -10px;margin-bottom: 20px;">
    <table class="table table-condensed table-bordered">
        <tbody>
        <g:each in="${usuarios}" var="usuario">
            <tr style="width: 100%" data-id="${usuario.usro__id}" class="${usuario.usroetdo == 1 ? 'activo' : 'inactivo'}">
                <td style="width: 10%">${usuario.usrologn}</td>
                <td style="width: 25%">${usuario.usronmbr}</td>
                <td style="width: 25%">${usuario.usroapll}</td>
                <td style="width: 25%">${usuario.dptodscr}</td>
                <td style="width: 15%">${usuario.usroprfl}</td>
            </tr>
        </g:each>
        </tbody>
    </table>
</div>

<script type="text/javascript">


    $(function () {
        $("tr").contextMenu({
            items  : createContextMenu,
            onShow : function ($element) {
                $element.addClass("trHighlight");
            },
            onHide : function ($element) {
                $(".trHighlight").removeClass("trHighlight");
            }
        });
    });


%{--    $("tr").contextMenu({--}%
%{--        items  : {--}%
%{--            header   : {--}%
%{--                label  : "Acciones",--}%
%{--                header : true--}%
%{--            },--}%
%{--            ver      : {--}%
%{--                label  : "Numeración",--}%
%{--                icon   : "fa fa-search",--}%
%{--                action : function ($element) {--}%
%{--                    var id = $element.data("id");--}%
%{--                    $.ajax({--}%
%{--                        type    : "POST",--}%
%{--                        url     : "${createLink(controller: 'numero', action:'numeracion_ajax')}",--}%
%{--                        data    : {--}%
%{--                            id : id--}%
%{--                        },--}%
%{--                        success : function (msg) {--}%
%{--                            bootbox.dialog({--}%
%{--                                title   : "Numeración por tipo de trámite",--}%
%{--                                message : msg,--}%
%{--                                buttons : {--}%
%{--                                    cancelar : {--}%
%{--                                        label     : "Cancelar",--}%
%{--                                        className : "btn-primary",--}%
%{--                                        callback  : function () {--}%
%{--                                        }--}%
%{--                                    },--}%
%{--                                    guardar : {--}%
%{--                                        label     : "Guardar",--}%
%{--                                        className : "btn-success",--}%
%{--                                        callback  : function () {--}%
%{--                                            guardarValor();--}%
%{--                                        }--}%
%{--                                    }--}%
%{--                                }--}%
%{--                            });--}%
%{--                        }--}%
%{--                    });--}%
%{--                }--}%
%{--            }--}%
%{--        },--}%
%{--        onShow : function ($element) {--}%
%{--            $element.addClass("trHighlight");--}%
%{--        },--}%
%{--        onHide : function ($element) {--}%
%{--            $(".trHighlight").removeClass("trHighlight");--}%
%{--        }--}%
%{--    });--}%

</script>