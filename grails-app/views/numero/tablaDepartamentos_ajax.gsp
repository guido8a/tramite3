<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 23/11/20
  Time: 15:01
--%>

<div style="width: 100%;height: 300px;overflow: auto; margin-top: -10px;margin-bottom: 20px;">
    <table class="table table-condensed table-bordered">
        <tbody>
        <g:each in="${departamentos}" var="departamento">
            <tr style="width: 100%">
                <td style="width: 25%">${departamento.dptocdgo}</td>
                <td style="width: 75%">${departamento.dptodscr}</td>
            </tr>
        </g:each>
        </tbody>
    </table>
</div>

<script type="text/javascript">

    $("tr").contextMenu({
        items  : {
            header   : {
                label  : "Acciones",
                header : true
            },
            ver      : {
                label  : "Numeración",
                icon   : "fa fa-search",
                action : function ($element) {
                    var id = $element.data("id");
                    $.ajax({
                        type    : "POST",
                        url     : "${createLink(controller: 'numero', action:'numeracion_ajax')}",
                        data    : {
                            id : id
                        },
                        success : function (msg) {
                            bootbox.dialog({
                                title   : "Numeración por tipo de trámite",
                                message : msg,
                                buttons : {
                                    cancelar : {
                                        label     : "Cancelar",
                                        className : "btn-primary",
                                        callback  : function () {
                                        }
                                    },
                                    guardar : {
                                        label     : "Guardar",
                                        className : "btn-success",
                                        callback  : function () {
                                        }
                                    }
                                }
                            });
                        }
                    });
                }
            }
        },
        onShow : function ($element) {
            $element.addClass("trHighlight");
        },
        onHide : function ($element) {
            $(".trHighlight").removeClass("trHighlight");
        }
    });

</script>