<%@ page import="seguridad.Prfl" %>

<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.js')}"></script>
<g:if test="${!prflInstance}">
    <elm:notFound elem="Prfl" genero="o"/>
</g:if>
<g:else>
    <g:form class="form-horizontal" name="frm" role="form" action="save" method="POST">
        <g:hiddenField name="id" value="${prflInstance?.id}"/>

        <div class="form-group ${hasErrors(bean: prflInstance, field: 'codigo', 'error')} ">
            <span class="grupo">
                <label for="codigo" class="col-md-3 control-label text-info">
                    Código
                </label>

                <div class="col-md-6" style="width: 140px;">
                    <g:textField name="codigo" class="form-control allCaps" value="${prflInstance?.codigo}" style="width:120px"
                    maxlength="4"/>
                </div>*

            </span>
        </div>

        <div class="form-group ${hasErrors(bean: prflInstance, field: 'descripcion', 'error')} ">
            <span class="grupo">
                <label for="descripcion" class="col-md-3 control-label text-info">
                    Descripción
                </label>

                <div class="col-md-6" style="width: 380px;">
                    <g:textField name="descripcion" class="form-control allCaps" value="${prflInstance?.descripcion}" style="width: 360px;" maxlength="60"/>
                </div>*

            </span>
        </div>

        <div class="form-group ${hasErrors(bean: prflInstance, field: 'nombre', 'error')} ">
            <span class="grupo">
                <label for="nombre" class="col-md-3 control-label text-info">
                    Nombre
                </label>

                <div class="col-md-6"  style="width: 380px">
                    <g:textField name="nombre" class="form-control allCaps" value="${prflInstance?.nombre}" maxlength="60" style="width: 360px"/>
                </div> *

            </span>
        </div>

        <div class="form-group ${hasErrors(bean: prflInstance, field: 'observaciones', 'error')} ">
            <span class="grupo">
                <label for="observaciones" class="col-md-3 control-label text-info">
                    Observaciones
                </label>

                <div class="col-md-6" style="width: 380px;">
                    <g:textField name="observaciones" class="form-control allCaps" value="${prflInstance?.observaciones}" style="width: 360px;" maxlength="60"/>
                </div> *
            </span>
        </div>


    </g:form>

    <script type="text/javascript">
        var validator = $("#frmPrfl").validate({
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

</g:else>