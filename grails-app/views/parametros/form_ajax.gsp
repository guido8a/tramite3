<%@ page import="utilitarios.Parametros" %>

%{--<script type="text/javascript" src="${resource(dir: 'js', file: 'ui.js')}"></script>--}%
<g:if test="${!parametrosInstance}">
    <elm:notFound elem="Parametros" genero="o"/>
</g:if>
<g:else>
    <g:form class="form-horizontal" name="frmParametros" role="form" action="save" method="POST">
        <g:hiddenField name="id" value="${parametrosInstance?.id}"/>

        <div class="form-group ${hasErrors(bean: parametrosInstance, field: 'institucion', 'error')} required">
            <span class="grupo">
                <label for="institucion" class="col-md-2 control-label text-info">
                    Institución
                </label>

                <div class="col-md-6">
                    <g:textField name="institucion" required="" class="form-control required"
                                 value="${parametrosInstance?.institucion}" style="width:400px;" maxlength="255"/>
                </div>
                *
            </span>
        </div>



            <div class="form-group ${hasErrors(bean: parametrosInstance, field: 'horaInicio', 'error')} required">
                <span class="grupo">
                    <label for="horaInicio" class="col-md-3 control-label text-info" style="margin-top:-10px;">
                        Hora Inicio de la Jornada de Trabajo
                    </label>

                    <div class="col-md-3">
                        <g:select name="horaInicio" from="${0..23}" value="${parametrosInstance.horaInicio ?: 8}"
                                  optionValue="${{ it.toString().padLeft(2, '0') }}"/>
                        <g:select name="minutoInicio" from="${0..59}" value="${parametrosInstance.minutoInicio ?: 00}"
                                  optionValue="${{ it.toString().padLeft(2, '0') }}"/>
                    </div>
                </span>
                <span class="grupo">
                    <label for="horaFin" class="col-md-3 control-label text-info" style="margin-top:-10px;">
                        Hora Fin de la Jornada de Trabajo
                    </label>

                    <div class="col-md-3">
                        <g:select name="horaFin" from="${0..23}" value="${parametrosInstance.horaFin ?: 16}"
                                  optionValue="${{ it.toString().padLeft(2, '0') }}"/>
                        <g:select name="minutoFin" from="${0..59}" value="${parametrosInstance.minutoFin ?: 00}"
                                  optionValue="${{ it.toString().padLeft(2, '0') }}"/>
                    </div>
                </span>
            </div>


%{--        <div class="form-group ${hasErrors(bean: parametrosInstance, field: 'imagenes', 'error')} required">--}%
%{--            <span class="grupo">--}%
%{--                <label for="imagenes" class="col-md-2 control-label text-info">--}%
%{--                    Ruta de Imágenes--}%
%{--                </label>--}%

%{--                <div class="col-md-6">--}%
%{--                    <g:textField name="imagenes" required="" class="form-control required"--}%
%{--                                 value="${parametrosInstance?.imagenes}" style="width:400px;" maxlength="255"/>--}%
%{--                </div>--}%
%{--                *--}%
%{--            </span>--}%
%{--        </div>--}%

    </g:form>




    <script type="text/javascript">
        var validator = $("#frmParametros").validate({
            errorClass: "help-block",
            errorPlacement: function (error, element) {
                if (element.parent().hasClass("input-group")) {
                    error.insertAfter(element.parent());
                } else {
                    error.insertAfter(element);
                }
                element.parents(".grupo").addClass('has-error');
            },
            success: function (label) {
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