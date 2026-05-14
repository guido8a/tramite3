
<asset:javascript src="/apli/pdf.min.js"/>
<asset:javascript src="/apli/pdf.worker.min.js"/>

<div style="overflow: hidden">
    <fieldset class="borde" style="border-radius: 4px; margin-bottom: 10px"  >
        <embed src="${createLink(controller: 'tramite2', action: 'downloadFile', id: tramite?.id)}" style="width: 100%; height: 600px" type='application/pdf' id="divPDF" >
%{--        <iframe id="pdf-js-viewer" src="${createLink(controller: 'tramite2', action: 'downloadFile', id: tramite?.id)}" title="webviewer" frameborder="0" width="100%" height="700" allowfullscreen="" webkitallowfullscreen=""/>--}%
%{--        <iframe id="pdf-js-viewer" src="${createLink(controller: 'tramite2', action: 'downloadFile', id: tramite?.id)}" title="webviewer" width="100%" height="600" ></iframe>--}%
    </fieldset>
</div>

<script type="text/javascript">


</script>
