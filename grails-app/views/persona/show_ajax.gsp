<%@ page import="seguridad.Persona" %>

<g:if test="${!personaInstance}">
    <elm:notFound elem="Persona" genero="o"/>
</g:if>
<g:else>
    <div class="modal-contenido">
        <div class="row">
            <label class="col-md-3  text-info">
                Usuario/Login
            </label>
            <div class="col-md-3 text-success">
                ${personaInstance?.login}
            </div>
        </div>
        <div class="row">
            <label class="col-md-3  text-info">
                Nombre
            </label>
            <div class="col-md-3">
                ${personaInstance?.nombre}
            </div>

            <label class="col-md-2  text-info">
                Apellido
            </label>
            <div class="col-md-4">
                ${personaInstance?.apellido}
            </div>
        </div>
        <div class="row">
            <label class="col-md-3  text-info">
                Cédula
            </label>
            <div class="col-md-3">
                ${personaInstance?.cedula}
            </div>

            <label class="col-md-2  text-info">
                Sexo
            </label>
            <div class="col-md-4">
                ${personaInstance?.sexo == 'F' ? 'Femenino' : 'Masculino'}
            </div>
        </div>
        <div class="row">
            <label class="col-md-3  text-info">
                Email
            </label>
            <div class="col-md-3">
                ${personaInstance?.mail}
            </div>

            <label class="col-md-2  text-info">
                Teléfono
            </label>
            <div class="col-md-4">
                ${personaInstance?.telefono}
            </div>
        </div>
        <div class="row">
            <label class="col-md-3  text-info">
                Dirección
            </label>
            <div class="col-md-6">
                ${personaInstance?.direccion}
            </div>
        </div>
        <div class="row">
            <label class="col-md-3  text-info">
                Cargo
            </label>
            <div class="col-md-3">
                ${personaInstance?.cargo}
            </div>

            <label class="col-md-2  text-info">
                Título
            </label>
            <div class="col-md-4">
                ${personaInstance?.titulo}
            </div>
        </div>
        <div class="row">
            <label class="col-md-3  text-info">
                Activo
            </label>
            <div class="col-md-3" style="color: ${personaInstance?.activo == 1 ? '#47B636' : '#c42623'}">
                <strong>${personaInstance?.activo == 1 ? 'SI' : 'NO'}</strong>
            </div>

            <label class="col-md-2  text-info">
                Discapacidad
            </label>
            <div class="col-md-4">
                ${personaInstance?.discapacidad == 1 ? 'SI' : 'NO'}
            </div>
        </div>
        <div class="row">
            <label class="col-md-3  text-info">
                Fecha de Inicio
            </label>
            <div class="col-md-3">
                ${personaInstance?.fechaInicio?.format("dd-MM-yyyy")}
            </div>

            <g:if test="${personaInstance?.fechaFin}">
                <label class="col-md-2  text-info">
                    Fecha Fin
                </label>
                <div class="col-md-4">
                    ${personaInstance?.fechaFin?.format("dd-MM-yyyy")}
                </div>
            </g:if>
        </div>
    </div>
</g:else>