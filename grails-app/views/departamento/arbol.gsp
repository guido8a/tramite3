

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title>Departamentos</title>

    <asset:javascript src="/jstree-3.0.8/dist/jstree.min.js"/>
    <asset:stylesheet src="/jstree-3.0.8/dist/themes/default/style.min.css"/>

    <style type="text/css">

    #list-cuenta {
        width : 950px;
    }

    #tree {
        background : #DEDEDE;
        overflow-y : auto;
        height     : 600px;
    }

    .jstree-search {
        color : #5F87B2 !important;
    }

    .leyenda {
        background    : #ddd;
        border        : solid 1px #aaa;
        padding-left  : 5px;
        padding-right : 5px;
    }

    .infoCambioEstado {
        font-size   : larger;
        font-weight : bold;
    }

    .entrada {
        color : #83C483;
    }

    .salida {
        color : #7676E2;
    }
    </style>

</head>

<body>
<g:if test="${session.usuario.puedeAdmin}">
    <g:set var="iconActivar" value="fa-power-off text-success"/>
    <g:set var="iconDesactivar" value="fa-power-off text-danger"/>
    <g:set var="iconDanger" value="fa-exclamation-triangle text-danger"/>

    <div id="list-cuenta" style="width: 900px; display: inline">

        <!-- botones -->
        <div class="btn-toolbar toolbar">
            <div class="btn-group">
                <g:link controller="inicio" action="parametros" class="btn btn-default">
                    <i class="fa fa-arrow-left"></i> Regresar
                </g:link>
            </div>

            <div class="btn-group" style="margin-top: 4px;">
                <g:link action="arbol" params="[sort: 'nombre']" class="btn btn-sm btn-info">
                    <i class="fa fa-sort-amount-down"></i> Ordenar por nombre
                </g:link>
                <g:link action="arbol" params="[sort: 'apellido']" class="btn btn-sm btn-info">
                    <i class="fa fa-sort-amount-down"></i> Ordenar por apellido
                </g:link>
            </div>

            <g:if test="${utilitarios.Parametros.get(1).validaLDAP == 1}">
                <div class="btn-group" style="margin-top: 4px;">
                    <a href="#" id="cargaPrsn" class="btn btn-primary btn-sm"><i class="fa fa-users"></i> Cargar / Actualizar LDAP
                    </a>
                </div>
            </g:if>

            <div class="btn-group col-md-2" style="margin-top: 4px;">
                <div class="input-group">
                    <g:textField name="search" class="form-control input-sm"/>
                    <span class="input-group-btn">
                        <a href="#" id="btnSearch" class="btn btn-sm btn-info" type="button">
                            <i class="fa fa-search"></i>&nbsp;
                        </a>
                    </span>
                </div>
            </div><!-- /input-group -->
            <div class="btn-group col-md-1" style="margin-top: 4px; width: 100px">
                <div class="input-group">
                    Ocultar Inactivos: <g:checkBox name="activos" value="${false}" />
                </div><!-- /input-group -->
            </div>

            <div class="btn-group pull-right ui-corner-all leyenda">
                <i class="fa fa-user text-info"></i> Usuario activo&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <i class="fa fa-user text-warning"></i> Jefe<br/>
                <i class="fa fa-user text-muted"></i> Usuario inactivo&nbsp;&nbsp;&nbsp;
                <i class="fa fa-user text-danger"></i> Director<br/>
            </div>
        </div>

        <div id="loading" class="text-center">
            <p>
                Cargando los departamentos
            </p>
            <p>
                <img src="${resource(dir: 'images/spinners', file: 'loading_new.GIF')}" alt='Cargando...'/>
            </p>
            <p>
                Por favor espere
            </p>
        </div>

        <div id="tree" class="hide">

        </div>
    </div>

