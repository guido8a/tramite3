<g:if test="${personasDoc.size() > 0}">
    <div class="alert alert-info" style="padding:5px; font-size: 14px">
        <ul>
            <li>Ya se ha asignado el permiso de imprimir a <strong>${personasDoc.persona.login.join(', ')}</strong>.</li>
            <li>Si asigna permiso de imprimir a otro usuario se eliminará el anterior.</li>
        </ul>
    </div>
</g:if>

<div class="row">
    <div class="col-md-2">
        <label>Personal:</label>
    </div>
    <div class="col-md-6">
        <g:select from="${personal}" name="iden" optionKey="id" class="form-control" style='width: 400px;'/>
    </div>
</div>
<div class="row">
    <div class="col-md-2">
        <label>Observaciones:</label>
    </div>
    <div class="col-md-6">
        <g:textArea name="observImp_name" style='width: 400px; height: 80px; resize: none;' id='observImp'/>
    </div>
</div>





