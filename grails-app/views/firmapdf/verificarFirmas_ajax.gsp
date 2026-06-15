<div class="row">
    <div class="col-md-12">
        <g:if test="${fechas}">
            <table class="table table-condensed table-bordered table-striped">
                <thead>
                <tr>
                    <th>Firma</th>
                    <th>Fecha</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <g:each var="numero" in="${fechas}" status="j">
                    <tr style="width: 100%">
                        <td style="width: 5%">${j+1}</td>
                        <td style="width: 30%; text-align: center">${fechas[j]}</td>
                        <td style="width: 65%">${nombres[j]}</td>
                    </tr>
                </g:each>
                </tbody>
            </table>
        </g:if>
        <g:else>
            <div class="alert alert-fin">
                <i class="fa fa-exclamation-triangle fa-2x text-info"></i> Error al verificar la firma.
            </div>
        </g:else>
    </div>
</div>
