
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title>Búsqueda de Trámites Anulados</title>

    <style type="text/css">

    .container-celdas {
        width    : 1070px;
        height   : 310px;
        float    : left;
        overflow : auto;
    }

    .alinear {
        text-align : center !important;
    }

    </style>
</head>

<body>

<div style="margin-top: 0px;" class="vertical-container">

    <p class="css-vertical-text" style="margin-top: -10px;">Buscar</p>

    <div class="linea"></div>

    <div style="margin-bottom: 20px">
        <div class="col-md-2">
            <label>Documento</label>
            <g:textField name="memorando" maxlength="15" class="form-control allCaps"/>
        </div>

        <div class="col-md-2">
            <label>Asunto</label>
            <g:textField name="asunto" style="width: 300px" maxlength="30" class="form-control"/>
        </div>

        <div class="col-md-2" style="margin-left: 150px">
            <label>Anulados Desde</label>
            <input name="fechaRecepcion" id='datetimepicker1' type='text' class="form-control"/>
        </div>


        <div class="col-md-2" style="margin-left: 15px">
            <label>Anulados Hasta</label>
            <input name="fechaBusqueda" id='datetimepicker2' type='text' class="form-control"/>
        </div>


        <div style="padding-top: 25px">
            <a href="#" name="busqueda" class="btn btn-success btnBusqueda btn-ajax"><i
                    class="fa fa-search"></i> Buscar</a>

            <a href="#" name="borrar" class="btn btn-warning btnBorrar"><i
                    class="fa fa-eraser"></i> Limpiar</a>

        </div>

    </div>

</div>

<div style="margin-top: 30px; min-height: 510px" class="vertical-container" id="divBandeja">

    <p class="css-vertical-text">Resultado - Buscar Trámites Anulados</p>

    <div class="linea"></div>

    <div id="bandeja">

    </div>

</div>

<div><strong>Nota</strong>: Si existen muchos registros que coinciden con el criterio de búsqueda, se retorna como máximo 20
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

    $(function () {
        var cellWidth = 150;
        var celHegth = 25;
        var select = null;
        var headerTop = $(".header-columnas");

        $(".h-A").resizable({
            handles    : "e",
            minWidth   : 30,
            alsoResize : ".A"
        });
        $(".container-celdas").scroll(function () {
            $("#container-cols").scrollLeft($(".container-celdas").scrollLeft());
        });

    });

    $(function () {
        $('#datetimepicker1, #datetimepicker2').datetimepicker({
            locale: 'es',
            format: 'DD-MM-YYYY',
            // daysOfWeekDisabled: [0, 6],
            // inline: true,
            // sideBySide: true,
            showClose: true,
            icons: {
                close: 'closeText'
            }
        });
    });

    function loading(div) {
        y = 0;
        $("#" + div).html("<div class='tituloChevere' id='loading'>Cargando, Espere por favor</div>")
        var interval = setInterval(function () {
            if (y == 30) {
                $("#detalle").html("<div class='tituloChevere' id='loading'>Cargando, Espere por favor</div>")
                y = 0
            }
            $("#loading").append(".");
            y++
        }, 500);
        return interval
    }

    $(".btnBusqueda").click(function () {
        buscar();
    });

    $("input").keyup(function (ev) {
        if (ev.keyCode == 13) {
            buscar();
        }
    });

    function buscar(){
        $("#bandeja").html("").append($("<div style='width:100%; text-align: center;'/>").append(spinnerSquare64));
        var memorando = $("#memorando").val();
        var asunto = $("#asunto").val();
        var fecha = $("#datetimepicker2").val();
        var fechaRecepcion = $("#datetimepicker1").val();

        var datos = "memorando=" + memorando + "&asunto=" + asunto + "&fechaHasta=" + fecha + "&fechaDesde=" + fechaRecepcion

        $.ajax({
            type    : "POST",
            url     : "${g.createLink(controller: 'buscarTramite', action: 'tablaBusquedaAnulados')}",
            data    : datos,
            success : function (msg) {
                $("#bandeja").html(msg);
            }
        });
    }

    var padre;

    function createContextMenu(node) {
        var $tr = $(node);

        var items = {
            header : {
                label  : "Sin Acciones",
                header : true
            }
        };

        var id = $tr.data("id");
        var codigo = $tr.attr("codigo");
        var estado = $tr.attr("estado");
        var padre = $tr.attr("padre");
        var de = $tr.attr("de");
        var archivo = $tr.attr("departamento") + "/" + $tr.attr("anio") + "/" + $tr.attr("codigo");
        var idPxt = $tr.attr("prtr");
        var valAnexo = $tr.attr("anexo");

        var porRecibir = $tr.hasClass("porRecibir");
        var sinRecepcion = $tr.hasClass("sinRecepcion");
        var recibido = $tr.hasClass("recibido");
        var retrasado = $tr.hasClass("retrasado");
        var conAnexo = $tr.hasClass("conAnexo");
        var conPadre = $tr.hasClass("padre");

        var tieneAlerta = $tr.hasClass("alerta");
        var enviado = $tr.hasClass("estado");

        var arbol = {
            label  : 'Cadena del trámite',
            icon   : "fa fa-sitemap",
            action : function (e) {
                location.href = '${createLink(controller: 'tramite3', action: 'arbolTramite')}/' + id + "?b=bqe"
            }
        };

        var detalles = {
            label  : 'Detalles',
            icon   : "fa fa-search",
            action : function (e) {
                $.ajax({
                    type    : 'POST',
                    url     : '${createLink(controller: 'tramite3', action: 'detalles')}',
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        $("#dialog-body").html(msg)
                    }
                });
                $("#dialog").modal("show")
            }
        };

        items.header.label = "Acciones";
        <g:if test="${session.usuario.getPuedeVer()}">
        items.detalles = detalles;
        items.arbol = arbol;
        </g:if>

        return items
    }

    $(".btnBorrar").click(function () {
        $("#memorando").val("");
        $("#asunto").val("");
        $("#datetimepicker1").val('');
        $("#datetimepicker2").val('');
        buscar();
    });

</script>
</body>
</html>