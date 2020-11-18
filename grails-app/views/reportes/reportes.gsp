<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 21/09/20
  Time: 10:22
--%>

<%@ page contentType="text/html" %>

<html>
<head>
    <meta name="layout" content="main"/>
    <title>Reportes</title>

    %{--    <script type="text/javascript" src="${resource(dir: 'js/jquery/plugins', file: 'jquery.cookie.js')}"></script>--}%

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

%{--<ul class="nav nav-tabs">--}%
<ul class="nav nav-pills">
    <li class="active"><a data-toggle="pill" href="#generales">Generales</a></li>
%{--    <li><a data-toggle="pill" href="#obra">POA</a></li>--}%
%{--    <li><a data-toggle="pill" href="#cont">Datos geográficos</a></li>--}%
</ul>

<div class="tab-content">
    <div id="generales" class="tab-pane fade in active">

        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>
                    <a href="#" id="btnReporteSemaforo" class="btn btn-info btn-ajax example_c item" texto="trnp">
                        <i class="fa fa-traffic-light fa-4x text-success"></i>
                        <br/> Reporte
                    </a>
%{--                    <a href="#" id="btnSocios" class="btn btn-info btn-ajax example_c item" texto="dire">--}%
%{--                        <i class="fa fa-users fa-4x text-success"></i>--}%
%{--                        <br/> Socios--}%
%{--                    </a>--}%
%{--                    <a href="#" id="btnEncuestas" class="btn btn-info btn-ajax example_c item" texto="undd">--}%
%{--                        <i class="fa fa-paste fa-4x text-success"></i>--}%
%{--                        <br/> Encuestas--}%
%{--                    </a>--}%
                </p>
            </div>
        </div>

%{--        <div class="row">--}%
%{--            <div class="col-md-12 col-xs-5">--}%
%{--                <p>--}%
%{--                    <a href="#" id="btnTalleres" class="btn btn-info btn-ajax example_c item" texto="func">--}%
%{--                        <i class="fa fa-book-medical fa-4x text-success"></i>--}%
%{--                        <br/> Talleres--}%
%{--                    </a>--}%
%{--                    <a href="#" id="btnCapacitaciones" class="btn btn-info btn-ajax example_c item" texto="ddlb">--}%
%{--                        <i class="fa fa-atlas fa-4x text-success"></i>--}%
%{--                        <br/> Capacitaciones--}%
%{--                    </a>--}%
%{--                    <a href="#" id="btnConvenios" class="btn btn-info btn-ajax example_c item" texto="auxl">--}%
%{--                        <i class="fa fa-handshake fa-4x text-success"></i>--}%
%{--                        <br/> Convenios--}%
%{--                    </a>--}%
%{--                </p>--}%
%{--            </div>--}%
%{--        </div>--}%
    </div>

%{--    <div id="obra" class="tab-pane fade">--}%
%{--        <div class="row">--}%
%{--            <div class="col-md-12 col-xs-5">--}%
%{--                <p>--}%
%{--                    <a href="#" id="btnPoaFuente" class="btn btn-info btn-ajax example_c item" texto="tpob">--}%
%{--                        <i class="fa fa-list-alt fa-4x text-success"></i>--}%
%{--                        <br/> POA por fuente--}%
%{--                    </a>--}%
%{--                    <a href="#" id="btnPoaComponente" class="btn btn-info btn-ajax example_c item" texto="prsp">--}%
%{--                        <i class="fa fa-list-ol fa-4x text-success"></i>--}%
%{--                        <br/> POA por componente--}%
%{--                    </a>--}%
%{--                    <a href="#" id="btnPoaGrupo" class="btn btn-info btn-ajax example_c item" texto="crit">--}%
%{--                        <i class="fa fa-th-list fa-4x text-success"></i>--}%
%{--                        <br/> POA por grupo de gasto--}%
%{--                    </a>--}%
%{--                    <a href="#" id="btnReporteAsignacionesCrono" class="btn btn-info btn-ajax example_c item" texto="anua">--}%
%{--                        <i class="fa fa-calendar-check fa-4x text-success"></i>--}%
%{--                        <br/> Cronograma valorado--}%
%{--                    </a>--}%
%{--                </p>--}%
%{--            </div>--}%
%{--        </div>--}%
%{--    </div>--}%

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

<div id="trnp" style="display:none">
    <h3>Reporte Semáforo</h3><br>
    <p>Listado de cantones con su respectivo semáforo</p>
</div>


<script type="text/javascript">

    $("#btnReporteSemaforo").click(function () {
        location.href="${createLink(controller: 'reportes', action: 'semaforoExcel')}"
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
