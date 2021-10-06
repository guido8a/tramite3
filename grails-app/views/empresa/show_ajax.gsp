<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 04/10/21
  Time: 11:52
--%>

<g:if test="${empresa?.ruc}">
    <div class="row">
        <div class="col-md-2 text-info">
            RUC
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="ruc"/>
        </div>
    </div>
</g:if>

<g:if test="${empresa?.nombre}">
    <div class="row">
        <div class="col-md-2 text-info">
            Nombre
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="nombre"/>
        </div>
    </div>
</g:if>

<g:if test="${empresa?.sigla}">
    <div class="row">
        <div class="col-md-2 text-info">
            Sigla
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="sigla"/>
        </div>
    </div>
</g:if>

<g:if test="${empresa?.codigo}">
    <div class="row">
        <div class="col-md-2 text-info">
            Código
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="codigo"/>
        </div>
    </div>
</g:if>

<g:if test="${empresa?.descripcion}">
    <div class="row">
        <div class="col-md-2 text-info">
            Descripción
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="descripcion"/>
        </div>
    </div>
</g:if>

<g:if test="${empresa?.direccion}">
    <div class="row">
        <div class="col-md-2 text-info">
            Dirección
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="direccion"/>
        </div>
    </div>
</g:if>

<g:if test="${empresa?.email}">
    <div class="row">
        <div class="col-md-2 text-info">
            Email
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="email"/>
        </div>
    </div>
</g:if>

<g:if test="${empresa?.telefono}">
    <div class="row">
        <div class="col-md-2 text-info">
            Teléfono
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="telefono"/>
        </div>
    </div>
</g:if>

<g:if test="${empresa?.observaciones}">
    <div class="row">
        <div class="col-md-2 text-info">
            Observaciones
        </div>
        <div class="col-md-3">
            <g:fieldValue bean="${empresa}" field="observaciones"/>
        </div>
    </div>
</g:if>