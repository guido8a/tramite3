<%@ page contentType="text/html" %>

<html>
<head>
    <meta name="layout" content="main"/>
    <title>Reportes</title>

    <style type="text/css">

    .tab-content, .left, .right {
        height : 500px;
    }

    .tab-content {
        background    : #EEEEEE;
        border-left   : solid 1px #DDDDDD;
        border-bottom : solid 1px #DDDDDD;
        border-right  : solid 1px #DDDDDD;
        padding-top   : 10px;
    }

    .descripcion {
        /*margin-left : 20px;*/
        font-size : 12px;
        border    : solid 2px cadetblue;
        padding   : 0 10px;
        margin    : 0 10px 0 0;
    }

    .info {
        font-style : italic;
        color      : navy;
    }

    .descripcion h4 {
        color      : cadetblue;
        text-align : center;
    }

    .left {
        width : 600px;
        text-align: justify;
        /*background : red;*/
    }

    .right {
        width       : 300px;
        margin-left : 20px;
        padding: 20px;
        /*background  : blue;*/
    }

    .fa-ul li {
        margin-bottom : 10px;
    }

    .example_c {
        color: #808b9d !important;
        /*text-transform: uppercase;*/
        text-decoration: none;
        background: #ffffff;
        padding: 20px;
        border: 4px solid #78b665 !important;
        display: inline-block;
        transition: all 0.4s ease 0s;
    }

    .example_c:hover {
        color: #ffffff !important;
        background: #f6b93b;
        border-color: #f6b93b !important;
        transition: all 0.4s ease 0s;
    }


    .mensaje {
        color: #494949 !important;
        /*text-transform: uppercase;*/
        text-decoration: none;
        background: #ffffff;
        padding: 20px;
        border: 4px solid #f6b93b !important;
        display: inline-block;
        transition: all 0.4s ease 0s;
    }

    </style>


</head>

<body>


<g:set var="iconGen" value="fa fa-cog"/>
<g:set var="iconEmpr" value="fa fa-building-o"/>

<ul class="nav nav-pills">
    <li class="active"><a data-toggle="pill" href="#generales">Generales</a></li>
    <li><a data-toggle="pill" href="#obra">Trámites</a></li>
%{--    <li><a data-toggle="pill" href="#cont">Personales / Oficina</a></li>--}%
</ul>

<div class="tab-content">
    <div id="generales" class="tab-pane fade in active">

        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>

                    <a href="#" id="btnBloqueadas" class="btn btn-info btn-ajax example_c item" texto="trnp">
                        <i class="fa fa-user-slash fa-4x text-success"></i>
                        <br/> Bandejas bloqueadas
                    </a>
                    <a href="#" id="btnDepartamentos" class="btn btn-info btn-ajax example_c item" texto="dire">
                        <i class="fa fa-building fa-4x text-success"></i>
                        <br/> Departamentos
                    </a>
                    <a href="#" id="btnEmpleados" class="btn btn-info btn-ajax example_c item" texto="undd">
                        <i class="fa fa-users fa-4x text-success"></i>
                        <br/> Empleados
                    </a>
                </p>
            </div>
        </div>
    </div>

    <div id="obra" class="tab-pane fade">
        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>
                    <a href="#" id="btnAnulados" class="btn btn-info btn-ajax example_c item" texto="tpob">
                        <i class="fa fa-ban fa-4x text-success"></i>
                        <br/> Anulados
                    </a>
                    <a href="#" id="btnArchivados" class="btn btn-info btn-ajax example_c item" texto="prsp">
                        <i class="fa fa-file-archive fa-4x text-success"></i>
                        <br/> Archivados
                    </a>
                    <a href="#" id="btnPersonal" class="btn btn-info btn-ajax example_c item" texto="crit">
                        <i class="fa fa-user fa-4x text-success"></i>
                        <br/> Personales
                    </a>
                    <a href="#" id="btnOficina" class="btn btn-info btn-ajax example_c item" texto="anua">
                        <i class="fa fa-home fa-4x text-success"></i>
                        <br/> Oficina
                    </a>
                </p>
            </div>
        </div>
    </div>

%{--    <div id="cont" class="tab-pane fade">--}%
%{--        <div class="row">--}%
%{--            <div class="col-md-12 col-xs-5">--}%
%{--                <p>--}%
%{--                    <g:link class="link btn btn-info btn-ajax example_c item" texto="grgf"  controller="reportes" action="mapa">--}%
%{--                        <i class="fa fa-map-marked-alt fa-4x text-success"></i>--}%
%{--                        <br/> Localización de proyectos--}%
%{--                    </g:link>--}%
%{--                </p>--}%
%{--            </div>--}%
%{--        </div>--}%
%{--    </div>--}%

    <div id="tool" style="margin-left: 350px; width: 300px; height: 160px; display: none;padding:25px;"
         class="ui-widget-content ui-corner-all mensaje">
    </div>

</div>

<div id="grgf" style="display:none">
    <h3>Localización geográfica</h3><br>
    <p>Mapa que contiene la localización geográfica de los proyectos</p>
