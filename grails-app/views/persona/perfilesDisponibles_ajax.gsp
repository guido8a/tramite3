<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 26/06/20
  Time: 10:52
--%>

<g:if test="${perfiles.size() > 0}">
    <div class="col-md-10">
        <g:select name="perfil" from="${perfiles}" class="form-control input-sm"
                  optionKey="id" optionValue="nombre"/>
    </div>
    <div class="col-md-2">
        <a href="#" class="btn btn-success btn-sm" id="btn-addPerfil" title="Agregar perfil">
            <i class="fa fa-plus"></i> Agregar perfil
        </a>
    </div>
</g:if>
<g:else>
    <g:select name="perfil" from="${perfiles}" class="form-control input-sm"
              optionKey="id" optionValue="nombre" noSelection="[null: 'Sin perfiles disponibles']"/>
</g:else>

<script type="text/javascript">

    $("#btn-addPerfil").click(function () {
        var perfil = $("#perfil option:selected").val();
        $.ajax({
           type: 'POST',
           url: '${createLink(controller: 'persona', action: 'agregarPerfil_ajax')}',
           data:{
              id:'${persona?.id}',
              perfil: perfil
           },
           success: function(msg){
               if(msg == 'ok'){
                   log("Perfil asignado correctamente","success");
                   cargarPerfilesDisponibles();
                   cargarPerfiles();
               }else{
                   log("Error al asignar el perfil","error");
               }
           }
        });
    });

</script>


