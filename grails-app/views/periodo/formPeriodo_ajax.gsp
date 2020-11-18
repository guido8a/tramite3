<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 23/10/20
  Time: 9:52
--%>


<g:form class="form-horizontal" name="frmPeriodo" action="save_ajax">


    <div class="col-md-12" style="margin-bottom: 10px">
        <strong>* Al crear un nuevo período se copiarán los semáforos del último período</strong>
    </div>

    <div class="form-group ${hasErrors(bean: periodo, field: 'fechaDesde', 'error')} ">
        <span class="grupo">
            <label for="fechaDesde" class="col-md-2 control-label text-info">
                Fecha Desde
            </label>
            <div class="col-md-4">
                <input name="fechaDesde" id='fechaDesde' type='text' class="form-control required" value="${''}"/>
                <p class="help-block ui-helper-hidden"></p>
            </div>
        </span>
    </div>

    <div class="form-group ${hasErrors(bean: periodo, field: 'fechaHasta', 'error')} ">
        <span class="grupo">
            <label for="fechaHasta" class="col-md-2 control-label text-info">
                Fecha Hasta
            </label>
            <div class="col-md-4">
                <input name="fechaHasta" id='fechaHasta' type='text' class="form-control required" value="${''}"/>
                <p class="help-block ui-helper-hidden"></p>
            </div>
        </span>
    </div>
</g:form>

<script type="text/javascript">

    $('#fechaDesde').datetimepicker({
        locale: 'es',
        format: 'DD-MM-YYYY',
        // daysOfWeekDisabled: [0, 6],
        // inline: true,
        sideBySide: true,
        showClose: true,
        icons: {
            // close: 'closeText'
        }
    });

    $('#fechaHasta').datetimepicker({
        locale: 'es',
        format: 'DD-MM-YYYY',
        // daysOfWeekDisabled: [0, 6],
        // inline: true,
        sideBySide: true,
        showClose: true,
        icons: {
            // close: 'closeText'
        }
    });

    var validator = $("#frmPeriodo").validate({
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
