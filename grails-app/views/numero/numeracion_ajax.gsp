<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 23/11/20
  Time: 16:42
--%>
<g:hiddenField name="idDepartamento" value="${departamento?.id}"/>

<div class="row">
    <div class="col-md-3">
        <label>Tipo de documento:</label>
    </div>
    <div class="col-md-6">
        <g:select name="tipo" id="tipoDocumento" from="${tipos}" class="form-control" optionKey="id" optionValue="descripcion"/>
    </div>
</div>

<div class="row">
    <div class="col-md-3">
        <label>Numeración:</label>
    </div>
    <div class="col-md-2" id="divValor">

    </div>
</div>

<script type="text/javascript">

    $("#tipoDocumento").change(function () {
        var tipo = $(this).val();
        cargarValor('${departamento?.id}', tipo);
    });

    cargarValor('${departamento?.id}', $("#tipoDocumento option:selected").val());

    function cargarValor(departamento, tipo){
        $.ajax({
            type: 'POST',
            url: '${createLink(controller: 'numero', action: 'valor_ajax')}',
            data:{
                id: departamento,
                tipo: tipo
            },
            success: function (msg) {
                $("#divValor").html(msg)
            }
        })
    }

</script>

