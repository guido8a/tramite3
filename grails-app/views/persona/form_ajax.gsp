<%@ page import="tramites.Departamento" %>

<g:if test="${!personaInstance}">
    <elm:notFound elem="Persona" genero="o"/>
</g:if>
<g:else>
    <g:form class="form-horizontal" name="frmPersona" role="form" action="save_ajax" method="POST">
        <g:hiddenField name="id" value="${personaInstance?.id}"/>

        <div class="keeptogether">

            <div class="form-group keeptogether ${hasErrors(bean: personaInstance, field: 'departamento', 'error')} ">
                <span class="grupo">
                    <label for="departamento" class="col-md-3 control-label text-info">
                        Departamento
                    </label>

                    <div class="col-md-9">
                        <g:select id="departamento" name="departamento.id" from="${tramites.Departamento.findAllByActivo(1).sort{it.descripcion}}"
                                  optionKey="id" optionValue="descripcion"
                                  value="${personaInstance?.departamento?.id}" class="many-to-one form-control"/>
                    </div>

                </span>
            </div>

            <div class="form-group keeptogether ${hasErrors(bean: personaInstance, field: 'fechaInicio', 'error')} ">
                <span class="grupo">
                    <label for="login" class="col-md-3 control-label text-info">
                        Usuario
                    </label>

                    <div class="col-md-4">
                        <g:textField name="login" maxlength="15" class="form-control" value="${personaInstance?.login}" required=""/>
                    </div>
                    *
                </span>
            </div>

            <div class="form-group keeptogether ${hasErrors(bean: personaInstance, field: 'nombre', 'error')} required">
                <span class="grupo">
                    <label for="nombre" class="col-md-3 control-label text-info">
                        Nombre
                    </label>

                    <div class="col-md-7">
                        <g:textField name="nombre" maxlength="31" required="" class="form-control required" value="${personaInstance?.nombre}"/>
                    </div>
                    *
                </span>
            </div>

            <div class="form-group keeptogether ${hasErrors(bean: personaInstance, field: 'apellido', 'error')} required">
                <span class="grupo">
                    <label for="apellido" class="col-md-3 control-label text-info">
                        Apellido
                    </label>

                    <div class="col-md-7">
                        <g:textField name="apellido" maxlength="31" required="" class="form-control required" value="${personaInstance?.apellido}"/>
                    </div>
                    *
                </span>
            </div>

            <div class="form-group keeptogether ${hasErrors(bean: personaInstance, field: 'mail', 'error')} ">
                <span class="grupo">
                    <label for="mail" class="col-md-3 control-label text-info">
                        E-mail
                    </label>

                    <div class="col-md-7">
                        <g:textField name="mail" maxlength="63" email="true" class="required form-control noCaps" value="${personaInstance?.mail}"/>
                    </div>
                    *
                </span>
            </div>
        </div>

        <div class="keeptogether">
            <div class="form-group keeptogether ${hasErrors(bean: personaInstance, field: 'telefono', 'error')} ">
                <span class="grupo">
                    <label for="telefono" class="col-md-3 control-label text-info">
                        Teléfonos
                    </label>

                    <div class="col-md-7">
                        <g:textField name="telefono" maxlength="63" class="form-control digits" value="${personaInstance?.telefono}" />
                    </div>

                </span>
            </div>

            <g:if test="${session.usuario.puedeAdmin && personaInstance.id && personaInstance?.puedeAdmin}">
                <div class="form-group keeptogether ${hasErrors(bean: personaInstance, field: 'password', 'error')} required">
                    <span class="grupo">
                        <label for="password" class="col-md-3 control-label text-info">
                            Password
                        </label>

                        <div class="col-md-5">
                            <div class="input-group">
                                <g:passwordField name="password" class="form-control required" maxlength="15" value="${'pandagnaros'}"/>
                                <span class="input-group-addon"><i class="fa fa-lock"></i></span>

                            </div>
                        </div>
                        *
                    </span>
                </div>
            </g:if>
        </div>
    </g:form>

    <script type="text/javascript">
        var validator = $("#frmPersona").validate({
            errorClass     : "help-block",
            errorPlacement : function (error, element) {
                if (element.parent().hasClass("input-group")) {
                    error.insertAfter(element.parent());
                } else {
                    error.insertAfter(element);
                }
                element.parents(".grupo").addClass('has-error');
            },
            success        : function (label) {
                label.parents(".grupo").removeClass('has-error');
            },
            rules          : {
                cedula : {
                    remote : {
                        url  : "${createLink(action: 'validarCedula_ajax')}",
                        type : "post",
                        data : {
                            id : "${personaInstance.id}"
                        }
                    }
                },
                mail   : {
                    remote : {
                        url  : "${createLink(action: 'validarMail_ajax')}",
                        type : "post",
                        data : {
                            id : "${personaInstance.id}"
                        }
                    }
                },
                login  : {
                    remote : {
                        url  : "${createLink(action: 'validarLogin_ajax')}",
                        type : "post",
                        data : {
                            id : "${personaInstance.id}"
                        }
                    }
                }
            },
            messages       : {
                cedula : {
                    remote : "Cédula ya ingresada"
                },
                mail   : {
                    remote : "E-mail ya registrado"
                },
                login  : {
                    remote : "Login ya registrado"
                }
            }
        });
        $(".form-control").keydown(function (ev) {
            if (ev.keyCode == 13) {
                submitForm();
                return false;
            }
            return true;
        });

        $("#apellido, #nombre").blur(function () {
            var nombre = $.trim($("#nombre").val());
            var apellido = $.trim($("#apellido").val());
            if (nombre != "" || apellido != "") {
                var login = nombre.acronym() + "" + apellido.split(" ")[0];
                if ($.trim($("#login").val()) == "") {
                    $("#login").val(login.toLowerCase());
                }
            }
        });

    </script>

</g:else>
