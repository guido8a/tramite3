
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <meta name="layout" content="main">
        <title>Redireccionar tramites</title>
    </head>

    <body>
        <div class="well">
            <ul>
                <li> Persona de quien se desea redireccionar sus trámites:</li>
            </ul>

            <form class="form-inline" role="form">
                <div class="form-group">
                    <g:textField name="nombre" class="form-control" placeholder="Nombre"/>
                </div>

                <div class="form-group">
                    <g:textField name="apellido" class="form-control" placeholder="Apellido"/>
                </div>

                <div class="form-group">
                    <g:textField name="user" class="form-control" placeholder="Usuario"/>
                </div>

                <a href="#" class="btn btn-info" id="btnBuscar"><i class="fa fa-search"></i> Buscar</a>
            </form>
        </div>
      <strong> * Se muestran máximo 10 coincidencias por búsqueda. </strong>
        <div class="well" id="divPersonas">
            <div class="alert alert-info">
                <i class="fa fa-info-circle text-shadow pull-left fa-5x"></i>
                <ul style="margin-left: 50px">
                    <li>Ingrese uno o varios criterios de búsqueda para ubicar a la persona.</li>
                    <li>Haga clic en el botón Buscar para mostrar los resultados.</li>
                    <li>No se mostrarán más de 10 coincidencias por búsqueda.</li>
                </ul>
            </div>
        </div>

        <script type="text/javascript">
            $(function () {
                $("#btnBuscar").click(function () {
                    var v = cargarLoader("Cargando...");
                    $("#divPersonas").html(spinner);
                    $.ajax({
                        type    : 'POST',
                        url     : '${createLink(controller: 'tramiteAdmin', action: 'buscarPersonasRedireccionar')}',
                        data    : {
                            nombre   : $.trim($("#nombre").val()),
                            apellido : $.trim($("#apellido").val()),
                            user     : $.trim($("#user").val())
                        },
                        success : function (msg) {
                            v.modal("hide");
                            $("#divPersonas").html(msg);
                        }
                    });
                    return false;
                });
            });
        </script>
    </body>
</html>