<%@ page contentType="text/html" %>

<html>
<head>
    <meta name="layout" content="main"/>
    <title>Parámetros</title>

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
        color: #494949 !important;
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
    <li><a data-toggle="pill" href="#obra">Obras</a></li>
    <li><a data-toggle="pill" href="#cont">Contratación</a></li>
</ul>

<div class="tab-content">
    <div id="generales" class="tab-pane fade in active">

        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>
                    <g:link class="link btn btn-success btn-ajax example_c item " texto="admn" controller="administracion" action="list">
                        <i class="fa fa-crown fa-4x text-success"></i>
                        <br/> Administración
                    </g:link>

                    <g:link class="link btn btn-info btn-ajax example_c item" texto="grgf"  controller="canton" action="arbol">
                        <i class="fa fa-map-marked-alt fa-4x text-success"></i>
                        <br/> Divisi&oacute;n geogr&aacute;fica del Pa&iacute;s
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="undd" controller="unidad" action="list">
                        <i class="fa fa-underline fa-4x text-success"></i>
                        <br/> Unidad
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="trnp" controller="transporte" action="list">
                        <i class="fa fa-truck fa-4x text-success"></i>
                        <br/> Transporte
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="dire" controller="direccion" action="list">
                        <i class="fa fa-list fa-4x text-success"></i>
                        <br/> Direcciones del Personal
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="dpto" controller="departamento" action="arbol">
                        <i class="fa fa-building fa-4x text-success"></i>
                        <br/> Coordinación del Personal
                    </g:link>
                </p>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="func" controller="funcion" action="list">
                        <i class="fa fa-id-badge fa-4x text-success"></i>
                        <br/> Funciones del Personal
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="ddlb" controller="diaLaborable" action="calendario">
                        <i class="fa fa-calendar-day fa-4x text-success"></i>
                        <br/> Días Laborables
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="anio" controller="anio" action="list">
                        <i class="fab fa-amilia fa-4x text-success"></i>
                        <br/> Ingreso de Años
                    </g:link>
                    <a href="#" class="btn btn-success bt-ajax example_c item" texto="iva" id="btnIva">
                        <i class="fa fa-file-invoice-dollar fa-4x text-success"></i>
                        <br/> Iva
                    </a>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="crit" controller="criterio" action="list">
                        <i class="fa fa-hand-point-up fa-4x text-success"></i>
                        <br/> Criterio
                    </g:link>
%{--                    <g:link class="link btn btn-success btn-ajax example_c item" texto="rltr" controller="parametros" action="cargarDatos">--}%
%{--                        <i class="fa fa-upload fa-4x"></i>--}%
%{--                        <br/> Cargar Datos--}%
%{--                    </g:link>--}%
                </p>
            </div>
        </div>
    </div>

    <div id="obra" class="tab-pane fade">

        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="tpob" controller="tipoProyecto" action="list">
                        <i class="fa fa-list-alt fa-4x text-success"></i>
                        <br/> Tipo de Proyecto
                    </g:link>

                    <g:link class="link btn btn-info btn-ajax example_c item disabled" texto="prsp"  controller="presupuesto" action="list">
                        <i class="fa fa-building fa-4x"></i>
                        <br/> Partida Presupuestaria
                    </g:link>

                    <g:link class="link btn btn-success btn-ajax example_c item disabled" texto="auxl" controller="auxiliar" action="textosFijos">
                        <i class="fa fa-building fa-4x"></i>
                        <br/> Textos Fijos
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="anua" controller="valoresAnuales" action="list">
                        <i class="fa fa-search-dollar fa-4x text-success"></i>
                        <br/> Valores Anuales
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="listas" controller="tipoLista" action="list">
                        <i class="fa fa-list-alt fa-4x text-success"></i>
                        <br/> Tipo de listas de precios
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="adqu" controller="tipoAdquisicion" action="list">
                        <i class="fa fa-cubes fa-4x text-success"></i>
                        <br/> Tipo de Adquisición
                    </g:link>
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="prog" controller="programacion" action="list">
                        <i class="fa fa-stopwatch fa-4x text-success"></i>
                        <br/> Programacion
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="prof" controller="proforma" action="proforma">
                        <i class="fa fa-file-export fa-4x text-success"></i>
                        <br/> Proforma
                    </g:link>
                </p>
            </div>
        </div>
    </div>

    <div id="cont" class="tab-pane fade">
        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="tpgr" controller="tipoGarantia" action="list">
                        <i class="fab fa-gofore fa-4x text-success"></i>
                        <br/>Tipo de Garantía
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="tdgr" controller="tipoDocumentoGarantia" action="list">
                        <i class="fab fa-gofore fa-4x text-success"></i>
                        <br/> Tipo de documento de garantía
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="edgr" controller="estadoGarantia" action="list">
                        <i class="fab fa-gofore fa-4x text-success"></i>
                        <br/> Estado de la garantía
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="asgr" controller="aseguradora" action="list">
                        <i class="fab fa-adn fa-4x text-success"></i>
                        <br/> Aseguradora
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="tpas" controller="tipoAseguradora" action="list">
                        <i class="fab fa-adn fa-4x text-success"></i>
                        <br/> Tipo de aseguradora
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item disabled" texto="itun" controller="unidadIncop" action="calendario">
                        <i class="fa fa-building fa-4x"></i>
                        <br/> Unidad del Item
                    </g:link>
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12 col-xs-5">
                <p>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="tppt" controller="tipoProcedimiento" action="list">
                        <i class="fa fa-file-powerpoint fa-4x text-success"></i>
                        <br/>Tipo de procedimiento
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="tpcp" controller="tipoCompra" action="list">
                        <i class="fa fa-cash-register fa-4x text-success"></i>
                        <br/> Tipo de compra
                    </g:link>
                    <g:link class="link btn btn-success btn-ajax example_c item" texto="fnfn" controller="fuenteFinanciamiento" action="list">
                        <i class="fa fa-hand-holding-usd fa-4x  text-success"></i>
                        <br/> Fuente de Financiamiento
                    </g:link>
                </p>
            </div>
        </div>
    </div>

    <div id="tool" style="margin-left: 350px; width: 300px; height: 160px; display: none;padding:25px;"
         class="ui-widget-content ui-corner-all mensaje">
    </div>

