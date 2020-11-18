<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 26/06/20
  Time: 11:34
--%>

<table class="table table-hover table-bordered table-condensed">
    <g:if test="${perfiles.size() > 0}">
        <g:each in="${perfiles.perfil}" var="perfil">
            <tr class="perfiles" data-id="${perfil.id}">
                <td>
                    ${perfil?.nombre}
                </td>
                <td width="35">
                    <a href="#" class="btn btn-danger btn-xs btn-deletePerfil" data-id="${perfil.id}">
                        <i class="fa fa-trash"></i>
                    </a>
                </td>
            </tr>
        </g:each>
    </g:if>
    <g:else>
       <div class="alert alert-info col-md-6">
           Ningún perfil asignado
       </div>
    </g:else>
</table>

<script type="text/javascript">

    $(".btn-deletePerfil").click(function() {
        var id = $(this).data("id");
        bootbox.confirm({
            title: "Borrar perfil",
            message: "Está seguro de borrar este perfil? Esta acción no puede deshacerse.",
            buttons: {
                cancel: {
                    label: '<i class="fa fa-times"></i> Cancelar',
                    className: 'btn-primary'
                },
                confirm: {
                    label: '<i class="fa fa-trash"></i> Borrar',
                    className: 'btn-danger'
                }
            },
            callback: function (result) {
                if(result){
                    $.ajax({
                        type: 'POST',
                        url: '${createLink(controller: 'persona', action: 'borrarPerfil_ajax')}',
                        data:{
                            perfil: id,
                            id: '${persona?.id}'
                        },
                        success: function (msg) {
                            var parts = msg.split("_");
                            if(parts[0] == 'ok'){
                                log("Perfil borrado correctamente","success");
                                cargarPerfilesDisponibles();
                                cargarPerfiles();
                            }else{
                                if(parts[0] == 'er'){
                                    bootbox.alert('<i class="fa fa-exclamation-triangle text-danger fa-3x"></i> ' + '<strong style="font-size: 14px">' + parts[1] + '</strong>');
                                    return false;
                                }else{
                                    log("Error al borrar el perfil","error");
                                }
                            }
                        }
                    })
                }
            }
        });





    })

</script>