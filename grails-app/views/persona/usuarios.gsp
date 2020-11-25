<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 25/11/20
  Time: 9:19
--%>

<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title>Usuarios</title>
</head>

<body>

<elm:flashMessage tipo="${flash.tipo}" clase="${flash.clase}">${flash.message}</elm:flashMessage>

<!-- botones -->
<div class="btn-toolbar toolbar" style="margin-top: 5px">
    <g:if test="${parametros[0]?.validaLDAP == 0}">
        <div class="btn-group">
            <g:link action="form" class="btn btn-info btnCrear">
                <i class="fa fa-file"></i> Nueva persona
            </g:link>
        </div>
    </g:if>
</div>

<div class="btn-toolbar toolbar">
    <div class="col-md-2">
        <label>Buscar por</label>
        <g:select name="tipo" from="${[0: 'Usuario', 1 : 'Nombre', 2: 'Apellido', 3: 'Departamento']}" class="form-control" optionKey="key" optionValue="value"/>
    </div>
    <div class="col-md-3">
        <label>Criterio</label>
        <g:textField name="texto" class="form-control" placeholder="Buscar..."/>
    </div>
    <div class="col-md-3">
        <label>Perfil</label>
        <g:select name="perfil" from="${seguridad.Prfl.list([sort: 'nombre'])}" optionKey="descripcion" optionValue="descripcion"
                  class="form-control input-sm" noSelection="[0: 'Todos']" />
    </div>
    <div class="col-md-2">
        <label>Estado</label>
        <g:select name="estado" from="${[0: 'Todos', 1: 'Activo', 2 : 'Inactivo']}" optionKey="key" optionValue="value" class="form-control input-sm"/>
    </div>

    <div class="col-md-2" style="margin-top: 20px">
        <div class="btn-group">
            <a href="#" class="btn btn-success" id="btnBuscar"><i class="fa fa-search" title="Buscar"></i> Buscar </a>
            <a href="#" class="btn btn-warning" id="btnLimpiar"><i class="fa fa-eraser" title="Limpiar búsqueda"></i> </a>
        </div>
    </div>
</div>

<table class="table table-condensed table-bordered">
    <thead>
    <tr style="width: 100%">
        <th style="width: 10%">Usuario</th>
        <th style="width: 25%">Nombre</th>
        <th style="width: 25%">Apellido</th>
        <th style="width: 25%">Departamento</th>
        <th style="width: 15%">Perfiles</th>
    </tr>
    </thead>
</table>

<div id="divNumeros">

</div>


<script type="text/javascript">

    $("#btnLimpiar").click(function () {
        // $("#texto").val('');
        // $("#tipo").val(0);
        // cargarTablaDepartamentos($("#tipo option:selected").val(), $("#texto").val());
    });

    $("#btnBuscar").click(function () {
        cargarTablaUsuarios($("#tipo option:selected").val(), $("#texto").val(), $("#perfil option:selected").val(), $("#estado option:selected").val());
    });

    cargarTablaUsuarios($("#tipo option:selected").val(), $("#texto").val(), $("#perfil option:selected").val(), $("#estado option:selected").val());

    function cargarTablaUsuarios(tipo, texto, perfil, estado){
        var a = cargarLoader("Cargando...");
        $.ajax({
            type:'POST',
            url:'${createLink(controller: 'persona', action: 'tablaUsuarios_ajax')}',
            data:{
                tipo: tipo,
                texto: texto,
                perfil: perfil,
                estado:estado
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

</script>

</body>
</html>
