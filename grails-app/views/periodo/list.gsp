<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 22/10/20
  Time: 16:49
--%>

<html>
<head>
    <meta name="layout" content="main">
    <title>Períodos</title>
</head>

<div class="panel panel-primary col-md-6">
    <h3>Períodos</h3>
    <div class="panel-info" style="padding: 3px; margin-top: 2px">
        <div class="btn-toolbar toolbar">
            <div class="btn-group">
                <a href="#" class="btn btn-sm btn-success" id="btnAgregarPeriodo">
                    <i class="fa fa-plus"></i> Agregar período
                </a>
            </div>
        </div>
    </div>
    <div class="alert-warning" style="text-align: center; font-size: 14px; font-weight: bold">
        * Haga clic derecho sobre un registro para desplegar su menú de opciones
    </div>
    <div id="tablaPeriodos"></div>
</div>

<script type="text/javascript">
    cargarTablaPeriodos();

    $("#btnAgregarPeriodo").click(function () {
        createEditPeriodo();
    });

    function cargarTablaPeriodos(){
        $.ajax({
            type: 'POST',
            url:'${createLink(controller: 'periodo', action: 'tablaPeriodos_ajax')}',
            data:{

            },
            success: function(msg){
                $("#tablaPeriodos").html(msg)
            }
        });
    }

    function createEditPeriodo(id) {
        var title = id ? "Editar" : "Crear";
        var data = id ? {id : id} : {};
        $.ajax({
            type    : "POST",
            url     : "${createLink(controller:'periodo', action:'formPeriodo_ajax')}",
            data    : data,
            success : function (msg) {
                var b = bootbox.dialog({
                    id      : "dlgCreateEdit",
                    title   : title + " Período",
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
                                return submitFormPeriodo();
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

    function submitFormPeriodo() {
        var $form = $("#frmPeriodo");
        var $btn = $("#dlgCreateEdit").find("#btnSave");
        if ($form.valid()) {
            var data = $form.serialize();
            $btn.replaceWith(spinner);
            var dialog = cargarLoader("Guardando...");
            $.ajax({
                type    : "POST",
                url     : $form.attr("action"),
                data    : data,
                success : function (msg) {
                    dialog.modal('hide');
                    var parts = msg.split("_");
                    if(parts[0] == 'ok'){
                        log(parts[1], "success");
                        setTimeout(function () {
                            location.reload(true);
                        }, 1000);
                    }else{
                        bootbox.alert('<i class="fa fa-exclamation-triangle text-danger fa-3x"></i> ' + '<strong style="font-size: 14px">' + parts[1] + '</strong>');
                        return false;
                    }
                }
            });
        } else {
            return false;
        }
    }

    function borrarPeriodo(id){
        bootbox.confirm({
            message: "<i class='fa fa-3x fa-exclamation-triangle text-danger'></i> <strong style='font-size: 14px'>  Está seguro de eliminar este período? </strong>",
            buttons: {
                confirm: {
                    label: 'Borrar',
                    className: 'btn-success'
                },
                cancel: {
                    label: 'Cancelar',
                    className: 'btn-danger'
                }
            },
            callback: function (result) {
                if(result){
                    $.ajax({
                        type:'POST',
                        url:'${createLink(controller: 'periodo', action: 'borrarPeriodo_ajax')}',
                        data:{
                            id: id
                        },
                        success:function(msg){
                            var parts = msg.split("_");
                            if(parts[0] == 'ok'){
                                log("Período borrado correctamente","success");
                                setTimeout(function () {
                                    location.reload(true);
                                }, 1000);
                            }else{
                                if(parts[0] == 'er'){
                                    bootbox.alert('<i class="fa fa-exclamation-triangle text-danger fa-3x"></i> ' + '<strong style="font-size: 14px">' + parts[1] + '</strong>');
                                    return false;
                                }else{
                                    log("Error al borrar el período","error")
                                }
                            }
                        }
                    })
                }
            }
        });
    }

    function createContextMenu(node) {
        var $tr = $(node);

        var items = {
            header: {
                label: "Acciones",
                header: true
            }
        };

        var id = $tr.data("id");

        var borrar = {
            label: 'Borrar',
            icon: "fa fa-trash",
            action: function (e) {
                borrarPeriodo(id)
            }
        };

        items.borrar = borrar;

        return items
    }

</script>
</html>