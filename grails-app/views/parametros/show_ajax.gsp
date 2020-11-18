
<%@ page import="utilitarios.Parametros" %>

<g:if test="${!parametrosInstance}">
    <elm:notFound elem="Parametros" genero="o" />
</g:if>
<g:else>


    <g:if test="${parametrosInstance?.institucion}">
        <div class="row">
            <div class="col-md-2 text-info">
                Institución
            </div>

            <div class="col-md-5">
                <g:fieldValue bean="${parametrosInstance}" field="institucion"/>
            </div>

        </div>
    </g:if>

    <div class="row">
        <g:if test="${parametrosInstance?.horaInicio}">
                <div class="col-md-3 text-info">
                    Hora Inicio de la Jornada de Trabajo
                </div>

                <div class="col-md-3">
                    <g:fieldValue bean="${parametrosInstance}" field="horaInicio"/> :
                    <g:fieldValue bean="${parametrosInstance}" field="minutoInicio"/>
                </div>
        </g:if>
        <g:if test="${parametrosInstance?.horaFin}">
                <div class="col-md-3 text-info">
                    Hora Fin dela Jornada de Trabajo
                </div>

                <div class="col-md-3">
                    <g:fieldValue bean="${parametrosInstance}" field="horaFin"/> :
                    <g:fieldValue bean="${parametrosInstance}" field="minutoFin"/>
                </div>
        </g:if>
    </div>

%{--    <g:if test="${parametrosInstance?.imagenes}">--}%
%{--        <div class="row">--}%
%{--            <div class="col-md-2 text-info">--}%
%{--                Imágenes--}%
%{--            </div>--}%
%{--            --}%
%{--            <div class="col-md-3">--}%
%{--                <g:fieldValue bean="${parametrosInstance}" field="imagenes"/>--}%
%{--            </div>--}%
%{--        </div>--}%
%{--    </g:if>--}%

</g:else>