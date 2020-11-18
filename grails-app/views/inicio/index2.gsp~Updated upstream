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

    .color1 {
        background : #e7f5f1;
    }

    .color2 {
        background : #FFF;
    }


    section {
        padding-top: 4rem;
        padding-bottom: 5rem;
        background-color: #f1f4fa;
    }
    .wrap {
        display: flex;
        background: white;
        padding: 1rem 1rem 1rem 1rem;
        border-radius: 0.5rem;
        box-shadow: 7px 7px 30px -5px rgba(0,0,0,0.1);
        margin-bottom: 2rem;
    }

    .wrap:hover {
        background: linear-gradient(135deg,#6394ff 0%,#0a193b 100%);
        color: white;
    }

    .ico-wrap {
        margin: auto;
    }

    .mbr-iconfont {
        font-size: 4.5rem !important;
        color: #313131;
        margin: 1rem;
        padding-right: 1rem;
    }
    .vcenter {
        margin: auto;
    }

    .mbr-section-title3 {
        text-align: left;
    }
    h2 {
        margin-top: 0.5rem;
        margin-bottom: 0.5rem;
    }
    .display-5 {
        font-family: 'Source Sans Pro',sans-serif;
        font-size: 1.4rem;
    }
    .mbr-bold {
        font-weight: 700;
    }

    p {
        padding-top: 0.5rem;
        padding-bottom: 0.5rem;
        line-height: 25px;
    }
    .display-6 {
        font-family: 'Source Sans Pro',sans-serif;
        font-size: 1re
    }

    </style>
</head>

<body>
<div class="dialog">
    <g:set var="inst" value="${utilitarios.Parametros.get(1)}"/>

    <div style="text-align: center;margin-bottom: 20px"><h2 class="titl">
        %{--            <p class="text-warning">${inst.institucion}</p>--}%
        <p class="text-warning">Sistema de Administración del Proyecto FAREPS</p>
    </h2>
    </div>




    %{--    <section>--}%
    %{--        <div class="container">--}%

    <div class="row mbr-justify-content-center">

    <a href= "${createLink(controller:'proyecto', action: 'proy', id:1)}" style="text-decoration: none">
        <div class="col-lg-6 mbr-col-md-10">
            <div class="wrap">
                <div class="ico-wrap">
                    %{--                            <span class="mbr-iconfont fa-volume-up fa"></span>--}%
                    <asset:image src="apli/proyecto.png" title="Marco lógico de Proyecto"  width="80%" height="80%"/>
                </div>
                <div class="text-wrap vcenter">
                    <h2 class="mbr-fonts-style mbr-bold mbr-section-title3 display-5"><span>Proyecto</span></h2>
                    <p class="mbr-fonts-style text1 mbr-text display-6">Fortalecimiento de los Actores Rurales de la Economía Popular y Solidaria</p>
                </div>
            </div>
        </div>
    </a>
    <a href= "${createLink(controller:'taller', action: 'listTaller')}" style="text-decoration: none">
        <div class="col-lg-6 mbr-col-md-10">
            <div class="wrap">
                <div class="ico-wrap">
                    %{--                            <span class="mbr-iconfont fa-calendar fa"></span>--}%
                    <asset:image src="apli/taller.png" title="Talleres" width="80%" height="80%"/>
                </div>
                <div class="text-wrap vcenter">
                    <h2 class="mbr-fonts-style mbr-bold mbr-section-title3 display-5">
                        <span>Talleres</span>
                    </h2>
                    <p class="mbr-fonts-style text1 mbr-text display-6"> Fortalecimiento de las capacidades de las familias y sus organizaciones</p>
                </div>
            </div>
        </div>
    </a>
    <a href= "${createLink(controller:'convenio', action: 'convenio')}" style="text-decoration: none">
        <div class="col-lg-6 mbr-col-md-10">
            <div class="wrap">
                <div class="ico-wrap">
                    %{--                            <span class="mbr-iconfont fa-calendar fa"></span>--}%
                    <asset:image src="apli/convenio.png" title="Convenios" width="80%" height="80%"/>
                </div>
                <div class="text-wrap vcenter">
                    <h2 class="mbr-fonts-style mbr-bold mbr-section-title3 display-5">
                        <span>Convenios</span>
                    </h2>
                    <p class="mbr-fonts-style text1 mbr-text display-6"> Fortalecimiento de las capacidades de las familias y sus organizaciones</p>
                </div>
            </div>
        </div>
    </a>
    <div class="col-lg-6 mbr-col-md-10">
        <div class="wrap">
            <div class="ico-wrap">
                %{--                            <span class="mbr-iconfont fa-calendar fa"></span>--}%
                <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="80%" height="80%"/>
            </div>
            <div class="text-wrap vcenter">
                <h2 class="mbr-fonts-style mbr-bold mbr-section-title3 display-5">
                    <span>Plan opetativo anual</span>
                </h2>
                <p class="mbr-fonts-style text1 mbr-text display-6"> Fortalecimiento de las capacidades de las familias y sus organizaciones</p>
            </div>
        </div>
    </div>
        <div class="col-lg-6 mbr-col-md-10">
            <div class="wrap">
                <div class="ico-wrap">
%{--                    <span class="mbr-iconfont fa-trophy fa"></span>--}%
                    <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="80%" height="80%"/>
                </div>
                <div class="text-wrap vcenter">
                    <h2 class="mbr-fonts-style mbr-bold mbr-section-title3 display-5"><span>Ajustes</span></h2>
                    <p class="mbr-fonts-style text1 mbr-text display-6">Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum</p>
                </div>
            </div>
        </div>
    <div class="col-lg-6 mbr-col-md-10">
        <div class="wrap">
            <div class="ico-wrap">
                %{--                    <span class="mbr-iconfont fa-trophy fa"></span>--}%
                <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="80%" height="80%"/>
            </div>
            <div class="text-wrap vcenter">
                <h2 class="mbr-fonts-style mbr-bold mbr-section-title3 display-5"><span>Reformas</span></h2>
                <p class="mbr-fonts-style text1 mbr-text display-6">Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum</p>
            </div>
        </div>
    </div>




    </div>

    %{--        </div>--}%

    %{--    </section>--}%

    %{--    <div class="body ui-corner-all" style="width: 860px;position: relative;margin: auto;margin-top: 40px;height: 280px; ">--}%

    %{--        <a href= "${createLink(controller:'proyecto', action: 'proy', id:1)}" style="text-decoration: none">--}%
    %{--            <div class="ui-corner-all item fuera">--}%
    %{--                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">--}%
    %{--                    <div class="imagen">--}%
    %{--                        <asset:image src="apli/proyecto.png" title="Marco lógico de Proyecto"  width="100%"--}%
    %{--                                     height="100%"/>--}%
    %{--                    </div>--}%
    %{--                    <span class="texto">--}%
    %{--                        <span class="text-success" style="text-align: center"><strong>Proyecto</strong></span>--}%
    %{--                    </span>--}%
    %{--                    <div style="display: inline">--}%
    %{--                        Fortalecimiento de los Actores Rurales de la Economía Popular y Solidaria--}%
    %{--                    </div>--}%
    %{--                </div>--}%
    %{--            </div>--}%
    %{--        </a>--}%

    %{--        <a href= "${createLink(controller:'taller', action: 'listTaller')}" style="text-decoration: none">--}%
    %{--            <div class="ui-corner-all item fuera">--}%
    %{--                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">--}%
    %{--                    <div class="imagen">--}%
    %{--                        <asset:image src="apli/taller.png" title="Talleres" width="100%" height="100%"/>--}%
    %{--                    </div>--}%
    %{--                    <span class="texto">--}%
    %{--                        <span class="text-success"><strong>Talleres</strong></span>--}%
    %{--                    </span>--}%
    %{--                    <div style="display: inline">--}%
    %{--                        Fortalecimiento de las capacidades de las familias y sus organizaciones--}%
    %{--                    </div>--}%
    %{--                </div>--}%
    %{--            </div>--}%
    %{--        </a>--}%

    %{--        <a href= "${createLink(controller:'convenio', action: 'convenio')}" style="text-decoration: none">--}%
    %{--            <div class="ui-corner-all item fuera">--}%
    %{--                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">--}%
    %{--                    <div class="imagen">--}%
    %{--                        <asset:image src="apli/convenio.png" title="Convenios" width="100%" height="100%"/>--}%
    %{--                    </div>--}%
    %{--                    <span class="texto">--}%
    %{--                        <span class="text-success"><strong>Convenios</strong></span>--}%
    %{--                    </span>--}%
    %{--                    <div style="display: inline">--}%
    %{--                        Convenios...--}%
    %{--                    </div>--}%
    %{--                </div>--}%
    %{--            </div>--}%
    %{--        </a>--}%

    %{--        <a href= "${createLink(controller:'proyecto', action: 'registroProyecto')}" style="text-decoration: none">--}%
    %{--            <div class="ui-corner-all item fuera">--}%
    %{--                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">--}%
    %{--                    <div class="imagen">--}%
    %{--                        <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="100%" height="100%"/>--}%
    %{--                    </div>--}%
    %{--                    <span class="texto">--}%
    %{--                        <span class="text-success"><strong>Plan Operativo Anual</strong></span>--}%
    %{--                    </span>--}%
    %{--                    <div style="display: inline">--}%
    %{--                        POA...--}%
    %{--                    </div>--}%
    %{--                </div>--}%
    %{--            </div>--}%
    %{--        </a>--}%

    %{--        <a href= "${createLink(controller:'proyecto', action: 'registroProyecto')}" style="text-decoration: none">--}%
    %{--            <div class="ui-corner-all item fuera">--}%
    %{--                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">--}%
    %{--                    <div class="imagen">--}%
    %{--                        <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="100%" height="100%"/>--}%
    %{--                    </div>--}%
    %{--                    <span class="texto">--}%
    %{--                        <span class="text-success"><strong>Administración del POA</strong></span>--}%
    %{--                    </span>--}%
    %{--                    <div style="display: inline">--}%
    %{--                        Avales...--}%
    %{--                    </div>--}%
    %{--                </div>--}%
    %{--            </div>--}%
    %{--        </a>--}%

    %{--        <a href= "${createLink(controller:'proyecto', action: 'registroProyecto')}" style="text-decoration: none">--}%
    %{--            <div class="ui-corner-all item fuera">--}%
    %{--                <div class="ui-corner-all item" style="padding-left: 10px; padding-right: 10px">--}%
    %{--                    <div class="imagen">--}%
    %{--                        <asset:image src="apli/plan.png" title="Plan Operativo Anual" width="100%" height="100%"/>--}%
    %{--                    </div>--}%
    %{--                    <span class="texto">--}%
    %{--                        <span class="text-success"><strong>Seguimiento</strong></span>--}%
    %{--                    </span>--}%
    %{--                    <div style="display: inline">--}%
    %{--                        Ejecución del POA...--}%
    %{--                    </div>--}%
    %{--                </div>--}%
    %{--            </div>--}%
    %{--        </a>--}%

    %{--    </div>--}%


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