</div>

<div id="admn" style="display:none">
    <h3>Autoridad del GADPP</h3><br>

    <p>Administración presente del GADPP</p>
</div>
<div id="grgf" style="display:none">
    <h3>Divisi&oacute;n geogr&aacute;fica del Pa&iacute;s</h3><br>

    <p>Provincias, cantones, parroquias y comunidades</p>
</div>

<div id="tpit" style="display:none">
    <h3>Tipo de ítem</h3><br>

    <p>Diferencia entre los ítems y los rubros. Un rubro se halla conformado por ítems de los grupos: Materiales, Mano de obra y Equipos.</p>
</div>

<div id="undd" style="display:none">
    <h3>Unidad de Medida</h3><br>

    <p>Unidades de medida utilizadas para materiales, mano de obra y equipos</p>
</div>

<div id="grpo" style="display:none">
    <h3>Grupos de Rubros</h3><br>

    <p>Grupos para la clasificación de los rubros para la elaboración de los distintos análisis de precios unitarios</p>
</div>

<div id="trnp" style="display:none">
    <h3>Transporte</h3><br>

    <p>Variable de transporte que define entre Chofer y medio o vehículo de transporte, como Volquetas.</p>
</div>

<div id="dpto" style="display:none">
    <h3>Coordinación</h3><br>

    <p>Distribución administrativa de la institución: nivel de Gestión, que la conforman, para la asociación de los
    empleados a cada uno de ellos.</p>
</div>
<div id="dire" style="display:none">
    <h3>Direcciones</h3><br>

    <p>Distribución administrativa de la institución: Direcciones o según el organigrama del GADPP, nivel de Secretarías.</p>
</div>

<div id="func" style="display:none">
    <h3>Funciones del Personal</h3><br>

    <p>Funciones que una persona puede desempeñar en los procesos de
    contratación y ejecución de obras.</p>
</div>

<div id="iva" style="display:none">
    <h3>IVA</h3><br>
    <p>Permite cambiar el valor del IVA </p>
</div>

<div id="crit" style="display:none">
    <h3>Criterios de selección</h3><br>
    <p>Criterios de selección de precios unitarios </p>
</div>

<div id="prof" style="display:none">
    <h3>Proforma</h3><br>
    <p>Proforma</p>
</div>

%{--
<div id="tpin" style="display:none">
    <h3>Tipo de Indice</h3><br>

    <p>Para distinguir la fuente: INEC o C.G.E., se aplica a la fórmula polinómica y cada uno de sus coeficientes.
    Tanto para la cuadrilla tipo como para fórmula general.</p>
</div>
--}%

<div id="tptr" style="display:none">
    <h3>Tipo de Trámite</h3><br>
    <p>Tipos de trámites a los cuales se asociarán los procesos y documentación. El tipo de trámite sirve para la
    Gestión de procesos y Flujo de trabajo en concordancia con el Sistema de Administración Documental SAD. </p>
