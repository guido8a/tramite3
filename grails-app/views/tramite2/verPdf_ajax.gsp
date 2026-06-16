
<div style="overflow: hidden">
    <fieldset class="borde" style="border-radius: 4px; margin-bottom: 10px"  >
        <g:if test="${tramite?.firmados != 0}">
            <embed src="${createLink(controller: 'tramite2', action: 'downloadFileFirmado', id: tramite?.id)}" style="width: 100%; height: 600px" type='application/pdf' id="divPDF" >
        </g:if>
        <g:else>
            <embed src="${createLink(controller: 'tramite2', action: 'downloadFile', id: tramite?.id)}" style="width: 100%; height: 600px" type='application/pdf' id="divPDF" >
        </g:else>
    </fieldset>
</div>

