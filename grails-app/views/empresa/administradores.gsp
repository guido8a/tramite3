<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 07/10/21
  Time: 11:11
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
    <div class="btn-group">
        <g:link class="btn btn-default" controller="empresa" action="list"><i class="fa fa-arrow-left"></i> Regresar</g:link>
    </div>
    <div class="btn-group">
        <g:link action="form" class="btn btn-info btnCrear">
            <i class="fa fa-file"></i> Nueva persona
        </g:link>
    </div>
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
    <div class="col-md-2 hidden">
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

    $(".btnCrear").click(function () {
        createEditRow(null, "persona");
        return false;
    });

    $("#btnLimpiar").click(function () {
        $("#texto").val('');
        $("#tipo").val(0);
        $("#perfil").val(0);
        $("#estado").val(0);
        // cargarTablaUsuarios($("#tipo").val(0), $("#texto").val(''), $("#perfil").val(0), $("#estado").val(0));
    });

    $("#btnBuscar").click(function () {
        cargarTablaUsuarios($("#tipo option:selected").val(), $("#texto").val(), $("#perfil option:selected").val(), $("#estado option:selected").val());
    });

    cargarTablaUsuarios($("#tipo option:selected").val(), $("#texto").val(), $("#perfil option:selected").val(), $("#estado option:selected").val());

    function cargarTablaUsuarios(tipo, texto, perfil, estado){
        var a = cargarLoader("Cargando...");
        $.ajax({
            type:'POST',
            url:'${createLink(controller: 'empresa', action: 'tablaUsuarios_ajax')}',
            data:{
                tipo: tipo,
                texto: texto,
                perfil: perfil,
                estado:estado,
                empresa: '${empresa?.id}'
            },
            success: function(msg){
                a.modal("hide");
                $("#divNumeros").html(msg)
            }
        })
    }


    function createContextMenu(node) {
        var $tr = $(node);

        var items = {
            header : {
                label  : "Acciones",
                header : true
            }
        };

        var id = $tr.data("id");

        var estaActivo = $tr.hasClass("activo");
        var estaInactivo = $tr.hasClass("inactivo");

        var puedeEliminar = $tr.hasClass("eliminar");
        puedeEliminar = true;

        var ver = {
            label  : 'Ver',
            icon   : "fa fa-search",
            action : function () {
                $.ajax({
                    type    : "POST",
                    url     : "${createLink(controller: 'persona', action:'show_ajax')}",
                    data    : {
                        id : id
                    },
                    success : function (msg) {
                        bootbox.dialog({
                            title   : "Ver Persona",
                            message : msg,
                            buttons : {
                                ok : {
                                    label     : "Aceptar",
                                    className : "btn-primary",
                                    callback  : function () {
                                    }
                                }
                            }
                        });
                    }
                });
            }
        };

        var editar = {
            label           : 'Editar',
            icon            : "fa fa-edit",
            separator_after : true,
            action          : function (e) {
                createEditRow(id, "persona");
            }
        };

        var config = {
            label           : 'Perfiles',
            icon            : "fa fa-cogs",
            separator_after : true,
            url             : "${createLink(controller: 'empresa', action: 'perfiles')}?id=" + id + "&empresa=" + '${empresa?.id}'
        };

        var eliminar = {
            label            : 'Eliminar',
            icon             : "fa fa-trash",
            separator_before : true,
            action           : function (e) {
                deleteRow(id);
            }
        };

        items.ver = ver;
        items.editar = editar;
        if (estaActivo) {
            items.config = config;
        }

        if (puedeEliminar) {
            items.eliminar = eliminar;
        }

        return items;
    }

    function deleteRow(itemId) {
        bootbox.dialog({
            title   : "Alerta - Está a punto de Eliminar una Persona del Sistema",
            message : "<i class='fa fa-trash fa-3x pull-left text-danger text-shadow'></i>" +
                "<p>¿Está seguro que desea eliminar a la Persona seleccionada? Esta acción no se puede deshacer.</p>",
            buttons : {
                cancelar : {
                    label     : "Cancelar",
                    className : "btn-primary",
                    callback  : function () {
                    }
                },
                eliminar : {
                    label     : "<i class='fa fa-trash'></i> Eliminar Persona",
                    className : "btn-danger",
                    callback  : function () {
                        openLoader("Eliminando");
                        $.ajax({
                            type    : "POST",
                            url     : '${createLink(controller: 'persona', action:'delete_ajax')}',
                            data    : {
                                id : itemId
                            },
                            success : function (msg) {
                                var parts = msg.split("_");
                                log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                                if (parts[0] == "OK") {
                                    location.reload(true);
                                } else {
                                    closeLoader();
                                }
                            }
                        });
                    }
                }
            }
        });
    }

    function createEditRow(id, tipo) {
        var title = id ? "Editar " : "Crear ";
        var data = id ? {id : id} : {};
        var url = "${createLink(controller: 'persona', action:'form_ajax')}";

        $.ajax({
            type    : "POST",
            url     : url,
            data    : data,
            success : function (msg) {
                var b = bootbox.dialog({
                    id      : "dlgCreateEdit",
                    class   : "long",
                    title   : title + tipo,
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
                                return submitForm(id);
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

    function submitForm(id) {
        var $form = $("#frmPersona");
        var $btn = $("#dlgCreateEdit").find("#btnSave");
        var idPersona = id
        if ($form.valid()) {
            $btn.replaceWith(spinner);
            openLoader("Grabando");
            $.ajax({
                type    : "POST",
                url     : '${createLink(controller: 'persona', action:'save_ajax')}',
                data    : $form.serialize(),
                success : function (msg) {
                    var parts = msg.split("_");
                    if (parts[0] != "INFO") {
                        log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                        if (parts[0] == "OK") {
                            location.reload(true);
                        } else {
                            spinner.replaceWith($btn);
                            return false;
                        }
                    } else {
                        closeLoader();
                        bootbox.dialog({
                            title   : "Alerta",
                            message : "<i class='fa fa-warning fa-3x pull-left text-warning text-shadow'></i>" + parts[1],
                            buttons : {
                                cancelar : {
                                    label     : "Cancelar",
                                    className : "btn-primary",
                                    callback  : function () {
                                    }
                                },
                                aceptar  : {
                                    label     : "<i class='fa fa-thumbs-o-up '></i> Continuar",
                                    className : "btn-success",
                                    callback  : function () {
                                        var $sel = $("#selWarning");
                                        var resp = $sel.val();
                                        var dpto = $sel.data("dpto");
                                        if (resp == 1 || resp == "1") {
                                            openLoader("Cambiando");
                                            $.ajax({
                                                type    : "POST",
                                                url     : '${createLink(action:'cambioDpto_ajax')}',
                                                data    : {
                                                    id   : idPersona,
                                                    dpto : dpto
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
                            }
                        });
                    }
                }
            });
        } else {
            return false;
        } //else
    }


</script>

</body>
</html>
