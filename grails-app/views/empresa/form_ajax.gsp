<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 04/10/21
  Time: 11:52
--%>

<g:form class="form-horizontal" name="frmEmpresa" role="form" action="save_ajax" method="POST">
    <g:hiddenField name="id" value="${empresa?.id}" />

    <div class="form-group ${hasErrors(bean: empresa, field: 'ruc', 'error')} required">
        <span class="grupo">
            <label for="ruc" class="col-md-2 control-label text-info">
                RUC
            </label>
            <div class="col-md-4">
                <g:textField name="ruc" maxlength="13" minlength="10" required="" class="form-control required allCaps rucId" value="${empresa?.ruc}"/>
            </div>
        </span>
    </div>

    <div class="form-group ${hasErrors(bean: empresa, field: 'nombre', 'error')} required">
        <span class="grupo">
            <label for="nombre" class="col-md-2 control-label text-info">
                Nombre
            </label>
            <div class="col-md-6">
                <g:textField name="nombre" maxlength="63" required="" class="form-control required" value="${empresa?.nombre}"/>
            </div>
        </span>
    </div>

    <div class="form-group ${hasErrors(bean: empresa, field: 'sigla', 'error')} required">
        <span class="grupo">
            <label for="sigla" class="col-md-2 control-label text-info">
                Sigla
            </label>
            <div class="col-md-3">
                <g:textField name="sigla" maxlength="63" required="" class="form-control required allCaps" value="${empresa?.sigla}"/>
            </div>
        </span>

        <span class="grupo">
            <label for="codigo" class="col-md-2 control-label text-info">
                Código
            </label>
            <div class="col-md-3">
                <g:textField name="codigo" maxlength="4" required="" class="form-control required allCaps" value="${empresa?.codigo}"/>
            </div>
        </span>
    </div>

    <div class="form-group ${hasErrors(bean: empresa, field: 'descripcion', 'error')}">
        <span class="grupo">
            <label for="descripcion" class="col-md-2 control-label text-info">
                Descripción
            </label>
            <div class="col-md-8">
                <g:textArea name="descripcion" style="resize: none" maxlength="255" class="form-control" value="${empresa?.descripcion}"/>
            </div>
        </span>
    </div>

    <div class="form-group ${hasErrors(bean: empresa, field: 'direccion', 'error')}">
        <span class="grupo">
            <label for="direccion" class="col-md-2 control-label text-info">
                Dirección
            </label>
            <div class="col-md-8">
                <g:textField name="direccion" style="resize: none" maxlength="255" class="form-control" value="${empresa?.direccion}"/>
            </div>
        </span>
    </div>

    <div class="form-group ${hasErrors(bean: empresa, field: 'email', 'error')}">
        <span class="grupo">
            <label for="email" class="col-md-2 control-label text-info">
                Email
            </label>
            <div class="col-md-6">
                <g:textField name="email" maxlength="63" class="email mail form-control" value="${empresa?.email}"/>
            </div>
        </span>
    </div>

    <div class="form-group ${hasErrors(bean: empresa, field: 'telefono', 'error')}">
        <span class="grupo">
            <label for="telefono" class="col-md-2 control-label text-info">
                Teléfono
            </label>
            <div class="col-md-6">
                <g:textField name="telefono" maxlength="63" class="number form-control" value="${empresa?.telefono}"/>
            </div>
        </span>
    </div>

    <div class="form-group ${hasErrors(bean: empresa, field: 'observaciones', 'error')}">
        <span class="grupo">
            <label for="observaciones" class="col-md-2 control-label text-info">
                Observaciones
            </label>
            <div class="col-md-8">
                <g:textArea name="observaciones" style="resize: none" maxlength="255" class="form-control" value="${empresa?.descripcion}"/>
            </div>
        </span>
    </div>
</g:form>

<script type="text/javascript">


    $(function () {
        $("#ruc").blur(function () {
            $.ajax({
               type: 'POST',
                url: '${createLink(controller: 'empresa', action: 'validarRuc_ajax')}',
                data:{
                    ruc: $("#ruc").val(),
                    id: "${empresa?.id}"
                },
                success: function (msg) {
                    if(msg == "false"){
                     bootbox.alert("<i class='fa fa-exclamation-triangle fa-2x text-danger'></i> El número de RUC ya se encuentra ingresado")
                    }
                }
            });
        });
    });


     var validator = $("#frmEmpresa").validate({
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
            ruc : {
                remote : {
                    url  : "${createLink(action: 'validarRuc_ajax')}",
                    type : "post",
                    data : {
                        id : "${empresa.id}",
                        ruc: $("#ruc").val()
                    }
                }
            }
        },
        messages       : {
            ruc : {
                remote : "RUC ya ingresado"
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
</script>
