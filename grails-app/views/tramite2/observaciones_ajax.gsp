<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 03/12/20
  Time: 10:16
--%>

<g:if test="${tramite?.observaciones}">
    <div class="alert alert-success">
        Observaciones anteriores:

        <br>${tramite?.observaciones}

    </div>
</g:if>

<g:textArea name="txaObsJefe_name" id="txaObsJefe" style='height: 130px;resize: none' class='form-control'/>