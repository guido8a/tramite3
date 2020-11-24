<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title>Numeración</title>
</head>

<body>

<elm:flashMessage tipo="${flash.tipo}" clase="${flash.clase}">${flash.message}</elm:flashMessage>

<!-- botones -->
<div class="btn-toolbar toolbar">
    <div class="btn-group">
        <g:link class="btn btn-default col-md-2" style="width: 100px;" controller="inicio" action="parametros"><i class="fa fa-arrow-left"></i> Parámetros</g:link>
    </div>
</div>

<div class="btn-toolbar toolbar">
    <div class="col-md-1">
        <label>Buscar por:</label>
    </div>
    <div class="col-md-3">
        <g:select name="tipo" from="${[0: 'Código', 1 : 'Nombre']}" class="form-control" optionKey="key" optionValue="value"/>
    </div>
    <div class="col-md-3">
        <g:textField name="texto" class="form-control" />
    </div>
    <div class="col-md-3">
        <div class="btn-group">
            <a href="#" class="btn btn-success" id="btnBuscar"><i class="fa fa-search" title="Buscar"></i> Buscar </a>
            <a href="#" class="btn btn-warning" id="btnLimpiar"><i class="fa fa-eraser" title="Limpiar búsqueda"></i> </a>
        </div>
    </div>
</div>

<table class="table table-condensed table-bordered">
    <thead>
    <tr style="width: 100%">
        <th style="width: 25%">Código</th>
        <th style="width: 75%">Departamento</th>
    </tr>
    </thead>
</table>

<div id="divNumeros">

</div>


<script type="text/javascript">

    $("#btnLimpiar").click(function () {
        $("#texto").val('');
        $("#tipo").val(0);
        cargarTablaDepartamentos($("#tipo option:selected").val(), $("#texto").val());
    });

    $("#btnBuscar").click(function () {
        cargarTablaDepartamentos($("#tipo option:selected").val(), $("#texto").val());
    });

    cargarTablaDepartamentos($("#tipo option:selected").val(), $("#texto").val());

    function cargarTablaDepartamentos(tipo, texto){
        var a = cargarLoader("Cargando...");
        $.ajax({
            type:'POST',
            url:'${createLink(controller: 'numero', action: 'tablaDepartamentos_ajax')}',
            data:{
                tipo: tipo,
                texto: texto
            },
            success: function(msg){
                a.modal("hide");
                $("#divNumeros").html(msg)
            }
        })
    }

    var id = null;
    function submitForm() {
        var $form = $("#frmNumero");
        var $btn = $("#dlgCreateEdit").find("#btnSave");
        if ($form.valid()) {
            $btn.replaceWith(spinner);
            openLoader("Grabando");
            $.ajax({
                type    : "POST",
                url     : '${createLink(action:'save_ajax')}',
                data    : $form.serialize(),
                success : function (msg) {
                    var parts = msg.split("_");
                    log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                    if (parts[0] == "OK") {
                        location.reload(true);
                    } else {
                        spinner.replaceWith($btn);
                        return false;
                    }
                }
            });
        } else {
            return false;
        } //else
    }
    function deleteRow(itemId) {
        bootbox.dialog({
            title   : "Alerta",
            message : "<i class='fa fa-trash-o fa-3x pull-left text-danger text-shadow'></i><p>¿Está seguro que desea eliminar el Numero seleccionado? Esta acción no se puede deshacer.</p>",
            buttons : {
                cancelar : {
                    label     : "Cancelar",
                    className : "btn-primary",
                    callback  : function () {
                    }
                },
                eliminar : {
                    label     : "<i class='fa fa-trash-o'></i> Eliminar",
                    className : "btn-danger",
                    callback  : function () {
                        openLoader("Eliminando");
                        $.ajax({
                            type    : "POST",
                            url     : '${createLink(action:'delete_ajax')}',
                            data    : {
                                id : itemId
                            },
                            success : function (msg) {
                                var parts = msg.split("_");
                                log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                                if (parts[0] == "OK") {
                                    location.reload(true);
                                }
                            }
                        });
                    }
                }
            }
        });
    }
    function createEditRow(id) {
        var title = id ? "Editar" : "Crear";
        var data = id ? { id : id } : {};
        $.ajax({
            type    : "POST",
            url     : "${createLink(action:'form_ajax')}",
            data    : data,
            success : function (msg) {
                var b = bootbox.dialog({
                    id      : "dlgCreateEdit",
                    title   : title + " Numero",
                    message : msg,
                    buttons : {
                        cancelar : {
                            label     : "Cancelar",
                            className : "btn-primary",
                            callback  : function () {
                            }
                        },
                        guardar  : {
                            id        : "btnSave",
                            label     : "<i class='fa fa-save'></i> Guardar",
                            className : "btn-success",
                            callback  : function () {
                                return submitForm();
                            } //callback
                        } //guardar
                    } //buttons
                }); //dialog
                setTimeout(function () {
                    b.find(".form-control").not(".datepicker").first().focus()
                }, 500);
            } //success
        }); //ajax
    } //createEdit

    %{--$(function () {--}%

    %{--    $(".btnCrear").click(function () {--}%
    %{--        createEditRow();--}%
    %{--        return false;--}%
    %{--    });--}%

    %{--    $("tr").contextMenu({--}%
    %{--        items  : {--}%
    %{--            header   : {--}%
    %{--                label  : "Acciones",--}%
    %{--                header : true--}%
    %{--            },--}%
    %{--            ver      : {--}%
    %{--                label  : "Ver",--}%
    %{--                icon   : "fa fa-search",--}%
    %{--                action : function ($element) {--}%
    %{--                    var id = $element.data("id");--}%
    %{--                    $.ajax({--}%
    %{--                        type    : "POST",--}%
    %{--                        url     : "${createLink(action:'show_ajax')}",--}%
    %{--                        data    : {--}%
    %{--                            id : id--}%
    %{--                        },--}%
    %{--                        success : function (msg) {--}%
    %{--                            bootbox.dialog({--}%
    %{--                                title   : "Ver Número",--}%
    %{--                                message : msg,--}%
    %{--                                buttons : {--}%
    %{--                                    ok : {--}%
    %{--                                        label     : "Aceptar",--}%
    %{--                                        className : "btn-primary",--}%
    %{--                                        callback  : function () {--}%
    %{--                                        }--}%
    %{--                                    }--}%
    %{--                                }--}%
    %{--                            });--}%
    %{--                        }--}%
    %{--                    });--}%
    %{--                }--}%
    %{--            },--}%
    %{--            editar   : {--}%
    %{--                label  : "Editar",--}%
    %{--                icon   : "fa fa-pencil",--}%
    %{--                action : function ($element) {--}%
    %{--                    var id = $element.data("id");--}%
    %{--                    createEditRow(id);--}%
    %{--                }--}%
    %{--            },--}%
    %{--            eliminar : {--}%
    %{--                label            : "Eliminar",--}%
    %{--                icon             : "fa fa-trash-o",--}%
    %{--                separator_before : true,--}%
    %{--                action           : function ($element) {--}%
    %{--                    var id = $element.data("id");--}%
    %{--                    deleteRow(id);--}%
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
    %{--});--}%
</script>

</body>
</html>
