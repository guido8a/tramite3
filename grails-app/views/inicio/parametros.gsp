<%@ page contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <meta name="layout" content="main">
        <title>Parámetros</title>

        <style type="text/css">
        ul {padding:0.2em}
        li {padding:0.2em}
        </style>
    </head>

    <body>

        <div class="row">
            <div class="col-md-8">

                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h3 class="panel-title">Parámetros del Sistema</h3>
                    </div>

                    <div class="panel-body">
                        <ul class="fa-ul">
                            <li>
                                <i class="fa-li far fa-bookmark text-info"></i>
                                <g:link data-info="catalogo" class="over" controller="tema" action="list">
                                    Temas
                                </g:link> Tópicos sobre los cuales se recopila lecciones aprendidas en el formato
                                problema - solución

                                <div class="descripcion hidden">
                                    <h4>Temas</h4>

                                    <p>Temas sobre los cuales de ingresan en el sistema lecciones aprendidas<br/>

                                       Se registran los problemas solucionados y el modo de solucionarlos</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fas fa-certificate text-info"></i>
                                <g:link data-info="categoria" class="over" controller="tipoInstitucion" action="list">
                                    Tipos de institución
                                </g:link> para diferenciar entre la Unidad Ejecutora de Proyecto y otras organizaciones

                                <div class="descripcion hidden">
                                    <h4>Tipos de institución</h4>

                                    <p>Además del proyecto FAREPS se registran otros tipos de organizaciones
                                    que van a participar en el proyecto como por ejemplo en Convenios.
                                    </p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fas fa-map-marker-alt text-info"></i>
                                <g:link data-info="categoria" class="over" controller="canton" action="arbol">
                                    Distribución geográfica
                                </g:link> del país para referenciar las metas y los Convenios

                                <div class="descripcion hidden">
                                    <h4>istribución geográfica de Ecuador</h4>

                                    <p>Permitirá referenciar geográficamente las metas del proyeto y los lugares donde
                                        se firmen los Convenios.
                                    </p>
                                    <p>Cuenta con las provincias, cantones y parroquias.
                                    </p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li far fa-money-bill-alt text-info"></i>
                                <g:link class="over" controller="presupuesto" action="arbol">
                                    Plan de cuentas Presupuestario
                                </g:link> o partidas presupuestarias para la asignación de gasto permanente y de inversión

                                <div class="descripcion hidden">
                                    <h4>Plan de cuentas Presupuestario</h4>

                                    <p>Plan de cuentas o de partidas presupuestarias conforme exista en el ESIGEF</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fas fa-scroll text-info"></i>
                                <g:link class="over" controller="tipoElemento" action="list">
                                    Tipo de Elemento
                                </g:link> del marco lógico

                                <div class="descripcion hidden">
                                    <h4>Tipo de Elemento</h4>

                                    <p>Pueden existir varios tipos como: Fin, Propósito, Componestes y Acciones</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fas fa-highlighter text-info"></i>
                                <g:link class="over" controller="indicadorOrms" action="list">
                                    Indicadores ORMS
                                </g:link> que se aplican al proyecto

                                <div class="descripcion hidden">
                                    <h4>Indicadores ORMS</h4>

                                    <p>Indicadores que figuran como parte del Proyeto y que deben figurar tanto en las metas
                                    a cumplir del Proyecto como en la linea base y resultados de los Convenios</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fa fa-calendar text-info"></i>
                                <g:link class="over" controller="anio" action="list">
                                    Año Fiscal
                                </g:link> Año al cual corresponde el POA. Es el período contable o año fiscal

                                <div class="descripcion hidden">
                                    <h4>Año Fiscal</h4>

                                    <p>Año al cual corresponde el POA, cada año debe iniciarse una nueva gestión del
                                    proyecto, definiendo un cronograma y con ello las asignaciones para las disitntas
                                    actividades del POA.</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li far fa-folder text-info"></i>
                                <g:link class="over" controller="grupoProcesos" action="list">
                                    Grupo de procesos
                                </g:link> del proyecto: Inicio, Planificación, ejecución y cierre

                                <div class="descripcion hidden">
                                    <h4>Grupo de procesos</h4>

                                    <p>Sirve para organizar la biblioteca del proyecto y la de los Convenios.</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fa fa-suitcase text-info"></i>
                                <g:link class="over" controller="fuente" action="list">
                                    Fuente de financiamiento
                                </g:link> de las actividades y componentes del Proyecto

                                <div class="descripcion hidden">
                                    <h4>Fuente de financiamiento</h4>

                                    <p>Organismos de financiamiento que paricipan en el Poryecto.<br/>

                                        Cada fuente participa en el financiamiento de la sactividades registradas en el
                                        cronograma y en el Plan de Negocios Solidario.</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fas fa-list text-info"></i>
                                <g:link class="over" controller="mes" action="list">
                                    Meses
                                </g:link> para el registro del cronograma del POA de Proyecto

                                <div class="descripcion hidden">
                                    <h4>Meses</h4>

                                    <p>Sirve para el registro del cronograma del POA del Proyecto.</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fa fa-map-marker text-info"></i>
                                <g:link class="over" controller="unidad" action="list">
                                    Unidad de medida
                                </g:link> para definir las Metas del Proyecto

                                <div class="descripcion hidden">
                                    <h4>Unidad de medida</h4>

                                    <p>Sirve para cuantificar las Metas del Proyecto</p>
                                </div>
                            </li>

                            <li>
                                <i class="fa-li fa fa-map-marker text-warning"></i>
                                <g:link class="over text-warning" controller="aseguradora" action="list">
                                    Aseguradora
                                </g:link> Lista de aseguradoras
                                <div class="descripcion hidden">
                                    <h4>Aseguradora</h4>
                                    <p>Lista de aseguradoras</p>
                                </div>
                            </li>
                            <li>
                                <i class="fa-li fa fa-map-marker text-warning"></i>
                                <g:link class="over text-warning" controller="tipoCategoria" action="list">
                                    Tipo de Categoría
                                </g:link> Lista de tipos de categorías
                                <div class="descripcion hidden">
                                    <h4>Tipo de Categoría</h4>
                                    <p>Lista de tipos de categorías</p>
                                </div>
                            </li>
                            <li>
                                <i class="fa-li fa fa-map-marker text-warning"></i>
                                <g:link class="over text-warning" controller="estadoGarantia" action="list">
                                    Estado de la garantía
                                </g:link> Lista de estados de la garantía
                                <div class="descripcion hidden">
                                    <h4>Estado de la garantía</h4>
                                    <p>Lista de estados de la garantía</p>
                                </div>
                            </li>
                            <li>
                                <i class="fa-li fa fa-map-marker text-warning"></i>
                                <g:link class="over text-warning" controller="tipoNecesidad" action="list">
                                    Tipo de necesidad
                                </g:link> Listado de Tipos de necesidad
                                <div class="descripcion hidden">
                                    <h4>Tipo de necesidad</h4>
                                    <p>Listado de Tipos de necesidad</p>
                                </div>
                            </li>
                            <li>
                                <i class="fa-li fa fa-map-marker text-warning"></i>
                                <g:link class="over text-warning" controller="tipoTaller" action="list">
                                    Tipo de Taller
                                </g:link> Listado de Tipos de talleres
                                <div class="descripcion hidden">
                                    <h4>Tipo de Taller</h4>
                                    <p>Listado de Tipos de talleres</p>
                                </div>
                            </li>
                            <li>
                                <i class="fa-li fa fa-map-marker text-warning"></i>
                                <g:link class="over text-warning" controller="tipoProcesoComprasPublicas" action="list">
                                    Tipo de Proceso
                                </g:link> Listado de Tipos de proceso de comrpas públicas
                                <div class="descripcion hidden">
                                    <h4>Tipo de Proceso</h4>
                                    <p>Listado de Tipos de proceso de comrpas públicas</p>
                                </div>
                            </li>
                            <li>
                                <i class="fa-li fas fa-chart-line text-success"></i>
                                <g:link class="over text-success" controller="tipoEvaluacion" action="list">
                                    Tipo de evaluación
                                </g:link> de los indicadores del Convenio: Linea base y Evaluaciones posteriores

                                <div class="descripcion hidden">
                                    <h4>Tipo de evaluación</h4>

                                    <p>Se refiere al momento en el cual se relaiza la evaluación de los indicadores
                                    del Convenio o del Proyecto en general para facilitar su seguimiento y determinar
                                    su evolución, en la cuantificación de resultados obtenidos</p>
                                </div>
                            </li>
                            <li>
                                <i class="fa-li fas fa-box text-success"></i>
                                <g:link class="over text-success" controller="unidadCompras" action="list">
                                    Unidad de compras públicas
                                </g:link> para la contratación de bienes o servicios del PNS

                                <div class="descripcion hidden">
                                    <h4>Unidad de compras públicas</h4>

                                    <p>Sirve para el registro del bien o servicio a contratarse como
                                    parte del Plan de Negocios Solidario</p>
                                </div>
                            </li>