%{--    <elm:select name="selDptoOrig" from="${tramites.Departamento.findAllByActivo(1, [sort: 'descripcion'])}"--}%
%{--                optionKey="id" optionValue="descripcion" optionClass="id" class="form-control hide" style="margin-top: 30px;"/>--}%

    <script type="text/javascript">

        var index = 0;

        var $btnCloseModal = $('<button type="button" class="btn btn-default" data-dismiss="modal">Cancelar</button>');
        var $btnSave = $('<button type="button" class="btn btn-success"><i class="fa fa-save"></i> Guardar</button>');

        function submitForm() {
            var $form = $("#frmDepartamento");
            var $btn = $("#dlgCreateEdit").find("#btnSave");
            if ($form.valid()) {
                $btn.replaceWith(spinner);
                openLoader("Grabando");
                $.ajax({
                    type    : "POST",
                    url     : $form.attr("action"),
                    data    : $form.serialize(),
                    success : function (msg) {
                        var parts = msg.split("_");
                        log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                        if (parts[0] == "OK") {
                            location.reload(true);
                        } else {
                            closeLoader();
                            spinner.replaceWith($btn);
                            return false;
                        }
                    }
                });
            } else {
                return false;
            } //else
        }
        function submitFormPersona(id) {
            var $form = $("#frmPersona");
            var $btn = $("#dlgCreateEditPersona").find("#btnSave");
            if ($form.valid()) {
                $btn.replaceWith(spinner);
                openLoader("Grabando");
                $.ajax({
                    type    : "POST",
                    url     : $form.attr("action"),
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
                                message : parts[1],
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
                                            var $txt = $("#txtWarning");
                                            var resp = $sel.val();
                                            var dpto = $sel.data("dpto");
                                            var autoriza = $.trim($txt.val());
                                            if (resp == 1 || resp == "1") {
//                                                    if (validaAutorizacion($txt)) {
                                                openLoader("Cambiando");
                                                $.ajax({
                                                    type    : "POST",
                                                    url     : '${createLink(controller: 'persona', action:'cambioDpto_ajax')}',
                                                    data    : {
                                                        id   : id,
                                                        dpto : dpto,
                                                        aut  : autoriza
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

        function createEditRow(id, tipo) {
            var data = tipo == "Crear" ? {padre : id} : {id : id};
            var c =  bootbox.dialog({
                message: '<div class="text-center"><i class="fa fa-spin fa-spinner"></i> Cargando...</div>',
                closeButton: false
            });
            $.ajax({
                type    : "POST",
                url     : "${createLink(controller: 'departamento', action:'form_ajax')}",
                data    : data,
                success : function (msg) {
                    c.modal('hide');
                    var b = bootbox.dialog({
                        id      : "dlgCreateEdit",
                        title   : tipo + " Departamento",
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
                        var $input = b.find(".form-control").not(".datepicker").first();
                        var val = $input.val();
                        $input.focus();
                        $input.val("");
                        $input.val(val);
                    }, 500);
                } //success
            }); //ajax
        } //createEdit

        function doSaveTipoDoc(data) {
            $.ajax({
                type    : "POST",
                url     : "${createLink(action:'saveTipoDoc_ajax')}",
                data    : data,
                success : function (msg) {
                    var parts = msg.split("_");
                    log(parts[1], parts[0] == "OK" ? "success" : "error");
                }
            });
        }

        function createEditTipo(id, tipo) {
            var data = tipo == "Crear" ? {padre : id} : {id : id};
            $.ajax({
                type    : "POST",
                url     : "${createLink(controller: 'departamento', action:'tipoDoc_ajax')}",
                data    : data,
                success : function (msg) {
                    var b = bootbox.dialog({
                        id      : "dlgCreateEdit",
                        title   : tipo + " Departamento",
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
                                    var data = "id=" + id;
                                    var band = false;
                                    $(".tipoDoc .fa-li").each(function () {
                                        var ico = $(this);
                                        if (ico.hasClass("fa-check-square")) {
                                            data += "&tipoDoc=" + ico.data("id");
                                            band = true;
                                        }
                                    });
                                    if (!band) {
                                        bootbox.confirm("<i class='fa fa-warning fa-3x pull-left text-warning text-shadow'></i><p>No ha seleccionado ningún tipo. Desea continuar?.</p>", function (result) {
                                            if (result) {
                                                doSaveTipoDoc(data);
                                            }
                                        })
                                    } else {
                                        doSaveTipoDoc(data);
                                    }
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
        } //createEditTipoDocumento

        function createEditRowPersona(id, tipo) {
            var data = tipo == "Crear" ? {'departamento.id' : id} : {id : id};
            $.ajax({
                type    : "POST",
                url     : "${createLink(controller: 'persona', action:'form_ajax')}",
                data    : data,
                success : function (msg) {
                    var b = bootbox.dialog({
                        id      : "dlgCreateEditPersona",
                        class   : "long",
                        title   : tipo + " Persona",
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
                                    return submitFormPersona(id);
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
        } //createEditPersona

        function cambiarEstadoRowPersonaAjax(itemId, activar) {
            var textLoader, url;
            if (activar) {
                textLoader = "Activando";
                url = "${createLink(controller: 'persona', action:'activar_ajax')}";
            } else {
                textLoader = "Desactivando";
                url = "${createLink(controller: 'persona', action:'desactivar_ajax')}";
            }
            openLoader(textLoader);
            $.ajax({
                type    : "POST",
                url     : url,
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

        function cambiarEstadoRowPersona(itemId, strUsuario, activar, tramites, tramitess) {
            var icon, textMsg, textBtn, textLoader, url, clase, botones;
            if (tramites != 0) {
                clase = "default";
                icon = "${iconDanger}";
                textMsg = "<p>" +
                    "Por favor verifique si el usuario <span class='infoCambioEstado'>" + strUsuario + "</span> que desea " +
                    "<span class='infoCambioEstado'>" + (activar ? 'activar' : 'desactivar') + "</span> tiene " +
                    "trámites en su bandeja de entrada y de salida" +
                    ".</p>";
                textMsg += "<p>" +
                    "Puede: <br> <span class='infoCambioEstado'> 1.- Redireccionar los trámites de la bandeja de entrada</span> " +
                    " <br> <span class='infoCambioEstado'>" + "2.- " + (activar ? 'activar' : 'desactivar') +
                    " la persona dejando sus trámites intactos.</span>" +
                    "</p>";
                botones = {
                    redireccionar : {
                        label     : "<i class='fa fa-exchange-alt'></i> Redireccionar trámites",
                        className : "btn-success",
                        callback  : function () {
                            location.href = "${createLink(controller: 'tramiteAdmin', action: 'redireccionarTramites')}/" + itemId;
                        }
                    },
                    cambiarEstado : {
                        label     : "<i class='fa fa-power-off'></i> " + (activar ? 'Activar' : 'Desactivar'),
                        className : "btn-danger",
                        callback  : function () {
                            cambiarEstadoRowPersonaAjax(itemId, activar);
                        }
                    },
                    cancelar      : {
                        label     : "Cancelar",
                        className : "btn-primary",
                        callback  : function () {
                        }
                    }
                };
            } else {
                if (activar) {
                    clase = "success";
                    icon = "${iconActivar}";
                    textMsg = "<p>¿Está seguro que desea activar la persona seleccionada?</p>";
                    textBtn = "Activar";
                    botones = {
                        cancelar : {
                            label     : "Cancelar",
                            className : "btn-primary",
                            callback  : function () {
                            }
                        },
                        activar  : {
                            label     : "<i class='fa " + icon + "'></i> " + textBtn,
                            className : "btn-" + clase,
                            callback  : function () {
                                cambiarEstadoRowPersonaAjax(itemId, true);
                            }
                        }
                    }
                }
                else {
                    clase = "danger";
                    icon = "${iconDesactivar}";
                    textMsg = "<p>¿Está seguro que desea desactivar la persona seleccionada?</p>";
                    textBtn = "Desactivar1";
                    botones = {
                        cancelar   : {
                            label     : "Cancelar",
                            className : "btn-primary",
                            callback  : function () {
                            }
                        },
                        desactivar : {
                            label     : "<i class='fa " + icon + "'></i> " + textBtn,
                            className : "btn-" + clase,
                            callback  : function () {
                                cambiarEstadoRowPersonaAjax(itemId, false);
                            }
                        }
                    }
                }
            }
            bootbox.dialog({
                title   : "Alerta",
                message : "<i class='fa " + icon + " fa-3x pull-left text-" + clase + " text-shadow'></i>" + textMsg,
                buttons : botones
            });
        } //cambiar estado row persona

        function cambiarEstadoRow(itemId, strId, activar, tramites) {
            var icon, textMsg, textBtn, textLoader, url, clase;
            if (activar) {
                clase = "success";
                icon = "${iconActivar}";
                textMsg = "<p>¿Está seguro que desea activar el departamento seleccionado?</p>";
                textBtn = "Activar";
                textLoader = "Activando";
                url = "${createLink(action:'activar_ajax')}";
            } else {
                clase = "danger";
                icon = "${iconDesactivar}";
                textMsg = "<p>¿Está seguro que desea desactivar el departamento seleccionado?</p>";
                textBtn = "Desactivar";
                textLoader = "Desactivando";
                url = "${createLink(action:'desactivar_ajax')}";
            }
            bootbox.dialog({
                id      : "dlgWarning",
                title   : "Alerta",
                message : "<i class='fa " + icon + " fa-3x pull-left text-" + clase + " text-shadow'></i>" + textMsg,
                buttons : {
                    cancelar : {
                        label     : "Cancelar",
                        className : "btn-primary",
                        callback  : function () {
                        }
                    },
                    eliminar : {
                        label     : "<i class='fa " + icon + "'></i> " + textBtn,
                        className : "btn-" + clase,
                        callback  : function () {
                            var $txt = $("#aut");
                            openLoader(textLoader);
                            $.ajax({
                                type    : "POST",
                                url     : url,
                                data    : {
                                    id    : itemId
//                                    nuevo : $sel.val()
                                },
                                success : function (msg) {
                                    var parts = msg.split("_");
                                    log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                                    if (parts[0] == "OK") {
                                        location.reload(true);
                                    }
                                    closeLoader();
                                }
                            });
                        }
                    }
                }
            });
            if ($sel) {
                $sel.removeClass("hide");
                $sel.attr("name", "selDpto");
                $sel.attr("id", "selDpto");
                $sel.find("option." + itemId).remove();
                $("#pWarning").append($sel);
            }
        } //cambiar estado row

        function cambiarEstadoDpto(itemId, strId, activar, tramites) {
            var icon, textMsg, textBtn, textLoader, url, clase;
            if (activar) {
                clase = "success";
                icon = "${iconActivar}";
                textMsg = "<p>¿Está seguro que desea activar el departamento seleccionado?</p>";
                textBtn = "Activar";
                textLoader = "Activando";
                url = "${createLink(action:'activar_ajax')}";
            } else {
                clase = "danger";
                icon = "${iconDesactivar}";
                textMsg = "<p>¿Está seguro que desea desactivar el departamento seleccionado?</p>";
                textMsg += "<p id='pWarning'>Los trámites de las bandejas de entrada y de salida serán redireccionados " +
                    "al nuevo departamento seleccionado</p>";

                var $sel = $("#selDptoOrig").clone();
                textBtn = "Desactivar";
                textLoader = "Desactivando";
                url = "${createLink(action:'desactivar_dpto_ajax')}";
            }
            bootbox.dialog({
                id      : "dlgWarning",
                title   : "Alerta",
                message : "<i class='fa " + icon + " fa-3x pull-left text-" + clase + " text-shadow'></i>" + textMsg,
                buttons : {
                    cancelar : {
                        label     : "Cancelar",
                        className : "btn-primary",
                        callback  : function () {
                        }
                    },
                    eliminar : {
                        label     : "<i class='fa " + icon + "'></i> " + textBtn,
                        className : "btn-" + clase,
                        callback  : function () {
                            var $txt = $("#aut");
                            openLoader(textLoader);
                            $.ajax({
                                type    : "POST",
                                url     : url,
                                data    : {
                                    id    : itemId,
                                    nuevo : $sel.val()
                                },
                                success : function (msg) {
                                    var parts = msg.split("_");
                                    log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                                    if (parts[0] == "OK") {
                                        location.reload(true);
                                    }
                                    closeLoader();
                                }
                            });
                        }
                    }
                }
            });
            if ($sel) {
                $sel.removeClass("hide");
                $sel.attr("name", "selDpto");
                $sel.attr("id", "selDpto");
                $sel.find("option." + itemId).remove();
                $("#pWarning").append($sel);
            }
        } //cambiar estado dpto

        function createContextMenu(node) {
            var nodeStrId = node.id;
            var $node = $("#" + nodeStrId);
            var nodeId = nodeStrId.split("_")[1];
            var nodeType = $node.data("jstree").type;
            var nodeUsu = $node.data("usuario");

            var nodeHasChildren = $node.hasClass("hasChildren");
            var nodeOcupado = $node.hasClass("ocupado");

            var nodeTramites = $node.data("tramites");
            var nodeTramitess = $node.data("tramitess");

            var estaAusente = $node.hasClass("ausente");
            var triangulos = $node.data("tienetri");
            var hijitos = $node.data("tienehij");

            if (nodeType == "root") {
                var items = {
                    crear    : {
                        label  : "Nuevo departamento hijo",
                        icon   : "fa fa-plus-circle text-success",
                        action : function (obj) {
                            createEditRow(nodeId, "Crear");
                        }
                    },
                    imprimir : {
                        label   : "Imprimir",
                        icon    : "fa fa-print",
                        action  : false,
                        submenu : {
                            si : {
                                label  : "Con usuarios",
                                icon   : "fa fa-users text-info",
                                action : function () {
                                    location.href = "${createLink(controller: 'departamentoExport', action: 'crearPdf')}/-1?usu=true&sort=${params.sort}";
                                }
                            },
                            no : {
                                label  : "Solo departamentos",
                                icon   : "fa fa-home text-info",
                                action : function () {
                                    location.href = "${createLink(controller: 'departamentoExport', action: 'crearPdf')}/-1?usu=false&sort=${params.sort}";
                                }
                            }
                        }
                    }
                };
            }
            else if (nodeType.contains('padre') || nodeType.contains('hijo')) {
                items = {
                    editar       : {
                        label  : "Editar departamento",
                        icon   : "fa fa-edit text-info",
                        action : function (obj) {
                            createEditRow(nodeId, "Editar");
                        }
                    },
                    tpDocumento  : {
                        label  : "Fijar tipo de documentos",
                        icon   : "fa fa-check text-info",
                        action : function (obj) {
                            createEditTipo(nodeId, "Tipo de Documentos por");
                        }
                    },
                    ver          : {
                        label  : "Ver departamento",
                        icon   : "fa fa-laptop text-info",
                        action : function (obj) {
                            $.ajax({
                                type    : "POST",
                                url     : "${createLink(action:'show_ajax')}",
                                data    : {
                                    id : nodeId
                                },
                                success : function (msg) {
                                    bootbox.dialog({
                                        title   : "Ver Departamento",
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
                    crear        : {
                        separator_before : true,
                        label  : "Nuevo departamento hijo",
                        icon   : "fa fa-plus-circle text-success",
                        action : function (obj) {
                            createEditRow(nodeId, "Crear");
                        }
                    },
                    crearPersona : {
                        label            : "Nueva persona",
                        icon             : "fa fa-user text-success",
                        action           : function (obj) {
                            createEditRowPersona(nodeId, "Crear");
                        }
                    }
                };

                if (nodeType.indexOf('Inactivo') !== -1) {
                    delete items.crear;
                    delete items.crearPersona;
                    delete items.desactivar;

                    items.activar = {
                        separator_before : true,
                        label            : "Activar",
                        icon             : "fa ${iconActivar} text-success",
                        action           : function (obj) {
                            cambiarEstadoRow(nodeId, nodeStrId, true, nodeTramites);
                        }
                    }
                }

                if(nodeType.contains('padreActivo') || nodeType.contains('hijoActivo')|| nodeType.contains('hijoRemotoActivo') ||
                    nodeType.contains('padreRemotoActivo')) {
                    if(triangulos == '1'){
                        items.desactivar = {
                            separator_before : true,
                            label            : "Pasar Bandejas E/S y Desactivar Δ",
                            icon             : "fa ${iconDesactivar}",
                            action           : function (obj) {
                                cambiarEstadoDpto(nodeId, nodeStrId, false, nodeTramites);
                            }
                        };
                    }
                }

                if (!nodeHasChildren && !nodeOcupado) {
                    if (!nodeType.contains('Inactivo')) {
                        items.desactivar = {
                            separator_before: true,
                            label: "Desactivar",
                            icon: "fa ${iconDesactivar}",
                            action: function (obj) {
                                cambiarEstadoRow(nodeId, nodeStrId, false, nodeTramites);
                            }
                        };
                    }

                    items.eliminar = {
                        label  : "Eliminar departamento",
                        icon   : "fa fa-trash-o text-danger",
                        action : function (obj) {
                            var $node = $('#' + nodeStrId);
                            bootbox.dialog({
                                title   : "Alerta",
                                message : "<i class='fa fa-trash-o fa-3x pull-left text-danger text-shadow'></i>" +
                                    "<p>¿Está seguro que desea eliminar el departamento seleccionado? Esta acción no se puede deshacer.</p>",
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
                                                    id : nodeId
                                                },
                                                success : function (msg) {
                                                    var parts = msg.split("_");
                                                    log(parts[1], parts[0] == "OK" ? "success" : "error"); // log(msg, type, title, hide)
                                                    if (parts[0] == "OK") {
                                                        location.reload(true);
                                                    } else {
                                                        closeLoader();
                                                        return false;
                                                    }
                                                }
                                            });
                                        }
                                    }
                                }
                            });
                        }
                    };
                }

                items.imprimir = {
                    label   : "Imprimir",
                    icon    : "fa fa-print",
                    action  : false,
                    submenu : {
                        si : {
                            label  : "Con usuarios",
                            icon   : "fa fa-users text-info",
                            action : function () {
                                location.href = "${createLink(controller: 'departamentoExport', action: 'crearPdf')}/" + nodeId + "?usu=true&sort=${params.sort}";
                            }
                        },
                        no : {
                            label  : "Solo departamentos",
                            icon   : "fa fa-home text-info",
                            action : function () {
                                location.href = "${createLink(controller: 'departamentoExport', action: 'crearPdf')}/" + nodeId + "?usu=false&sort=${params.sort}";
                            }
                        }
                    }
                };

                items.departamentoPara= {
                    label   : "Departamento Para",
                    icon    : "fa fa-tasks",
                    action  : function (obj) {
                        location.href = "${createLink(controller: 'departamento', action: 'departamentoPara')}/" + nodeId
                    }
                };

                items.departamentoDesde= {
                    label   : "Departamento Desde",
                    icon    : "fa fa-tasks",
                    action  : function (obj) {
                        location.href = "${createLink(controller: 'departamento', action: 'departamentoDesde')}/" + nodeId
                    }
                };

                if(nodeType.contains('padreActivo')){
                    items.desactivar = {
                        separator_before : true,
                        label            : "Desactivar Departamento",
                        icon             : "fa ${iconDesactivar}",
                        action           : function (obj) {
                            cambiarEstadoRow(nodeId, nodeStrId, false, nodeTramites);
                        }
                    };
                }

                if (nodeType.contains('hijo')) {
                    delete items.imprimir.submenu.no
                }

            }
            else if (nodeType.contains('usuario') || nodeType.contains('jefe') || nodeType.contains('director')) {
                items = {
                    editar : {
                        label  : "Editar persona",
                        icon   : "fa fa-edit text-info",
                        action : function (obj) {
                            createEditRowPersona(nodeId, "Editar");
                        }
                    },
                    ver    : {
                        label  : "Ver Persona",
                        icon   : "fa fa-laptop text-info",
                        action : function (obj) {
                            $.ajax({
                                type    : "POST",
                                url     : "${createLink(controller: 'persona', action:'show_ajax')}",
                                data    : {
                                    id : nodeId
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
                    }
                };

                if (nodeType.contains("Activo")) {
                    items.ausentismo = {
                        separator_before : true,
                        label            : "Ausentismo",
                        icon             : "fa fa-user-injured",
                        action           : function () {
                            location.href = "${createLink(controller: 'persona', action: 'personalAdm')}/" + nodeId;
                        }
                    };
                }

                if (nodeTramites > 0) {
                    items.redireccionar = {
                        separator_before : true,
                        label            : "Redireccionar trámites",
                        icon             : "fa fa-fa-exchange-alt",
                        action           : function () {
                            location.href = "${createLink(controller: 'tramiteAdmin', action: 'redireccionarTramites')}/" + nodeId;
                        }
                    };
                }

                if (nodeType.contains('Inactivo')) {
                    if (!estaAusente) {
                        items.activar = {
                            separator_before : true,
                            label            : "Activar",
                            icon             : "fa ${iconActivar} text-success",
                            action           : function (obj) {
                                cambiarEstadoRowPersona(nodeId, nodeUsu, true, nodeTramites, nodeTramitess);
                            }
                        };
                    }
                    if (estaAusente) {
                        items.terminar = {
                            separator_before : true,
                            label            : "Terminar ausentismo",
                            icon             : "fa ${iconActivar} text-success",
                            action           : function (obj) {
                                $.ajax({
                                    type    : "POST",
                                    url     : "${createLink(controller: 'persona', action:'personalArbol')}",
                                    data    : {
                                        id : nodeId
                                    },
                                    success : function (msg) {
                                        bootbox.dialog({
                                            title   : "Terminar ausentismo",
                                            message : msg,
                                            buttons : {
                                                cancelar : {
                                                    label     : "Cerrar",
                                                    className : "btn-primary",
                                                    callback  : function () {
                                                        openLoader("Guardando cambios");
                                                        location.reload(true)
                                                    }
                                                }
                                            }
                                        });
                                    }
                                });
                            }
                        };
                    }
                } else {
                    if (!node.data.triangulos || node.data.triangulos > 1) {
                        items.desactivar = {
                            separator_before : true,
                            label            : "Desactivar",
                            icon             : "fa ${iconDesactivar}",
                            action           : function (obj) {
                                cambiarEstadoRowPersona(nodeId, nodeUsu, false, nodeTramites, nodeTramitess);
                            }
                        };
                    }
                }
            }
            return items;
        }

        $(function () {

            $(".btnCopiar").click(function () {
                openLoader("Copiando");
            });

            $("#btnCreate").click(function () {
                createEditRow(null, "Crear");
            });

            $('#tree').on("loaded.jstree", function () {
                $("#loading").hide();
                $("#tree").removeClass("hide").show();
            }).on("select_node.jstree", function (node, selected, event) {
            }).jstree({
                plugins     : ["types", "contextmenu", "wholerow", "search"],
                core        : {
                    multiple       : false,
                    check_callback : true,
                    themes         : {
                        variant : "small",
                        dots    : true,
                        stripes : true
                    },
                    data           : {
                        async : false,
                        url   : '${createLink(controller: 'departamento', action:"loadTreePart")}',
                        data  : function (node) {
                            return {
                                id    : node.id,
                                sort  : "${params.sort?:'apellido'}",
                                order : "${params.order?:'asc'}",
                                actv  : $("#activos").is(':checked')
                            };
                        }
                    }
                },
                contextmenu : {
                    show_at_node : false,
                    items        : createContextMenu
                },
                search      : {
                    fuzzy             : false,
                    show_only_matches : true,
                    ajax              : {
                        url     : "${createLink(action:'arbolSearch_ajax')}",
                        success : function (msg) {
                            var json = $.parseJSON(msg);
                            $.each(json, function (i, obj) {
                                $('#tree').jstree("open_node", obj);
                            });
                        }
                    }
                },
                types       : {
                    root                      : {
                        icon : "fa fa-folder text-warning"
                    },
                    padreActivo               : {
                        icon : "fa fa-building text-info"
                    },
                    padreInactivo             : {
                        icon : "fa fa-building-o text-muted"
                    },
                    padreExternoActivo        : {
                        icon : "fa fa-paper-plane text-info"
                    },
                    padreExternoInactivo      : {
                        icon : "fa fa-paper-plane text-muted"
                    },
                    padreRemotoActivo         : {
                        icon : "fa fa-wifi text-info"
                    },
                    padreRemotoInactivo       : {
                        icon : "fa fa-wifi text-muted"
                    },
                    hijoActivo                : {
                        icon : "fa fa-home text-success"
                    },
                    hijoInactivo              : {
                        icon : "fa fa-home text-muted"
                    },
                    hijoExternoActivo         : {
                        icon : "fa fa-paper-plane text-success"
                    },
                    hijoExternoInactivo       : {
                        icon : "fa fa-paper-plane text-muted"
                    },
                    hijoRemotoActivo          : {
                        icon : "fa fa-rss text-success"
                    },
                    hijoRemotoInactivo        : {
                        icon : "fa fa-rss text-muted"
                    },
                    usuarioActivo             : {
                        icon : "fa fa-user text-info"
                    },
                    usuarioInactivo           : {
                        icon : "fa fa-user text-muted"
                    },
                    jefeActivo                : {
                        icon : "fa fa-user text-warning"
                    },
                    jefeInactivo              : {
                        icon : "fa fa-user text-muted"
                    },
                    directorActivo            : {
                        icon : "fa fa-user text-danger"
                    },
                    directorInactivo          : {
                        icon : "fa fa-user text-muted"
                    },
                    usuarioTrianguloActivo    : {
                        icon : "fa fa-download text-info"
                    },
                    usuarioTrianguloInactivo  : {
                        icon : "fa fa-download text-muted"
                    },
                    jefeTrianguloActivo       : {
                        icon : "fa fa-cloud-download text-warning"
                    },
                    jefeTrianguloInactivo     : {
                        icon : "fa fa-cloud-download text-muted"
                    },
                    directorTrianguloActivo   : {
                        icon : "fa fa-cloud-download text-danger"
                    },
                    directorTrianguloInactivo : {
                        icon : "fa fa-cloud-download text-muted"
                    }
                }
            });

            $('#btnSearch').click(function () {
                $('#tree').jstree(true).search($.trim($("#search").val()));
                return false;
            });
            $("#search").keypress(function (ev) {
                if (ev.keyCode == 13) {
                    $('#tree').jstree(true).search($.trim($("#search").val()));
                    return false;
                }
            });

            $("#cargaPrsn").click(function () {
                bootbox.confirm("Cargar/Actualizar personal y Departamentos desde el servidor LDAP?", function (result) {
                    if (result) {
                        openLoader();
                        location.href = "${createLink(controller:'persona', action:'cargarUsuariosLdap')}"
                    }
                });
            });

            $('#activos').change(function () {
                location.reload()
            });

        });
    </script>
</g:if>
<g:else>
    <elm:flashMessage clase="alert-warning" dismissable="false">
        <i class="fa fa-warning fa-2x pull-left"></i>
        <span style="font-size: larger">La estructura departamental solamente puede ser visualizada por administradores</span>
    </elm:flashMessage>
</g:else>
</body>
</html>
