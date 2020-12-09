<%@ page import="tramites.EstadoTramiteExterno" %>

<i class='fa fa-sync-alt fa-3x pull-left text-default text-shadow'></i>

<p class='lead' style="margin-left: 5px">
       Va a cambiar el estado del trámite <strong> ${params.tramiteInfo}</strong>.
</p>

<p>
    Estado actual: <strong style="color: #78b665">${tramite.estadoTramiteExterno.descripcion}</strong>
</p>

<div class="row">
    <label class="col-md-2">Estado:</label>
    <div class="col-md-6">
        <g:select name="estadoExterno" from="${tramites.EstadoTramiteExterno.list([sort: 'descripcion'])}"
                  optionKey="id" optionValue="descripcion" class="form-control" value="${tramite.estadoTramiteExternoId}"/>
    </div>
</div>
