<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="seguridad.Persona" %>

<html xmlns="http://www.w3.org/1999/html">
<head>
    <title>Proyecto FAREPS</title>
    <meta name="layout" content="main"/>
    <style type="text/css">
    @page {
        size: 8.5in 11in;  /* width height */
        margin: 0.25in;
    }

    .item {
        width: 260px;
        height: 225px;
        float: left;
        margin: 4px;
        font-family: 'open sans condensed';
        background-color: #e7f5f1;
        border: 1px;
        border-color: #5c6e80;
        border-style: solid;
    }
    .item2 {
        width: 660px;
        height: 160px;
        float: left;
        margin: 4px;
        font-family: 'open sans condensed';
        background-color: #eceeff;
        border: 1px;
        border-color: #5c6e80;
        border-style: solid;
    }

    .imagen {
        width: 200px;
        height: 140px;
        margin: auto;
        margin-top: 10px;
    }
    .imagen2 {
        width: 180px;
        height: 130px;
        margin: auto;
        margin-top: 10px;
        margin-right: 40px;
        float: right;
    }

    .texto {
        width: 90%;
        /*height: 50px;*/
        padding-top: 0px;
        margin: auto;
        margin: 8px;
        font-size: 16px;
        font-style: normal;
    }

    .fuera {
        margin-left: 15px;
        margin-top: 20px;
        /*background-color: #317fbf; */
        background-color: rgba(114, 131, 147, 0.9);
        border: none;
    }

    .titl {
        font-family: 'open sans condensed';
        font-weight: bold;
        text-shadow: -2px 2px 1px rgba(0, 0, 0, 0.25);
        color: #0070B0;
        margin-top: 20px;
    }

    body {
        background : #e5e4e7;
    }
    </style>
</head>

<body>
<div class="dialog">
    <g:set var="inst" value="${utilitarios.Parametros.get(1)}"/>

    <div style="text-align: center;"><h2 class="titl">
        %{--            <p class="text-warning">${inst.institucion}</p>--}%
        <p class="text-warning">Sistema de Administración del Proyeto FAREPS</p>
    </h2>
    </div>

    <div class="body ui-corner-all" style="width: 860px;position: relative;margin: auto;margin-top: 40px;height: 280px; ">

        <a href= "${createLink(controller:'proyecto', action: 'proy', id:1)}" style="text-decoration: none">
            <div class="ui-corner-all item fuera">
                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">
                    <div class="imagen">
                        <asset:image src="apli/proyecto.png" title="Marco lógico de Proyecto"  width="100%"
                                     height="100%"/>
                    </div>
                    <span class="texto">
                        <span class="text-success" style="text-align: center"><strong>Proyecto</strong></span>
                    </span>
                    <div style="display: inline">
                        Fortalecimiento de los Actores Rurales de la Economía Popular y Solidaria
                    </div>
                </div>
            </div>
        </a>

        <a href= "${createLink(controller:'taller', action: 'listTaller')}" style="text-decoration: none">
            <div class="ui-corner-all item fuera">
                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">
                    <div class="imagen">
                        <asset:image src="apli/taller.png" title="Talleres" width="100%" height="100%"/>
                    </div>
                    <span class="texto">
                        <span class="text-success"><strong>Talleres</strong></span>
                    </span>
                    <div style="display: inline">
                        Fortalecimiento de las capacidades de las familias y sus organizaciones
                    </div>
                </div>
            </div>
        </a>

        <a href= "${createLink(controller:'convenio', action: 'convenio')}" style="text-decoration: none">
            <div class="ui-corner-all item fuera">
                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">
                    <div class="imagen">
                        <asset:image src="apli/convenio.png" title="Convenios" width="100%" height="100%"/>
                    </div>
                    <span class="texto">
                        <span class="text-success"><strong>Convenios</strong></span>
                    </span>
                    <div style="display: inline">
                        Convenios...
                    </div>
                </div>
            </div>
        </a>

        <a href= "${createLink(controller:'proyecto', action: 'registroProyecto')}" style="text-decoration: none">
            <div class="ui-corner-all item fuera">
                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">
                    <div class="imagen">
                        <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="100%" height="100%"/>
                    </div>
                    <span class="texto">
                        <span class="text-success"><strong>Plan Operativo Anual</strong></span>
                    </span>
                    <div style="display: inline">
                        POA...
                    </div>
                </div>
            </div>
        </a>

        <a href= "${createLink(controller:'proyecto', action: 'registroProyecto')}" style="text-decoration: none">
            <div class="ui-corner-all item fuera">
                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">
                    <div class="imagen">
                        <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="100%" height="100%"/>
                    </div>
                    <span class="texto">
                        <span class="text-success"><strong>Administración del POA</strong></span>
                    </span>
                    <div style="display: inline">
                        Avales...
                    </div>
                </div>
            </div>
        </a>

        <a href= "${createLink(controller:'proyecto', action: 'registroProyecto')}" style="text-decoration: none">
            <div class="ui-corner-all item fuera">
                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">
                    <div class="imagen">
                        <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="100%" height="100%"/>
                    </div>
                    <span class="texto">
                        <span class="text-success"><strong>Seguimiento</strong></span>
                    </span>
                    <div style="display: inline">
                        Ejecución del POA...
                    </div>
                </div>
            </div>
        </a>

    </div>


</div>
<script type="text/javascript">
    $(".fuera").hover(function () {
        var d = $(this).find(".imagen,.imagen2")
        d.width(d.width() + 10)
        d.height(d.height() + 10)

    }, function () {
        var d = $(this).find(".imagen, .imagen2")
        d.width(d.width() - 10)
        d.height(d.height() - 10)
    })


    $(function () {
        $(".openImagenDir").click(function () {
            openLoader();
        });

        $(".openImagen").click(function () {
            openLoader();
        });
    });



</script>
</body>
</html>
