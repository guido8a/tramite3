<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main">
    <title>Parámetros</title>

    <style type="text/css">
    ul {padding:0.2em}
    li {padding:0.2em}

    ul{
        font-size: 14px;
    }
    </style>
</head>

<body>

<elm:flashMessage tipo="${flash.tipo}" clase="${flash.clase}">${flash.message}</elm:flashMessage>

<div class="row">
    <div class="col-md-7">

        <div class="panel panel-primary">
            <div class="panel-heading">
                <h3 class="panel-title">Parámetros del Sistema</h3>
            </div>

            <div class="panel-body">
                <ul class="fa-ul">
                    <li>
                        <i class="fa-li fas fa-users text-success"></i>
                        <g:link data-info="categoria" class="over text-success" controller="departamento" action="arbol">Estructura Departamental
                        </g:link> del GADPP conforme al organigrama de procesos institucional.

                        <div class="descripcion hidden">
                            <h4>Estructura Departamental</h4>
                            <p>Distribución organizacional del GADPP.</p>
                            <p>Conforme a la estructura del orgánico - funcional.</p>
                        </div>
                    </li>
                    <li>
                        <i class="fa-li fas fa-paste text-success"></i>
                        <g:link data-info="categoria" class="over text-success" controller="tipoDocumento" action="list">Tipo de documento</g:link>
                        para diferenciar los distintos documentos que se producen dentro de un trámite, ejemplo:
                    Memorando, Oficio, Sumilla, Circular, etc.

                        <div class="descripcion hidden">
                            <h4>Tipo de Documento</h4>
                            <p>Determina el tipo de documento que se utiliza en los distintos trámites, pueden ser:</p>
                            <p>Memorando, Oficio, Sumilla, Circular, etc.</p>
                        </div>
                    </li>

                    <li>
                        <i class="fa-li fas fa-clock text-success"></i>
                        <g:link data-info="categoria" class="over text-success" controller="tipoPrioridad" action="list">Tipo de Prioridad</g:link> que posee los
                        distintos trámites

                        <div class="descripcion hidden">
                            <h4>Tipo de Prioridad</h4>
                            <p>El tipo de prioridad determina el tiempo que se tiene para dar contestacón al trámite.</p>
                        </div>
                    </li>

                    <li>
                        <i class="fa-li far fa-calendar text-success"></i>
                        <g:link data-info="categoria" class="over text-success" controller="diaLaborable" action="calendario">Días Laborables</g:link> para determinar
                        la secuencia de días que se trabajan y calcular el número de horas laborables requeridos para
                        responder un trámite

                        <div class="descripcion hidden">
                            <h4>Días Laborables</h4>
                            <p>Se usa un calendario para determinar los días laborables y festivos.</p>
                            <p>Esto sirve para fijar la secuencia de días que se trabajan y calcular el número de horas
                            laborables requeridos para responder un trámite</p>
                        </div>
                    </li>

                    <li>
                        <i class="fa-li fas fa-scroll text-success"></i>
                        <g:link data-info="categoria" class="over text-success" controller="parametros" action="list">Parámetros del sistema</g:link> sirve para
                        fijar las horas de la jornada de trabajo por defecto y las direcciones de conexión para la
                        autenticación de los usuarios
                        <div class="descripcion hidden">
                            <h4>Parámetros del Sistema</h4>
                            <p>Fija las horas de la jornada de trabajo por defecto.</p>
                            <p>Ingreso de las direcciones de conexión del servidor LDAP para la
                            autenticación de los usuarios</p>
                            <p>Registro de la Unidad organizacional principal del LDAP</p>
                        </div>
                    </li>

                    <li>
                        <i class="fa-li fas fa-highlighter text-success"></i>
                        <g:link data-info="categoria" class="over text-success" controller="numero" action="list">Fijar números consecutivos por tipo de documento</g:link> sirve para
                        fijar los números consecutivos que se aplican por departamento y tipo de documento

                        <div class="descripcion hidden">
                            <h4>Fijar Consecutivos</h4>
                            <p>Fija los números consecutivos para cada tipo de documento que puede emitir el Departamento.</p>
                            <p>Primero se debe definir que tipos de documentos puede tramitar un Departamento para luego
                            actualizar los números consecutivos que se han de usar</p>
                            <p>Este proceso debe usarse sólo al poner en marcha el sistema</p>

                        </div>
                    </li>

                    <li>
                        <i class="fa-li fa fa-calendar text-success"></i>
                        <g:link data-info="categoria" class="over text-success" controller="estadoTramiteExterno" action="list">Estado de los trámites externos</g:link> sirve para
                        fijar el estado que puede tener un trámite externo

                        <div class="descripcion hidden">
                            <h4>Estado de Trámite Externo</h4>
                            <p>Fija el estado de untrámite externo:</p>
                            <p>Por defecto empieza en "EN TRAMITE"</p>

                        </div>
                    </li>

                    <li>
                        <i class="fa-li fa fa-building text-success"></i>
                        <g:link data-info="categoria" class="over text-success" controller="empresa" action="list">Empresa</g:link> sirve para
                        administrar las empresas ingresadas en el sistema

                        <div class="descripcion hidden">
                            <h4>Empresa</h4>
                            <p>Administración de la información de las empresas</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="panel panel-info right hidden">
            <div class="panel-heading">
                <h3 class="panel-title"></h3>
            </div>

            <div class="panel-body">

            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(function () {
        $(".over").hover(function () {
            var $h4 = $(this).siblings(".descripcion").find("h4");
            var $cont = $(this).siblings(".descripcion").find("p");
            $(".right").removeClass("hidden").find(".panel-title").text($h4.text()).end().find(".panel-body").html($cont.html());
        }, function () {
            $(".right").addClass("hidden");
        });
    });
</script>

</body>
</html>