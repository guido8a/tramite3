<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 14/12/20
  Time: 11:48
--%>

                            <span class="small">
                                <strong>CC:</strong>
                                <g:each in="${tramite.copias}" var="c" status="i">
                                    <g:if test="${c.persona}">
                                        ${c.persona.nombre} ${c.persona.apellido} (${c.persona.departamento?.codigo})${i < tramite.copias.size() - 1 ? ', ' : ''}
                                    </g:if>
                                    <g:elseif test="${c.departamento}">
                                        ${c.departamento.codigo}${i < tramite.copias.size() - 1 ? ', ' : ''}
                                    </g:elseif>
                                </g:each>
                            </span>