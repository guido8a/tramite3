<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 10/10/19
  Time: 16:48
--%>

<g:form class="form-horizontal" name="frmIva">
<div class="form-group">
    <span class="grupo">
        <label for="iva" class="col-md-2 control-label text-info" style="font-size: 14px">
            Iva
        </label>
        <div class="col-md-4">
            <g:textField name="iva" id="ivaExi" class="form-control digits" value="${seguridad.ParametrosAux.findByIvaIsNotNull().iva}"/>
            <p class="help-block ui-helper-hidden"></p>
        </div>
    </span>
</div>
</g:form>

<script type="text/javascript">
    var validator = $("#frmIva").validate({
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
</script>