</div>
<div id="rltr" style="display:none">
    <h3>Rol de la Persona en el Trámite</h3><br>
    <p>Distintos roles que puede desempeñar una persona en el trámite. </p>
</div>

<div id="tpob" style="display:none">
    <h3>Tipo de Obra</h3><br>
    <p>Tipo de obra a ejecutarse.</p>
</div>
<div id="csob" style="display:none">
    <h3>Clase de Obra</h3><br>
    <p>Clase de obra, ejemplo: aulas, pavimento, cubierta, estructuras, adoquinado, puentes, mejoramiento, etc.</p>
</div>
<div id="prsp" style="display:none">
    <h3>Partida presupuestaria</h3><br>
    <p>Con la cual se financia la obra. El registro se debe hacer conforme se obtenga la partida desde el financiero,
    una vez que se haya expedido la certificación presupuestaria para la obra.</p>
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
    <h3>Textos fijos</h3><br>
    <p>Textos para los documentos precontractuales de presupuesto, volúmenes de obra y fórmula polinómica.</p>
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
    <h3>Variables Anuales</h3><br>
    <p>Valores de las variables anuales.</p>
</div>

%{--
<div id="tpbn" style="display:none">
    <h3>Tipo de Bien</h3><br>
    <p>Detalle de si el bien se halla dentro de la lista de bienes producidos a nivel nacional.</p>
</div>
--}%


<div id="tpcr" style="display:none">
    <h3>Tipo de contrato</h3><br>
    <p>Tipo de contrato que se puede registrar en el sistema, por ejemplo: COntrato, escritura pública, convenio.</p>
</div>
<div id="tpgr" style="display:none">
    <h3>Tipo de garantía</h3><br>
    <p>Tipo de garantía que se debe presentar en el contrato. Puden ser por ejemplo: Buen uso del anticipo, fiel cumplimiento,
    buena calidad de materiales, etc.</p>
</div>
<div id="tdgr" style="display:none">
    <h3>Documento de la garantía</h3><br>
    <p>Documento que se presenta como garantía.</p>
</div>
<div id="edgr" style="display:none">
    <h3>Estado de la garantía</h3><br>
    <p>Estado que puede tener la garantía. Pueden ser por ejemplo: Vigente, pedido de cobro, devuelta, efectivizada, pasivo,
    renovada, vencida, etc.</p>
</div>
<div id="mnda" style="display:none">
    <h3>Moneda de la garantía</h3><br>
    <p>Moneda en la que se entrega la garantía.</p>
</div>
<div id="tpas" style="display:none">
    <h3>Tipo de Aseguradora</h3><br>
    <p>Tipo de aseguradora que emite la garantía, puede ser Banco, Cooperativa, Aseguradora.</p>
</div>
<div id="asgr" style="display:none">
    <h3>Aseguradora</h3><br>
    <p>Aseguradora que emite la garantía, puede ser Banco, Cooperativa, Aseguradora. Se registran los datos de la
    aseguradora</p>
</div>
<div id="itun" style="display: none">
    <h3>Unidad del item</h3>
    <p>Unidades que se emplean en el Pan Anual de Compras Públicas</p>
    <p>Adquisiciones según el INCOP</p>
</div>
<div id="tppt" style="display:none">
    <h3>Tipo de Procedimiento</h3><br>
    <p>Tipo de Procedimiento de contratación según el monto a contratarse.</p>
    <p>Pueden ser: Ínfima Cuantía, Subasta, Licitación, etc.</p>
</div>
<div id="tpcp" style="display: none">
    <h3>Tipo de Compra</h3>
    <p>Tipo de bien que se va a adquirir, pudiendo ser: Bien, Obra, Servcios, Consultoría, etc.</p>
</div>
<div id="fnfn" style="display: none">
    <h3>Fuente de financiamiento</h3>
    <p>Fuente de financiamiento de las partidas presupuestarias</p>
    <p>Entidad que financia la adquisición o construcción.</p>
</div>

<div id="espc" style="display: none">
    <h3>Espacialidad del Proveedor</h3>
    <p>Experiencia o especialidad del proveedor en los servicios que puede proveer</p>
</div>


<div id="edpl" style="display:none">
    <h3>Estado de la Planilla</h3><br>
    <p>Estado que puede tener una planilla dentro del proceso de ejecución de la obra: ingresada, pagada, anulada.</p>
