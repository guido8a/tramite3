<%@ page import="tramites.PersonaDocumentoTramite; tramites.DocumentoTramite; tramites.RolPersonaTramite" %>

<style type="text/css">
.claseMin {
    max-height: 60px;
    overflow: auto;
}
</style>

<g:set var="recibe" value="${tramites.RolPersonaTramite.get(3)}"/>
<g:set var="trmtpara" value="${tramites.RolPersonaTramite.get(1)}"/>

<div style="max-height: 500px; overflow-y: auto; overflow-x: hidden;font-size: 11px">
    <g:if test="${tp}">
        <div style="margin-bottom: 20px;min-height: 140px" class="vertical-container">
            <p class="css-vertical-text">T. Principal</p>

            <div class="linea"></div>

            <div class="row">
                <div class="col-xs-1 negrilla">No:</div>
                <div class="col-xs-5">${tp.codigo}</div>
                <div class="col-xs-1 negrilla">Fecha:</div>
                <div class="col-xs-5">${tp.fechaCreacion.format("dd-MM-yyyy HH:mm")}</div>
            </div>

            <g:if test="${tp.tipoTramite.codigo == 'C'}">
                <div class="row">
                    <div class="col-xs-2 negrilla">Confidencial</div>
                </div>
            </g:if>
            <div class="row">
                <div class="col-xs-1 negrilla">De:</div>

                <div class="col-xs-5 alert alert-info" style="min-height: 60px">
                    <g:if test="${tp.tipoDocumento.codigo == 'DEX'}">
                        ${tp.paraExterno} (EXT)
                    </g:if>
                    <g:else>
                        ${tp.deDepartamento ? tp.deDepartamento.codigo : "" + tp.de.departamento.codigo + ":" + tp.de.nombre + ' ' + tp.de.apellido}
                    </g:else>
                </div>

                <div class="col-xs-5 claseMin alert alert-success"  style="min-height: 60px">
                    <g:each in="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(tp, rolesNo, [sort: 'rolPersonaTramite'])}" var="pdt" status="j">
                        <g:set var="fecha" value=""/>
                        <g:set var="estado" value=""/>
                        <g:if test="${pdt?.estado?.codigo == 'E006'}">
                            <g:set var="estado" value="ANULADO"/>
                            <g:set var="fecha" value="${pdt.fechaAnulacion?.format('dd-MM-yyyy HH:mm')}"/>
                        </g:if>
                        <g:else>
                            <g:if test="${pdt?.estado?.codigo == 'E003' && pdt.fechaEnvio}">
                                <g:set var="estado" value="ENVIADO"/>
                                <g:set var="fecha" value="${pdt.fechaEnvio?.format('dd-MM-yyyy HH:mm')}"/>
                            </g:if>
                            <g:else>
                                <g:if test="${pdt?.estado?.codigo == 'E004' && pdt.fechaRecepcion}">
                                    <g:set var="estado" value="RECIBIDO"/>
                                    <g:set var="fecha" value="${pdt.fechaRecepcion?.format('dd-MM-yyyy HH:mm')}"/>
                                </g:if>
                                <g:else>
                                    <g:set var="estado" value="CREADO"/>
                                    <g:set var="fecha" value="${pdt.tramite.fechaCreacion?.format('dd-MM-yyyy HH:mm')}"/>
                                </g:else>
                                <g:if test="${pdt?.estado?.codigo == 'E005' && pdt.fechaArchivo}">
                                    <g:set var="estado" value="ARCHIVADO"/>
                                    <g:set var="fecha" value="${pdt.fechaArchivo?.format('dd-MM-yyyy HH:mm')}"/>
                                </g:if>
                            </g:else>
                        </g:else>

                        <span style="font-weight: bold">${pdt.rolPersonaTramite.descripcion}:</span>
                        <g:if test="${tp.tipoDocumento.codigo == 'OFI' && pdt.rolPersonaTramite.codigo == 'R001'}">
                            ${tp.paraExterno} (EXT)
                        </g:if>
                        <g:else>
                            ${(pdt.departamento) ? pdt?.departamento?.codigo : "" + pdt.persona?.departamento?.codigo + ":" + pdt.persona?.login}
                        </g:else>

                        <div>
                            <b><span style="${pdt?.estado?.codigo == 'E006' || pdt?.estado?.codigo == 'E005' ? 'color:red' : ''}">${estado}</span>
                            </b> el ${fecha} <br>
                        </div>

                    </g:each>
                </div>
            </div>

            <div class="row">
                <div class="col-xs-1 negrilla text-info">Asunto:</div>
                <div class="col-xs-10 text-info">${tp.asunto.decodeHTML()}</div>
            </div>

            <g:if test="${tp.personaPuedeLeer(session.usuario) && tp.texto?.size() > 2}">
                <div class="row" style="margin-bottom: 10px">
                    <div class="col-xs-1 negrilla">Texto:</div>

                    <div class="col-xs-10" style="background: #dedede; max-height: 300px; overflow: auto;">
                        <util:renderHTML html="${tp.texto}"/>
                    </div>
                </div>
            </g:if>
            <g:if test="${tp.observaciones}">
                <div class="row" style="margin-bottom: 10px">
                    <div class="col-xs-1 negrilla">Obser:</div>

                    <div class="col-xs-10  claseMin">${tp.observaciones}</div>
                </div>
            </g:if>

            <g:if test="${tp.anexo == 1}">
                <g:if test="${tp.personaPuedeLeerAnexo(session.usuario)}">
                    <div class="row" style="margin-bottom: 10px;margin-left: 2px">
                        <g:each in="${DocumentoTramite.findAllByTramite(tp)}" var="anexo" status="k">
                            <span style='color: #327BBA'>Archivo:</span>
                            ${anexo.path}
                            <a href='#' class='btn btn-success bajar' style='margin-right: 15px' title="Descargar Archivo" iden="${anexo.id}">
                                <i class="fa fa-download"></i>
                            </a>
                            ${anexo.descripcion}
                            <br>
                        </g:each>
                    </div>
                </g:if>
            </g:if>
        </div>
    </g:if>
    <g:each in="${tramites}" var="t" status="i">
        <g:if test="${i == 0}">
            <div style="margin-bottom: 20px;min-height: 140px" class="vertical-container">
                <p class="css-vertical-text">D. Principal</p>

                <div class="linea"></div>

                <div class="row">
                    <div class="col-xs-1 negrilla">No:</div>
                    <div class="col-xs-5">${t.codigo}</div>
                    <div class="col-xs-1 negrilla">Fecha:</div>
                    <div class="col-xs-5">${t.fechaCreacion.format("dd-MM-yyyy HH:mm")}</div>
                </div>
                <g:if test="${t.tipoTramite.codigo == 'C'}">
                    <div class="row">
                        <div class="col-xs-2 negrilla">Confidencial</div>
                    </div>
                </g:if>
                <div class="row">
                    <div class="col-xs-1 negrilla">De:</div>

                    <div class="col-xs-5 alert alert-info"  style="min-height: 60px">
                        <g:if test="${t.tipoDocumento.codigo == 'DEX'}">
                            ${t.paraExterno} (EXT)
                        </g:if>
                        <g:else>
                            ${(t?.departamentoNombre ?: '') + ":" + (t?.persona ?: '')}
                        </g:else>
                    </div>

                    %{--                    <div class="col-xs-6 claseMin alert-success" style="background-color: #d0d0d0; overflow-y: auto">--}%
                    <div class="col-xs-5 claseMin alert-success" style="overflow-y: auto; min-height: 60px">
                        <g:each in="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(t, rolesNo, [sort: 'rolPersonaTramite'])}" var="pdt" status="j">
                            <g:set var="fecha" value=""/>
                            <g:set var="estado" value=""/>
                            <g:if test="${pdt?.estado?.codigo == 'E006'}">
                                <g:set var="estado" value="ANULADO"/>
                                <g:set var="fecha" value="${pdt.fechaAnulacion?.format('dd-MM-yyyy HH:mm')}"/>
                            </g:if>
                            <g:else>
                                <g:if test="${pdt?.estado?.codigo == 'E003' && pdt.fechaEnvio}">
                                    <g:set var="estado" value="ENVIADO"/>
                                    <g:set var="fecha" value="${pdt.fechaEnvio?.format('dd-MM-yyyy HH:mm')}"/>
                                </g:if>
                                <g:else>
                                    <g:if test="${pdt?.estado?.codigo == 'E004' && pdt.fechaRecepcion}">
                                        <g:set var="estado" value="RECIBIDO"/>
                                        <g:set var="fecha" value="${pdt.fechaRecepcion?.format('dd-MM-yyyy HH:mm')}"/>
                                    </g:if>
                                    <g:else>
                                        <g:set var="estado" value="CREADO"/>
                                        <g:set var="fecha" value="${pdt.tramite.fechaCreacion?.format('dd-MM-yyyy HH:mm')}"/>
                                    </g:else>
                                    <g:if test="${pdt?.estado?.codigo == 'E005' && pdt.fechaArchivo}">
                                        <g:set var="estado" value="ARCHIVADO"/>
                                        <g:set var="fecha" value="${pdt.fechaArchivo?.format('dd-MM-yyyy HH:mm')}"/>
                                    </g:if>
                                </g:else>
                            </g:else>
                            <span style="font-weight: bold">${pdt.rolPersonaTramite.descripcion}:</span>
                            <g:if test="${t.tipoDocumento.codigo == 'OFI' && pdt.rolPersonaTramite.codigo == 'R001'}">
                                ${t.paraExterno} (EXT)
                            </g:if>
                            <g:else>
                                <g:if test="${pdt?.persona}">
                                    ${pdt?.persona}
                                </g:if>
                                <g:else>
                                    ${pdt?.departamentoNombre}
                                </g:else>
                            </g:else>

                            <div>
                                <b><span style="${pdt?.estado?.codigo == 'E006' || pdt?.estado?.codigo == 'E005' ? 'color:red' : ''}">${estado}</span>
                                </b> el ${fecha} <br>
                            </div>

                            <g:set var="recibidoVar2" value="${tramites.PersonaDocumentoTramite.findByTramiteAndRolPersonaTramiteAndDepartamentoPersona(pdt?.tramite, recibe, pdt.departamento)?.personaNombre}"/>

                            <g:if test="${recibidoVar2 && tramite.estadoTramite.codigo == 'E004'}">
                                <div class="col-xs-4 negrilla">RECIBIDO POR: </div>
                                <div class="col-xs-8">${recibidoVar2}</div>
                            </g:if>
                            <br/>
                        </g:each>
                    </div>
                </div>

                <g:if test="${t.tipoDocumento.codigo == 'DEX'}">
                    <div class="row">
                        <div class="col-xs-2 negrilla">Num. Doc.:</div>
                        <div class="col-xs-3">${t.numeroDocExterno} </div>

                        <div class="col-xs-1 negrilla">Teléfono:</div>
                        <div class="col-xs-3">${t?.telefono}
                        </div>

                    </div>
                    <div class="row" style="align-content: flex-start">

                        <div class="col-xs-2 negrilla">Contacto:</div>
                        <div class="col-xs-3">${t?.contacto}
                        </div>

                        <div class="col-xs-1 negrilla">Email:</div>
                        <div class="col-xs-3">${t?.mail} </div>
                    </div>
                </g:if>

                <div class="row">
                    <div class="col-xs-1 negrilla text-info">Asunto:</div>
                    <div class="col-xs-10 text-info">${t.asunto.decodeHTML()}</div>
                </div>

                <g:if test="${t.personaPuedeLeer(session.usuario) && t.texto?.size() > 2}">
                    <div class="row" style="margin-bottom: 10px">
                        <div class="col-xs-1 negrilla">Texto:</div>

                        <div class="col-xs-10" style="background: #dedede; max-height: 300px; overflow: auto;">
                            <util:renderHTML html="${t.texto}"/>
                        </div>
                    </div>
                </g:if>
                <g:if test="${t.observaciones}">
                    <div class="row" style="margin-bottom: 10px">
                        <div class="col-xs-1 negrilla">Obser:</div>

                        <div class="col-xs-10  claseMin">${t.observaciones}</div>
                    </div>
                </g:if>
                <g:if test="${t.anexo == 1}">
                    <g:if test="${t.personaPuedeLeerAnexo(session.usuario)}">
                        <div class="row" style="margin-bottom: 10px;margin-left: 2px">
                            <g:each in="${DocumentoTramite.findAllByTramite(t)}" var="anexo" status="k">
                                <span style='color: #327BBA'>Archivo:</span>
                                ${anexo.path}
                                <a href='#' class='btn btn-success bajar' style='margin-right: 15px' title="Descargar Archivo" iden="${anexo.id}">
                                    <i class="fa fa-download"></i>
                                </a>
                                ${anexo.descripcion}
                                <br>
                            </g:each>
                        </div>
                    </g:if>
                </g:if>
            </div>
        </g:if>
        <g:else>
            <div style="margin-bottom: 20px" class="vertical-container">
                <p class="css-vertical-text">Trámite</p>

                <div class="linea"></div>

                <div class="row">
                    <div class="col-xs-1 negrilla">No:</div>
                    <div class="col-xs-5">${t.codigo}</div>
                    <div class="col-xs-1 negrilla">Fecha:</div>
                    <div class="col-xs-5">${t.fechaCreacion.format("dd-MM-yyyy HH:mm")}</div>
                </div>
                <g:if test="${t.tipoTramite.codigo == 'C'}">
                    <div class="row">
                        <div class="col-xs-2 negrilla">Confidencial</div>
                    </div>
                </g:if>
                <div class="row">
                    <div class="col-xs-1 negrilla">De:</div>

                    <div class="col-xs-5 alert alert-info" style="min-height: 60px">
                        <g:if test="${t.tipoDocumento.codigo == 'DEX'}">
                            ${t.paraExterno} (EXT)
                        </g:if>
                        <g:else>
                            ${(t?.departamentoNombre ?: '') + ":" + (t?.persona ?: '')}
                        </g:else>
                    </div>

                    %{--                    <div class="col-xs-6 claseMin"  style="background-color: #d0d0d0; overflow-y: auto">--}%
                    <div class="col-xs-5 claseMin alert alert-success"  style="overflow-y: auto; min-height: 60px">
                        <g:each in="${tramites.PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteNotInList(t, rolesNo, [sort: 'rolPersonaTramite'])}" var="pdt" status="j">
                            <g:set var="fecha" value=""/>
                            <g:set var="estado" value=""/>
                            <g:if test="${pdt?.estado?.codigo == 'E006'}">
                                <g:set var="estado" value="ANULADO"/>
                                <g:set var="fecha" value="${pdt.fechaAnulacion?.format('dd-MM-yyyy HH:mm')}"/>
                            </g:if>
                            <g:else>
                                <g:if test="${pdt?.estado?.codigo == 'E003' && pdt.fechaEnvio}">
                                    <g:set var="estado" value="ENVIADO"/>
                                    <g:set var="fecha" value="${pdt.fechaEnvio?.format('dd-MM-yyyy HH:mm')}"/>
                                </g:if>
                                <g:else>
                                    <g:if test="${pdt?.estado?.codigo == 'E004' && pdt.fechaRecepcion}">
                                        <g:set var="estado" value="RECIBIDO"/>
                                        <g:set var="fecha" value="${pdt.fechaRecepcion?.format('dd-MM-yyyy HH:mm')}"/>
                                    </g:if>
                                    <g:else>
                                        <g:set var="estado" value="CREADO"/>
                                        <g:set var="fecha" value="${pdt.tramite.fechaCreacion?.format('dd-MM-yyyy HH:mm')}"/>
                                    </g:else>
                                    <g:if test="${pdt?.estado?.codigo == 'E005' && pdt.fechaArchivo}">
                                        <g:set var="estado" value="ARCHIVADO"/>
                                        <g:set var="fecha" value="${pdt.fechaArchivo?.format('dd-MM-yyyy HH:mm')}"/>
                                    </g:if>
                                </g:else>
                            </g:else>

                            <span style="font-weight: bold">${pdt.rolPersonaTramite.descripcion}:</span>
                            <g:if test="${t.tipoDocumento.codigo == 'OFI' && pdt.rolPersonaTramite.codigo == 'R001'}">
                                ${t.paraExterno} (EXT)
                            </g:if>
                            <g:else>
                                <g:if test="${pdt?.persona}">
                                    ${pdt?.persona}
                                </g:if>
                                <g:else>
                                    ${pdt?.departamentoNombre}
                                </g:else>
                            </g:else>

                            <div>
                                <b>
                                    <span style="${pdt?.estado?.codigo == 'E006' || pdt?.estado?.codigo == 'E005' ? 'color:red' : ''}">${estado}</span>
                                </b> el ${fecha} <br>
                            </div>


                            <g:set var="recibidoVar" value="${tramites.PersonaDocumentoTramite.findByTramiteAndRolPersonaTramiteAndDepartamentoPersona(pdt?.tramite,
                                    recibe, pdt?.departamento)?.personaNombre}"/>

                            <g:if test="${recibidoVar && tramite.estadoTramite.codigo == 'E004'}">
                                <div class="col-xs-4 negrilla">RECIBIDO POR: </div>
                                <div class="col-xs-8">${recibidoVar}</div>
                            </g:if>
                        </g:each>
                    </div>
                </div>

                <g:if test="${t.tipoDocumento.codigo == 'DEX'}">
                    <div class="row">

                        <div class="col-xs-2 negrilla">Num. Doc.:</div>
                        <div class="col-xs-3">${t.numeroDocExterno} </div>
                        <div class="col-xs-1 negrilla">Teléfono:</div>
                        <div class="col-xs-3">${t?.telefono}
                        </div>

                    </div>
                    <div class="row" style="align-content: flex-start">

                        <div class="col-xs-2 negrilla">Contacto:</div>
                        <div class="col-xs-3">${t?.contacto}
                        </div>

                        <div class="col-xs-1 negrilla">Email:</div>
                        <div class="col-xs-3">${t?.mail} </div>
                    </div>
                </g:if>

                <div class="row">
                    <div class="col-xs-1 negrilla text-info">Asunto:</div>
                    <div class="col-xs-10 text-info">${t.asunto}</div>
                </div>

                <g:if test="${t.personaPuedeLeer(session.usuario) && t.texto?.size() > 2}">
                    <div class="row" style="margin-bottom: 10px">
                        <div class="col-xs-1 negrilla">Texto:</div>

                        <div class="col-xs-10" style="background: #dedede; max-height: 300px; overflow: auto;">
                            <util:renderHTML html="${t.texto}"/>
                        </div>
                    </div>
                </g:if>

                <g:if test="${t.observaciones}">
                    <div class="row" style="margin-bottom: 10px">
                        <div class="col-xs-1 negrilla">Obser:</div>
                        <div class="col-xs-10  claseMin">${t.observaciones}</div>
                    </div>
                </g:if>
                <g:if test="${t.anexo == 1}">
                    <g:if test="${t.personaPuedeLeerAnexo(session.usuario)}">
                        <div class="row" style="margin-bottom: 10px;margin-left: 2px">
                            <g:each in="${tramites.DocumentoTramite.findAllByTramite(t)}" var="anexo" status="k">
                                <span style='color: #327BBA'>Archivo:</span>
                                ${anexo.path}
                                <a href='#' class='btn btn-success bajar' style='margin-right: 15px' title="Descargar Archivo" iden="${anexo.id}">
                                    <i class="fa fa-download"></i>
                                </a>
                                ${anexo.descripcion}
                                <br>
                            </g:each>
                        </div>
                    </g:if>
                </g:if>
            </div>
        </g:else>
    </g:each>
</div>

<script type="text/javascript">

    $(function() {
        $(".bajar").click(function () {
            var id = $(this).attr("iden");
            openLoader();
            $.ajax({
                type    : "POST",
                url     : "${g.createLink(controller: 'documentoTramite',action: 'generateKey')}",
                data    : "id=" + id,
                success : function (msg) {
                    closeLoader();
                    if (msg == "ok") {
                        location.href = "${g.createLink(controller: 'documentoTramite', action: 'descargarDoc')}/" + id
                    } else {
                        bootbox.alert("No se ha encontrado el archivo solicitado");
                    }
                }
            });
        });
    });
</script>