%{--
                            <li>
                                <i class="fa-li fas fa-boxes text-success"></i>
                                <g:link class="over text-success" controller="macroActividad" action="list">
                                    Código de compras publicas
                                </g:link> para la contratación de bienes o servicios del PNS

                                <div class="descripcion hidden">
                                    <h4>Código de compras publicas</h4>

                                    <p>Sirve para el registro del bien o servicio a contratarse como
                                    parte del Plan de Negocios Solidario</p>
                                </div>
                            </li>
--}%
%{--
                            <li>
                                <i class="fa-li far fa-calendar-alt text-success"></i>
                                <g:link class="over text-success" controller="macroActividad" action="list">
                                    Periodo del plan
                                </g:link> para las actividades del PNS

                                <div class="descripcion hidden">
                                    <h4>Periodo del plan</h4>

                                    <p>Sirve para el registro en detalle de las actividades del Plan de Negocios
                                    Solidario, una vez que se tiene la fecha de inicio del Convenio.</p>
                                </div>
                            </li>
--}%
                            <li>
                                <i class="fa-li fas fa-cogs text-success"></i>
                                <g:link class="over text-success" controller="estadoAval" action="list">
                                    Estado del Aval y Reforma
                                </g:link> para la emisión de Avales y Reformas al POA

                                <div class="descripcion hidden">
                                    <h4>Estado del Aval y Reforma</h4>

                                    <p>Sirve para el registro del proceso de emisión de Avales y Reformas.</p>
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