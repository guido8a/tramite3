<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="seguridad.Persona" %>

<html xmlns="http://www.w3.org/1999/html">
<head>
    <title>Trámites</title>
    <meta name="layout" content="main"/>
    <style type="text/css">
    @page {
        size: 8.5in 11in;  /* width height */
        margin: 0.25in;
    }

    .item {
        width: 260px;
        height: 260px;
        float: left;
        margin: 4px;
        font-family: 'open sans condensed';
        border: none;

    }

    .imagen {
        width: 160px;
        height: 160px;
        margin: auto;
        margin-top: 10px;
    }

    .texto {
        width: 90%;
        height: 50px;
        padding-top: 0px;
        margin: auto;
        margin: 8px;
        font-size: 16px;
        font-style: normal;
    }

    .fuera {
        margin-left: 15px;
        margin-top: 20px;
        background-color: rgba(200, 200, 200, 0.9);
        border: none;
    }

    .titl {
        font-family: 'open sans condensed';
        font-weight: bold;
        text-shadow: -2px 2px 1px rgba(0, 0, 0, 0.25);
        color: #0070B0;
        margin-top: 10px;
        background: transparent;
        pointer-events: none;
        position: relative;
        z-index: 100;
    }

    body {
        font-family: 'Poppins', sans-serif;
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
    }

    .quotes {
        width: 100%;
        min-height: 400px;
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
        z-index: 2;
    }

    .quotes .box {
        position: relative;
        width: 35vw;
        height: 300px;
        min-height: 100px;
        background: #f2f2f2;
        overflow: hidden;
        transition: all 0.5s ease-in;
        z-index: 2;
        box-sizing: border-box;
        padding: 30px;
        box-shadow: -10px 25px 50px rgba(0, 0, 0, 0.3);
        border-radius: 10px;
    }

    .quotes .box::before {
        content: '\201C';
        position: absolute;
        top: -20px;
        left: 5px;
        width: 100%;
        height: 100%;
        font-size: 120px;
        opacity: 0.2;
        background: transparent;
        pointer-events: none;
    }

    .quotes .box::after {
        content: '\201D';
        position: absolute;
        bottom: -20%;
        right: 5%;
        font-size: 120px;
        opacity: 0.2;
        background: transparent;
        filter: invert(1);
        pointer-events: none;
    }

    .quotes .box p {
        margin: 0;
        padding: 10px;
        font-size: 1.2rem;
    }

    .quotes .box h2 {
        position: absolute;
        margin: 0;
        padding: 0;
        bottom: 10%;
        right: 10%;
        font-size: 1.5rem;
    }

    .quotes .box:hover {
        color: #f2f2f2;
        box-shadow: 20px 50px 100px rgba(0, 0, 0, 0.5);
    }

    .quotes .bg {
        position: absolute;
        top: 0;
        left: 0;
        z-index: 1;
        opacity: 0;
        transition: all 0.5s ease-in;
        pointer-events: none;
        width: 100%;
        height: 100%;
        overflow: hidden;
    }

    .quotes .box.box1:hover,
    .quotes .box.box1:hover~.bg {
        opacity: 1;
        background: #e5ab9e;
        background: -moz-linear-gradient(-45deg, #e5ab9e 15%, #2b94e5 100%);
        background: -webkit-linear-gradient(-45deg, #e5ab9e 15%,#2b94e5 100%);
        background: linear-gradient(135deg, #e5ab9e 15%,#2b94e5 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#e2a9e5', endColorstr='#2b94e5',GradientType=1 );
    }

    .quotes .box.box2:hover,
    .quotes .box.box2:hover~.bg {
        opacity: 1;
        background: #75a9b9;
        background: -moz-linear-gradient(-45deg, #75a9b9 15%, #e5b596 100%);
        background: -webkit-linear-gradient(-45deg, #75a9b9 15%,#e5b596 100%);
        background: linear-gradient(135deg, #75a9b9 15%,#e5b596 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#75a9b9', endColorstr='#e5b596',GradientType=1 );
    }

    .quotes .box.box3:hover,
    .quotes .box.box3:hover~.bg {
        opacity: 1;
        background: #4b384c;
        background: -moz-linear-gradient(-45deg, #4b384c 15%, #da5de2 100%);
        background: -webkit-linear-gradient(-45deg, #4b384c 15%,#da5de2 100%);
        background: linear-gradient(135deg, #4b384c 15%,#da5de2 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#4b384c', endColorstr='#da5de2',GradientType=1 );
    }

    </style>
</head>

<body>
<div style="text-align: center;">
    <h2 class="titl">Trámites<br>
        SISTEMA DE ADMINISTRACIÓN DOCUMENTAL<br/>
        Tedein S.A.</h2>
</div>

<g:if test="${!(session.usuario.getPuedeDirector() || session.usuario.getPuedeJefe())}">

    <div class="quotes" style="margin-top: 100px">
        <div class="card">
            <div class="box box1">
                <g:if test="${session.usuario.esTriangulo()}">
                    <a href= "${createLink(controller:'tramite3', action: 'bandejaEntradaDpto')}" style="text-decoration: none" onclick="cargarLoader('Cargando...')">
                </g:if>
                <g:else>
                    <a href= "${createLink(controller:'tramite', action: 'bandejaEntrada')}" style="text-decoration: none" onclick="cargarLoader('Cargando...')">
                </g:else>

                <div class="imagen">
                    <asset:image src="apli/entrada.png" style="padding: 10px; width: 100%; height:100%"/>
                </div>

                <div class="texto"><span class="text-success"><strong>Bandeja de entrada</strong></span>: trámites que ingresan y pendientes de contestación</div>
            </a>
            </div>
            <div class="bg"></div>
        </div>
        <div class="card">
            <div class="box box2">
                <g:if test="${session.usuario.esTriangulo()}">
                    <a href= "${createLink(controller:'tramite2', action: 'bandejaSalidaDep')}" style="text-decoration: none" onclick="cargarLoader('Cargando...')">
                </g:if>
                <g:else>
                    <a href= "${createLink(controller:'tramite2', action: 'bandejaSalida')}" style="text-decoration: none" onclick="cargarLoader('Cargando...')">
                </g:else>

                <div class="imagen">
                    <asset:image src="apli/salida.png" style="padding: 10px; width: 100%; height:100%"/>
                </div>

                <div class="texto"><span class="text-info"><strong>Bandeja de salida</strong></span>: trámites por enviar y que no han sido recibidos</div>
            </a>
            </div>
            <div class="bg"></div>
        </div>
    </div>
</g:if>

<div style="text-align: center; margin-top: 100px">

    <g:if test="${session.usuario.getPuedeDirector()}">
        <g:link controller="departamento" action="arbolReportes" class="openImagenDir" params="[dpto: Persona.get(session.usuario.id).departamento.id, inicio: '1', dir: '1']">
            <asset:image src="ingreso_adm.png" style="width: 360px"/>
        </g:link>
    </g:if>

    <g:if test="${session.usuario.getPuedeJefe()}">
        <g:link controller="departamento" action="arbolReportes" class="openImagen" params="[dpto: Persona.get(session.usuario.id).departamento.id, inicio: '1']">
            <asset:image src="ingreso_adm.png" style="width: 360px"/>
        </g:link>
    </g:if>

</div>

<script type="text/javascript">

    $(function () {
        $(".openImagenDir").click(function () {
            cargarLoader("Cargando...");
        });

        $(".openImagen").click(function () {
            cargarLoader("Cargando....");
        });
    });
</script>
</body>
</html>
