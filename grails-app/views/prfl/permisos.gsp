<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="main"/>
    <title>Permisos de trámites</title>
</head>

<body>

<elm:flashMessage tipo="${flash.tipo}" clase="${flash.clase}">${flash.message}</elm:flashMessage>

<div class="btn-toolbar toolbar">
    <div class="btn-group">
        <g:link action="form" class="btn btn-azul btnCrear">
            <i class="fa fa-pencil-square-o"></i> Crear perfil
        </g:link>
        <a href="#" class="btn btn-primary btnEdit">
            <i class="fa fa-camera-retro fa-lg"></i> Editar perfil
        </a>
        <a href="#" class="btn btn-primary btnDelete">
            <i class="fa fa-trash-o"></i> Eliminar perfil
        </a>
    </div>

    <span style="font-size: 10pt; color: black; margin-left: 160px;">Seleccione un Perfil
    <g:select optionKey="id" from="${seguridad.Prfl.list()}" name="perfil" value="${prflInstace?.id}"
              style="width: 180px;"/>
    </span>

</div>

<div id="tipo" class="alert ">

<div class="" id="parm">
    <g:form action="registro" method="post">
        <input type="hidden" id="prfl__id" name="id" value="${prflInstance?.id}"/>

            <div class="alert alert-info modulo" style="text-align: center; width: 900px">
                <strong>Permisos:</strong>
                Gestionar los permisos de acceso en el sistema
            </div>
    </g:form>
    <div id="ajx" style="width:900px; padding-left: 20px;"></div>

</div>

<div id="datosPerfil" class="container entero  ui-corner-bottom">
</div>


<script type="text/javascript">
    function submitForm(tipo) {
        var $form = $("#frm");
        var $btn = $("#dlgCreateEdit").find("#btnSave");
        var url = "";
        switch (tipo) {
            case "perfil":
                url = '${createLink(controller: 'prfl', action:'save_ajax')}';
                break;
            case "modulo":
                url = '${createLink(controller: 'modulo', action:'save_ajax')}';
                break;
        }
        if ($form.valid()) {
            $btn.replaceWith(spinner);
            $.ajax({
                type: "POST",
                url: url,
                data: $form.serialize(),
                success: function (msg) {
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
    } //submit form
    function deleteRow(itemId, tipo) {
        var url = "", str = "";
        switch (tipo) {
            case "perfil":
                url = '${createLink(controller: 'prfl', action:'delete_ajax')}';
                str = "perfil";
                break;
            case "modulo":
                url = '${createLink(controller: 'modulo', action:'delete_ajax')}';
                str = "módulo";
                break;
        }
        bootbox.dialog({
            title: "Alerta",
            message: "<i class='fa fa-trash-o fa-3x pull-left text-danger text-shadow'></i><p>¿Está seguro que desea eliminar el " + str + " seleccionado? Esta acción no se puede deshacer.</p>",
            buttons: {
                cancelar: {
                    label: "Cancelar",
                    className: "btn-primary",
                    callback: function () {
                    }
                },
                eliminar: {
                    label: "<i class='fa fa-trash-o'></i> Eliminar",
                    className: "btn-danger",
                    callback: function () {
                        $.ajax({
                            type: "POST",
                            url: url,
                            data: {
                                id: itemId
                            },
                            success: function (msg) {
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
    function createEditRow(id, tipo) {
        var title = id ? "Editar" : "Crear";
        var data = id ? { id: id } : {};
        var url = "", str = "";
        switch (tipo) {
            case "perfil":
                url = '${createLink(controller: 'prfl', action:'form_ajax')}';
                title += " perfil";
                break;
            case "modulo":
                url = '${createLink(controller: 'modulo', action:'form_ajax')}';
                title += " módulo";
                break;
        }
        $.ajax({
            type: "POST",
            url: url,
            data: data,
            success: function (msg) {
                var b = bootbox.dialog({
                    id: "dlgCreateEdit",
                    title: title,
                    message: msg,
                    buttons: {
                        cancelar: {
                            label: "Cancelar",
                            className: "btn-primary",
                            callback: function () {
                            }
                        },
                        guardar: {
                            id: "btnSave",
                            label: "<i class='fa fa-save'></i> Guardar",
                            className: "btn-success",
                            callback: function () {
                                return submitForm(tipo);
                            } //callback
                        } //guardar
                    } //buttons
                }); //dialog
                setTimeout(function () {
                    b.find(".form-control").first().focus()
                }, 500);
            } //success
        }); //ajax
    } //createEdit

    $(function () {
        $( document ).ready(function() {
            $(".modulo").click();
        });

        $(".btnCrear").click(function () {
            createEditRow(null, "perfil");
            return false;
        });
        $(".btnEdit").click(function () {
            createEditRow($("#perfil").val(), "perfil");
            return false;
        });
        $(".btnDelete").click(function () {
            deleteRow($("#perfil").val(), "perfil");
            return false;
        });
        $(".btnCrearMdlo").click(function () {
            createEditRow(null, "modulo");
            return false;
        });
        $(".btnEditMdlo").click(function () {
            createEditRow($(".modulo.active").find("input").val(), "modulo");
            return false;
        });
        $(".btnDeleteMdlo").click(function () {
            deleteRow($(".modulo.active").find("input").val(), "modulo");
            return false;
        });

        $("#perfil").change(function () {
                    $(".modulo").click();
                }
        )

        $(".modulo").click(function () {
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    url: "${createLink(action: 'ajaxPermisoTramite')}",
                    data: {
                        ids: $(".modulo.active").find("input").val(),
                        prfl: $('#perfil').val(),
                        tpac: $(".tipo.active").find("input").val()
                    },
                    success: function (msg) {
                        $("#ajx").html(msg)
                    }
                });
            }, 1);
        });
    });
</script>

</body>
</html>