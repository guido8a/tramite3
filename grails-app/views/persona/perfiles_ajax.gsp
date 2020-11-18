<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 26/06/20
  Time: 10:27
--%>

<div class="form-group keeptogether ${hasErrors(bean: personaInstance, field: 'perfil', 'error')} ">
    <div class="col-md-12">
        <span class="grupo">
            <label  class="col-md-2 control-label" style="margin-top: 20px">
                Perfiles
            </label>

            <div class="col-md-9">
                <div class="row">
                    <div class="col-md-10" id="divDisponibles">

                    </div>
                </div>
            </div>
        </span>
        <div class="col-md-12" style="margin-top: 20px">
            <span class="grupo">
                <label  class="col-md-3 control-label" style="margin-top: 10px">
                    Perfiles Actuales
                </label>

                <div class="col-md-9" id="tblPerfiles">

                </div>
            </span>
        </div>
    </div>
</div>

<script type="text/javascript">

    cargarPerfilesDisponibles();
    cargarPerfiles();

    function cargarPerfilesDisponibles(){
        $.ajax({
            type: 'POST',
            url: '${createLink(controller: 'persona', action: 'perfilesDisponibles_ajax')}',
            data:{
                id: '${personaInstance?.id}'
            },
            success: function (msg) {
                $("#divDisponibles").html(msg)
            }
        });
    }

    function cargarPerfiles(){
        $.ajax({
            type: 'POST',
            url: '${createLink(controller: 'persona', action: 'tablaPerfiles_ajax')}',
            data:{
                id: '${personaInstance?.id}'
            },
            success: function (msg) {
                $("#tblPerfiles").html(msg)
            }
        });
    }
</script>