</div>

<div id="undd" style="display:none">
    <h3>Reporte de encuestas</h3><br>
    <p>Reporte de las encuestas generadas en el sistema</p>
</div>

<div id="trnp" style="display:none">
    <h3>Organizaciones</h3><br>
    <p>Listado de organizaciones por provincia.</p>
</div>

<div id="dpto" style="display:none">
    <h3>Socios</h3><br>
    <p>Listado de socios por organización.</p>
</div>

<div id="dire" style="display:none">
    <h3>Socios</h3><br>
    <p>Listado de socios por organización.</p>
</div>

<div id="func" style="display:none">
    <h3>Talleres</h3><br>
    <p>Listado de capacitaciones que ha recibido una organización.</p>
</div>

<div id="crit" style="display:none">
    <h3>POA por grupo de gasto</h3><br>
    <p>Ejecución del POA por grupo de gasto</p>
</div>

<div id="tpob" style="display:none">
    <h3>POA por fuente</h3><br>
    <p>Ejecución del POA por fuente de financiamiento.</p>
</div>
<div id="csob" style="display:none">
    <h3>Clase de Obra</h3><br>
    <p>Clase de obra, ejemplo: aulas, pavimento, cubierta, estructuras, adoquinado, puentes, mejoramiento, etc.</p>
</div>
<div id="prsp" style="display:none">
    <h3>POA por componente</h3><br>
    <p>Ejecución del POA por componente y actividad.</p>
</div>
<div id="edob" style="display:none">
    <h3>Estado de la Obra</h3><br>
    <p>Estado de la obra durante el proyecto de construcción, para distinguir entre: precontractual, ofertada, contratada, etc.</p>
</div>
<div id="prog" style="display:none">
    <h3>Programa</h3><br>
    <p>Programa del cual forma parte una obra o proyecto.</p>
</div>
<div id="auxl" style="display:none">
    <h3>Convenios consolidados</h3><br>
    <p>Listado de convenios.</p>
</div>
<div id="tpfp" style="display:none">
    <h3>Tipo de fórmula polinómica</h3><br>
    <p>Tipo de forma polínomica que tiene el contrato, puede ser contractual o de liquidación.</p>
</div>
<div id="var" style="display:none">
    <h3>Variables</h3><br>
    <p>Valores de parámetros de transporte y costos indirectos que se usan por defecto en las obras.</p>
</div>
<div id="anio" style="display:none">
    <h3>Ingreso de Años</h3><br>
    <p>Registro de los años para el control y manejo de los índices año por año.</p>
</div>
<div id="anua" style="display:none">
    <h3>Cronograma valorado</h3><br>
    <p>Cronograma valorado por año</p>
</div>
<div id="fnfn" style="display: none">
    <h3>Fuente de financiamiento</h3>
    <p>Fuente de financiamiento de las partidas presupuestarias</p>
    <p>Entidad que financia la adquisición o construcción.</p>
</div>
<div id="ddlb" style="display:none">
    <h3>Capacitaciones</h3><br>
    <p>Listado de capacitaciones por provincia</p>
</div>

<script type="text/javascript">

    $("#btnEmpleados").click(function () {
        location.href="${createLink(controller: 'departamentoExport', action: 'reporteConUsuarios')}";
    });

    $("#btnPersonal").click(function () {
        location.href="${createLink(controller: 'reportesPersonales', action: 'personal')}";
    });

    $("#btnOficina").click(function () {
        location.href="${createLink(controller: 'departamento', action: 'arbolReportes')}";
    });

    $("#btnArchivados").click(function () {
        location.href="${createLink(controller: 'buscarTramite', action: 'busquedaArchivados')}";
    });

    $("#btnAnulados").click(function () {
        location.href="${createLink(controller: 'buscarTramite', action: 'busquedaAnulados')}";
    });


    $("#btnDepartamentos").click(function () {
        location.href="${createLink(controller: 'departamentoExport', action: 'reporteSinUsuarios')}";
    });

    $("#btnBloqueadas").click(function () {
        // var cl1 = cargarLoader("Cargando....");
        location.href="${createLink(controller: 'bloqueados', action: 'reporteConsolidado')}";
     });

    function prepare() {
        $(".fa-ul li span").each(function () {
            var id = $(this).parents(".tab-pane").attr("id");
            var thisId = $(this).attr("id");
            $(this).siblings(".descripcion").addClass(thisId).addClass("ui-corner-all").appendTo($(".right." + id));
        });
    }

    $(function () {
        prepare();
        $(".fa-ul li span").hover(function () {
            var thisId = $(this).attr("id");
            $("." + thisId).removeClass("hide");
        }, function () {
            var thisId = $(this).attr("id");
            $("." + thisId).addClass("hide");
        });
    });

    $(document).ready(function () {
        $('.item').hover(function () {
            $('#tool').html($("#" + $(this).attr('texto')).html());
            $('#tool').show();
        }, function () {
            $('#tool').hide();
        });
    });
</script>
</body>
</html>