<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 04/10/21
  Time: 11:53
--%>


<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title>Empresa</title>
</head>
<body>

<elm:flashMessage tipo="${flash.tipo}" clase="${flash.clase}">${flash.message}</elm:flashMessage>

<!-- botones -->
<div class="btn-toolbar toolbar" style="margin-top: 10px">
    <div class="btn-group">
        <g:link class="btn btn-default col-md-2" style="width: 100px;" controller="inicio" action="parametros"><i class="fa fa-arrow-left"></i> Parámetros</g:link>
        <g:link action="form" class="btn btn-info btnCrear">
            <i class="fa fa-file"></i> Nueva empresa
        </g:link>
    </div>
</div>

<table class="table table-condensed table-bordered">
    <thead>
    <tr>
        <th>RUC</th>
        <th>Nombre</th>
        <th>Sigla</th>
        <th>Email</th>
        <th>Teléfono</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${empresas}" status="i" var="empresa">
        <tr data-id="${empresa.id}">
            <td>${empresa?.ruc}</td>
            <td>${empresa?.nombre}</td>
            <td>${empresa?.sigla}</td>
            <td>${empresa?.email}</td>
            <td>${empresa?.telefono}</td>
        </tr>
    </g:each>
    </tbody>
</table>

<elm:pagination total="${empresaInstanceCount}" params="${params}"/>

<script type="text/javascript">

    var id = null;
    function submitForm() {
        var $form = $("#frmEmpresa");
        if ($form.valid()) {
            var r = cargarLoader("Grabando");
            $.ajax({
                type    : "POST",
                url     : '${createLink(action:'save_ajax')}',
                data    : $form.serialize(),
                success : function (msg) {
                    r.modal("hide");
                    var parts =  msg.split("_");
                    if(parts[0] == 'ok'){
                        log("Empresa guardada correctamente","success");
                        setTimeout(function () {
                            location.reload(true)
                        }, 1000);
                    }else{
                        if(parts[0] == 'er'){
                            bootbox.alert("<i class='fa fa-exclamation-triangle fa-2x text-danger'></i> El número de RUC ya se encuentra ingresado")
                        }else{
                            log("Error al guardar la empresa", "error")
                        }
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
            message : "<i class='fa fa-trash fa-3x pull-left text-danger text-shadow'></i><p>¿Está seguro que desea eliminar la empresa seleccionada? Esta acción no se puede deshacer.</p>",
            buttons : {
                cancelar : {
                    label     : "Cancelar",
                    className : "btn-primary",
                    callback  : function () {
                    }
                },
                eliminar : {
                    label     : "<i class='fa fa-trash'></i> Eliminar",
                    className : "btn-danger",
                    callback  : function () {
                        var v = cargarLoader("Eliminando...");
                        $.ajax({
                            type    : "POST",
                            url     : '${createLink(action:'delete_ajax')}',
                            data    : {
                                id : itemId
                            },
                            success : function (msg) {
                                v.modal("hide");
                                if(msg == 'ok'){
                                    log("Empresa borrada correctamente","success");
                                    setTimeout(function () {
                                        location.reload(true)
                                    }, 1000);
                                }else{
                                    log("Error al borrar la empresa","error")
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
        var data = id ? { id: id } : {};
        $.ajax({
            type    : "POST",
            url     : "${createLink(action:'form_ajax')}",
            data    : data,
            success : function (msg) {
                var b = bootbox.dialog({
                    id      : "dlgCreateEdit",
                    title   : title + " Empresa",
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


    function inicializarArbol(id){
        $.ajax({
            type: 'POST',
            url: '${createLink(controller: 'empresa', action: 'verificarArbol_ajax')}',
            data:{
                id: id
            },
            success: function (msg) {
                if(msg == 'no'){
                    bootbox.alert("<i class='fa fa-exclamation-circle fa-2x text-warning'></i> El árbol de estructura departamental ya se encuentra inicializado")
                }else{
                    createEditRowDpto(null, "Crear", id)
                }

            }
        })
    }

    function createEditRowDpto(id, tipo, empresa) {
        var data = tipo == "Crear" ? {padre : id, bb: 1, empresa: empresa} : {id : id, bb: 1, empresa: empresa};
        var c =  cargarLoader("Cargando...");
        $.ajax({
            type    : "POST",
            url     : "${createLink(controller: 'departamento', action:'form_ajax')}",
            data    : data,
            success : function (msg) {
                c.modal('hide');
                var b = bootbox.dialog({
                    id      : "dlgCreateEdit",
                    title   : tipo + " Departamento Inicial",
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
                                return submitFormDpto();
                            } //callback
                        } //guardar
                    } //buttons
                }); //dialog
                setTimeout(function () {
                    var $input = b.find(".form-control").not(".datepicker").first();
                    var val = $input.val();
                    $input.focus();
                    $input.val("");
                    $input.val(val);
                }, 500);
            } //success
        }); //ajax
    } //createEdit

    function submitFormDpto() {
        var $form = $("#frmDepartamento");
        var $btn = $("#dlgCreateEdit").find("#btnSave");
        if ($form.valid()) {
            var cl2 = cargarLoader("Guardando...");
            $btn.replaceWith(spinner);
            $.ajax({
                type    : "POST",
                url     : $form.attr("action"),
                data    : $form.serialize(),
                success : function (msg) {
                    cl2.modal("hide");
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


    $(function () {

        $(".btnCrear").click(function() {
            createEditRow();
            return false;
        });

        $("tbody tr").contextMenu({
            items  : {
                header   : {
                    label  : "Acciones",
                    header : true
                },
                ver      : {
                    label  : "Ver",
                    icon   : "fa fa-search",
                    action : function ($element) {
                        var id = $element.data("id");
                        $.ajax({
                            type    : "POST",
                            url     : "${createLink(controller: 'empresa', action:'show_ajax')}",
                            data    : {
                                id : id
                            },
                            success : function (msg) {
                                bootbox.dialog({
                                    title   : "Empresa",
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
                },
                editar   : {
                    label  : "Editar",
                    icon   : "fa fa-edit",
                    action : function ($element) {
                        var id = $element.data("id");
                        createEditRow(id);
                    }
                },
                admin : {
                    label            : "Administradores",
                    icon             : "fa fa-user",
                    separator_before : true,
                    action           : function ($element) {
                        var id = $element.data("id");
                        location.href="${createLink(controller: 'empresa', action: 'administradores')}/" + id;
                    }
                },
                dpto : {
                    label            : "Inicializar árbol",
                    icon             : "fa fa-tree",
                    separator_before : true,
                    action           : function ($element) {
                        var id = $element.data("id");
                        inicializarArbol(id);
                    }
                },
                eliminar : {
                    label            : "Eliminar",
                    icon             : "fa fa-trash",
                    separator_before : true,
                    action           : function ($element) {
                        var id = $element.data("id");
                        deleteRow(id);
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
    });
</script>

</body>
</html>
