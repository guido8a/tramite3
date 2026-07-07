<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title>Editor Trámites</title>
</head>

<body>

<div class="row">
    <div class="col-md-12" style="text-align: center">
        <div class="col-md-1">Cédula</div>
        <div class="col-md-3">
            <g:textField name="cedula" class="form-control" />
        </div>
        <div class="col-md-1">Nombre</div>
        <div class="col-md-3">
            <g:textField name="nombre" class="form-control" />
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12" style="text-align: center">
        <div class="alert alert-info">Trámite</div>
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

        var texto = $("#consulta").val();
        var cedula = $("#cedula").val();
        var nombre = $("#nombre").val();

        if(cedula !== ''){
            if(nombre !== ''){
                var a = cargarLoader("Cargando...");
                $.ajax({
                    type:'POST',
                    url:'${createLink(controller: 'inicio', action: 'generar_ia_tramite')}',
                    data:{
                        texto: texto,
                        cedula: cedula,
                        nombre: nombre
                    },
                    success: function(msg){
                        a.modal("hide");
                        $("#respuesta").html(msg)
                    }
                })
            }else{
                bootbox.alert('<i class="fa fa-exclamation-triangle text-danger fa-3x"></i> ' + '<strong style="font-size: 14px">' + "Ingrese un nombre" + '</strong>');
            }
        }else{
            bootbox.alert('<i class="fa fa-exclamation-triangle text-danger fa-3x"></i> ' + '<strong style="font-size: 14px">' + "Ingrese un número de cédula" + '</strong>');
        }
    }

    $("#cedula").keydown(function (ev) {
        return validarNum(ev)
    });

    function validarNum(ev) {
        /*
         48-57      -> numeros
         96-105     -> teclado numerico
         188        -> , (coma)
         190        -> . (punto) teclado
         110        -> . (punto) teclado numerico
         8          -> backspace
         46         -> delete
         9          -> tab
         37         -> flecha izq
         39         -> flecha der
         */
        return ((ev.keyCode >= 48 && ev.keyCode <= 57) ||
            (ev.keyCode >= 96 && ev.keyCode <= 105) ||
            ev.keyCode === 8 || ev.keyCode === 46 || ev.keyCode === 9 ||
            ev.keyCode === 37 || ev.keyCode === 39);
    }


    $(".form-control").keydown(function (ev) {
        if (ev.keyCode === 13) {
            cargarRespuestaIA();
            return false;
        }
        return true;
    });

</script>

</body>
</html>
