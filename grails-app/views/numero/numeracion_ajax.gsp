<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 23/11/20
  Time: 16:42
--%>

<div class="row">
    <div class="col-md-3">
        <label>Tipo de documento:</label>
    </div>
    <div class="col-md-6">
        <g:select name="tipo" from="${tramites.TipoDocumento.list().sort{it.descripcion}}" class="form-control" optionKey="id" optionValue="descripcion"/>
    </div>
</div>

<div class="row">
    <div class="col-md-3">
        <label>Numeración:</label>
    </div>
    <div class="col-md-2">
        <g:textField name="texto" class="form-control" />
    </div>
</div>

