
<g:set var="cc1" value="${tramite.observaciones.trim().split("\\s+")}"/>
<g:if test="${cc1.length >= 40}">
    <div style="height: 300px; overflow: auto">
        ${tramite?.observaciones}
    </div>
</g:if>
<g:else>
    <div style="height: 100px; overflow: auto">
        ${tramite?.observaciones}
    </div>
</g:else>


