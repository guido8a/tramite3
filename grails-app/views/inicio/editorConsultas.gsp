<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title>Consultas</title>
</head>

<body>

<div class="row">
    <div class="col-md-12" style="text-align: center">
        <div class="alert alert-info">Consulta</div>
        <g:textArea name="consulta" id="consulta" class="form-control col-md-10" style="height: 200px; resize: none" />
    </div>
    <div class="col-md-12 btn-group" style="margin-top: 10px">
        <a href="#" class="btn btn-success btnConsultar"><i class="fa fa-search"></i> Consultar</a>
        <a href="#" class="btn btn-warning btnLimpiar"><i class="fa fa-search"></i> Limpiar</a>
    </div>

    <div class="col-md-12" style="text-align: center; margin-top: 10px">
        <div class="alert alert-success">Respuesta</div>
        <g:textArea name="respuesta" id="respuesta" class="form-control col-md-10" style="height: 200px; resize: none" readonly="" />
    </div>
</div>


<script type="text/javascript">

    $(".btnLimpiar").click(function () {
        $("#consulta").val('');
        $("#respuesta").val('');
    });

    $(".btnConsultar").click(function () {
        cargarRespuestaIA();
    });

    function cargarRespuestaIA(){
        var a = cargarLoader("Cargando...");
        var texto = $("#consulta").val();
        $.ajax({
            type:'POST',
            url:'${createLink(controller: 'inicio', action: 'consulta_ai')}',
            data:{
                texto: texto
            },
            success: function(msg){
                a.modal("hide");
                $("#respuesta").html(msg)
            }
        })
    }

</script>

</body>
</html>