</div>
<div id="tppl" style="display:none">
    <h3>Tipo de Planilla</h3><br>
    <p>Tipo de planilla, pueden ser: anticipo, liquidación, avance de obra, reajuste, etc. </p>
</div>
%{--<div id="tpds" style="display:none">--}%
%{--<h3>Tipo de descuento de una Planilla</h3><br>--}%
%{--<p>Tipo de descuento que puede tener una planilla, pueden ser: anticipo, fiscalización, timbres, etc. </p>--}%
%{--</div>--}%
%{--
<div id="dstp" style="display:none">
    <h3>Descuento por tipo de Planilla</h3><br>
    <p>Descuentos que se aplican a cada tipo de planilla. </p>
</div>
--}%
%{--
<div id="tpml" style="display:none">
    <h3>Tipo de multa</h3><br>
    <p>Tipo de multa que puede tener una planilla, según el contrato, distintos de retraso en obra y presentación de la planilla.</p>
</div>
--}%
<div id="ddlb" style="display:none">
    <h3>Días laborables</h3><br>
    <p>El calendario se genera en forma automática para cada año, con los fines de semana definidos como días no
    laborables, en el se debe corregir para que solo aparezcan señalados los días que no son laborables.
    </p>
</div>




<script type="text/javascript">

    $("#btnIva").click(function () {
         $.ajax({
             type: 'POST',
             url: '${createLink(controller: 'parametros', action: 'formIva_ajax')}',
             data:{
             },
             success: function (msg) {
                 var b = bootbox.dialog({
                     id    : "dlgIva",
                     title : "Iva",
                     message : msg,
                     buttons : {
                         cancelar : {
                             label     : "Cancelar",
                             className : "btn-primary",
                             callback  : function () {
                             }
                         },
                         guardar  : {
                             id        : "btnSave",
                             label     : "<i class='fa fa-save'></i> Guardar",
                             className : "btn-success",
                             callback  : function () {
                                 guardarIva($("#ivaExi").val());
                             } //callback
                         } //guardar
                     } //buttons
                 }); //dialog
             }
         })
    });



    function  guardarIva(iva){
        $.ajax({
           type: 'POST',
           url:'${createLink(controller: 'parametros', action: 'guardarIva_ajax')}',
           data:{
              iva:iva
           },
            success: function (msg) {
               if(msg == 'ok'){
                   log("Iva guardado correctamente", "success")
               }else{
                   log("Error al guardar el Iva","error")
               }
            }
        });
    }


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


    $("#btnCambiarIva").click(function () {
        $.ajax({
            type: "POST",
            url: "${createLink(controller: "obra", action:'formIva_ajax')}",
            data: {

            },
            success: function (msg) {
                var btnOk = $('<a href="#" data-dismiss="modal" class="btn">Cancelar</a>');
                var btnSave = $('<a href="#"  class="btn btn-success"><i class="icon-save"></i> Guardar</a>');

                btnSave.click(function () {
                    $(this).replaceWith(spinner);
                    $.ajax({
                        type: "POST",
                        url: "${createLink(controller: 'obra', action:'guardarIva_ajax')}",
                        data: $("#frmIva").serialize(),
                        success: function (msg) {
//                            if (msg.lastIndexOf("No", 0) == 0) {
//                                alert(msg)
//                            } else {
//                                $("#claseObra").replaceWith(msg);
//                                alert('Clase de obra creada!')
//                            }
                            if(msg == 'ok'){
                                alert('Iva cambiado correctamente!');
                                $("#modal-TipoObra").modal("hide");
                            }else{
                                alert("Error al cambiar el Iva")

                            }
                            $("#modal-TipoObra").modal("hide");
                        }
                    });
                    return false;

                });

                $("#modalHeader_tipo").removeClass("btn-edit btn-show btn-delete");
                $("#modalTitle_tipo").html("Cambiar IVA");
                $("#modalBody_tipo").html(msg);
                $("#modalFooter_tipo").html("").append(btnOk).append(btnSave);
                $("#modal-TipoObra").modal("show");
            }
        });
        return false;

    });

    $(document).ready(function () {
        $('.item').hover(function () {
            $('#tool').html($("#" + $(this).attr('texto')).html());
            $('#tool').show();
        }, function () {
            $('#tool').hide();
        });

        // $('#info').tabs({
        //     cookie:{ expires:30 },
        //     event:'click', fx:{
        //         opacity:'toggle',
        //         duration:'fast'
        //     },
        //     spinner:'Cargando...',
        //     cache:true
        // });
    });
</script>
</body>
</html>
