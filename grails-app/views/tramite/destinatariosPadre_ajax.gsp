<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 29/12/20
  Time: 13:29
--%>

<g:each in="${personaDocuTra}" var="pdt" status="j">
    <span style="font-weight: bold">${pdt.rolPersonaTramite.descripcion}:</span>
    <span style="margin-right: 10px">
        ${(pdt.departamento) ? pdt.departamento : "" + pdt.persona.departamento.codigo + ":" + pdt.persona}
        ${pdt.fechaRecepcion ? "(" + pdt.fechaRecepcion.format("dd-MM-yyyy") + ")" : ""}
    </span><br>
</g:each>